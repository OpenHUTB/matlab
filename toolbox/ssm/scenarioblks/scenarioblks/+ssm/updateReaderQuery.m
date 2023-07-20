function updateReaderQuery()

    maskObj=Simulink.Mask.get(gcb);
    tableControl=maskObj.getDialogControl('queryTable');
    temp=get_param(gcb,'queryTable');
    query=strrep(strrep(regexprep(temp,'[,{}'''' ]',''),'Dialog',''),';','&&');
    set_param(gcb,'QueryString',query);
end

