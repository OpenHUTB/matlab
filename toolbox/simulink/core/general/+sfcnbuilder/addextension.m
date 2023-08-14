function Name=addextension(name,LangExt)

    hasextension=findstr(name,'.');
    if(isempty(hasextension))
        Name=[name,'.',LangExt];
    else
        Name=name;
    end
end