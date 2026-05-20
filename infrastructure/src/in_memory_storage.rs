//! In-memory storage adapter for development and testing.

use core_domain::{DomainError, Storage, User, UserId};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

/// Thread-safe in-memory implementation of [`Storage`].
#[derive(Debug, Default, Clone)]
pub struct InMemoryStorage {
    users: Arc<Mutex<HashMap<String, User>>>,
}

impl InMemoryStorage {
    /// Creates an empty in-memory store.
    #[must_use]
    pub fn new() -> Self {
        Self::default()
    }
}

impl Storage for InMemoryStorage {
    fn save_user(&self, user: &User) -> Result<(), DomainError> {
        let mut users = self
            .users
            .lock()
            .map_err(|_| DomainError::ValidationFailed("storage lock poisoned".to_string()))?;

        let key = user.id().as_str().to_string();
        if users.contains_key(&key) {
            return Err(DomainError::UserAlreadyExists(key));
        }

        users.insert(key, user.clone());
        Ok(())
    }

    fn find_user(&self, id: &UserId) -> Result<User, DomainError> {
        let users = self
            .users
            .lock()
            .map_err(|_| DomainError::ValidationFailed("storage lock poisoned".to_string()))?;

        users
            .get(id.as_str())
            .cloned()
            .ok_or_else(|| DomainError::UserNotFound(id.as_str().to_string()))
    }
}

#[cfg(test)]
mod tests {
    use super::InMemoryStorage;
    use core_domain::{Storage, User, UserId};

    #[test]
    fn saves_and_loads_user() -> Result<(), core_domain::DomainError> {
        let storage = InMemoryStorage::new();
        let id = UserId::new("user-1".to_string())?;
        let user = User::new(id.clone(), "Alice".to_string());

        storage.save_user(&user)?;
        let loaded = storage.find_user(&id)?;
        assert_eq!(loaded.display_name(), "Alice");
        Ok(())
    }
}
