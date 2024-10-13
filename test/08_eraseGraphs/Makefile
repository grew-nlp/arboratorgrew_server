selfdoc:
	@echo "make local"
	@echo "make dev"
	@echo "make prod"

local:
	@echo ""
	@echo "======================================================================================================="
	@echo " eraseGraphs"
	@echo "======================================================================================================="
	python3 0_clean.py
	python3 1_save_graphs.py
	python3 2_erase.py
	python3 0_clean.py

dev:
	@echo ""
	@echo "======================================================================================================="
	@echo " eraseGraphs"
	@echo "======================================================================================================="
	python3 0_clean.py dev
	python3 1_save_graphs.py dev
	python3 2_erase.py dev
	python3 0_clean.py dev

prod:
	@echo ""
	@echo "======================================================================================================="
	@echo " eraseGraphs"
	@echo "======================================================================================================="
	python3 0_clean.py prod
	python3 1_save_graphs.py prod
	python3 2_erase.py prod
	python3 0_clean.py prod
