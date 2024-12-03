import os

# Получаем путь к директории, в которой находится текущий скрипт
current_dir = os.path.dirname(os.path.abspath(__file__))


test_filepath = os.path.join(current_dir, 'test-data_p2.txt')
real_filepath = os.path.join(current_dir, 'data_p2.txt')

file_path = real_filepath

with open(file_path, 'r') as file:
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
    j = 0
    done = False
    while not done:
        if j >= len(array2) or array2[j] > a:
            done = True
        else:
            if array2[j] == a:
                result += a
        j += 1

print("Результат:", result)
