### Forked kerberos-sidecar
- This fork is a modification of the original ahmetgurbuz1 version to match a specific use case. 


### What is sidecar container ?
[kerberos-sidecar-container](https://www.openshift.com/blog/kerberos-sidecar-container)

To reach a kerberized service, a kerberos ticket and krb5.conf file is enough. 
Sidecar containers help to other containers to reach kerberized services without calling kinit in each container.


### Creating example secret
``` docker secret create client.keytab [path_to_the_keytab]/client.keytab```


### .Keytab file
- You can crete a keytab file using JRE or JSDK
- You can also create it using microsoft server using [ktpass utility](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ktpass)


### kerberos sidecar container
```
docker-compose build
docker stack deploy -c docker-stack.yml kerberos-auth
```

### using sidecar volume in other containers using docker stack
Other services can use the sidecar-volume. Sidecar volume will always be containing a valid kerberos ticket cache.
Other services can just mount sidecar-volume and use the valid kerberos ticket by setting KRB5CCNAME environment variable.
See for more details: [KRB5CCNAME](https://web.mit.edu/kerberos/krb5-1.12/doc/basic/ccache_def.html)

#### other-docker-stack.yml
```
.
.
services:
  [service_name]:
    volumes:
      - sidecar-volume:/kerberos-sidecar
volumes:
  sidecar-volume:
    external:true
    name: kerberos-sidecar
```

### how to implement it in kubernetes ?
Same strategy can be applied in kubernetes using kubernetes secrets. Kubernetes secrets can be updated during runtime. A pod who is mounting the secret to itself will get the updated secret without restart. But the secret type should be a file. A kubernetes secret can contain multiple files. One for krb5.conf and other one will be krb5cc (the ticket).

A simple kerberos-auth pod in kubernetes can be implemented in a python container. The secret which is containing kerberos ticket cache and krb5.conf should be updated (with a scheduler before ticket expires) during runtime using [kubernetes](https://pypi.org/project/kubernetes/) library.

### Modifications
- Changed parameters to grab user from windows enviroment variables
- Changed from kubernetes stack to container distro