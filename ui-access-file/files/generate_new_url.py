#!/usr/bin/python

import os
import sys
import json

region = sys.argv[1].strip().lower()
existing_str = sys.argv[2].strip()

def resolve_external_url(ext_url):
    if "https://www.mgmt.cloud.vmware.com/ni" in ext_url and region == "us":
        return ext_url
    if region not in ext_url:
        b = ext_url.split("https://")
        new_url = "https://{}.{}".format(region, b[1])
        return new_url
    
def resolve_pod_url(pod_url):
    b = pod_url.split('.')
    pod_id = b[0]
    new_pod_url = "{}.pd.ni-onsaas-internal.com".format(pod_id)
    return new_pod_url

def resolve_tenant_url(tenant_url):
    check = ".{}.".format(region)
    if check not in tenant_url:
        t = tenant_url.split("<tenant>")
        new_t_url = "<tenant>.{}{}".format(region,t[1])
        return new_t_url
    else:
        return tenant_url
    

trimmed_bits = [s.strip() for s in existing_str.split(',')]
new_ext = resolve_external_url(trimmed_bits[0])
new_pod = resolve_pod_url(trimmed_bits[1])
new_tenant = resolve_tenant_url(trimmed_bits[2])

print("{},{},{}".format(new_ext, new_pod, new_tenant))