# Manual Bring Up

``` bash
docker-compose build
docker-compose up
```

# Bring down

``` bash 
docker-compose down
```

## Ubuntu Common Bugs

After running `docker-compose up` if you receive the following error.

```
...
app_1  | Authorization required, but no authorization protocol specified
app_1  | Could not initialize GTK!  Is DISPLAY env var/xhost set?
...
```

The following command allows your local services to access xhost and showed resolve your issues.

``` bash
xhost +local:docker
```

## Windows Common Bugs

Getting the docker container to work on windows is a little more tricky. Windows does not have a built in service that handles x11 forwarding so you must install a 3rd party software. Success has been found using **Xming**. After starting Xming make sure to set the *DISPLAY* environment variable. 

``` bash
$env:DISPLAY="host.docker.internal:0.0"
```