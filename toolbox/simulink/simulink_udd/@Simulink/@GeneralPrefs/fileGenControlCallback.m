function fileGenControlCallback(~,dlg,tag)











    param=regexprep(tag,'Browse$','');



    if strcmp(param,'CacheFolder')
        uiTitle=DAStudio.message('Simulink:slbuild:CacheFolderBrowseTitle');
    else
        uiTitle=DAStudio.message('Simulink:slbuild:CodeGenFolderBrowseTitle');
    end


    curFold=dlg.getWidgetValue(param);
    f=uigetdir(curFold,uiTitle);


    if f
        dlg.setWidgetValue(param,f);
    end


