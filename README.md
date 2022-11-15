### Kerberos
Kerberos is a network authentication protocol. It is designed to provide strong authentication for client/server applications by using secret-key cryptography. A free implementation of this protocol is available from the Massachusetts Institute of Technology. Kerberos is available in many commercial products as well. [MIT Kerberos](https://web.mit.edu/kerberos/)

From <https://web.mit.edu/kerberos/#what_is> 


### Forked kerberos-sidecar
This fork is a modification of the original ahmetgurbuz1 version.  It's a docker compose version instead of swarm.


### What is sidecar container ?
[kerberos-sidecar-container](https://www.openshift.com/blog/kerberos-sidecar-container)

To reach a kerberized service, a kerberos ticket and krb5.conf file is enough. 
Sidecar containers help to other containers to reach kerberized services without calling kinit in each container.


### .Keytab file
A [keytab](https://web.mit.edu/kerberos/krb5-latest/doc/basic/keytab_def.html) (short for “key table”) stores long-term keys for one or more principals. Keytabs are normally represented by files in a standard format, although in rare cases they can be represented in other ways. Keytabs are used most often to allow server applications to accept authentications from clients, but can also be used to obtain initial credentials for client applications.

A keytab file can be created using many methods:
- Using JRE or JSDK, using the [ktab utility](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/ktab.html)
- Using microsoft server using the [ktpass utility](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ktpass)
- Inside a unix system, there is a [docker container with all steps](https://github.com/simplesteph/docker-kerberos-get-keytab)

The file name format should be: ${username}.keytab
located inside a secrets path inside the main repo


### keytab generation demo
The docker being run expects you to mount the path where you would output the keytab 

[Git repo with Instructions](https://github.com/simplesteph/docker-kerberos-get-keytab) 

There are more parameters that can be added to command in instructions.

OS: ```Windows```

console: ```powershell```

#### Example: 
```
docker run -it --rm `
-v C:\git\kerberos-sidecar\secrets:/output `
-e PRINCIPAL=$Env:username@$Env:userdnsdomain `
-e KEYTAB_SECURITY=AES256-SHA1 `
simplesteph/docker-kerberos-get-keytab
```

Please replace the ```< >``` blocks by the appropriate values
#### Template:
```
docker run -it --rm `
-v <output path :/output `
-e PRINCIPAL=$Env:username@$Env:userdnsdomain `
-e KEYTAB_SECURITY=AES256-SHA1 `
simplesteph/docker-kerberos-get-keytab
```

```KEYTAB_SECURITY```: Optional security level for your keytab (default is rc4-hmac)


### kerberos sidecar container
```
docker-compose up --build 
```
Check the docker-compose file for environment variables (ex. KEYTAB_SECURITY)


### using sidecar volume in other containers using docker compose
Other services can use the sidecar-volume. Sidecar volume will always be containing a valid kerberos ticket cache.
Other services can just mount sidecar-volume and use the valid kerberos ticket by setting KRB5CCNAME environment variable.
See for more details: [KRB5CCNAME](https://web.mit.edu/kerberos/krb5-1.12/doc/basic/ccache_def.html)


#### other-docker-compose.yml
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

### Modifications
- Changed docker-compose environment variables to grab user from Windows environment variables
- Changed from docker swarm to docker compose, based on [kerberos-sidecar from ahmetgurbuz1](https://github.com/ahmetgurbuz1/kerberos-sidecar)
- Added example in docker compose on how to generate keytab file inside project repo


### Sources
This proyect is based on the code from:
- [kerberos-sidecar by ahmetgurbuz1](https://github.com/ahmetgurbuz1/kerberos-sidecar)
- [docker-kerberos-get-keytab by simplesteph](https://github.com/simplesteph/docker-kerberos-get-keytab) 

