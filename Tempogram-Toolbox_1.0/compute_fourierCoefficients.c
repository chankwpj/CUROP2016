#include "mex.h"
#include "math.h"


#define PI 3.141592653589793
#define twoPI 6.283185307179586

#ifdef _OPENMP
#include <omp.h>
#else
#pragma message("WARNING: OpenMP not enabled. Use -fopenmp (>gcc-4.2) or -openmp (icc) for speed enhancements on SMP machines.")
#endif


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    
    const double *sig, *win, *noverlap, *f, *fs;
    double *xr, *xi;
    
    mxArray *mx_x, *mx_twoPiT, *mx_cosine, *mx_sine, *mx_T;
    real_T *twoPiT, *cosine, *sine, *T;
    
    mwSize win_len, sig_len, f_len, win_num, i, j, f0, w;
    double realV, imagV, store;
    int start, hopsize;
    
    
    
    if (nrhs<5)
        mexErrMsgTxt("You didn't specify all required arguments.");
    
    #ifdef _OPENMP
        if (omp_get_num_procs()>4)
            omp_set_num_threads(4);
        else 
            omp_set_num_threads(omp_get_num_procs());
/* mexPrintf("Number of threads used: %d of %d\n", omp_get_max_threads( ), omp_get_num_procs()); */
    #endif 
    
    
    sig      = mxGetPr(prhs[0]);
    win      = mxGetPr(prhs[1]);
    noverlap = mxGetPr(prhs[2]);
    f        = mxGetPr(prhs[3]);
    fs       = mxGetPr(prhs[4]);
      
    win_len   = mxGetM(prhs[1]);
    sig_len   = mxGetM(prhs[0]);
    f_len     = mxGetM(prhs[3]);
    
    hopsize = (win_len-*noverlap);
    win_num = floor(((sig_len-*noverlap))/(hopsize));
    
    
    mx_x  = mxCreateDoubleMatrix(f_len, win_num, mxCOMPLEX );
    xr    = mxGetPr(mx_x);
    xi    = mxGetPi(mx_x);
    
    mx_T   = mxCreateDoubleMatrix(win_num, 1, mxREAL );
    T      = mxGetPr(mx_T);
    
    mx_twoPiT = mxCreateDoubleMatrix(win_len, 1, mxREAL  );
    twoPiT    = mxGetPr(mx_twoPiT);
    
    mx_cosine = mxCreateDoubleMatrix(win_len, 1, mxREAL );
    cosine    = mxGetPr(mx_cosine);
    
    mx_sine   = mxCreateDoubleMatrix(win_len, 1, mxREAL );
    sine      = mxGetPr(mx_sine);
    
    
    #pragma omp parallel for
        for(i=0;i<win_len;i++)
            twoPiT[i] = i/(*fs)*twoPI;
    #pragma omp parallel for
        for(w = 0; w<win_num; w++)
            T[w] = (w * hopsize+ win_len * 0.5) /(*fs);
    
    for(f0 = 0;f0<f_len;f0++) {
            
        #pragma omp parallel for private(store)
        for (j =0;j<win_len;j++) {
            store = f[f0]*twoPiT[j];
            cosine[j] = cos(store);
            sine[j] = sin(store);
        }
        
        #pragma omp parallel for private(w, i, start, store, realV, imagV)
        for(w = 0; w<win_num; w++) {
            start = w * hopsize;
            
            realV = 0;
            imagV = 0;
            
            for (i=0;i<win_len;i++) {
                store = sig[start+i]*win[i];
                
                realV += store * cosine[i];
                imagV -= store * sine[i];
                
            }
            i = f_len*w+f0;
            xr[i] = realV;
            xi[i] = imagV;
            
        }
    }
    
    plhs[0] = mx_x;
    
    if (nlhs>1) {
        mxArray* mx_F   = mxCreateDoubleMatrix(f_len, 1, mxREAL );
        real_T*  F      = mxGetPr(mx_F);
        for (i=0;i<f_len;i++){
            F[i] = f[i];
        }
        plhs[1] = mx_F;
    }
    if (nlhs==3){
        plhs[2] = mx_T;
    }
    
    return;
}





