function[cpuinfo,gpuinfo]=saveMachineInfo(isWorker)

    warnState=warning('query','all');
    warning('off','MATLAB:structOnObject');
    cleanupObj=onCleanup(@()warning(warnState));

    cpuinfo=experiments.internal.getCPUInfo;
    gpuinfo=[];
    if matlab.internal.parallel.isPCTInstalled&&matlab.internal.parallel.isPCTLicensed
        if gpuDeviceCount>0
            for gpuIndex=1:gpuDeviceCount
                gpuinfo=[gpuinfo,struct(gpuDevice(gpuIndex))];
            end
        end
        if isWorker
            gpuinfoWithWorkerInfo=[];
            workerName=experiments.internal.getWorkerName();
            cpuinfo=cell2struct([{workerName};struct2cell(cpuinfo);],['WorkerName';fieldnames(cpuinfo)]);
            for gpuIndex=1:gpuDeviceCount
                gpuinfoWithWorkerInfo=[gpuinfoWithWorkerInfo,cell2struct([{workerName};struct2cell(gpuinfo(gpuIndex));],['WorkerName';fieldnames(gpuinfo(gpuIndex))])];
            end
            gpuinfo=gpuinfoWithWorkerInfo;
        end
    end
end

