#include <iostream>
#include <algorithm>
#include <cstdint>

using namespace std;

uint64_t rdtsc() {
   uint32_t hi, lo;
   __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
   return static_cast<uint64_t>(lo)|(static_cast<uint64_t>(hi)<<32);
}

#include <sys/time.h>

static inline double gettime(void) {
   struct timeval now_tv;
   gettimeofday (&now_tv, NULL);
   return ((double)now_tv.tv_sec) + ((double)now_tv.tv_usec)/1000000.0;
}

uint64_t n;
uint64_t* v;
uintptr_t rep;
unsigned ool;

static double benchmarkLatency() {
   uint64_t start=rdtsc();
   uint64_t x[100];
   for (unsigned j=0; j<ool; j++)
      x[j]=j;
   for (uint64_t i=0; i<rep; i++) {
      for (unsigned j=0; j<ool; j++) {
         x[j]=v[x[j]];
      }
   }

   uint64_t sum=0;
   for (unsigned j=0; j<ool; j++)
      sum+=x[j];

   uint64_t end=rdtsc();
   cout << "Result: " << (end-start)/(double)rep << " "<< sum << endl;

   return (end-start)/(double)rep;
}

int main(int argc, char** argv) {

   n=atof(argv[1]);
   rep=atof(argv[2]);
   ool=atof(argv[3]);

   uint64_t* v2=new uint64_t[n];
   for (uint64_t i=0; i<n;i++)
      v2[i]=i;
   random_shuffle(v2,v2+n);

   v=new uint64_t[n];
   for (uint64_t i=0; i<n;i++)
      v[v2[i]]=v2[(i+1)%n];

   double start=gettime();
   auto result = benchmarkLatency();
   auto duration = (gettime()-start);

   cout << "final: " << n << " ";
   cout << ((ool*8*rep)/(1024.0*1024.0*1024.0))/duration << "GB/s ";
   cout << (duration*1.0e9)/(ool*rep)  << " ";
   cout << ((duration*1e9)/rep) << "ns" << endl;
   return 0;
}
