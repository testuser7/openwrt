# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato and Donald Hoskins

include $(TOPDIR)/rules.mk

PKG_NAME:=rust
PKG_VERSION:=1.96.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT
PKG_CPE_ID:=cpe:/a:rust-lang:rust

PKG_HOST_ONLY:=1
PKG_BUILD_FLAGS:=no-mips16

include ./rust-values.mk

ifeq ($(CONFIG_RUST_USE_PREBUILT_BINARIES),y)
  ifeq ($(strip $(RUST_BIN_SUM)),)
    $(warning rust: No prebuilt host binary hash defined for RUSTC_HOST_ARCH='$(RUSTC_HOST_ARCH)', falling back to building from source)
  endif
else
  RUST_BIN_SUM:=
endif

ifeq ($(CONFIG_RUST_USE_PREBUILT_STD),y)
  ifeq ($(strip $(RUST_STD_SUM)),)
    $(warning rust: No prebuilt target std hash defined for RUSTC_TARGET_ARCH='$(RUSTC_TARGET_ARCH)', falling back to building from source)
  endif
else
  RUST_STD_SUM:=
endif

# Source build configuration (must be set before host-build.mk)
ifneq ($(RUST_BIN_SUM),)
  PKG_SOURCE:=rust-$(PKG_VERSION)-$(RUSTC_HOST_ARCH).tar.xz
  PKG_SOURCE_URL:=https://static.rust-lang.org/dist/
  PKG_HASH:=$(RUST_BIN_SUM)
  PKG_BUILD_DIR:=$(BUILD_DIR_HOST)/rust-$(PKG_VERSION)-$(RUSTC_HOST_ARCH)
  HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/rust-$(PKG_VERSION)-$(RUSTC_HOST_ARCH)
  HOST_BUILD_DEPENDS:=
else
  PKG_SOURCE:=rustc-$(PKG_VERSION)-src.tar.xz
  PKG_SOURCE_URL:=https://static.rust-lang.org/dist/
  PKG_HASH:=$(RUST_SRC_HASH)
  PKG_BUILD_DIR:=$(BUILD_DIR_HOST)/rustc-$(PKG_VERSION)-src
  HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/rustc-$(PKG_VERSION)-src
  HOST_BUILD_DEPENDS:=python3/host
endif

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

ifneq ($(RUST_BIN_SUM),)
  HOST_UNPACK:=$(HOST_TAR) -C "$(HOST_BUILD_DIR)" --strip-components=1 -xf "$(DL_DIR)/$(PKG_SOURCE)"
endif

define Package/rust
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust
  TITLE:=Rust Programming Language Compiler
  URL:=https://www.rust-lang.org/
  DEPENDS:=$(RUST_ARCH_DEPENDS)
endef

define Package/rust/description
  Rust is a multi-paradigm, general-purpose programming language designed for performance
  and safety, especially safe concurrency. Rust is syntactically similar to C++, but can
  guarantee memory safety by using a borrow checker to validate references.
endef

define Package/rust/config
  source "$(SOURCE)/Config.in"
endef

# Rust-lang has an uninstall script
RUST_UNINSTALL:=$(STAGING_DIR)/host/lib/rustlib/uninstall.sh

# Install directory flags shared by both build paths
RUST_HOST_INSTALL_ARGS = \
	--prefix=$(STAGING_DIR)/host \
	--bindir=$(STAGING_DIR)/host/bin \
	--libdir=$(STAGING_DIR)/host/lib \
	--sysconfdir=$(STAGING_DIR)/host/etc \
	--datadir=$(STAGING_DIR)/host/share \
	--mandir=$(STAGING_DIR)/host/man

# Target Flags
TARGET_CONFIGURE_ARGS = \
	--set=target.$(RUSTC_TARGET_ARCH).ar=$(TARGET_AR) \
	--set=target.$(RUSTC_TARGET_ARCH).cc=$(TARGET_CC_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).cxx=$(TARGET_CXX_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).linker=$(TARGET_CC_NOCACHE) \
	--set=target.$(RUSTC_TARGET_ARCH).ranlib=$(TARGET_RANLIB) \
	--set=target.$(RUSTC_TARGET_ARCH).crt-static=false \
	$(if $(CONFIG_USE_MUSL),--set=target.$(RUSTC_TARGET_ARCH).musl-root=$(TOOLCHAIN_ROOT_DIR))

define Host/Prepare
	$(call Host/Prepare/Default)
	$(if $(RUST_STD_SUM),
		$(if $(RUST_BIN_SUM),
			$(Q) MKHASH="$(MKHASH)" $(SCRIPT_DIR)/download.pl "$(DL_DIR)" \
				"rust-std-$(PKG_VERSION)-$(RUSTC_TARGET_ARCH).tar.xz" "$(RUST_STD_SUM)" "" \
				"https://static.rust-lang.org/dist/"
		)
	,
		$(if $(RUST_BIN_SUM),
			$(Q) MKHASH="$(MKHASH)" $(SCRIPT_DIR)/download.pl "$(DL_DIR)" \
				"rustc-$(PKG_VERSION)-src.tar.xz" "$(RUST_SRC_HASH)" "" \
				"https://static.rust-lang.org/dist/"
		)
	)
endef

define Host/Uninstall
	[ -f $(RUST_UNINSTALL) ] && \
		$(BASH) $(RUST_UNINSTALL) || echo No Uninstall
endef

ifneq ($(RUST_BIN_SUM),)

define Host/Patch
	@:
endef

define Host/Configure
	@:
endef

define Host/Compile
	@:
endef

define Host/Install
	$(BASH) $(HOST_BUILD_DIR)/install.sh \
		--prefix=$(STAGING_DIR)/host \
		--disable-ldconfig \
		--components=rustc,cargo,rust-std-$(RUSTC_HOST_ARCH),llvm-tools-preview
	$(if $(RUST_STD_SUM),$(call Rust/Install/Std/Prebuilt),$(call Rust/Install/Std/Source))
endef

define Rust/Install/Std/Prebuilt
	$(INSTALL_DIR) $(HOST_BUILD_DIR)/std-$(RUSTC_TARGET_ARCH)
	$(HOST_TAR) -xf "$(DL_DIR)/rust-std-$(PKG_VERSION)-$(RUSTC_TARGET_ARCH).tar.xz" -C "$(HOST_BUILD_DIR)/std-$(RUSTC_TARGET_ARCH)" --strip-components=1
	$(BASH) "$(HOST_BUILD_DIR)/std-$(RUSTC_TARGET_ARCH)/install.sh" \
		--prefix=$(STAGING_DIR)/host \
		--disable-ldconfig \
		--components=rust-std-$(RUSTC_TARGET_ARCH)
	rm -rf $(HOST_BUILD_DIR)/std-$(RUSTC_TARGET_ARCH)
endef

define Rust/Install/Std/Source
	$(INSTALL_DIR) $(HOST_BUILD_DIR)/src
	$(HOST_TAR) -xf "$(DL_DIR)/rustc-$(PKG_VERSION)-src.tar.xz" -C "$(HOST_BUILD_DIR)/src" --strip-components=1
	cd $(HOST_BUILD_DIR)/src && $(BASH) ./configure \
		$(RUST_HOST_INSTALL_ARGS) \
		--set=build.rustc="$(STAGING_DIR)/host/bin/rustc" \
		--set=build.cargo="$(STAGING_DIR)/host/bin/cargo" \
		$(TARGET_CONFIGURE_ARGS)
	$(INSTALL_DIR) $(STAGING_DIR)/host/bin \
		$(STAGING_DIR)/host/lib \
		$(STAGING_DIR)/host/lib/rustlib/$(RUSTC_TARGET_ARCH)/lib \
		$(STAGING_DIR)/host/share \
		$(STAGING_DIR)/host/etc \
		$(STAGING_DIR)/host/include \
		$(STAGING_DIR)/host/man
	PATH="$(STAGING_DIR)/host/bin:$(PATH)" $(PYTHON) $(HOST_BUILD_DIR)/src/x.py \
		--build-dir $(HOST_BUILD_DIR)/src/build \
		install library/std --target $(RUSTC_TARGET_ARCH)
endef

else

# CARGO_HOME is an environmental
HOST_CONFIGURE_VARS += CARGO_HOME="$(CARGO_HOME)"

# Rust Configuration Arguments
HOST_CONFIGURE_ARGS = \
	--build=$(RUSTC_HOST_ARCH) \
	--target=$(RUSTC_TARGET_ARCH),$(RUSTC_HOST_ARCH) \
	--host=$(RUSTC_HOST_ARCH) \
	$(RUST_HOST_INSTALL_ARGS) \
	--dist-compression-formats=gz \
	--disable-sanitizers \
	--release-channel=stable \
	--enable-cargo-native-static \
	--bootstrap-cache-path=$(DL_DIR)/rustc \
	--set=llvm.download-ci-llvm=false \
	$(TARGET_CONFIGURE_ARGS)

define Host/Compile
	$(RUST_SCCACHE_VARS) \
	CARGO_HOME=$(CARGO_HOME) \
	TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	$(PYTHON) $(HOST_BUILD_DIR)/x.py \
		--build-dir $(HOST_BUILD_DIR)/build \
		dist build-manifest rustc rust-std cargo llvm-tools rust-src
endef

define Host/Install
	( \
		cd $(HOST_BUILD_DIR)/build/dist ; \
		for targz in *.tar.gz; do \
			$(STAGING_DIR_HOST)/bin/libdeflate-gzip -dc "$$$$targz" | tar -xf - ; \
		done ; \
		find . -mindepth 2 -maxdepth 2 -type f -name install.sh \
			-execdir bash '{}' --prefix=$(STAGING_DIR)/host --disable-ldconfig \; ; \
	)
endef

endif

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rust))
