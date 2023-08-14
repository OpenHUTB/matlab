function cc=getBestComputeCapability()






    cc=coder.GpuCodeConfig.DefaultComputeCapability;
    gDev=gpuDevice;
    if(~isempty(gDev))
        devCC=gDev.ComputeCapability;
        [devMajor,devMinor]=getCCMajorMinor(devCC);
        maxCC=coder.GpuCodeConfig.MaximumComputeCapability;
        [maxMajor,maxMinor]=getCCMajorMinor(maxCC);

        if devMajor>maxMajor||...
            (devMajor==maxMajor&&devMinor>maxMinor)
            cc=maxCC;
        else
            cc=devCC;
        end
    end
end

function[major,minor]=getCCMajorMinor(cc)
    majorMinor=strsplit(cc,'.');
    major=str2double(majorMinor{1});
    minor=str2double(majorMinor{2});
end
