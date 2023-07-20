function dev=buildCUDADevice(idx)
    ;%#ok undocumented



    dev=parallel.gpu.CUDADevice.hBuild(idx);

end
