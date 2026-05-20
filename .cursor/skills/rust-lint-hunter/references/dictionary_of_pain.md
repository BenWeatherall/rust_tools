# Dictionary of Pain — Common Rust Compiler Errors

## E0502: cannot borrow as mutable because it is also borrowed as immutable

**Cause**: Overlapping mutable and immutable references.

**Fixes**:
- Clone the immutably borrowed data before mutating.
- Restructure to narrow the immutable borrow scope.
- Collect indices first, then mutate in a second pass.

## E0382: borrow of moved value

**Cause**: Value was moved and then used again.

**Fixes**:
- Borrow with `&` instead of moving.
- Clone if ownership is needed in both places.
- Use `Rc`/`Arc` for shared ownership when appropriate.

## E0597: borrowed value does not live long enough

**Cause**: Reference outlives its source.

**Fixes**:
- Return owned data instead of references.
- Store data in a struct field to extend lifetime.
- Restructure so the reference scope matches the data scope.

## E0277: trait bound not satisfied

**Cause**: Missing trait implementation or generic constraint.

**Fixes**:
- Add `#[derive(...)]` for the required trait.
- Add explicit trait bounds to generic functions.
- Implement the trait manually.

## E0308: mismatched types

**Cause**: Expected type differs from found type.

**Fixes**:
- Check newtype wrappers — do not pass `UserId` where `SessionId` is expected.
- Use `.into()` or explicit conversion at boundaries.
