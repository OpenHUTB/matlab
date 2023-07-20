function[infoType,value]=getModelVersion(source)




    infoType=message('simulink_comparisons:rptgen:ModelVersion').getString;
    mdlInfo=Simulink.MDLInfo(source.Path);
    value=mdlInfo.ModelVersion;

end
