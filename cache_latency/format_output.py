import json
import sys


def parse_file_to_json(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    throughput_memory_list = [[], [], []]
    latency_list = [[], [], []]
    time_list = [[], [], []]
    threads_list = [[], [], []]
    thread_count_list = [[], [], []]
    input_size = set()
    prev_cores = 0
    cache_level = 0
    for i in range(0, len(lines)):
        if lines[i].startswith('final:'):
            _, cores, size, throughput_memory, throughput_elements, time_ns = lines[i].split()

            cores = int(cores)
            size = int(size)
            throughput_memory = float(throughput_memory.replace('GB/s', ''))
            throughput_elements = float(throughput_elements)
            time_ns = float(time_ns.replace('ns', ''))

            threads_times = list(map(int, lines[i + 1].split()))

            if prev_cores > cores:
                cache_level += 1
            input_size.add(size)
            prev_cores = cores
            throughput_memory_list[cache_level].append(throughput_memory)
            latency_list[cache_level].append(throughput_elements)
            time_list[cache_level].append(time_ns)
            threads_list[cache_level].append(threads_times)
            thread_count_list[cache_level].append(len(threads_times))

    data = {
        "thread_counts": thread_count_list[0],
        "input_size": sorted(list(input_size)),

        "l1_throughput_gb_s": throughput_memory_list[0],
        "l1_latency": latency_list[0],
        "l1_time_ns": time_list[0],
        "l1_threads_times": threads_list[0],

        "l2_throughput_gb_s": throughput_memory_list[1],
        "l2_latency": latency_list[1],
        "l2_time_ns": time_list[1],
        "l2_threads_times": threads_list[1],

        "l3_throughput_gb_s": throughput_memory_list[2],
        "l3_latency": latency_list[2],
        "l3_time_ns": time_list[2],
        "l3_threads_times": threads_list[2]
    }
    json_output = json.dumps(data, indent=4)
    print(json_output)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python format_output.py <file_path>")
    else:
        file_path = sys.argv[1]
        parse_file_to_json(file_path)
