///*
// * app_fft_old.xc
// *
// *  Created on: Dec 1, 2016
// *		Contact: sritan@synapticon.com
// */
//
//#include <FFT.h>
//
//#define N_FFT_POINTS 8
//#define INPUT_FREQ N_FFT_POINTS/8
//
//lib_dsp_fft_complex_t  two_re[N_FFT_POINTS];
//lib_dsp_fft_complex_t  two_im[N_FFT_POINTS];
//int do_tworeal_fft_and_ifft();
//
//// sine signal with 8 samples per cycle
//int sin8(int x) {
//    x = x & (8-1); // mask off 3 bits
//    switch (x >> 1) {
//       // upper two bits determine the quadrant.
//       case 0: return lib_dsp_sine_8[x];
//       case 1: return lib_dsp_sine_8[4-x];
//       case 2: return -lib_dsp_sine_8[x-4];
//       case 3: return -lib_dsp_sine_8[8-x];
//    }
//    return 0; // unreachable
//}
//int cos8(int x) {
//    return sin8(x+(8/4)); // cos a = sin(a + 2pi/4)
//}
//
//int sin16(int x)
//{
//    x = x & (16-1); // mask off 4 bits
//    switch(x >> 2) {
//        case 0: return lib_dsp_sine_16[x];
//        case 1: return lib_dsp_sine_16[8-x];
//        case 2: return -lib_dsp_sine_16[x-8];
//        case 3: return -lib_dsp_sine_16[16-x];
//    }
//    return 0;
//}
//
//int cos16(int x) {
//    return sin16(x+(16/8)); // cos a = sin(a + 2pi/4)
//}
//
//int sin128(int x)
//{
//    x = x & (128-1); // mask off 7 bits
//    switch(x >> 5) {
//        case 0: return lib_dsp_sine_128[x];
//        case 1: return lib_dsp_sine_128[64-x];
//        case 2: return -lib_dsp_sine_128[x-64];
//        case 3: return -lib_dsp_sine_128[128-x];
//    }
//    return 0;
//}
//
//int cos128(int x) {
//    return sin128(x+(128/64)); // cos a = sin(a + 2pi/4)
//}
//
//
//// in complex signal there are two fields (one for real part and one for imaginary)
//// every element of those fields are actually a structure with two elements .re and .im => complex array
//// in complex signals one signal is two_re.re and two_im.re and the other signal is two_re.im and two_im.im
//
//
//void generate_tworeal_test_signal(int N, int test) {     // in complex signal there are two fields (one for real part and one for imaginary)
//    switch(test) {                                       // every element of those fields are actually a structure with two elements .re and .im => complex array
//    case 0: {                                            // in complex signals one signal is two_re.re and two_im.re and the other signal is two_re.im and two_im.im
//        printf("++++ Test %d: %d point FFT of two real signals:: re0: %d Hz cosine, re1: %d Hz cosine\n"
//                ,test,N,INPUT_FREQ,INPUT_FREQ);
//        for(int i=0; i<N; i++) {                         // two real signals are entered in real parts of previously described signals
//            two_re[i].re = cos8(i) >> RIGHT_SHIFT;
//            two_re[i].im = cos8(i) >> RIGHT_SHIFT;
//            two_im[i].re = 0;
//            two_im[i].im = 0;
//        }
//        break;
//    }
//    case 1: {
//        printf("++++ Test %d: %d point FFT of two real signals:: re0: %d Hz sine, re1: %d Hz sine\n"
//                 ,test,N,INPUT_FREQ,INPUT_FREQ);
//        for(int i=0; i<N; i++) {
//            two_re[i].re = sin8(i) >> RIGHT_SHIFT;
//            two_re[i].im = sin8(i) >> RIGHT_SHIFT;
//            two_im[i].re = 0;
//            two_im[i].im = 0;
//        }
//        break;
//    }
//    case 2: {
//        printf("++++ Test %d: %d point FFT of two real signals:: re0: %d Hz sine, re1: %d Hz cosine\n"
//                 ,test,N,INPUT_FREQ,INPUT_FREQ);
//        for(int i=0; i<N; i++) {
//            two_re[i].re = lib_dsp_math_multiply(Q30(0.75), sin8(i) >> RIGHT_SHIFT, 30);
//            two_re[i].im = lib_dsp_math_multiply(Q30(0.75), cos8(i) >> RIGHT_SHIFT, 30);
//            two_im[i].re = 0;
//            two_im[i].im = 0;
//        }
//        break;
//    }
//    case 3: {
//        printf("++++ Test %d: %d point FFT of two real signals:: re0: %d Hz cosine, re1: %d Hz sine\n"
//                 ,test,N,INPUT_FREQ,INPUT_FREQ);
//        for(int i=0; i<N; i++) {
//            two_re[i].re = lib_dsp_math_multiply(Q30(0.33) >> RIGHT_SHIFT, cos8(i), 30);
//            two_re[i].im = lib_dsp_math_multiply(Q30(0.18) >> RIGHT_SHIFT, sin8(i), 30);
//            two_im[i].re = 0;
//            two_im[i].im = 0;
//        }
//        break;
//    }
//    }
//    printf("Generated Two Real Input Signals:\n");
//    printf("re0,          re1         \n");
//    for(int i=0; i<N; i++) {
//        printf("%.10f, %.10f\n",F30(two_re[i].re), F30(two_re[i].im));
//    }
//}
//
//void app_fft_old()
//{
//    for(int test=0; test<4; test++) {
//
//        generate_tworeal_test_signal(N_FFT_POINTS, test);
//
//        /*
//         *  FFT
//         */
//
//        printf("Forward 2xReal FFT, Size = %05u\n", N_FFT_POINTS );
//
//        lib_dsp_fft_forward_tworeals( two_re, two_im, N_FFT_POINTS, FFT_SINE(N_FFT_POINTS));
//
//
//        // Print forward complex FFT results
//        printf( "Complex FFT output spectrum of Real signal 0 (cosine):\n");
//        printf("re,           im         \n");
//        for(int i=0; i<N_FFT_POINTS; i++) {
//            printf( "%.10f, %.10f\n", F30(two_re[i].re), F30(two_im[i].re));
//        }
//
//        printf( "Complex FFT output spectrum of Real signal 1 (sine):\n");
//        printf("re,           im         \n");
//        for(int i=0; i<N_FFT_POINTS; i++) {
//            printf( "%.10f, %.10f\n", F30(two_re[i].im), F30(two_im[i].im));
//        }
//
//
//        /*
//         * inverse FFT
//         */
//
//        printf( "Inverse 2xReal FFT, Size = %05u\n", N_FFT_POINTS );
//
//        lib_dsp_fft_inverse_tworeals( two_re, two_im, N_FFT_POINTS, FFT_SINE(N_FFT_POINTS) );
//
//        printf("Recovered Two Real Input Signals:\n");
//        printf("re,           re         \n");
//        for(int i=0; i<N_FFT_POINTS; i++) {
//            printf( "%.10f, %.10f\n", F30(two_re[i].re), F30(two_re[i].im));
//        }
//
//        printf("\n" ); // Test delimiter
//    }
//
//    printf( "DONE.\n" );
//}
