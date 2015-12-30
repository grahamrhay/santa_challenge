PROJECT = santa_challenge
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.0.1

# Whitespace to be used when creating files from templates.
SP = 4

DEPS = lager
DEP_LAGER = git https://github.com/basho/lager 3.0.2

include erlang.mk

ERLC_OPTS += +'{parse_transform, lager_transform}'
