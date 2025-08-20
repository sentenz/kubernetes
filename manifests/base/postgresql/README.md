# PostgreSQL

- [1. Usage](#1-usage)
  - [1.1. Naming Convention](#11-naming-convention)

## 1. Usage

### 1.1. Naming Convention

PostgreSQL service endpoints are referenced using the fully qualified Kubernetes service DNS format.

- DNS Format

  ```plaintext
  postgresql.<namespace>.svc.cluster.local
  ```

- JDBC Connection String
  > In-cluster applications JDBC connection string format to connect to PostgreSQL.

  ```plaintext
  jdbc:postgresql://postgresql.<namespace>.svc.cluster.local:5432/<database>?sslmode=disable
  ```

> [!NOTE]
> Replace `<namespace>` and `<database>` with the actual PostgreSQL namespace and database name. This convention ensures reliable service discovery and avoids ambiguity across different environments.
