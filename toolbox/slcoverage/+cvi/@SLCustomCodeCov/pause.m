function pause(coveng,modelH)









    if~coveng.isLastReporting(modelH)
        return
    end


    cvi.SFunctionCov.pause(coveng);


    if~SlCov.isSLCustomCodeCovFeatureOn()
        return
    end


    libNames=coveng.slccCov.libName2Info.keys();
    numLibs=numel(libNames);
    dbInfo=cell(numLibs,2);
    for ii=1:numLibs
        libInfo=coveng.slccCov.libName2Info(libNames{ii});
        if isempty(libInfo.dbFile)||isempty(libInfo.instances)
            continue
        end
        dbInfo{ii,1}=libInfo.dbFile;
        dbInfo{ii,2}={libInfo.instances.dbFile};
        for jj=1:numel(dbInfo{ii,2})
            internal.cxxfe.instrum.runtime.ResultHitsManager.stopRecord(dbInfo{ii,2}{jj},'');
        end
    end


    cvi.SLCustomCodeCov.addResults(coveng);
    cvi.SLCustomCodeCov.updateResults(coveng,true);


    for ii=1:numLibs
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


