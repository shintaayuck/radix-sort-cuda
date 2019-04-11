all: radixsort_cuda.cu
    nvcc radixsort_cuda.cu -o radix_sort

run: radixsort_cuda.cu
    nvcc radixsort_cuda.cu -o radix_sort
	./radix_sort
