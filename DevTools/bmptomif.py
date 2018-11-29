import numpy as np
import scipy.misc as smp
import re
import cv2

# This script should generate the data between the BEGIN and END; of a mif from a bmp.
im = cv2.imread("Image.bmp")
# grab the image dimensions
h = im.shape[0]
w = im.shape[1]

f = open("outmif.txt", "w")

# loop over the image, pixel by pixel
for y in range(0, h):
    for x in range(0, w):
        # threshold the pixel
        r = im[y, x][2]
        g = im[y, x][1]
        b = im[y, x][0]
        f.write(str(x + (y * w)) + "  :   " + str((r//255)) + str((g//255)) + str((b//255)) + ";\n")

f.close()