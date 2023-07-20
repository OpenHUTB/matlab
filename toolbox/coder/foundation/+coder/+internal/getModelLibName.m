function modelLibName=getModelLibName(model,mdlRefTgtType)












    if strcmpi(mdlRefTgtType,'RTW')
        addStr='_rtw';
    else
        addStr='';
    end


    modelLibName=regexprep(model,'(.*)',['$0',addStr,'lib']);
