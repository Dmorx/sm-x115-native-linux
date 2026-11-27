#include <linux/module.h>
#include <linux/kobject.h>
#include <linux/sysfs.h>
#include "tcpci.h"
#include "tcpm.h"
static struct tcpc_device *port;
static struct kobject *node;
static ssize_t attach_show(struct kobject *k, struct kobj_attribute *a, char *buf)
{
 return scnprintf(buf, PAGE_SIZE, "%u\n", tcpm_inquire_typec_attach_state(port));
}
static struct kobj_attribute attach_attr = __ATTR_RO(attach);
static int __init tablet_usb_state_init(void)
{
 int ret;
 port = tcpc_dev_get_by_name("type_c_port0");
 if (!port) return -ENODEV;
 node = kobject_create_and_add("tablet_usb", kernel_kobj);
 if (!node) { put_device(&port->dev); return -ENOMEM; }
 ret = sysfs_create_file(node, &attach_attr.attr);
 if (ret) { kobject_put(node); put_device(&port->dev); }
 return ret;
}
static void __exit tablet_usb_state_exit(void)
{
 kobject_put(node); put_device(&port->dev);
}
module_init(tablet_usb_state_init);
module_exit(tablet_usb_state_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Read-only tablet Type-C attachment state for USB OTG policy");
