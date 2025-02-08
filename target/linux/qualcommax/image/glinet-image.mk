include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Build/nand-factory
	$(CP) $(TOPDIR)/target/linux/qualcommax/image/files/glinet_gl-b3000-nand-flash-$1.its \
	$(BUILD_DIR)/linux-qualcommax_ipq50xx/tmp/flash.its
	$(CP) $(TOPDIR)/target/linux/qualcommax/image/files/glinet_gl-b3000-nand-flash.scr \
	$(BUILD_DIR)/linux-qualcommax_ipq50xx/tmp/flash.scr
	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) \
	mkimage -f $(BUILD_DIR)/linux-qualcommax_ipq50xx/tmp/flash.its \
	$(BUILD_DIR)/linux-qualcommax_ipq50xx/tmp/openwrt-qualcommax-ipq50xx-glinet_gl-b3000-squashfs-nand-factory.$1
endef

