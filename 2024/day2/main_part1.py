import os

current_dir = os.path.dirname(os.path.abspath(__file__))


test_filepath = os.path.join(current_dir, 'test-data_p1.txt')
real_filepath = os.path.join(current_dir, 'data_p1.txt')
realp2_filepath = os.path.join(current_dir, 'data_p2.txt')

file_path = realp2_filepath

def isValid(report):
    allAscending = True
    allDescending = True
    distanceIsValid = True
    prev = -1
    for i, v in enumerate(report):
        if prev > 0 and v < prev: allAscending = False
        if prev > 0 and v > prev: allDescending = False
        if prev > 0 and (abs(v - prev) < 1 or abs(v - prev) > 3): distanceIsValid = False
        prev = v
        

    return (allAscending or allDescending) and distanceIsValid

def pairIsValid(a, b, allAscending, allDescending):
    trendValid = (allAscending and a > b) or (allDescending and b < a)
    d = abs(a - b)
    distanceValid = d >= 1 and d <= 3
    return trendValid and distanceValid

def isValidPart2(report):
    allAscending = True
    allDescending = True
    distanceIsValid = True
    errors = 0
    for i, v in enumerate(report):
        if i > 0: 
            prev = report[i-1]
            if not pairIsValid(prev, v, allAscending, allDescending):
                if i > 1 and errors <= 0: 
                    prev = report[i - 2]
                    errors += 1
                    if pairIsValid(prev, v, allAscending, allDescending):
                        if (v > prev): allDescending = False
                        if (v < prev): allAscending = False
                        continue
                else:
                    errors += 1
            else:
                if (v > prev): allDescending = False
                if (v < prev): allAscending = False

        
    print(errors)

    return (allAscending or allDescending) and distanceIsValid and (errors <= 1)



with open(file_path, 'r') as file:
    reports = []
    
    for line in file:
        reports.append([i for i in map(int, line.split())])


def findReportErrorTolerant(r):
    for i in range(len(r)):
       if isValid([e for k, e in enumerate(r) if (k != i)]):
            return True
    return False


result = 0
for i, r in enumerate(reports):
    if isValid(r) or findReportErrorTolerant(r): 
        result += 1
        continue

    




print("Reports", reports)    
print("Результат:", result)
