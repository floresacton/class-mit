months = {
    "January": 1,
    "February": 2,
    "March": 3,
    "April": 4,
    "May": 5,
    #finish this
}

print("12/12/2005".split("/"))

with open("weather.csv") as f:
    map = {}
    characters = f.read()
    lines = characters.split("\n")
    headers = lines[0].split(",")
    cols = len(headers)
    for i in range(cols):
        map[headers[i]] = []
    
    for i in range(1, len(lines)):
        parts = lines[i].split(",")
        for j in range(cols):
            if j != 0:
                map[headers[j]].append(float(parts[j]))
            else:
                map[headers[j]].append(parts[j])

    word_month = input("Month: ")
    data_month = months[word_month]

    data_year = input("Year: ")

    avg_temp = 0
    avg_humidity = 0
    avg_wind = 0
    rain_days = 0
    days = 0

    for i in range(len(map["Date"])):
        date = map["Date"][i].split("/")
        print(date)
        if date[0] == data_month and date[2] == data_year:
            days += 1
            if map["Precipitation (in)"][i] != 0:
                rain_days += 1
            avg_temp += map["temperature"]
            avg_humidity += map["humidity"]
            avg_wind += map["windiness"]
    
    avg_temp /= days
    avg_humidity /= days
    avg_wind /= days
    rain_days /= days

    ##print stuff here

