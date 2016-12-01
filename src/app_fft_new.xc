/*
 * app_fft_new.xc
 *
 *  Created on: Dec 1, 2016
 *		Contact: sritan@synapticon.com
 */

#include <FFT.h>

int32_t do_tworeals_fft_and_ifft();
dsp_complex_t  data[N_FFT_POINTS];

/**
 * Experiments with functions that generate sine and cosine signals with a defined number of points
 **/
// Macros to ease the use of the sin_N and cos_N functions
// Note: 31-clz(N) == log2(N) when N is power of two
#define SIN(M, N) sin_N(M, 31-clz(N), dsp_sine_ ## N)
#define COS(M, N) cos_N(M, 31-clz(N), dsp_sine_ ## N)

int32_t sin_N(int32_t x, int32_t log2_points_per_cycle, const int32_t sine[]);
int32_t cos_N(int32_t x, int32_t log2_points_per_cycle, const int32_t sine[]);

// generate sine signal with a configurable number of samples per cycle
#pragma unsafe arrays
int32_t sin_N(int32_t x, int32_t log2_points_per_cycle, const int32_t sine[]) {
    // size of sine[] must be equal to num_points!
    int32_t num_points = (1<<log2_points_per_cycle);
    int32_t half_num_points = num_points>>1;

    x = x & (num_points-1); // mask off the index

    switch (x >> (log2_points_per_cycle-2)) { // switch on upper two bits
       // upper two bits determine the quadrant.
       case 0: return sine[x];
       case 1: return sine[half_num_points-x];
       case 2: return -sine[x-half_num_points];
       case 3: return -sine[num_points-x];
    }
    return 0; // unreachable
}

// generate cosine signal with a configurable number of samples per cycle
#pragma unsafe arrays
int32_t cos_N(int32_t x, int32_t log2_points_per_cycle, const int32_t sine[]) {
    int32_t quarter_num_points = (1<<(log2_points_per_cycle-2));
    return sin_N(x+(quarter_num_points), log2_points_per_cycle, sine); // cos a = sin(a + 2pi/4)
}


void generate_tworeals_test_signal(int32_t N, int32_t test) {
    switch(test) {
     case 0: {
         printf("++++ Test %d: %d point FFT of two real signals:: re0: %d Hz cosine, re1: %d Hz cosine\n"
                 ,test,N,INPUT_FREQ,INPUT_FREQ);
         for(int32_t i=0; i<N; i++) {
             data[i].re = COS(i, 8) >> RIGHT_SHIFT;
             data[i].im = COS(i, 8) >> RIGHT_SHIFT;
         }
         break;
     }
     case 1: {
         printf("++++ Test %d: %d point FFT of two real signals:: re0: %d Hz sine, re1: %d Hz sine\n"
                 ,test,N,INPUT_FREQ,INPUT_FREQ);
         for(int32_t i=0; i<N; i++) {
             data[i].re = SIN(i, 8) >> RIGHT_SHIFT;
             data[i].im = SIN(i, 8) >> RIGHT_SHIFT;
         }
         break;
     }
     case 2: {
         printf("++++ Test %d: %d point FFT of two real signals:: re0: %d Hz sine, re1: %d Hz cosine\n"
                 ,test,N,INPUT_FREQ,INPUT_FREQ);
         for(int32_t i=0; i<N; i++) {
             data[i].re = dsp_math_multiply(Q30(0.75), SIN(i, 8) >> RIGHT_SHIFT, 30);
             data[i].im = dsp_math_multiply(Q30(0.75), COS(i, 8) >> RIGHT_SHIFT, 30);
         }
         break;
     }
     case 3: {
         printf("++++ Test %d: %d point FFT of two real signals:: re0: %d Hz cosine, re1: %d Hz sine\n"
                 ,test,N,INPUT_FREQ,INPUT_FREQ);
         for(int32_t i=0; i<N; i++) {
             data[i].re = dsp_math_multiply(Q30(0.33), COS(i, 8) >> RIGHT_SHIFT, 30);
             data[i].im = dsp_math_multiply(Q30(0.18), SIN(i, 8) >> RIGHT_SHIFT, 30);
         }
         break;
     }
    }

    printf("Generated Two Real Input Signals:\n");

    printf("re,           im         \n");
    for(int32_t i=0; i<N_FFT_POINTS; i++) {
        printf( "%.10f, %.10f\n", F30(data[i].re), F30(data[i].im));
    }
}

void app_fft_new()
{
    for(int32_t test=0; test<4; test++) {

        generate_tworeals_test_signal(N_FFT_POINTS, test);

        dsp_fft_bit_reverse(data, N_FFT_POINTS);
        dsp_fft_forward(data, N_FFT_POINTS, FFT_SINE(N_FFT_POINTS));
//        dsp_fft_split_spectrum(data, N_FFT_POINTS);

        // Print forward complex FFT results
        //printf( "First half of Complex FFT output spectrum of Real signal 0 (cosine):\n");
        printf( "FFT output of two half spectra. Second half could be discarded due to symmetry without loosing information\n");
        printf( "spectrum of first signal in data[0..N/2-1]. spectrum of second signal in data[N/2..N-1]:\n");

        printf("re,           im         \n");
        for(int32_t i=0; i<N_FFT_POINTS; i++) {
            printf( "%.10f, %.10f\n", F30(data[i].re), F30(data[i].im));
        }



        dsp_fft_bit_reverse(data, N_FFT_POINTS);
        dsp_fft_inverse(data, N_FFT_POINTS, FFT_SINE(N_FFT_POINTS));

        printf( "////// Time domain signal after dsp_fft_inverse\n");
        printf("re,           im         \n");
        for(int32_t i=0; i<N_FFT_POINTS; i++) {
            printf( "%.10f, %.10f\n", F30(data[i].re), F30(data[i].im));
        }


    }
}
