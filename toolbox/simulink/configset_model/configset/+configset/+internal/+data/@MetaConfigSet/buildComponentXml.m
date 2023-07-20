function componentDataModel=buildComponentXml(xmlFile,type,outputDir)




    [~,name,~]=fileparts(xmlFile);
    matFile=fullfile(outputDir,[name,'.mat']);
    componentDataModel=configset.internal.data.MetaConfigSet.parseComponentXml(xmlFile);
    componentDataModel.Type=type;
    componentDataModel.setup;
    save(matFile,'componentDataModel');
