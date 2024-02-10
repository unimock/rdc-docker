# remote docker controller
    * docker client
    * docker-compose
    * ssh client/server
    * rsync
    * rsnapshot

# configure (ovw)
    ./service/ovw/root/.ssh/authorized_keys    
    ./service/ovw/root/.ssh/id_rsa
    ./service/ovw/etc/rsnapshot.conf

# volumes
    /Docker:/Docker
    
    
# build

```
docker buildx build --push --platform  linux/arm/v7,linux/arm64/v8,linux/amd64 --tag unimock/rdc-docker:1.0.0 ./build
```
