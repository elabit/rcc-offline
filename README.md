# rcc Offline Demo Setup 

Scenario for the problem: The execution of Robot Framework tests with Robotmk requires the test client to be connected to the Internet if the underlying Python/nodejs environment is to be built with RCC. 
This is often not permitted for security reasons and the test clients are completely cut off from the Internet. 

This repository serves to demonstrate two ways to circumvent this problem: 

- rccremote
- hololib.zip
- combination of both 


**Proof of concept**: All strategies presented here are for demonstration purposes only. 

## Mode 1: rccremote 

With `rccremote`, a host (server) can provide the holotrees (environments) available on it to other hosts (clients).  
This example shows how an environment is built on the server and then made available via `rccremote`. 
The same environment can be obtained on the client with a considerable time advantage via rccremote instead of building it from scratch. 


### Preparation

`docker compose up --build -d `

Open two terminals for both rccremote and rcc. 

- RCC1 ("Server"): `docker exec -it rcc-offline-rcc1-1 bash`
- RCC2 ("Client"): `docker exec -it rcc-offline-rcc2-1 bash`

### RCC1 (="server")

```
cd data
bash rccremote_server.sh
```

This 

- enables the "shared holotree" feature (required for rccremote to work properly)
- builds a RCC environment (and downloads the installation sources fwith Playwright and starts then `rccremote`, listening on port 4653.

([This](https://github.com/robocorp/prebuilt-env-docker/blob/master/importer/nginx.conf) is a demo setup which uses nginx to serve rccremote via HTTPS)

### RCC2 ("client")

#### Creating the environment

```
cd data
bash rccremote_client.sh
```

This 

- sets the environment variable `RCC_REMOTE_ORIGIN` to the address `http://rcc1:4653`
- build the playwright env similar to the other container; but this time, it fetches all sources from the rccremote server.

#### Using the environment

Both commands on rcc1 and rcc2 should have printed the list of environments; their "Blueprint" should be the same. 
Now its time to prove that the environment can be used on the client: 

```
bash run_robot.sh
```

This starts the Playwright based RF suite in the newly created RCC environment, obtained from rcc1.  

---

## Mode 2: hololib.zip 

This approach represents an even more secure alternative to rccremote.
Another way to set up RCC environments quickly and efficiently is to import a  file. 
First, the environment is built on a reference machine and then exported into a `hololib.zip` file. 
The ZIP file must be transferred to the clients (copying/syncing) and can be imported there. 
In this way, it is possible to transfer RCC environments to hosts that are located in completely isolated network areas. 

### Preparation

`docker compose up --build -d `

Again, open two terminals for both rccremote and rcc. 

- RCC1 ("Server"): `docker exec -it rcc-offline-rcc1-1 bash`
- RCC2 ("Client"): `docker exec -it rcc-offline-rcc2-1 bash`


### RCC1 (="export")



```
cd data
bash hololib_export.sh
```

This 
- builds the environment
- exports the environment into a file `env.zip`

### RCC2 (=client)


#### Importing the catalog

```
cd data
bash hololib_import.sh
```

This imports the RCC catalog from the ZIP file. 
From the catalog, the client can now create holotrees from (next step)

#### Using the environment

```
bash run_robot.sh
```

This starts the Playwright based RF suite. RCC will first create a new hololib from the catalog (just takes some seconds), and then starts the test. 

---

## Mode 3: Combination of rccremote + hololib.zip

The two approaches presented above each have a disadvantage: 

- **rccremote**: Clients in isolated network areas may not be allowed to connect to hosts that can access the Internet. 
- **hololib.zip**: no centralized solution, high manual effort

To solve both disadvantages, the third mode is a combination of both: 

- The rccremote server is located **in the same network** as the clients; it also does not need a internet connection.
- The environments are built on a dedicated (development) machine which has internet access. (That's where the environments can also be checked/scanned against security). Finally, they are exported into ZIP files. 
- The ZIP files are copied/synced and imported on the rccremote server. 
- rccremote can serve the environments for the clients. 

Advantages: 
- Central provision of RCC catalogs
- Clean separation of network areas
- Can be automated