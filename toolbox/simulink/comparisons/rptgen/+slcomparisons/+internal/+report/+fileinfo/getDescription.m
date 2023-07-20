function[infoType,value]=getDescription(source)




    infoType=message('simulink_comparisons:rptgen:ModelDescription').getString;
    mdlInfo=Simulink.MDLInfo(source.Path);
    value=mdlInfo.Description;

end
