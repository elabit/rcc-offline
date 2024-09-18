# rccremote Demo Setup 

## Preparation

`docker compose up --build -d `

Open two terminals for both rccremote and rcc. 

## rccremote (="server")

```
docker exec -it rccremote-test-rccremote-1 bash
cd data
bash run_rccremote.sh
```

This 

- enables the "shared holotree" feature (required for rccremote to work properly)
- builds a RCC environment with Playwright and starts then `rccremote`, listening on port 4653.

## rcc ("client")

### Creating the environment

```
docker exec -it rccremote-test-rcc-1 bash
cd data
bash run_rcc.sh
```

This 

- sets the environment variable `RCC_REMOTE_ORIGIN` to the address `http://rccremote:4653`
- build the playwright env similar to the other container; but this time, it fetches all sources from the rccremote server.

### Using the environment

```
bash run_robot.sh
```

This starts the Playwright based RF suite in the newly created RCC environment. 
