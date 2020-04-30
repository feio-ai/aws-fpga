#include "libspir_types.h"
#include "hls_stream.h"
#include "xcl_top_defines.h"
#include "ap_axi_sdata.h"
#define EXPORT_PIPE_SYMBOLS 1
#include "cpu_pipes.h"
#undef EXPORT_PIPE_SYMBOLS
#include "xcl_half.h"
#include <cstddef>
#include <vector>
#include <complex>
#include <pthread.h>
using namespace std;

extern "C" {

void monte_sim_dev(size_t in1, size_t in2, size_t out_r, int size);

static pthread_mutex_t __xlnx_cl_monte_sim_dev_mutex = PTHREAD_MUTEX_INITIALIZER;
void __stub____xlnx_cl_monte_sim_dev(char **argv) {
  void **args = (void **)argv;
  size_t in1 = *((size_t*)args[0+1]);
  size_t in2 = *((size_t*)args[1+1]);
  size_t out_r = *((size_t*)args[2+1]);
  int size = *((int*)args[3+1]);
 pthread_mutex_lock(&__xlnx_cl_monte_sim_dev_mutex);
  monte_sim_dev(in1, in2, out_r, size);
  pthread_mutex_unlock(&__xlnx_cl_monte_sim_dev_mutex);
}
void monte_sim(size_t in1, size_t in2, size_t out_r, int size);

static pthread_mutex_t __xlnx_cl_monte_sim_mutex = PTHREAD_MUTEX_INITIALIZER;
void __stub____xlnx_cl_monte_sim(char **argv) {
  void **args = (void **)argv;
  size_t in1 = *((size_t*)args[0+1]);
  size_t in2 = *((size_t*)args[1+1]);
  size_t out_r = *((size_t*)args[2+1]);
  int size = *((int*)args[3+1]);
 pthread_mutex_lock(&__xlnx_cl_monte_sim_mutex);
  monte_sim(in1, in2, out_r, size);
  pthread_mutex_unlock(&__xlnx_cl_monte_sim_mutex);
}
}
