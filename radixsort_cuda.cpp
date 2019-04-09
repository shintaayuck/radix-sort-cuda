#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cstring>

int rank, size;

void rng(int* arr, int n) {
	int seed = 13516110; // Ganti dengan NIM anda sebagai seed.
	srand(seed);

	for (long i = 0; i < n; i++) {
		arr[i] = (int)rand();
	}
}

int* generate_flags(const int* arr, int n, int idx) {
	int* flag = NULL;
	int bit_test = 1 << idx;

	int splitSize = n / size;
	int* splitArr = (int*)malloc(splitSize * sizeof(int));
	int* splitFlag = (int*)malloc(splitSize * sizeof(int));

	MPI_Scatter(arr, splitSize, MPI_INT, splitArr, splitSize, MPI_INT, 0, MPI_COMM_WORLD);

	if (rank == 0) {
		flag = (int*)malloc(n * sizeof(int));
	}

	for (int i = 0; i < splitSize; i++) {
		if ((splitArr[i] & bit_test) == bit_test) {
			splitFlag[i] = 0;
		}
		else {
			splitFlag[i] = 1;
		}
	}

	MPI_Gather(splitFlag, splitSize, MPI_INT, flag, splitSize, MPI_INT, 0, MPI_COMM_WORLD);

	free(splitArr);
	free(splitFlag);

	return flag;
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
		int diff = (flag[i + 1] ? 0 : 1);
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

void permute(int* arr, int* index_down, int* index_up, int* flag, int n) {
	int splitSize = n / size;
	int* splitIdx = (int*)malloc(splitSize * sizeof(int));
	int* splitIndexDown = (int*)malloc(splitSize * sizeof(int));
	int* splitIndexUp = (int*)malloc(splitSize * sizeof(int));
	int* splitFlag = (int*)malloc(splitSize * sizeof(int));

	int* temps = NULL;
	int* indexes = NULL;

	if (rank == 0) {
		temps = (int*)malloc(n * sizeof(int));
		indexes = (int*)malloc(n * sizeof(int));
		memcpy(temps, arr, n * sizeof(int));
	}

	MPI_Scatter(index_down, splitSize, MPI_INT, splitIndexDown, splitSize, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Scatter(index_up, splitSize, MPI_INT, splitIndexUp, splitSize, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Scatter(flag, splitSize, MPI_INT, splitFlag, splitSize, MPI_INT, 0, MPI_COMM_WORLD);

	for (int i = 0; i < splitSize; i++) {
		if (splitFlag[i]) {
			splitIdx[i] = splitIndexDown[i];
		}
		else {
			splitIdx[i] = splitIndexUp[i];
		}
	}

	MPI_Gather(splitIdx, splitSize, MPI_INT, indexes, splitSize, MPI_INT, 0, MPI_COMM_WORLD);

	if (rank == 0) {
		for (int i = 0; i < n; i++) {
			arr[indexes[i]] = temps[i];
		}
	}

	free(temps);
	free(indexes);
	free(splitIdx);
	free(splitIndexDown);
	free(splitIndexUp);
	free(splitFlag);
}

void split(int* arr, int n, int idx) {
	int* flag = NULL;
	int* index_down = NULL;
	int* index_up = NULL;

	flag = generate_flags(arr, n, idx);
	if (rank == 0) {
		index_down = generate_index_down(flag, n);
		index_up = generate_index_up(flag, n);
	}
	permute(arr, index_down, index_up, flag, n);
	MPI_Barrier(MPI_COMM_WORLD);

	free(flag);
	free(index_down);
	free(index_up);
}

void radix_sort(int* arr, int n) {
	for (int i = 0; i < 32; i++) {
		split(arr, n, i);
	}
}

void create_test(int* arr, int n) {
	int max = n - 1;

	for (int i = 0; i < n; i++) {
		arr[i] = max;
		max--;
	}
}

void print(int* arr, int n) {
	for (int i = 0; i < n; i++) {
		printf("%d ", arr[i]);
	}

	printf("\n");
}

int main(int argc, char* argv[]) {
	clock_t start, end;
	int n = atoi(argv[1]);
	int* arr = NULL;
	
	// initialize MPI
	MPI_Init(&argc, &argv);

	// get process size
	MPI_Comm_size(MPI_COMM_WORLD, &size);

	// get process rank
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	if (rank == 0) {
		arr = (int*)malloc(n * sizeof(int));
		rng(arr, n);
	}
	
	MPI_Barrier(MPI_COMM_WORLD);
	if (rank == 0) {
		start = clock();
	}
	radix_sort(arr, n);
	if (rank == 0) {
		end = clock();
	}
	MPI_Barrier(MPI_COMM_WORLD);
	
	if (rank == 0) {
		double total_time = ((double)(end - start)) / (CLOCKS_PER_SEC / 1000);
		printf("Time : %f\n", total_time);

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
	}
	
	MPI_Finalize();

	free(arr);
	return 0;
}
