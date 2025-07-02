.PHONY: destroy destroy_sql destroy_all

# 1단계: Cloud SQL 인스턴스만 먼저 삭제
destroy_sql:
	terraform destroy -target=google_sql_database_instance.main -auto-approve

# 2단계: 전체 인프라 삭제 (SQL 제외한 모든 것)
destroy_all:
	terraform destroy -auto-approve

# 전체 destroy 순서 보장: SQL → 나머지
destroy: destroy_sql destroy_all