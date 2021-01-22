

'''
data = "41 42 44 43 45 48 47 46 49 4A 4B 4C 55 4E 4F 50 59 52 54 53 4D 56 57 58 51 5A 61 6A 63 64 65 66 6F 68 69 62 6B 6D 6C 6E 67 70 71 72 73 74 75 76 34 78 7A 79 38 31 32 33 77 35 36 37 30 39 2B 30"
listdata = data.split(" ")
for i in range(0,len(listdata)):
    listdata[i] = int(listdata[i],16)

for v3 in range(0x20,0x80):
    if listdata[v3 & 0x3f] == 0x6f:  
        for v2 in range(0x20,0x80):
            idx = ((v3 & 0xc0) >> 6)  + (v2 & 0xf)*4
            if listdata[idx] == 0x59:
                #print(i,j)
                for v1 in range(0x20, 0x80):
                    idx2 = ((v2 & 0xf0) >> 4) + 16 * (v1 & 3)
                    if listdata[idx2] == 0x33:
                        if listdata[(v1 & 0xfc) >> 2] == 0x63:
                            print(v1, v2, v3)
'''


buffData = "73 E9 39 D0 98 BB D6 23 16 19 FC 7C 0F 32 80 B2 9C 57 36 9E 91 4D DF 7A 08 42 76 A5 11 AD 3E D2 65 4F 71 20 A0 28 C3 33 4E 6C 79 95 AF 6B C8 70 A2 41 92 BA 4B D1 E3 BC 2B F4 1C 46 78 D9 B6 04 ED 96 68 97 F5 09 3A 25 EB BE 49 D8 6D B5 13 7E 00 77 6F B4 0E 1D B7 2C CA 7F 3C 5F 7D A9 88 C4 C0 5E 18 CD E0 0C 62 29 54 84 07 47 C9 F7 2E 06 E2 24 83 E4 52 15 45 43 DA 31 82 87 B8 14 E7 CF E5 40 1A DD 9A 35 85 F3 63 B1 F0 3D 0D EA 8B EE 99 AE A4 51 A8 1E 1B C5 34 4C FD FF EC 37 64 75 05 01 8C 21 A3 60 50 6A B9 5C 53 CE 26 C1 3B F2 3F 66 CC 2F A1 94 56 59 4A 9F D7 89 48 5B 12 9D 8F 55 D5 BF 5D 2D F8 1F 30 0B 5A 44 67 2A 38 F9 F6 6E 7B EF E8 8A DE C7 F1 A7 CB DC D4 D3 27 FE 10 02 BD 90 FA E1 69 E6 72 AB AC 22 8E 86 9B FB A6 17 B3 61 74 C6 C2 58 B0 AA DB 93 8D 03 0A 81 00 00 E3 00 00 00 E2 00 EB 00 00 00 00 10 00 00"
buffArr = buffData.split()
for i in range(len(buffArr)):
    buffArr[i] = int(buffArr[i], 16)


def case4(buffArr, iInOff, iCCheck):
    #strArr buffer
    #iInOff offset of first character
    #iCCheck offset of first check character

    v8 = 0
    v7 = 0
    v6 = 0
    v5 = 4
    
    for v6 in range (v5):
        v8 = (v8 + 1) % 256
        v7 = (v7 + buffArr[v8]) % 256
        v3 = buffArr[v8]
        buffArr[v8] = buffArr[v7]
        buffArr[v7] = v3

        for char in range(0x20, 0x80):
            check = (buffArr[v7] + buffArr[v8]) % 256
            check = buffArr[check]
            check = check ^ char #arrCheck[iInOff + v6]
            if check == arrCheck[iCCheck + v6]:
                print(char, chr(char))



arrCheck = [4, 0, 0, 0, 22, 0, 0, 0, 136, 63, 237, 13]
iInOff = 4
iCCheck = 8

case4(buffArr, iInOff, iCCheck)
