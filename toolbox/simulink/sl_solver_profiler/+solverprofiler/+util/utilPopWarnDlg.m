
function hf=utilPopWarnDlg(message,tag)

    if length(findall(0,'type','figure','tag',tag))>0 %#ok<ISMT>
        return;
    end

    dlgName=DAStudio.message('MATLAB:uistring:popupdialogs:WarnDialogTitle');

    hf=msgbox(message,dlgName,'warn','non-modal');
    set(hf,'tag',tag);
    setappdata(hf,'DisplayMessage',message);
end
