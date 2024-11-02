# Docker build system for GPGPU

1. Create ssh keys (id_rsa and id_rsa.pub) for your github account.

2. Put ssh key files in repo directory

3. Build docker image:

```
docker build .
```

4. Run docker image interactively:

```
docker run -Pit imageid
```

5. Run the following to list the containers
```
docker ps
```

6. Run the following to find the port to ssh into
```
docker port containerdid
```

7. SSH in
```
ssh -p port root@127.0.0.1
```

5. Inside of docker:

```
cd ~
./buildscript
```

6. Type your ssh password when requested

7. Wait