from sys import argv

if len(argv) == 2:
    script, image_file_name = argv
else:
    print "usage: ", argv[0], " image_filename"
    exit()

import os, json
from glob import glob
import numpy as np

import vgg16own; reload(vgg16own)
from vgg16own import Vgg16

vgg = Vgg16()

import cv2
im = cv2.imread(image_file_name)
im = cv2.resize(im, (224, 224))
im = im.astype(np.float32)
im[:,:,0] -= 103.939
im[:,:,1] -= 116.779
im[:,:,2] -= 123.68
im = im.transpose((2,0,1))
im = np.expand_dims(im, axis=0)

answer = vgg.predict(im, True)
print answer[2][0]
print answer[0][0]
