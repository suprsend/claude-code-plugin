.PHONY: build clean setup verify help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

build: ## Fetch skills from suprsend/skills repo
	@./scripts/build-skills.sh

clean: ## Remove built skills
	@rm -rf skills/

setup: ## Full setup (prerequisites + build + verify)
	@./scripts/setup.sh

verify: ## Verify plugin installation
	@./scripts/verify.sh
