function val=isGpuAvailable()




    try
        if~isempty(which('parallel.gpu.GPUDevice.isAvailable'))
            val=parallel.gpu.GPUDevice.isAvailable;
        else
            val=false;
        end
    catch
        val=false;
    end

end
