function id=validateTextItemId(id)









    if isempty(id)
        return;
    elseif id(1)==':'
        return;
    elseif id(1)>='1'&&id(1)<='9'
        id=[':',id];
    elseif any(id==':')
        [~,id]=strtok(id,':');
    else
        rmiut.warnNoBacktrace('Slvnv:reqmgt:rmi:InvalidObject',id);

    end
end
