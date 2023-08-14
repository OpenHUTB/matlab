function[infoType,value]=getReleaseName(source)




    infoType=message('simulink_comparisons:rptgen:SavedInVersion').getString;
    mdlInfo=Simulink.MDLInfo(source.Path);
    value=mdlInfo.ReleaseName;

end
