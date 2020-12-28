Alternative build 'su-exec' from source https://gist.github.com/dmrub/b311d36492f230887ab0743b3af7309b

```dockerfile
RUN  set -ex; \
     \
     curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
     \
     fetch_deps='gcc libc-dev'; \
     apt-get update; \
     apt-get install -y --no-install-recommends $fetch_deps; \
     rm -rf /var/lib/apt/lists/*; \
     gcc -Wall \
         /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
     chown root:root /usr/local/bin/su-exec; \
     chmod 0755 /usr/local/bin/su-exec; \
     rm /usr/local/bin/su-exec.c; \
     \
     apt-get purge -y --auto-remove $fetch_deps
```


# Alpine version

Testata anche una versione basata su alpine linux per contenere il più possibile le dimensioni del tool,
tuttavia sono stati riscontrati dei problemi di risoluzione dei nomi degli host all'interno del container
