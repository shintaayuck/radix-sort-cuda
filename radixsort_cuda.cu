#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <cuda_runtime.h>
#include "device_launch_parameters.h"

extern "C"

// Function for generating random array
void rng(int* arr, int n) {
	int seed = 13516029; // Ganti dengan NIM anda sebagai seed.
	srand(seed);
	for (long i = 0; i < n; i++) {
		arr[i] = (int)rand();
	}
}

__global__
void generate_flags(int* arr, int n, int idx, int* flag) {

	int bit_test = 1 << idx;
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;

	for (int i = index; i < n; i += stride) {
		if ((arr[i] & bit_test) == bit_test) {
			flag[i] = 0;
		}
		else {
			flag[i] = 1;
		}
	}
}

int* generate_index_down(int* flag, int n) {
	int* index_down = (int*)malloc(n * sizeof(int));
	index_down[0] = 0;

	for (int i = 1; i < n; i++) {
		index_down[i] = index_down[i - 1] + flag[i - 1];
	}

	return index_down;
}

int* generate_index_up(int* flag, int n) {
	int* index_up = (int*)malloc(n * sizeof(int));
	index_up[n - 1] = n - 1;
	for (int i = n - 2; i >= 0; i--) {
		int diff;
		if (flag[i + 1]) {
			diff = 0;
		}
		else {
			diff = 1;
		}
		index_up[i] = index_up[i + 1] - diff;
	}
	return index_up;
}

__global__
void assign_permute(int n, int* arr, int* indexes, int* temps) {
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;

	for (int i = index; i < n; i += stride) {
		arr[indexes[i]] = temps[i];
	}
}

__global__
void permute(int* arr, int* flag, int* index_down, int* index_up, int* indexes, int n) {
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;

	for (int i = index; i < n; i += stride) {
		if (flag[i]) {
			indexes[i] = index_down[i];
		}
		else {
			indexes[i] = index_up[i];
		}
	}
}

void split(int n, int idx, int* d_arr) {
	int block_size = 256; // harus bisa dibagi 32
	int num_blocks = (block_size + n - 1) / block_size;

	int* d_flags;
	cudaMalloc(&d_flags, sizeof(int) * n);

	generate_flags<<<num_blocks, block_size>>>(d_arr, n, idx, d_flags);
	cudaDeviceSynchronize();

	int* flags = (int*)malloc(sizeof(int)*n);
	cudaMemcpy(flags, d_flags, sizeof(int), cudaMemcpyDeviceToHost);

	int* index_down = generate_index_down(flags, n);
	int* index_up = generate_index_up(flags, n);

	free(flags);

	int *d_temps, *d_arr_idx, *d_idx_down, *d_idx_up;
	cudaMalloc(&d_temps, sizeof(int)*n);
	cudaMemcpy(d_temps, d_arr, sizeof(int)*n, cudaMemcpyDeviceToDevice);

	cudaMalloc(&d_arr_idx, sizeof(int)*n);

	cudaMalloc(&d_idx_down, sizeof(int)*n);
	cudaMemcpy(d_idx_down, index_down, sizeof(int)*n, cudaMemcpyHostToDevice);

	cudaMalloc(&d_idx_up, sizeof(int)*n);
	cudaMemcpy(d_idx_up, index_up, sizeof(int)*n, cudaMemcpyHostToDevice);

	permute<<<num_blocks, block_size>>>(d_arr, d_flags, d_idx_down, d_idx_up, d_arr_idx, n);
	cudaDeviceSynchronize();

	assign_permute<<<num_blocks, block_size>>>(n, d_arr, d_arr_idx, d_temps);
	cudaDeviceSynchronize();

	cudaFree(d_temps);
	cudaFree(d_idx_down);
	cudaFree(d_idx_up);
	cudaFree(d_arr_idx);
	cudaFree(d_flags);
}

void radix_sort(int* arr, int n) {

	int max = n - 1;

	for (int i = 0; i < n; i++) {
		arr[i] = max;
		max--;
	}

	int* d_arr;
	cudaMalloc(&d_arr, sizeof(int) * n);
	cudaMemcpy(d_arr, arr, sizeof(int) * n, cudaMemcpyHostToDevice);

	for (int i = 0; i < 32; i++) {
		split(n, i, d_arr);
	}

	cudaMemcpy(arr, d_arr, sizeof(int) * n, cudaMemcpyDeviceToHost);
	cudaFree(d_arr);
}

// A utility function to print an array
void print(int* arr, int n)
{
	for (int i = 0; i < n; i++)
		printf("%d ", arr[i]);
}

int main(int argc, char** argv) {
	if (argc<2) {
		printf("Usage : radix_sort <array length>\n");
		return 0;
	}


	int n = atoi(argv[1]);
	int* arr = (int*)malloc(sizeof(int)*n);

	rng(arr, n);
	clock_t start = clock();
	radix_sort(arr, n);
	clock_t end = clock();
	print(arr, n);
	double total_time = ((double)(end - start)) / (CLOCKS_PER_SEC / 1000);
	printf("%f\n", total_time);


	// Tulis di file eksternal
	FILE *file = fopen("output.txt", "w");
	if (file == NULL)
	{
		printf("Error opening output.txt!\n");
		exit(1);
	}

	for (int i = 0; i < n; i++) {
		fprintf(file, "%d\n", arr[i]);
	}

	fclose(file);
	free(arr);
}
