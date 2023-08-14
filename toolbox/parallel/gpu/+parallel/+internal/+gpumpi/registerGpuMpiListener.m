function registerGpuMpiListener









    addlistener(parallel.gpu.GPUDeviceManager.instance(),...
    'DeviceDeselecting',@parallel.internal.gpumpi.reset);

end
