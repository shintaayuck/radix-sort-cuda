#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void rng(int* arr, int n) {
    int seed = 13516110; // Ganti dengan NIM anda sebagai seed.
    srand(seed);
    for(long i = 0; i < n; i++) {
        arr[i] = (int)rand();
    }
}

__global__
void generate_flags(int* arr, int n, int idx, int* flag) {

    int bit_test = 1 << idx;
	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;

    for (int i = index; i < n; i+=stride) {
        if ((arr[i] & bit_test) == bit_test) {
            flag[i] = 0;
        } else {
            flag[i] = 1;
        }
    }
    return flag;
}

int* generate_index_down(int* flag, int n) {
    int* index_down = (int*) malloc(n * sizeof(int));
    index_down[0] = 0;

    for (int i = 1; i < n; i++) {
        index_down[i] = index_down[i-1] + flag[i-1];
    }

    return index_down;
}

int* generate_index_up(int* flag, int n) {
    int* index_up = (int*) malloc(n * sizeof(int));
    index_up[n-1] = n-1;
    for (int i = n-2; i >=0; i--) {
        int diff;
        if (flag[i+1]) {
            diff = 0;
        } else {
            diff = 1;
        }
        index_up[i] = index_up[i+1] - diff;
    }
    return index_up;
}

__global__
void permute(int* arr, int* temps, int* flag, int* index_down, int* index_up, int* arr_idx int n) {

	int index = blockIdx.x * blockDim.x + threadIdx.x;
	int stride = blockDim.x * gridDim.x;

    for (i = index; i < n; i+=stride) {
        if (flag[i]) {
            indexes[i] = index_down[i];
        } else {
            indexes[i] = index_up[i];
        }
    }
	cudaDeviceSynchronize();

    for (i = index; i < n; i+=stride) {
        arr[indexes[i]] = temps[i];
    }

}

void split(int n, int idx, int* d_arr) {
    // assign flags
	int* flags, d_flags;
	cudaMalloc(&d_flags, sizeof(int) * n);

	int block_size = 256; // harus bisa dibagi 32
	int num_blocks = block_size + n - 1;

    generate_flags<<<num_blocks, block_size>>>(d_arr, n, idx, d_flags);
	cudaDeviceSynchronize();

	flags = (int*) malloc(sizeof(int)*n);
	cudaMemcpy(flags, d_flags, sizeof(int), cudaMemcpyDeviceToHost);

    int* index_down = generate_index_down(flag, n);
    int* index_up = generate_index_up(flag, n);

	int *d_temps, *d_arr_idx, *d_idx_down, *d_idx_up;
	cudaMalloc(&d_temps, sizeof(int)*n);
	cudaMemcpy(d_temps, d_arr, sizeof(int)*n, cudaMemcpyDeviceToDevice);

	cudaMalloc(&d_arr_idx, sizeof(int)*n);

	cudaMalloc(&d_idx_down, sizeof(int)*n);
	cudaMemcpy(d_idx_down, index_down, sizeof(int)*n, cudaMemcpyHostToDevice);

	cudaMalloc(&d_idx_up, sizeof(int)*n);
	cudaMemcpy(d_idx_up, index_up, sizeof(int)*n, cudaMemcpyHostToDevice);

    permute<<<num_blocks, block_size>>>(d_arr, d_temps, flag, d_index_down, d_index_up, d_arr_idx, n);
	cudaDeviceSynchronize();

	cudaFree(d_flags);
	cudaFree(d_temps);
	cudaFree(d_idx_down);
	cudaFree(d_idx_up);
	cudaFree(d_arr_idx);

	free(flags);
}


void radix_sort(int* arr, int n, int* d_arr) {

	cudaMalloc(&d_arr, sizeof(int) * n);
	cudaMemcpy(d_arr, sizeof(int) * n, cudaMemcpyHostToDevice);

    for (int i=0; i<32; i++) {
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
  // if (argc<2) {
  //   printf("Usage : radix_sort <array length>\n");
  //   return 0;
  // }


  // int n = atoi(argv[1]);
  int n = 1000;
  int* arr = (int*) malloc(sizeof(int)*n);

  rng(arr, n);
  clock_t start = clock();
  radix_sort(arr,n);
  print(arr, n);
  clock_t end = clock();
  double total_time = ((double) (end - start)) / (CLOCKS_PER_SEC / 1000);
  // print(arr, n);
  printf("%f\n", total_time);


  // Tulis di file eksternal
  // FILE *file = fopen("output.txt", "w");
  // if (file == NULL)
  // {
  //     printf("Error opening output.txt!\n");
  //     exit(1);
  // }
  //
  // for (int i = 0; i < n; i++){
  //     fprintf(file, "%d\n", arr[i]);
  // }
  //
  // fclose(file);
  free(arr);
}
