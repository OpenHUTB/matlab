function utilPopErrDlg(identifier,message,tag)

    if length(findall(0,'type','figure','tag',tag))>0 %#ok<ISMT>
        return;
    end

    hf=errordlg(message,identifier);
    set(hf,'tag',tag);
    setappdata(hf,'DisplayMessage',message);
end