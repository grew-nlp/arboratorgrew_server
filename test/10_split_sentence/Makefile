selfdoc:
	@echo "make local"
	@echo "make dev"
	@echo "make prod"

local:
	python3 0_clean.py
	python3 1_init.py
	python3 2_insert.py
	python3 0_clean.py

dev:
	python3 0_clean.py dev
	python3 1_init.py dev
	python3 2_insert.py dev
	python3 0_clean.py dev

prod:
	python3 0_clean.py prod
	python3 1_init.py prod
	python3 2_insert.py prod
	python3 0_clean.py prod
