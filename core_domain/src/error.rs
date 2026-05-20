//! Domain-level error types.

use thiserror::Error;

/// Errors produced by core domain operations.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum DomainError {
    /// A user with the given identifier already exists.
    #[error("user already exists: {0}")]
    UserAlreadyExists(String),

    /// A requested user was not found.
    #[error("user not found: {0}")]
    UserNotFound(String),

    /// Input validation failed.
    #[error("validation failed: {0}")]
    ValidationFailed(String),
}
