selfdoc:
	@echo "make local"
	@echo "make dev"
	@echo "make prod"

local:
	@echo ""
	@echo "======================================================================================================="
	@echo " saveGraphs"
	@echo "======================================================================================================="
	python3 0_clean.py
	python3 1_upload_gsd.py
	python3 2_save_graphs.py
	python3 0_clean.py

dev:
	@echo ""
	@echo "======================================================================================================="
	@echo " saveGraphs"
	@echo "======================================================================================================="
	python3 0_clean.py dev
	python3 1_upload_gsd.py dev
	python3 2_save_graphs.py dev
	python3 0_clean.py dev

prod:
	@echo ""
	@echo "======================================================================================================="
	@echo " saveGraphs"
	@echo "======================================================================================================="
	python3 0_clean.py prod
	python3 1_upload_gsd.py prod
	python3 2_save_graphs.py prod
	python3 0_clean.py prod
