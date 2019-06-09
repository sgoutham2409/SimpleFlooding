array = []
with open("manhattan.rou.xml", "r") as ins:
    for line in ins:
        if "<route edges=" in line:
            array.append(line)
with open("manhattan.rou2.xml", "w") as out:
    out.write("<routes>\n")
    for item in array:
        out.write("%s\n" % item)
    out.write("</routes>")
