include $(TOPDIR)/rules.mk

PKG_NAME:=qca-ppe
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/openwrt/qca-ppe.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2026-03-23
PKG_SOURCE_VERSION:=f533ab03237518824bcdc480ad2652497967c2ac
PKG_MIRROR_HASH:=a318b97cc2e3c2efa74add01839d99ec550636aa1ff7dfaa8d02b0469ebe5c2e

PKG_BUILD_PARALLEL:=1
PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/qca-ppe
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  DEPENDS:=@TARGET_qualcommax +kmod-qca-uniphy
  TITLE:=Qualcomm PPE switch driver
  FILES:=$(PKG_BUILD_DIR)/qca_ppe.ko
  AUTOLOAD:=$(call AutoLoad,32,qca_ppe)
endef

define KernelPackage/qca-ppe/Description
  Driver for Qualcomm PPE (Packet Processing Engine) switches.
endef

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		-C "$(LINUX_DIR)" \
		M="$(PKG_BUILD_DIR)" \
		modules
endef

$(eval $(call KernelPackage,qca-ppe))
