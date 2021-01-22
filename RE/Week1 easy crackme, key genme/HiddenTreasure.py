import struct

filepath = "inside-the-mind-of-a-hacker-memory.bmp"
fbmp = open(filepath, "rb")
fdata = fbmp.read()
imgData = fdata[struct.unpack("<I",fdata[10:14])[0]:]

flagData = []
for i in range(240):
    flagData += [imgData[i*3]]

flag = ''
for i in range(0, 240, 8):
    flag += chr((flagData[i+7] << 7) + (flagData[i+6] << 6) + (flagData[i+5] << 5) + (flagData[i+4] << 4) + (flagData[i+3] << 3) + (flagData[i+2] << 2) + (flagData[i+1] << 1) + flagData[i])

print(flag)
