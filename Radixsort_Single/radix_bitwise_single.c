#include <stdio.h>
#include <stdlib.h>
#include<time.h>

void rng(int* arr, int n) {
    int seed = 13516110; // Ganti dengan NIM anda sebagai seed.
    srand(seed);
    for(long i = 0; i < n; i++) {
        arr[i] = (int)rand();
    }
}

int* generate_flags(int* arr, int n, int idx) {
    int* flag = malloc(n * sizeof(int));
    int bit_test = 1 << idx;

    int i;
    for (i = 0; i < n; i++) {
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

void permute(int* arr, int* flag, int* index_down, int* index_up, int n) {
    int i;
    int* indexes = (int*) malloc(n * sizeof(int));
    int* temps = (int*) malloc(n * sizeof(int));

    for (i = 0; i < n; i++) {
        if (flag[i]) {
            indexes[i] = index_down[i];
        } else {
            indexes[i] = index_up[i];
        }
    }

    for (i = 0; i < n; i++) {
        temps[i] = arr[i];
    }

    for (i = 0; i < n; i++) {
        arr[indexes[i]] = temps[i];
    }
}

void split(int* arr, int n, int idx) {
    int* flag = generate_flags(arr, n, idx);
    int* index_down = generate_index_down(flag, n);
    int* index_up = generate_index_up(flag, n);

    permute(arr, flag, index_down, index_up, n);
}


void radix_sort(int* arr, int n) {
    for (int i=0; i<32; i++) {
      split(arr, n, i);
    }
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
  int* arr = (int*) malloc(sizeof(int)*n);

  rng(arr, n);
  clock_t start = clock();
  radix_sort(arr,n);
  clock_t end = clock();
  double total_time = ((double) (end - start)) / (CLOCKS_PER_SEC / 1000);
  // print(arr, n);
  printf("%f\n", total_time);

  // Tulis di file eksternal
  FILE *file = fopen("output.txt", "w");
  if (file == NULL)
  {
      printf("Error opening output.txt!\n");
      exit(1);
  }

  for (int i = 0; i < n; i++){
      fprintf(file, "%d\n", arr[i]);
  }

  fclose(file);
  free(arr);
}
