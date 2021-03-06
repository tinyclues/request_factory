.PHONY: clean-pyc clean-build docs clean

help:
	@echo "all - check style with flake8, check code coverage and run the tests, generate the Sphinx documentation, and runs the server."
	@echo "ci - Command used by the CI"
	@echo "clean - remove all build, test, coverage and Python artifacts"
	@echo "clean-build - remove build artifacts"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "clean-test - remove test and coverage artifacts"
	@echo "lint - check style with flake8"
	@echo "test - run tests quickly with the default Python"
	@echo "test-all - run tests on every Python version with tox"
	@echo "coverage - check code coverage quickly with the default Python"
	@echo "docs - generate Sphinx HTML documentation, including API docs"
	@echo "dist - package"
	@echo "install - install the package to the active Python's site-packages"

all: lint coverage docs

ci: lint test

clean: clean-build clean-pyc clean-docker clean-test

clean-docker:
	docker-compose kill
	docker-compose rm --all -fv

clean-build:
	rm -rf build/
	rm -rf dist/
	rm -rf *egg*/

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*.~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -rf {} +

clean-test:
	rm -f ./src/.coverage
	rm -fr ./src/htmlcov/
	rm -rf ./src/.cache
	rm -rf ./src/coverage.xml

lint:
	docker-compose run --no-deps request_factory flake8 request_factory

test:
	docker-compose run request_factory PYTHONPATH=$(shell pwd) py.test -s tests/


coverage:
	docker-compose run request_factory py.test -s --cov=request_factory --cov-report html --cov-report xml --cov-config .coveragerc tests/

docs:
	# rm -f docs/request_factory.rst
	# rm -f docs/modules.rst
	# sphinx-apidoc -o docs/ request_factory -e
	# $(MAKE) -C docs clean
	# $(MAKE) -C docs html
	@echo 'to do gen doc'

release: clean build
	docker-compose run --no-deps request_factory python setup.py bdist_wheel upload -r pypi

dist: clean
	python setup.py sdist
	python setup.py bdist_wheel

install: clean
	python setup.py install

shell:
	docker-compose run request_factory bash

build:
	docker-compose build
