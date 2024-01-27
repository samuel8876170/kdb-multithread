# Multi-Reader Allocator
Allocator process let readers connect to server in multi-threaded, read-only mode (i.e. [negative port](https://code.kx.com/q/kb/multithreaded-input/#multithreaded-input-queue-mode)), such that readers can benefit from shorter read-only query time.


## Installation
1. Download this repository
```
git clone https://github.com/samuel8876170/kdb-multithread.git
```
2. Set environement variables
   - Update [source profile](./src/config/profile) / [test profile](./test/config/profile)
      - `QMULTITHREAD` to src directory
      - `QMULTITHREAD_TEST` to test directory (optional, only for testing)
3. Update the server addresses in [serverList.txt](./src/config/serverList.txt) that will be serving readers with negative port and writers with positive port
4. Update the username of writers in [writerList.txt](./src/config/writerList.txt)


## Execution
1. Start the [server](./src/server.q)
```
q -p <port number> -t <timer>
```
2. Start the [allocator](./src/allocator.q)
```
q allocator.q -p <port number> -t <timer> -writerList <path to writer list file>.txt -serverList <path to server list file>.txt
```
3. Start any q process and request a connection to server via allocator
```
q) h: hopen `:<allocator address>:<writer/reader username>
q) serverH: h (`.multhr.register; `:<server address>)
q) serverH "query"
```


## Simple Speed Test
- Comparing read query by 30 readers between using multi-threaded mode and normal mode

### Set up
- 1 writer set a variable `zp` to `.z.P` every 100 ms 
- Read `zp` in server 100000 times and get total time used for each reader
- Aggregate 30 time used for both groups

### Result
| time used (in ms) | Normal    | Multi-threaded | Difference (%) |
| -                 | -         | -              | -              |
| minimum           | 4435      | 3536           | -20.2706       |
| maximum           | 4829      | 3655           | -24.3115       |
| average           | 4640.1    | 3600.6         | -22.4025       |
| median            | 4621.5    | 3609           | -21.9085       |


## Improvements / Assumptions
1. [Allocator](./src/allocator.q) do not have `.z.pw` set up
2. `admin` is always bypass `.z.pw` without password in [Server](./src/server.q)
   - This is for allocator to `hopen` the server
3. `.multhr.addToken` is needed to store a temporary password for read/writer accessing server


## Run Test Yourself
1. [Download qunit.q](https://www.timestored.com/kdb-guides/kdb-regression-unit-tests)
2. Source test profile
```
source test/config/profile
```
3. Run qunit and start testing
```
q qunit.q
q) .qunit.wait: {t:.z.p;while[.z.p<t+x]};
q) \l test/test.q
q) .qunit.runTests `.multhr
```
