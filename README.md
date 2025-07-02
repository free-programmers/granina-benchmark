# granina-benchmark

<img src="./benchmark_results.png"> 


# Django Server Benchmark Playground 🎉🚀

Welcome to the **Django Server Benchmark Playground** — a simple setup and benchmarking project where I put Django’s default development server, Gunicorn, and Granian through their paces.  
Tested on my own curiosity and just for fun!

---

## What’s inside? 🧐

- A bash script that **creates a minimal Django project** with a tiny app and a test view returning "OK".  
- A benchmarking script that runs load tests with [`wrk`](https://github.com/wg/wrk) on the three servers:
  - Django’s default runserver  
  - Gunicorn (the popular WSGI server)  
  - Granian (a fast Rust HTTP server for Python apps)  
- Nice charts generated using `gnuplot` to compare requests per second (RPS).

---

## Why?

Because I was curious how these servers stack up in speed and performance for a simple Django app.  
Also, it’s a fun way to practice some bash scripting, benchmarking, and data visualization.

---

## How to use

1. Clone this repo:

```bash
git clone https://github.com/yourusername/django-benchmark-playground.git
cd django-benchmark-playground
```

### Make sure you have:

- Python 3.12+
- pip installed
- wrk benchmarking tool installed (sudo apt install wrk on Ubuntu)
- gnuplot installed (optional, for charts)

- Rust toolchain (for installing Granian) or install Granian via pip:

```bash
pip install granian
```

## Run the setup script to create a Django project and app:

```bash
./setup.sh
```

## Run the benchmark script:

```bash
./benchmark.sh
```

### Check the output charts and RPS stats!
If you have gnuplot, a PNG chart named benchmark_results.png will be generated.

## Notes
This is not a scientific benchmark — just a quick and dirty comparison for fun and learning.

Granian is super interesting but may need extra config or debugging depending on your environment.

Feel free to tweak connection counts, threads, duration in the benchmark script to match your hardware!

## About Granian
Granian is a Rust HTTP server designed for Python web apps. It aims to deliver great speed by leveraging Rust’s performance while keeping Python compatibility.
This benchmark helped me get a feel for how it compares with Django’s default server and Gunicorn.

