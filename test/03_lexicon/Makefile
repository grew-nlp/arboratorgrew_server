selfdoc:
	@echo "make local"
	@echo "make dev"
	@echo "make prod"

local:
	@echo ""
	@echo "======================================================================================================="
	@echo " lexicon"
	@echo "======================================================================================================="
	python3 0_clean.py
	python3 1_init.py
	python3 2_get_lexicon.py
	python3 0_clean.py

dev:
	@echo ""
	@echo "======================================================================================================="
	@echo " lexicon"
	@echo "======================================================================================================="
	python3 0_clean.py dev
	python3 1_init.py dev
	python3 2_get_lexicon.py dev
	python3 0_clean.py dev

prod:
	@echo ""
	@echo "======================================================================================================="
	@echo " lexicon"
	@echo "======================================================================================================="
	python3 0_clean.py prod
	python3 1_init.py prod
	python3 2_get_lexicon.py prod
	python3 0_clean.py prod
