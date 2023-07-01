.PHONY: all run_dev_linux run_unit clean upgrade lint format build_dev_linux build_linux help 

all: lint format run_dev_linux

help: ## This help dialog.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

run_unit: ## Runs unit tests
	@echo "╠ Running the tests"
	@flutter test || (echo "Error while running tests"; exit 1)

clean: ## Cleans the environment
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@flutter clean

format: ## Formats the code
	@echo "╠ Formatting the code"
	@dart format .

lint: ## Lints the code
	@echo "╠ Verifying code..."
	@dart analyze . || (echo "Error in project"; exit 1)

upgrade: clean ## Upgrades dependencies
	@echo "╠ Upgrading dependencies..."
	@flutter pub upgrade

commit: format lint run_unit ## Commits all files
	@echo "╠ Committing..."
	git add .
	git commit

run_dev_linux: ## Runs the linux application in dev
	@echo "╠ Running the app"
	@flutter run -d linux

build_dev_linux: clean run_unit ## Builds linux application in dev
	@echo "╠  Building the app"
	@flutter build linux
	
build_linux: clean ## Builds AppImage, deb, rpm and zip archives
	@echo "╠  Building the app"
	@flutter_distributor package --platform linux --targets=deb,rpm,zip,appimage
	@cd dist/`flutter pub deps --json | jq -r '.packages[0].version'` && sha256sum -b * > SHA256SUMS && gpg --clearsign SHA256SUMS
