selfdoc:
	@echo "make local"
	@echo "make dev"
	@echo "make prod"

local:
	@echo ""
	@echo "======================================================================================================="
	@echo " rewrite"
	@echo "======================================================================================================="
	python3 0_clean.py
	python3 1_init.py
	python3 2_get_sample.py
	python3 3_try_package.py
	python3 4_apply_package.py
	python3 0_clean.py

dev:
	@echo ""
	@echo "======================================================================================================="
	@echo " rewrite"
	@echo "======================================================================================================="
	python3 0_clean.py dev
	python3 1_init.py dev
	python3 2_get_sample.py dev
	python3 3_try_package.py dev
	python3 4_apply_package.py dev
	python3 0_clean.py dev

prod:
	@echo ""
	@echo "======================================================================================================="
	@echo " rewrite"
	@echo "======================================================================================================="
	python3 0_clean.py prod
	python3 1_init.py prod
	python3 2_get_sample.py prod
	python3 3_try_package.py prod
	python3 4_apply_package.py prod
	python3 0_clean.py prod
