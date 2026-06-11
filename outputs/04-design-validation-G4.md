# Database Design Validation

## Coverage Check — Requirement to Schema

| Requirement | Entity/Table | Covered | Notes |
|-------------|-------------|---------|-------|
| User account info | User | ✅ | All fields mapped |
| Role-based access | User.Role | ✅ | CHECK constraint on roles |
| Manage bookable spaces | Space | ✅ | All fields, including status and policy |
| Facilities per space | SpaceFacility | ✅ | M:N resolved with quantity |
| Submit booking requests | BookingRequest | ✅ | All required fields |
| Prevent overlapping bookings | BookingRequest | ⚠️ | Application/trigger-level enforcement needed |
| Block unavailable spaces | Space.CurrentStatus + Maintenance | ✅ | Status + active maintenance check |
| Approval workflow | Approval | ✅ | 1:1 with booking, tracks decision |
| Check-in / Check-out | Session | ✅ | Tracks actual times and condition |
| Maintenance management | Maintenance | ✅ | Full lifecycle tracked |
| Historical records | All tables | ✅ | No data is deleted; status drives visibility |
| No-show tracking | BookingRequest.Status | ✅ | Status value 'NoShow' |

## Validation of Business Rules and Constraints

| Business Rule | Validated | Mechanism |
|--------------|-----------|-----------|
| No overlapping bookings | ⚠️ Partial | Need trigger or app logic to enforce |
| Unavailable spaces blocked | ✅ | CHECK on Space.CurrentStatus + app logic |
| Rejection requires reason | ✅ | Application-level check on Approval |
| Maintenance blocks bookings | ✅ | App logic checks active maintenance |
| Booking status lifecycle | ✅ | App-level state machine |
| Check-in records actual time | ✅ | Session.ActualStartTime nullable |

## Unresolved Gaps and Assumptions

1. **Overlap detection** — SQL Server has no native exclusion constraint. Must be implemented via:
   - An `AFTER INSERT, UPDATE` trigger on BookingRequest, or
   - Application-level validation in the business logic layer.
   - Recommended: a stored procedure for booking creation that checks for conflicts atomically.

2. **Maintenance unavailability** — Determining whether a space is "under maintenance" requires checking for any active (non-completed, non-cancelled) maintenance record. This is straightforward in application logic but should be encapsulated in a view or function.

3. **No-show timeout** — The business requirement does not specify a grace period before marking a booking as no-show. This will be handled by application logic.

4. **Archived data** — No archival strategy is defined. Historical data grows indefinitely.

## Discussion of Conflicting Bookings, Maintenance Blocks, and Status Transitions

### Conflicting Bookings
Two bookings for the same space conflict if their `[RequestedStartTime, RequestedEndTime)` intervals overlap and both have a status of `Approved` or `CheckedIn`. The conflict check must exclude bookings with status `Rejected`, `Cancelled`, or `Completed`.

### Maintenance Blocks
A space is unavailable if:
- `Space.CurrentStatus IN ('UnderMaintenance', 'TemporarilyClosed', 'Retired')`, OR
- There exists a `Maintenance` record for that space with `Status IN ('Reported', 'InProgress')`.

### Status Transition Rules
```
Pending ──→ Approved ──→ CheckedIn ──→ Completed
    │            │                        ↑
    ├──→ Rejected                         │
    └──→ Cancelled                  NoShow
```
- Pending → Approved/Rejected/Cancelled
- Approved → CheckedIn (when requester arrives)
- CheckedIn → Completed (session ends normally)
- CheckedIn → NoShow (requester did not arrive)

## Limitations Requiring Application Logic or Advanced SQL Server Features

1. **Overlap detection**: Requires a trigger or scheduled job. SQL Server 2022 offers `PERIOD FOR SYSTEM_TIME` but not exclusion constraints.
2. **Status state machine**: Best enforced at the application layer to avoid complex triggers.
3. **Email/notification integration**: Not part of schema; application layer should trigger notifications on status changes.
4. **Recurring bookings**: Not supported; each booking is an individual request.
5. **Reporting views**: Recommended to create views for booking history, upcoming bookings, spaces under maintenance, and utilization to simplify querying.
