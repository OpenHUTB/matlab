function linkType=getLinktype(sys,doc)







    ext='';
    if strcmp(sys,'other')
        if~isempty(doc)
            [~,~,ext]=fileparts(doc);
            linkType=rmi.linktype_mgr('resolveByFileExt',ext);
        else
            linkType=[];
        end
    else
        linkType=rmi.linktype_mgr('resolveByRegName',sys);
    end

    if isempty(linkType)
        if~strcmp(sys,'other')
            error(message('Slvnv:reqmgt:getLinktype:UnregisteredTarget',sys));
        elseif isempty(ext)
            error(message('Slvnv:reqmgt:getLinktype:UnknownFileType',doc));
        else
            error(message('Slvnv:reqmgt:getLinktype:UnregisteredExt',ext));
        end
    end

