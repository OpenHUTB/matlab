function pause(coveng)








    sfcnName2Info=coveng.slccCov.sfcnCov.sfcnName2Info;
    sfcnNames=sfcnName2Info.keys();
    numSFcn=numel(sfcnNames);
    dbInfo=cell(numSFcn,2);
    for ii=1:numSFcn
        sfcnInfo=sfcnName2Info(sfcnNames{ii});
        if isempty(sfcnInfo.dbFile)||isempty(sfcnInfo.instances)
            continue
        end
        dbInfo{ii,1}=sfcnInfo.dbFile;
        dbInfo{ii,2}={sfcnInfo.instances.dbFile};
        for jj=1:numel(dbInfo{ii,2})
            internal.cxxfe.instrum.runtime.ResultHitsManager.stopRecord(dbInfo{ii,2}{jj},'');
        end
    end


    allModelcovIds=coveng.getAllModelcovIds();
    for ii=1:numel(allModelcovIds)
        cvi.SFunctionCov.addResults(coveng,allModelcovIds(ii));
    end


    for ii=1:numSFcn
        if isempty(dbInfo{ii,1})
            continue
        end
        trDbFile=dbInfo{ii,1};
        allResFiles=dbInfo{ii,2};
        cellfun(@delete,unique(allResFiles));
        for jj=1:numel(allResFiles)
            internal.cxxfe.instrum.runtime.ResultHitsManager.startRecord(trDbFile,allResFiles{jj},'');
        end
    end
