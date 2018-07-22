#include <stdio.h>
#import <Cocoa/Cocoa.h>
#include <CoreAudio/AudioHardware.h>
#include "soundfx.h"
#include <string.h>
#include <unistd.h>
#include <assert.h>


static int get_frequency(const char *buffer, int size);
static int get_data(const char *buffer, int size);

#define BASE_FREQ 44100.0
#define DEFAULT_FREQ 10000
#define SOUND_SIGNAL 135
#define VOLUME_THROTTLE .25

static soundfx sfx;

OSStatus soundOutProc (AudioDeviceID inDevice, const AudioTimeStamp* inNow, const AudioBufferList* inInputData,
    const AudioTimeStamp* inInputTime, AudioBufferList*	outOutputData, const AudioTimeStamp* inOutputTime,
    void* inClientData) {
    static int where = 0;

    int size = outOutputData->mBuffers[0].mDataByteSize;
    int sampleCount = size / sizeof(float);
    float *buf = (float*) outOutputData->mBuffers[0].mData;
    float *sndBuf;
    BOOL lastZero = NO;
    
    if (sfx == NULL) {
        if (lastZero) return noErr;
        lastZero = YES;
         memset(buf, 0, sampleCount * sizeof(float));
         return (noErr);
    } else
        lastZero = NO;
    
    sndBuf = sfx->caBuffer;
    
    if (sampleCount >  (sfx->caSize - where)) {
        memcpy(buf, sndBuf + where, sizeof(float) * (sfx->caSize - where));
        memset(buf + (sfx->caSize - where), 0,
               sizeof(float) * (sampleCount - (sfx->caSize - where)));
    } else
        memcpy(buf, sndBuf + where, sizeof(float) * sampleCount);
    where += sampleCount;
    if (where >= sfx->caSize) {
        sfx = NULL;
        where = 0;
    }

    return (noErr);     
}

void soundfx_init() {
    OSStatus err = noErr;
    UInt32 count, bufferSize;
    AudioDeviceID device = kAudioDeviceUnknown;
    AudioStreamBasicDescription format;
    
    // get the default output device for the HAL
    count = sizeof(AudioDeviceID);
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice,  &count, (void *) &device);
    if (err != noErr) return;
    
    // get the buffersize that the default device uses for IO
    count = sizeof(UInt32);
    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyBufferSize, &count, &bufferSize);
    if (err != noErr) return;
   
    // get a description of the data format used by the default device
    count = sizeof(AudioStreamBasicDescription);
    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyStreamFormat, &count, &format);
    if (err != noErr) return;
    
    // we want linear pcm
    assert(format.mFormatID == kAudioFormatLinearPCM);

    err = AudioDeviceAddIOProc(device, soundOutProc, NULL);
    if(err != noErr) return;
    err = AudioDeviceStart(device, soundOutProc);			
    if(err != noErr) return;
}

/* Loads sound data from the file specified by filename. If
   successful, returns a non-NULL handle to the data. Otherwise
   returns a NULL handle. */
soundfx soundfx_load(const char *filename)
{
  FILE *fPath;
  int size = 0;
  soundfx new;
  int ii, sz;
  float k;
  
  /* Allocate memory for the handle. */
  new = (soundfx)malloc(sizeof(_soundfx));
  if (!new) return(NULL);
  
  /* Open the file. */
  fPath = fopen(filename, "r");
  if (NULL == fPath) {
  	free(new);
  	return(NULL);
  }
  
  /* Get the entire file. */
  do { size++;
  } while (getc(fPath) >= 0);
  fseek(fPath, 0, SEEK_SET);
  if ((new->size = size) <= 0) {
  	fclose(fPath);
  	free(new);
    return(NULL);
  }
  if (NULL == (new->buffer = (char *)malloc(size))) {
  	fclose(fPath);
  	free(new);
  	return(NULL);
  }
  if (size-1 != fread(new->buffer, 1, size, fPath)) {
  	free(new->buffer);
  	fclose(fPath);
  	free(new);
  	return(NULL);
  }
  fclose(fPath);
  
  /* Fill in the fields. */
  new->freq = get_frequency(new->buffer, size);
  new->dataoffset = get_data(new->buffer, size);
  new->size -= new->dataoffset;
  
  /* Fill in the core audio stuff */
  k = ((float)BASE_FREQ)/new->freq;
  sz = new->size * k;
  new->caSize = sz;
  new->caBuffer = calloc(2 * sz, sizeof(float));
  if (new->caBuffer == NULL) {
    	free(new->buffer);
  	fclose(fPath);
  	free(new);
  	return(NULL);
  }
  for(ii=0; ii<sz; ii+=2) {
    int idxLeft = ii/k;
    int idxRight = ii/k + 1;
    if (idxLeft >= new->size) idxLeft = new->size;
    if (idxRight >= new->size) idxRight = new->size;
    
    new->caBuffer[ii] = VOLUME_THROTTLE * ((signed char)(new->buffer[idxLeft + new->dataoffset]))/128.0f;
    new->caBuffer[ii+1] = VOLUME_THROTTLE * ((signed char)(new->buffer[idxRight + new->dataoffset]))/128.0f;
  }
  
  return(new);
}
  
void soundfx_destroy(soundfx snd)
{
  if (snd == NULL) return;
  free(snd->buffer);
  free(snd->caBuffer);
  free(snd);
  return;
}

void soundfx_play(game_screen g, soundfx snd)
{
    if (sfx == NULL)
        sfx = snd; // we assume this assignment is atomic
}

void soundfx_wait_and_play(game_screen g, soundfx snd)
{
    while(sfx != NULL) usleep(10000);
    soundfx_play(g, snd);
}

static int get_frequency(const char *buffer, int size)
{
  int ii;
  
  for (ii=0; ii<size-6; ii++) {
    if ( (buffer[ii] == 'F') && (buffer[ii+1] == 'O') &&
         (buffer[ii+2] == 'R') && (buffer[ii+3] == 'M') &&
         (buffer[ii+4] == 0) && (buffer[ii+5] == 0) )
      if ((ii + 33) < size) {
        return( ((buffer[ii+32] << 8) + buffer[ii+33])/2 );
      }
  }

  return(DEFAULT_FREQ);
}


static int get_data(const char *buffer, int size)
{
  int ii;
  
  for (ii=0; ii<size-6; ii++) {
    if ( (buffer[ii] == 'B') && (buffer[ii+1] == 'O') &&
         (buffer[ii+2] == 'D') && (buffer[ii+3] == 'Y') &&
         (buffer[ii+4] == 0) && (buffer[ii+5] == 0) )
      if ((ii + 6) < size)
        return(ii+6);
  }

  return(0);
}


int soundfx_signal_handler(int signal)
{
  return 0;
}


int soundfx_busy(void)
{
  return(sfx != NULL);
}
