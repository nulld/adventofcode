import os

current_dir = os.path.dirname(os.path.abspath(__file__))


test_filepath = os.path.join(current_dir, 'test-data_p1.txt')
real_filepath = os.path.join(current_dir, 'data_p1.txt')

file_path = real_filepath

with open(real_filepath, 'r') as file:
    array1 = []
    array2 = []
    
    for line in file:
        num1, num2 = map(int, line.split())
        
        array1.append(num1)
        array2.append(num2)

    array1.sort()
    array2.sort()

result = 0
for i in range(len(array1)):
    a = array1[i]
    b = array2[i]
    result += abs(b - a)
    
print("Результат:", result)
