#include "myrand.h"

unsigned short myrand(void)
{
  static unsigned short seed = 0x3045;
  register unsigned short nextBit;
  
  nextBit = (((seed & 0x8000) ^ (seed & 0x4000)) && 1) ^ (1 && ((seed & 0x1000) ^ (seed & 0x8)));
  return (seed = (seed << 1) | nextBit);
}  
