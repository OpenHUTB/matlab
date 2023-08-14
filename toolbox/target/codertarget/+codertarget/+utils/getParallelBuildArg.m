function ret=getParallelBuildArg(hCS)




    data=codertarget.data.getData(hCS);
    ret=0;
    if isfield(data,'Runtime')
        if isfield(data.Runtime,'DisableParallelBuild')
            disableParallelBuild=data.Runtime.DisableParallelBuild;
            if disableParallelBuild==0
                maxCores=codertarget.utils.getMaxPhysicalCores;
                ret=maxCores+1;
            end
        end
    end
end