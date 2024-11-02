#include <iostream>
#include <cuda_runtime.h>
 
#define N 16384
 
// write kernel function of vector addition
__global__ void vecAdd(float *a, float *b, float *c, int n)
{
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    if (i < n)
        c[i] = a[i] + b[i];
}
 
int main()
{
    float *a, *b, *c;
    float *d_a, *d_b, *d_c;
    int size = N * sizeof(float);
 
    // allocate space for device copies of a, b, c
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);
 
    // allocate space for host copies of a, b, c and setup input values
    a = (float *)malloc(size);
    b = (float *)malloc(size);
    c = (float *)malloc(size);
 
    for (int i = 0; i < N; i++)
    {
        a[i] = i;
        b[i] = i * i;
    }
 
    // copy inputs to device
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);
 
    // launch vecAdd() kernel on GPU
    vecAdd<<<(N + 255) / 256, 256>>>(d_a, d_b, d_c, N);
 
    cudaDeviceSynchronize();
 
    // copy result back to host
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
 
    // verify result
    for (int i = 0; i < N; i++)
    {
        if (a[i] + b[i] != c[i])
        {
            std::cout << "Error: " << a[i] << " + " << b[i] << " != " << c[i] << std::endl;
            break;
        }
    }
 
    std::cout << "Done!" << std::endl;
 
    // clean up
    free(a);
    free(b);
    free(c);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
 
    return 0;
}