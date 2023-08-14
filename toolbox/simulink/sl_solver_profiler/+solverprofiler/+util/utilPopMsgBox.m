
function hf=utilPopMsgBox(identifier,message,tag)

    if length(findall(0,'type','figure','tag',tag))>0 %#ok<ISMT>
        return;
    end

    if~isempty(identifier)
        hf=msgbox([identifier,'. ',message],identifier);
    else
        hf=msgbox(message);
    end
    set(hf,'tag',tag);
    setappdata(hf,'DisplayMessage',message);
end