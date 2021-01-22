int __cdecl sub_18B0000(const char *a1, int a2)
{
  signed int v2; // kr00_4
  char v3; // ST1E_1
  int v5; // [esp+Ch] [ebp-14h]
  signed int i; // [esp+10h] [ebp-10h]
  signed int j; // [esp+18h] [ebp-8h]

  v2 = strlen(a1);
  v5 = 0;
  for ( i = 0; i < 256; ++i )
    *(_BYTE *)(i + a2) = i;
  for ( j = 0; j < 256; ++j )
  {
    v5 = (a1[j % v2] + v5 + *(unsigned __int8 *)(j + a2)) % 256;
    v3 = *(_BYTE *)(j + a2);
    *(_BYTE *)(j + a2) = *(_BYTE *)(v5 + a2);
    *(_BYTE *)(v5 + a2) = v3;
  }
  return 0;
}


char __cdecl sub_AB0000(int a1, const char *a2, int a3)
{
  char v3; // ST22_1
  unsigned int v5; // [esp+4h] [ebp-20h]
  unsigned int v6; // [esp+10h] [ebp-14h]
  int v7; // [esp+14h] [ebp-10h]
  int v8; // [esp+1Ch] [ebp-8h]

  v8 = 0;
  v7 = 0;
  v6 = 0;
  v5 = strlen(a2);
  while ( v6 < v5 )
  {
    v8 = (v8 + 1) % 256;
    v7 = (v7 + *(unsigned __int8 *)(v8 + a1)) % 256;
    v3 = *(_BYTE *)(v8 + a1);
    *(_BYTE *)(v8 + a1) = *(_BYTE *)(v7 + a1);
    *(_BYTE *)(v7 + a1) = v3;
    if ( *(unsigned __int8 *)(v6 + a3) != (*(unsigned __int8 *)(a1
                                                              + (*(unsigned __int8 *)(v7 + a1)
                                                               + *(unsigned __int8 *)(v8 + a1))
                                                              % 256) ^ a2[v6]) )
      return 0;
    ++v6;
  }
  return 1;
}


int __cdecl sub_18D0000(char *a1, int a2, int a3)
{
  char v4; // [esp+0h] [ebp-11Ch]
  int (__cdecl *v5)(char *, char *, int); // [esp+100h] [ebp-1Ch]
  void (__cdecl *v6)(char *, char *); // [esp+104h] [ebp-18h]
  char v7; // [esp+108h] [ebp-14h]
  char v8; // [esp+109h] [ebp-13h]
  char v9; // [esp+10Ah] [ebp-12h]
  char v10; // [esp+10Bh] [ebp-11h]
  char v11; // [esp+10Ch] [ebp-10h]
  char v12; // [esp+110h] [ebp-Ch]
  int v13; // [esp+111h] [ebp-Bh]
  char v14; // [esp+115h] [ebp-7h]

  v12 = 115;
  v13 = 1851880309;
  v14 = 0;
  v6 = *(void (__cdecl **)(char *, char *))(a3 + 4);
  v5 = *(int (__cdecl **)(char *, char *, int))(a3 + 8);
  v6(&v12, &v4);
  v7 = *a1;
  v8 = a1[1];
  v9 = a1[2];
  v10 = a1[3];
  v11 = 0;
  return v5(&v4, &v7, a2);
}