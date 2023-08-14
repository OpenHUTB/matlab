function fastRestart(coveng)






    extraData=struct();
    if strcmp(get_param(coveng.topModelH,'CovUseTimeInterval'),'on')
        extraData.startRecTime=get_param(coveng.topModelH,'CovStartTime');
        extraData.stopRecTime=get_param(coveng.topModelH,'CovStopTime');
    end


    sfcnName2Info=coveng.slccCov.sfcnCov.sfcnName2Info;
    sfcnNames=sfcnName2Info.keys();
    for ii=1:numel(sfcnNames)
        sfcnInfo=sfcnName2Info(sfcnNames{ii});
        if isempty(sfcnInfo.dbFile)||isempty(sfcnInfo.instances)
            continue
        end
        allResFiles=unique({sfcnInfo.instances.dbFile});
        for jj=1:numel(allResFiles)
            internal.cxxfe.instrum.runtime.ResultHitsManager.updateExtraDatas(allResFiles{jj},extraData);
        end
    end
