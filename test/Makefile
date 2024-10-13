selfdoc:
	@echo "make local"
	@echo "make dev"
	@echo "make prod"

local:
	@make -C 01_big_request local
	@make -C 02_config local
	@make -C 03_lexicon local
	@make -C 04_multi_user local
	@make -C 05_rewrite local
	@make -C 06_saveGraph local
	@make -C 07_saveGraphs local
	@make -C 08_eraseGraphs local
	@make -C 09_searchRequestInGraphs local
	@make -C 10_split_sentence local

dev:
	@make -C 01_big_request dev
	@make -C 02_config dev
	@make -C 03_lexicon dev
	@make -C 04_multi_user dev
	@make -C 05_rewrite dev
	@make -C 06_saveGraph dev
	@make -C 07_saveGraphs dev
	@make -C 08_eraseGraphs dev
	@make -C 09_searchRequestInGraphs dev
	@make -C 10_split_sentence dev

prod:
	@echo "**** This test may need to add IP in apache config on the prod server ****"
	@make -C 01_big_request prod
	@make -C 02_config prod
	@make -C 03_lexicon prod
	@make -C 04_multi_user prod
	@make -C 05_rewrite prod
	@make -C 06_saveGraph prod
	@make -C 07_saveGraphs prod
	@make -C 08_eraseGraphs prod
	@make -C 09_searchRequestInGraphs prod
	@make -C 10_split_sentence prod
