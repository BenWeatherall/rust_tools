//! Storage abstraction for dependency inversion.

use crate::{DomainError, User, UserId};

/// Persistence contract implemented by infrastructure adapters.
pub trait Storage: Send + Sync {
    /// Persists a new user record.
    ///
    /// # Errors
    ///
    /// Returns [`DomainError`] when persistence fails or the user already exists.
    fn save_user(&self, user: &User) -> Result<(), DomainError>;

    /// Loads a user by identifier.
    ///
    /// # Errors
    ///
    /// Returns [`DomainError::UserNotFound`] when no matching user exists.
    fn find_user(&self, id: &UserId) -> Result<User, DomainError>;
}
