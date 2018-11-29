import math

def jump():
    y = 0
    frame = 0
    clk = 0
    t = 0
    while y >= 0:
        y_next = 0.4008255 + (518.1582*t) - (1413.798*t*t)
        if y != math.floor(y_next):
            y = math.floor(y_next)

            print("25'd"+str(clk)+": "+"elev <= " + str(y) + ";")
            # print("clk(" + str(clk) + "):(" + str(t) + ", " + str(y) + ")") 24
        t = clk / 50000000
        frame = clk // 833332
        clk += 1


def jumptest():
    y = 0
    frame = 0
    clk = 0
    t = 0
    while y >= 0:
        y_next = 0.4008255 + (518.1582*t) - (1413.798*t*t)
        if y != math.floor(y_next):
            y = math.floor(y_next)

            print("25'd"+str(clk)+": "+"elev <= " + str(y) + ";")
            # print("clk(" + str(clk) + "):(" + str(t) + ", " + str(y) + ")") 24
        t = clk / 5999940
        # t = clk / 50000000
        # frame = clk // 833332
        clk += 1

# f 1 0.4008255 + (498.1582*t) - (1673.798*t*t)
# formul 2 y=0.4008255+598.1582x-1413.798x^2

# jumptest()
jump()