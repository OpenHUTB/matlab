function ExportModel(mdlname)






    mdlname=get_param(mdlname,'Name');

    if bdIsDirty(mdlname)
        i_error(DAStudio.message('Simulink:Engine:InvSaveMdlBeforeSaveAs'));
        return;
    end

    if isempty(get_param(mdlname,'FileName'))
        i_error(DAStudio.message('Simulink:ExportPrevious:NoModelFile',mdlname));
        return;
    end

    [filename,version]=Simulink.ExportDialog(mdlname,true);
    if~isempty(filename)
        try
            Simulink.exportToVersion(mdlname,filename,version,'AllowPrompt',true);
        catch E

            if~strcmp(E.identifier,'Simulink:editor:DialogCancel')
                rethrow(E);
            end
        end
    end

end

function i_error(msg)
    title=DAStudio.message('Simulink:editor:FileDialogTitle_ExportToPreviousVersion');
    d=DAStudio.DialogProvider;
    d.errordlg(msg,title);
end


