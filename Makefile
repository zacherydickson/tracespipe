THIS_FILE := $(lastword $(MAKEFILE_LIST))
DEPEND_YAML = system_files/dependencies.yml
SCRIPT_STEMS = install update get_program_versions

GENERATOR_SCRIPT_DIR = src/TRACES_generator_scripts
SCRIPT_GENERATOR_SCRIPT = $(GENERATOR_SCRIPT_DIR)/generate_script.sh
#GENERATOR_SCRIPTS = $(addprefix $(GENERATOR_SCRIPT_DIR)/gen_, $(addsuffix .sh, $(SCRIPT_STEMS)))

GENERATED_SCRIPT_DIR = src
GENERATED_SCRIPTS = $(addprefix $(GENERATED_SCRIPT_DIR)/TRACES_, $(addsuffix .sh, $(SCRIPT_STEMS)))

TIMESTAMP_DIR = .build
TIMESTAMPS = $(addprefix $(TIMESTAMP_DIR)/, $(addsuffix .timestamp, $(SCRIPT_STEMS) readme))

all: $(TIMESTAMPS)

$(TIMESTAMP_DIR)/%.timestamp: $(GENERATED_SCRIPT_DIR)/TRACES_%.sh $(DEPEND_YAML) $(SCRIPT_GENERATOR_SCRIPT) 
	@mkdir -p $(TIMESTAMP_DIR)
	@echo Generating $<
	@$(SCRIPT_GENERATOR_SCRIPT) $*
	@touch $@

$(TIMESTAMP_DIR)/readme.timestamp: README.md $(DEPEND_YAML) $(GENERATOR_SCRIPT_DIR)/gen_readme.sh 
	@mkdir -p $(TIMESTAMP_DIR)
	@echo Generating $<
	@$(GENERATOR_SCRIPT_DIR)/gen_readme.sh
	@touch $@
