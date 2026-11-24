# Disclaimer:
This is part of the replication package for the paper "Revisiting Code Authorship in Large FLOSS Projects", authored by Arthur Pilone, Marco Raglianti, Michele Lanza, Fabio Kon and Paulo Roberto Miranda Meirelles. The replication package is available at https://doi.org/10.6084/m9.figshare.31549921


## Analysis + Visualization Server 

This submodule includes the code used for analyzing the data explored in the paper. All setup instructions suppose a unix-based environment.

### Installation

The script assumes you have access to `docker-compose` or an alternative container orchestration framework (such as `podman`). 

### Running

Run the script by running `docker compose up` in the `server` directory.

```
docker compose up
```

The container includes a simple Flask server presenting the treemaps used for exploring the subsystems visually.

For exploring the treemap colorcoded with the kernel subsystems sized by the number of files, use `localhost:5005`. To explore the treemap sized by the number of lines of code (LOC), use `localhost:5005`.
