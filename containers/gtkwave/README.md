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
