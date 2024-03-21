# Routine Tasks
report:
	docker run --rm \
       --volume "$(pwd):/data" \
       --user $(id -u):$(id -g) \
       pandoc/extra review/report.md -o review/report.pdf --template eisvogel --listings

# Local Dev Initialization

ln:
	# mkdir contracts/test/invariant
	ln -sf ../../../review/test/invariant/Handler.t.sol contracts/test/invariant/Handler.t.sol
	ln -sf ../../../review/test/invariant/Invariant.t.sol contracts/test/invariant/Invariant.t.sol
	ln -sf ../../../review/foundry.toml contracts/foundry.toml

fixperm:
	sudo chmod -R a+rwX .
	sudo chmod -R g+rwX .
	sudo find . -type d -exec chmod g+s '{}' +

# Project Initialization

git_url := https://github.com/Cyfrin/5-t-swap-audit.git

init:
	git init \
	if [ ! -d "contracts" ]; then \
		git submodule add $(git_url) contracts; \
	fi
	git submodule update --init
