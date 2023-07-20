function out=getDialogTitle(hSrc)




    if isempty(hSrc.getModel)
        title_path='';
        title_state=hSrc.Name;
    else
        title_path=[get_param(hSrc.getModel,'Name'),'/',hSrc.Name,' '];
        if hSrc.isActive
            title_state=message('RTW:configSet:titleStrActive').getString;
        else
            title_state=message('RTW:configSet:titleStrInactive').getString;
        end
    end
    if isa(hSrc,'Simulink.ConfigSetRef')
        title=message('RTW:configSet:refTitleCp').getString;
    else
        title=message('RTW:configSet:titleCp').getString;
    end
    out=[title,' ',title_path,title_state];


