function sz=getGPUDataTypeSize(gpuDT)









    switch(gpuDT)
    case 'double'
        sz=8;
    case 'float'
        sz=4;
    otherwise
        dt=regexprep(gpuDT,'unsigned ','');
        sz=feval('_gpu_getCTypeSize',dt);
    end
end


