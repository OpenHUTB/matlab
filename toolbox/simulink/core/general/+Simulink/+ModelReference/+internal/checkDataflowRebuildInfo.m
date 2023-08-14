function[upToDate,msg]=checkDataflowRebuildInfo(cachedInfo,tgtShortName,model,dir,buildArgs)




    msg=[];


    if isempty(cachedInfo)
        upToDate=true;
        return;
    end



    if(cachedInfo.isPartitioned&&(cachedInfo.numThreads>buildArgs.DataflowMaxThreads))
        msg=DAStudio.message('Simulink:slbuild:dataflowNumCoresChanged',tgtShortName,model);
        upToDate=false;
        return;
    end


    if(cachedInfo.isPartitioned)
        upToDate=true;
        return;
    end







    if Simulink.fileGenControl('GetParallelBuildInProgress')
        anchorDir=coder.internal.infoMATFileMgr('getParallelAnchorDir','SIM');
        dir=fullfile(anchorDir,dir);
    end


    matFileName=fullfile(dir,model,'tmwinternal',[model,'_DFCache.mat']);



    if~isfile(matFileName)
        msg=DAStudio.message('Simulink:slbuild:dataflowProfilingChanged',tgtShortName,model);
        upToDate=false;
        return;
    end

    isSimProfiled=true;


    mData=matfile(matFileName);
    varNames=who(mData);
    for i=1:numel(varNames)
        varName=varNames{i};
        if strcmpi(varName(1),'c')
            costData=eval(['mData.',varName]);
            isSimProfiled=isSimProfiled&&bitget(costData.Attributes,8);
        end
    end


    if isSimProfiled
        upToDate=false;
        msg=DAStudio.message('Simulink:slbuild:dataflowPartitioningChanged',tgtShortName,model);
        return;
    else



        cacheFolder=Simulink.fileGenControl('getinternalvalue','CacheFolder');
        if~strcmpi(cacheFolder,cachedInfo.cacheFolder)
            upToDate=false;
            msg=DAStudio.message('Simulink:slbuild:dataflowCacheFolderChanged',tgtShortName,model);
            return;
        end
    end

    upToDate=true;
end
