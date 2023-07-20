function shippingCudaLibs=getLinuxShippingCudaLibs()









    shippingCudaLibs=cell(1,6);
    libPath=fullfile(matlabroot,'bin','glnxa64');
    cudartFile=coder.gpu.internal.getShippingLibFullName('libcudart',libPath);
    assert(~isempty(cudartFile));
    shippingCudaLibs{1,1}=[':',cudartFile];
    cublasFile=coder.gpu.internal.getShippingLibFullName('libcublas',libPath);
    assert(~isempty(cublasFile));
    shippingCudaLibs{1,2}=[':',cublasFile];
    cusolverFile=coder.gpu.internal.getShippingLibFullName('libcusolver',libPath);
    if~isempty(cusolverFile)
        shippingCudaLibs{1,3}=[':',cusolverFile];
    end
    cufftFile=coder.gpu.internal.getShippingLibFullName('libcufft',libPath);
    if~isempty(cufftFile)
        shippingCudaLibs{1,4}=[':',cufftFile];
    end
    curandFile=coder.gpu.internal.getShippingLibFullName('libcurand',libPath);
    if~isempty(curandFile)
        shippingCudaLibs{1,5}=[':',curandFile];
    end
    cusparseFile=coder.gpu.internal.getShippingLibFullName('libcusparse',libPath);
    if~isempty(cusparseFile)
        shippingCudaLibs{1,6}=[':',cusparseFile];
    end
end
