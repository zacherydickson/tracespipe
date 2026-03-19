THIS_FILE := $(lastword $(MAKEFILE_LIST))
DEPEND_YAML = system_files/dependencies.yml
SCRIPT_STEMS = install update get_program_versions

GENERATOR_SCRIPT_DIR = src/TRACES_generator_scripts
GENERATOR_SCRIPTS = $(addprefix $(GENERATOR_SCRIPT_DIR)/gen_, $(addsuffix .sh, $(SCRIPT_STEMS)))
GENLIB = $(GENERATOR_SCRIPT_DIR)/generate_common.sh

GENERATED_SCRIPT_DIR = src
GENERATED_SCRIPTS = $(addprefix $(GENERATED_SCRIPT_DIR)/TRACES_, $(addsuffix .sh, $(SCRIPT_STEMS)))

TIMESTAMP_DIR = .build
TIMESTAMPS = $(addprefix $(TIMESTAMP_DIR)/, $(addsuffix .timestamp, $(SCRIPT_STEMS) readme))

PIPELINE_SCRIPT = src/TRACESPipe.sh
VERSION_FILE = Version.txt

all: $(TIMESTAMPS)

$(TIMESTAMP_DIR)/%.timestamp: $(GENERATED_SCRIPT_DIR)/TRACES_%.sh $(DEPEND_YAML) $(GENERATOR_SCRIPT_DIR)/gen_%.sh $(GENLIB)
	@mkdir -p $(TIMESTAMP_DIR)
	@echo Generating $<
	@$(GENERATOR_SCRIPT_DIR)/gen_$*.sh
	@touch $@

$(TIMESTAMP_DIR)/readme.timestamp: README.md $(DEPEND_YAML) $(GENERATOR_SCRIPT_DIR)/gen_readme.sh $(GENLIB) $(PIPELINE_SCRIPT) $(Version.txt)
	@mkdir -p $(TIMESTAMP_DIR)
	@echo Generating $<
	@$(GENERATOR_SCRIPT_DIR)/gen_readme.sh
	@touch $@
