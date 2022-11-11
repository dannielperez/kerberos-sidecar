### Kerberos
Kerberos is a network authentication protocol. It is designed to provide strong authentication for client/server applications by using secret-key cryptography. A free implementation of this protocol is available from the Massachusetts Institute of Technology. Kerberos is available in many commercial products as well. [MIT Kerberos](https://web.mit.edu/kerberos/)

From <https://web.mit.edu/kerberos/#what_is> 


### Forked kerberos-sidecar
- This fork is a modification of the original ahmetgurbuz1 version to match a specific use case. 


### What is sidecar container ?
[kerberos-sidecar-container](https://www.openshift.com/blog/kerberos-sidecar-container)

To reach a kerberized service, a kerberos ticket and krb5.conf file is enough. 
Sidecar containers help to other containers to reach kerberized services without calling kinit in each container.


### .Keytab file
A keytab file can be created using many methods:
- Using JRE or JSDK, using the [ktab utility](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/ktab.html)
- Using microsoft server using the [ktpass utility](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ktpass)
- Inside a unix system, there is a [docker container with all steps](https://github.com/simplesteph/docker-kerberos-get-keytab)

The file name format should be: ${username}.keytab
located inside a secrets path inside the main repo


### keytab generation demo
This demo is being run using powershell

The docker being run expects you to mount the path where you would output the keytab 

[Git repo with Instructions](https://github.com/simplesteph/docker-kerberos-get-keytab) 

]#### Example: 
'''
docker run -it --rm -v C:\git\kerberos-sidecar\secrets:/output -e PRINCIPAL=$Env:username@$Env:userdnsdomain simplesteph/docker-kerberos-get-keytab
'''

#### Template:
'''
docker run -it --rm -v < output path >:/output -e PRINCIPAL=$Env:username@$Env:userdnsdomain simplesteph/docker-kerberos-get-keytab
'''
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

