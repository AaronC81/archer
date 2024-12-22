FROM ubuntu:24.10 AS llvm-build

# Install dependencies
RUN apt-get update && apt-get install -y build-essential cmake make git python3

# Build TableGen on mainline LLVM
WORKDIR /llvm/mainline
RUN git clone --branch release/17.x https://github.com/llvm/llvm-project.git
WORKDIR /llvm/mainline/build
RUN cmake ../llvm-project/llvm -DCMAKE_BUILD_TYPE=Debug
RUN cmake --build . --target llvm-tblgen

# Check out TriCore fork
WORKDIR /llvm/tricore
RUN git clone https://github.com/TriDis/llvm-tricore.git
WORKDIR /llvm/tricore/llvm-tricore
RUN git checkout 4bfc5ee073becdcf799978431a9c03045b1091a2

# Check out J2 fork, applying required patch for mainline usage
WORKDIR /llvm/j2
RUN git clone https://github.com/francisvm/j2-llvm.git
WORKDIR /llvm/j2/j2-llvm
RUN git checkout a7d626727c7cd5935e43417d6ec7c2991a04c96b
COPY container/j2-llvm.patch ..
RUN git apply ../j2-llvm.patch

# Copy dump script
WORKDIR /script
COPY container/dump.sh .
