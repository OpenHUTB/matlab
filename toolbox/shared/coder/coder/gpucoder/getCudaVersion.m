function[defCudaVer,nvccFound,nvccCudaVer]=getCudaVersion


    defCudaVer='11';
    nvccFound=false;
    nvccCudaVer=[];

    cudaCmd='nvcc --version';
    [nvccStatus,cmdout]=system(cudaCmd);
    if(~nvccStatus)
        toks=regexp(cmdout,'V(\d+).(\d+).(\d+)','tokens');
        vers=toks{1};
        nvccCudaVer=vers{1};
        nvccFound=true;
    end

end