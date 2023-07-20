function value=gpu(value)






    persistent gpuAvailable;
    if isempty(gpuAvailable)
        gpuAvailable=false;
        mlock;
    end

    if(strcmp(value,'on')==1)&&~gpuAvailable
        try
            if~isempty(which('parallel.gpu.GPUDevice.isAvailable'))
                gpuAvailable=parallel.gpu.GPUDevice.isAvailable();
                if gpuAvailable


                    g=gpuDevice(1);
                    reset(g);
                    clear g;
                end
            end
        catch
        end
    elseif strcmp(value,'off')==1
        gpuAvailable=false;
    else

        if gpuAvailable
            value='on';
        else
            value='off';
        end
    end

end
