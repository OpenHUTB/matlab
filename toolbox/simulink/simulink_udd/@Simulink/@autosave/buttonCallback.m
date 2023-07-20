function[success,errstring]=buttonCallback(obj,str)





    assert(numel(obj.files)==1);
    if strcmp(str,'restore')
        obj.filestate=0;
    elseif strcmp(str,'discard')
        obj.filestate=1;
    else
        assert(strcmp(str,'ignore'));
        obj.filestate=2;
    end
    [success,errstring]=obj.apply;

    if~success&&obj.numFiles==1


        d=DAStudio.DialogProvider;
        title=DAStudio.message('Simulink:dialog:autosaveDialogTitle');
        d.errordlg(errstring,title,true);
    end
