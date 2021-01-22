'''
Find the correct "encoded" input value - out
'''
#1...
def out1():
    #0x2648ED87
    out = 0x2648ED87
    out = 0x2648ED87 ^ 0x13371337
    out = 0x100000000 + (0x13371337 - out)
    out = (out >> 6) | ((out & 0x3f) << (32 - 6))
    out = 0x100000000 + out - 0xBABECAFE
    print(hex(out))
    return out
    

#2...
def out2():
    #0x94C3E659
    out = 0x94C3E659
    out = 0xdeadbeef - out
    print(hex(out))
    return out


#3...
def out3():
    #0x5469a57F
    out = 0x5469a57F
    out = 0xffffffff - out
    out -= 0x89abcdef
    out ^= 0xabbaabba
    out = 0xffffffff - out
    out = ((out << 4) & 0xffffffff) | (out >> (32 - 4))
    print(hex(out))
    return out


'''
Decode the out -> input
'''
def decodeOut(out):
    in1 = out >> 24
    in1 -= 0x12
    
    in2 = (out >> 16) & 0xff
    in2 += 0x78
    if in2 >= 256:
        in2 -= 256
    
    in3 = (out >> 8) & 0xff
    in3 = (in3 >> 2) | ((in3 & 3) << 6)
    
    in4 = out & 0xff
    in4 = (in4 >> 4) | ((in4 & 0xf) << 4)
    
    inStr = ''
    inStr = chr(in1) + chr(in2) + chr(in3) + chr(in4)
    return inStr


'''
The main
'''
inputStr = ''
inputStr = decodeOut(out1()) + decodeOut(out2()) + decodeOut(out3())
print(inputStr)
