function files=generateIDLAndXMLFiles(modelName,buildInfo,bdir)






    files={};
    dd=get_param(modelName,'DataDictionary');
    ddConn=Simulink.data.dictionary.open(dd);
    ddsMf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddConn.filepath);

    xmlFileName=dds.internal.coder.getXmlFileName(modelName,buildInfo);
    [~,fileName,~]=fileparts(xmlFileName);

    idlFileName=[fileName,'.idl'];
    idlGen=dds.internal.simulink.IDLGenerator(ddsMf0Model,false);
    idlStr=idlGen.getStr;
    idlStr=dds.internal.coder.eProsima.convertIDLForFastrtps(idlStr);
    fd=fopen(fullfile(bdir,idlFileName),'w');
    fprintf(fd,'%s',idlStr);
    fprintf(fd,'\n');
    fclose(fd);
    files{1}=idlFileName;

    slrealtime.internal.dds.eprosima.exportToXMLBasedOnModel(fullfile(bdir,xmlFileName),modelName);
    files{2}=xmlFileName;

    buildInfo.addNonBuildFiles(idlFileName,bdir,'DDS_IDL');
    buildInfo.addNonBuildFiles(xmlFileName,bdir,'DDS_XML');
end
