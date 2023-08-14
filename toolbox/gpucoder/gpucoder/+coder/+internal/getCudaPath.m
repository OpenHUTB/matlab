function defCudaPath=getCudaPath

    defCudaPath='';

    if ispc
        defCudaPath=strtrim(getenv('CUDA_PATH'));
    else
        [status,cmdout]=system('which nvcc');
        cmdout=strtrim(cmdout);
        cmdout=replace(cmdout,[filesep,filesep],filesep);
        if status==0&&~isempty(cmdout)
            nvccdir=fullfile('bin','nvcc');
            pos=strfind(cmdout,nvccdir);
            defCudaPath=cmdout(1:pos-2);
        end
    end

end