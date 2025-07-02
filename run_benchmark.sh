#!/bin/bash

set -e

PORT=8888
URL="http://127.0.0.1:$PORT/"
DURATION="30s"
CONNECTIONS=500
THREADS=8
REPEAT=5

# Uncomment and adjust this if you use a virtual environment
# source ../venv/bin/activate

run_wrk() {
  wrk -t$THREADS -c$CONNECTIONS -d$DURATION "$URL" 2>/dev/null
}

extract_rps() {
  grep "Requests/sec" | awk '{print $2}'
}

run_test() {
  local name="$1"
  local start_cmd="$2"

  echo "🔥 Benchmarking $name ($REPEAT runs)..."
  local total_rps=0

  for i in $(seq 1 $REPEAT); do
    echo "▶ Run #$i"
    eval "$start_cmd" > /dev/null 2>&1 &
    PID=$!

    # Wait for server to be ready (max 10 seconds)
    local retries=10
    while ! curl -s "$URL" > /dev/null; do
      retries=$((retries-1))
      if [ $retries -le 0 ]; then
        echo "⚠ $name server did not start in time"
        kill $PID 2>/dev/null || true
        continue 2
      fi
      sleep 1
    done

    result=$(run_wrk)
    rps=$(echo "$result" | extract_rps)
    echo "$result"
    echo "📈 RPS: $rps"

    total_rps=$(echo "$total_rps + $rps" | bc)

    if kill -0 $PID 2>/dev/null; then
      kill $PID
      sleep 1
    else
      echo "⚠ $name process exited early!"
    fi
  done

  avg_rps=$(echo "scale=2; $total_rps / $REPEAT" | bc)
  echo "✅ $name Average RPS: $avg_rps"
  echo ""

  echo "$name $avg_rps" >> /tmp/benchmark_results.txt
}

rm -f /tmp/benchmark_results.txt

# Run tests
run_test "Django Runserver" "python3 manage.py runserver $PORT"
run_test "Gunicorn" "gunicorn djtestbench.wsgi:application --bind 127.0.0.1:$PORT"
run_test "Granian" "granian --interface wsgi djtestbench.wsgi:application --host 127.0.0.1 --port $PORT"

echo "📊 Generating results chart..."

if command -v gnuplot >/dev/null 2>&1; then
  cat > /tmp/benchmark_chart.gnuplot <<EOF
set terminal dumb size 60,15
set title "Django Server Benchmark (Requests/sec)"
set style data histogram
set style fill solid 1.00 border -1
set boxwidth 0.5
set yrange [0:*]
set grid ytics
set xlabel "Server"
set ylabel "Requests/sec"
plot '/tmp/benchmark_results.txt' using 2:xtic(1) title 'RPS'
EOF

  gnuplot /tmp/benchmark_chart.gnuplot

  echo "📊 Generating PNG chart..."
  cat > /tmp/benchmark_chart_png.gnuplot <<EOF
set terminal pngcairo size 800,600 enhanced font 'Verdana,12'
set output 'benchmark_results.png'
set title "Django Server Benchmark (Requests/sec)"
set style data histogram
set style fill solid 1.00 border -1
set boxwidth 0.5
set yrange [0:*]
set grid ytics
set xlabel "Server"
set ylabel "Requests/sec"
plot '/tmp/benchmark_results.txt' using 2:xtic(1) title 'RPS'
EOF

  gnuplot /tmp/benchmark_chart_png.gnuplot
  echo "✅ PNG chart saved as benchmark_results.png"
  echo "Open it with your favorite image viewer to see the results."

else
  echo "⚠ gnuplot not found. Printing ASCII bar chart instead:"

  max_rps=$(awk '{print $2}' /tmp/benchmark_results.txt | sort -nr | head -1)
  scale=$(echo "scale=4; 50 / $max_rps" | bc)

  while read -r line; do
    name=$(echo $line | awk '{print $1}')
    val=$(echo $line | awk '{print $2}')
    bar_len=$(echo "$val * $scale / 1" | bc)
    bar=$(printf "%0.s#" $(seq 1 $bar_len))
    printf "%-15s | %7s | %s\n" "$name" "$val" "$bar"
  done < /tmp/benchmark_results.txt
fi

echo "✅ Benchmarking complete."
