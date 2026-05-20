//! User domain model and validation.

use crate::DomainError;

/// Strongly typed user identifier.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct UserId(String);

impl UserId {
    /// Creates a new user identifier from a non-empty string.
    ///
    /// # Errors
    ///
    /// Returns [`DomainError::ValidationFailed`] when the identifier is empty.
    pub fn new(value: String) -> Result<Self, DomainError> {
        if value.trim().is_empty() {
            return Err(DomainError::ValidationFailed(
                "user id must not be empty".to_string(),
            ));
        }
        Ok(Self(value))
    }

    /// Returns the underlying identifier value.
    #[must_use]
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

/// A registered user in the domain.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct User {
    id: UserId,
    display_name: String,
}

impl User {
    /// Creates a validated user record.
    #[must_use]
    pub fn new(id: UserId, display_name: String) -> Self {
        Self { id, display_name }
    }

    /// Returns the user's identifier.
    #[must_use]
    pub fn id(&self) -> &UserId {
        &self.id
    }

    /// Returns the user's display name.
    #[must_use]
    pub fn display_name(&self) -> &str {
        &self.display_name
    }
}

/// Validates user registration input before persistence.
#[derive(Debug, Default)]
pub struct UserRegistrationValidator;

impl UserRegistrationValidator {
    /// Validates a display name for registration.
    ///
    /// # Errors
    ///
    /// Returns [`DomainError::ValidationFailed`] when the name is empty.
    pub fn validate_display_name(display_name: &str) -> Result<(), DomainError> {
        if display_name.trim().is_empty() {
            return Err(DomainError::ValidationFailed(
                "display name must not be empty".to_string(),
            ));
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::{UserId, UserRegistrationValidator};

    #[test]
    fn rejects_empty_user_id() {
        let result = UserId::new(String::new());
        assert!(result.is_err());
    }

    #[test]
    fn rejects_empty_display_name() {
        let result = UserRegistrationValidator::validate_display_name("   ");
        assert!(result.is_err());
    }
}
