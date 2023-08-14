function writeMetaData(configObj)




    metaData.modelName=configObj.getModelName();


    info=Simulink.MDLInfo(metaData.modelName);


    metaData.modelFileName=info.FileName;


    metaData.simulinkVersion=info.SimulinkVersion;


    if~isempty(info.ReleaseName)
        metaData.simulinkVersion=[metaData.simulinkVersion,' (',info.ReleaseName,')'];
    end


    v=ver('SLCI');
    metaData.slciVersion=[v.Version,' (',v.Release,')'];


    metaData.modelVersion=info.ModelVersion;



    mStamp=get_param(configObj.getModelName(),'LastModifiedDate');
    mdateformat=get_param(configObj.getModelName(),'ModifiedDateFormat');
    if strcmpi(mdateformat,'%<Auto>')

        dn=datenum(mStamp,'ddd mmm dd HH:MM:SS yyyy');
        metaData.modelTimeStamp=slci.internal.ReportUtil.setToDefaultFormat(dn);
    else

        metaData.modelTimeStamp=mStamp;
    end


    metaData.inspectionRunDate=slci.internal.ReportUtil.setToDefaultFormat(now);



    datamgr=configObj.getDataManager();
    datamgr.beginTransaction();
    try
        datamgr.setMetaData('ModelName',metaData.modelName);
        datamgr.setMetaData('ModelFileName',metaData.modelFileName);
        datamgr.setMetaData('ModelVersion',metaData.modelVersion);
        datamgr.setMetaData('SimulinkVersion',metaData.simulinkVersion);
        datamgr.setMetaData('SLCIVersion',metaData.slciVersion);
        datamgr.setMetaData('ModelTimeStamp',metaData.modelTimeStamp);
        datamgr.setMetaData('InspectionRunDate',metaData.inspectionRunDate);


        if~configObj.getTopModel()&&...
            configObj.getIncludeTopModelChecksumForRefModels()
            isTopModel=true;
            datamgr.setMetaData('TopModelChecksumForRef',...
            slci.internal.getModelChecksum(...
            configObj.getModelName(),isTopModel));


        end

    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();
end


