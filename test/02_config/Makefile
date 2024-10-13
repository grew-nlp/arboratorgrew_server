selfdoc:
	@echo "make local"
	@echo "make dev"
	@echo "make prod"

local:
	@echo ""
	@echo "======================================================================================================="
	@echo " config"
	@echo "======================================================================================================="
	python3 0_clean.py
	python3 1_init.py
	python3 2_change_config.py
	python3 0_clean.py

dev:
	@echo ""
	@echo "======================================================================================================="
	@echo " config"
	@echo "======================================================================================================="
	python3 0_clean.py dev
	python3 1_init.py dev
	python3 2_change_config.py dev
	python3 0_clean.py dev

prod:
	@echo ""
	@echo "======================================================================================================="
	@echo " config"
	@echo "======================================================================================================="
	python3 0_clean.py prod
	python3 1_init.py prod
	python3 2_change_config.py prod
	python3 0_clean.py prod
