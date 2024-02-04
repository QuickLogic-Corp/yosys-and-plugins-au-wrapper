# Makefile 'wrapper' for the OpenFPGA Aurora2 Wrapper

# usage hints:
# make and show onscreen and log everything to build_DATE_TIME.log:
#     make install -j$(nproc) 2>&1 | tee build_$(date "+%d_%B_%Y")_$(date +"%H_%M_%S").log

# https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR_PATH := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))
MAKEFILE_DIR_NAME := $(notdir $(MAKEFILE_DIR_PATH))
# $(info )
# $(info MAKEFILE_LIST=$(MAKEFILE_LIST))
# $(info MAKEFILE_PATH=$(MAKEFILE_PATH))
# $(info MAKEFILE_DIR_PATH=$(MAKEFILE_DIR_PATH))
# $(info MAKEFILE_DIR_NAME=$(MAKEFILE_DIR_NAME))
# $(info )
# https://stackoverflow.com/a/33616144 : get the jobs passed in to make...
MAKE_PID := $(shell echo $$PPID)
JOB_FLAG := $(filter -j%, $(subst -j ,-j,$(shell ps T | grep "^\s*$(MAKE_PID).*$(MAKE)")))
JOBS     := $(subst -j,,$(JOB_FLAG))
# $(info )
# $(info MAKE_PID=$(MAKE_PID))
# $(info JOB_FLAG=$(JOB_FLAG))
# $(info JOBS=$(JOBS))
# $(info )
$(info using parallel jobs: $(JOBS))

# underscores are better for using in filename/dirname
# DATE example: 01_JUL_2024
# TIME example: 21_36_45
# TZ example: +05:30 IST
export DATE_FORMAT := "%d_%^b_%Y"
export TIME_FORMAT := "%H_%M_%S"
export TZ_FORMAT := "%:z %Z"
CURRENT_DATE := $(shell date +$(DATE_FORMAT))
CURRENT_TIME := $(shell date +$(TIME_FORMAT))
CURRENT_TZ := $(shell date +$(TZ_FORMAT))
$(info time: $(CURRENT_DATE) $(CURRENT_TIME) $(CURRENT_TZ))

# Use bash as the default shell
SHELL := /bin/bash

# PREFIX for 'install' path
PREFIX ?= $(MAKEFILE_DIR_PATH)/install

# 'package' path
PACKAGE_DIR := $(MAKEFILE_DIR_PATH)/package

SOURCE_DIR_YOSYS := $(MAKEFILE_DIR_PATH)/yosys
SOURCE_DIR_PLUGINS_CHIPALLIANCE := $(MAKEFILE_DIR_PATH)/yosys-f4pga-plugins-chipalliance
SOURCE_DIR_PLUGINS_QL := $(MAKEFILE_DIR_PATH)/yosys-f4pga-plugins-quicklogic
SOURCE_DIR_YOSYS_TECHLIBS_QL := $(SOURCE_DIR_YOSYS)/techlibs/quicklogic

YOSYS_SYNTH_PASS_NAME_QL ?= synth_ql

# Version
COMMIT_SHA1_YOSYS := $(shell git -C $(SOURCE_DIR_YOSYS) rev-parse --short HEAD)
COMMIT_SHA1_PLUGINS_CHIPALLIANCE := $(shell git -C $(SOURCE_DIR_PLUGINS_CHIPALLIANCE) rev-parse --short HEAD)
COMMIT_SHA1_PLUGINS_QL := $(shell git -C $(SOURCE_DIR_PLUGINS_QL) rev-parse --short HEAD)


# https://askubuntu.com/questions/279168/detect-if-its-ubuntu-linux-os-in-makefile
# http://linuxmafia.com/faq/Admin/release-files.html
BUILD_PLATFORM ?=
SUPPORTED_BUILD_PLATFORMS :=
SUPPORTED_BUILD_PLATFORMS += WIN32_MSYS2_MINGW64
SUPPORTED_BUILD_PLATFORMS += WIN32_MSYS2_UCRT64
# SUPPORTED_BUILD_PLATFORMS += WIN32_MSYS2_CLANG64
# SUPPORTED_BUILD_PLATFORMS += WIN32_MSVC
SUPPORTED_BUILD_PLATFORMS += UBUNTU_2004
SUPPORTED_BUILD_PLATFORMS += UBUNTU_2204

ifeq ($(OS),Windows_NT)
ifneq ($(filter $(MSYSTEM),MINGW64),)
	BUILD_PLATFORM := WIN32_MSYS2_MINGW64
else ifneq ($(filter $(MSYSTEM),UCRT64),)
	BUILD_PLATFORM := WIN32_MSYS2_UCRT64
else ifneq ($(filter $(MSYSTEM),CLANG64),)
	BUILD_PLATFORM := WIN32_MSYS2_CLANG64
else
	BUILD_PLATFORM := WIN32_MSVC
endif
else ifeq ($(OS),)
	OS=$(shell uname -s)
ifeq ($(OS),Linux)
ifneq ("$(wildcard /etc/lsb-release)","")
	DISTRO := $(shell lsb_release -si | tr '[:lower:]' '[:upper:]')
	VERSION := $(subst .,,$(shell lsb_release -sr))
	BUILD_PLATFORM := $(DISTRO)_$(VERSION)
endif
endif
endif # ifeq ($(OS),Windows_NT)

ifneq ($(filter $(BUILD_PLATFORM),$(SUPPORTED_BUILD_PLATFORMS)),)
$(info using build platform: $(BUILD_PLATFORM))
else
$(error unsupported build platform: $(BUILD_PLATFORM))
endif


ifeq ($(BUILD_PLATFORM),$(filter $(BUILD_PLATFORM),WIN32_MSYS2_MINGW64 WIN32_MSYS2_UCRT64 WIN32_MSYS2_CLANG64))
export MSYSTEM_LC := $(shell echo $(MSYSTEM) | tr '[:upper:]' '[:lower:]')
export SEVENZIP_DIR_PATH := $(MAKEFILE_DIR_PATH)/7zip
export SEVENZIP_FILE_PATH := $(SEVENZIP_DIR_PATH)/7z.exe
export SEVENZIP_SFX_FILE_PATH_W=$(shell cygpath -w "$(SEVENZIP_DIR_PATH)/7z.sfx" | sed 's/\\/\\\\/g')
endif


.DEFAULT_GOAL := install


.PHONY: prepare
prepare:
	# @git -C $(SOURCE_DIR_YOSYS) checkout techlibs/quicklogic
	@rm -rf $(SOURCE_DIR_YOSYS)/techlibs/quicklogic


.PHONY: install
install: prepare
	@START_DATE=$$(date +$(DATE_FORMAT)) && echo "START_DATE=$${START_DATE}"; \
	START_TIME=$$(date +$(TIME_FORMAT)) && echo "START_TIME=$${START_TIME}"

ifeq ($(BUILD_PLATFORM),$(filter $(BUILD_PLATFORM),WIN32_MSYS2_MINGW64 WIN32_MSYS2_UCRT64 WIN32_MSYS2_CLANG64))
	$(MAKE) -C $(SOURCE_DIR_YOSYS) install PREFIX=$(PREFIX) CONFIG=msys2-64
else ifeq ($(BUILD_PLATFORM),$(filter $(BUILD_PLATFORM),UBUNTU_2004 UBUNTU_2204))
	$(MAKE) -C $(SOURCE_DIR_YOSYS) install PREFIX=$(PREFIX) CONFIG=gcc
endif
	$(MAKE) -C $(SOURCE_DIR_PLUGINS_QL) install_ql-qlf YOSYS_PATH=$(PREFIX) EXTRA_FLAGS="-DPASS_NAME=$(YOSYS_SYNTH_PASS_NAME_QL)"
	$(MAKE) -C $(SOURCE_DIR_PLUGINS_CHIPALLIANCE) install_sdc YOSYS_PATH=$(PREFIX)

	printf "\n\n >>>bin/ <<<\n"
	ls -hl $(PREFIX)/bin
	printf "\n\n >>>share/yosys/ <<<\n"
	ls -hl $(PREFIX)/share/yosys
	
	@END_DATE=$$(date +$(DATE_FORMAT)) && echo "END_DATE=$${END_DATE}"; \
	END_TIME=$$(date +$(TIME_FORMAT)) && echo "END_TIME=$${END_TIME}"


.PHONY: package
package: setup7zip
ifeq ($(BUILD_PLATFORM),$(filter $(BUILD_PLATFORM),WIN32_MSYS2_MINGW64 WIN32_MSYS2_UCRT64 WIN32_MSYS2_CLANG64))
else ifeq ($(BUILD_PLATFORM),$(filter $(BUILD_PLATFORM),UBUNTU_2004 UBUNTU_2204))
endif


.PHONY: clean
clean:
ifneq ("$(wildcard $(PREFIX)/bin/yosys)","")
	$(MAKE) -C $(SOURCE_DIR_PLUGINS_QL) clean_ql-qlf YOSYS_PATH=$(PREFIX) 2> /dev/null || true
	$(MAKE) -C $(SOURCE_DIR_PLUGINS_CHIPALLIANCE) clean_sdc YOSYS_PATH=$(PREFIX) 2> /dev/null || true
endif
	$(MAKE) -C $(SOURCE_DIR_YOSYS) clean PREFIX=$(PREFIX)
ifneq ("$(wildcard $(PREFIX))","")
	@rm -rf $(PREFIX)
endif
	@git -C $(SOURCE_DIR_YOSYS) checkout techlibs/quicklogic


.PHONY: setup7zip
setup7zip:
ifeq ($(BUILD_PLATFORM),$(filter $(BUILD_PLATFORM),WIN32_MSYS2_MINGW64 WIN32_MSYS2_UCRT64 WIN32_MSYS2_CLANG64))
	printf "\n\n >>>7zip setup <<<\n"
	mkdir -p $(SEVENZIP_DIR_PATH)
	wget --quiet https://www.7-zip.org/a/7zr.exe --directory-prefix=$(SEVENZIP_DIR_PATH)
	wget --quiet https://www.7-zip.org/a/7z2301-x64.exe --directory-prefix=$(SEVENZIP_DIR_PATH)
	cd $(SEVENZIP_DIR_PATH) && \
		$(SEVENZIP_DIR_PATH)/7zr.exe x $(SEVENZIP_DIR_PATH)/7z2301-x64.exe -y > /dev/null
else ifeq ($(BUILD_PLATFORM),$(filter $(BUILD_PLATFORM),UBUNTU_2004 UBUNTU_2204))
endif


.PHONY: _testing
_testing:
	$(info )
	$(info _testing)
	$(info OS: $(OS))
	$(info BUILD_PLATFORM: $(BUILD_PLATFORM))
