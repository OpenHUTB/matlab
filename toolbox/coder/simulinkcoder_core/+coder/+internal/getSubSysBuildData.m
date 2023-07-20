function[topHdl,subSys]=getSubSysBuildData(modelName)




    hMdl=get_param(modelName,'handle');
    ssHdl=rtwprivate('getSourceSubsystemHandle',hMdl);
    if isempty(ssHdl)
        topHdl=modelName;
        subSys=modelName;
    else
        topHdl=bdroot(ssHdl);
        subSys=getfullname(ssHdl);
    end

