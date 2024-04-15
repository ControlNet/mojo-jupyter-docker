# mojo-jupyter-docker
Mojo language environment with Jupyterlab

## Get Started
```bash
docker run \
    -e JUPYTER_TOKEN=<PASSWORD> \ 
    [-v <WORKSPACE>:/workspace] \
    -p <JUPYTER_PORT>:8888 \
    -d controlnet/mojo-jupyter
```
