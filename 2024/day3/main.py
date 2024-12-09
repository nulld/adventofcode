import os
import re


current_dir = os.path.dirname(os.path.abspath(__file__))


test_filepath = os.path.join(current_dir, 'test_p1.txt')
real_filepath = os.path.join(current_dir, 'data_p1.txt')
realp2_filepath = os.path.join(current_dir, 'data_p2.txt')

file_path = realp2_filepath

def scan_corrupted_memory(memory):
    print(memory)
    pattern = r'mul\((\d{1,3}),(\d{1,3})\)'
    
    matches = re.finditer(pattern, memory)
    
    total = 0
    for match in matches:
        num1 = int(match.group(1))
        num2 = int(match.group(2))
        
        result = num1 * num2
        total += result
        
        print(f"Found: mul({num1},{num2}) = {result}")
    
    return total


def scan_corrupted_memory_p2(memory, enabled):
    print(memory, enabled)
    # Regular expressions for different instructions
    mul_pattern = r'mul\((\d{1,3}),(\d{1,3})\)'
    do_pattern = r'do\(\)'
    dont_pattern = r'don\'t\(\)'
    
    all_instructions = re.finditer(f'{mul_pattern}|{do_pattern}|{dont_pattern}', memory)
    total = 0
    
    for instruction in all_instructions:
        if instruction.group(0) == 'do()':
            enabled = True
        elif instruction.group(0) == "don't()":
            enabled = False
        elif enabled and 'mul' in instruction.group(0):
            num1 = int(instruction.group(1))
            num2 = int(instruction.group(2))
            
            result = num1 * num2
            total += result
            
            print(f"Executed: mul({num1},{num2}) = {result}")
    return (enabled, total)

result = 0
with open(file_path, 'r') as file:
    reports = []
    
    enabled = True
    for line in file:
        (enabled, r) = scan_corrupted_memory_p2(line, enabled)
        print(enabled)
        result = result + r


print(f"\nTotal sum of all valid multiplications: {result}")