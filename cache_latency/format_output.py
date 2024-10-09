import json
import sys
import math


def parse_file_to_json(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    size_list = []
    throughput_memory_list = []
    latency_list = []
    time_list = []

    for i in range(0, len(lines)):
        if lines[i].startswith('final:'):
            _, size, throughput_memory, latency, time_ns = lines[i].split()

            size = math.log10(int(size) * 8 / 1024 / 1024)
            throughput_memory = float(throughput_memory.replace('GB/s', ''))
            latency = float(latency)
            time_ns = float(time_ns.replace('ns', ''))

            size_list.append(size)
            throughput_memory_list.append(throughput_memory)
            latency_list.append(latency)
            time_list.append(time_ns)

    data = {
        "input_size_log10": size_list,
        "throughput_gb_s": throughput_memory_list,
        "latency": latency_list,
        "time_ns": time_list,
    }
    json_output = json.dumps(data, indent=4)
    print(json_output)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python format_output.py <file_path>")
    else:
        file_path = sys.argv[1]
        parse_file_to_json(file_path)
