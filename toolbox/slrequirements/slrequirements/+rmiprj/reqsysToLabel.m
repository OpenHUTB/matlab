function typeLabel=reqsysToLabel(doc,type)




    if ischar(doc)
        typeLabel=convertOne(doc,type);
    else

        typeLabel=cell(size(doc));
        for i=1:length(doc)
            typeLabel{i}=convertOne(doc{i},type{i});
        end
    end
end

function typeLabel=convertOne(doc,type)

    objectLabelCheck=false;
    if ischar(type)
        if strcmp(type,'other')
            linktype=rmi.linktype_mgr('resolveByFileExt',doc);
        else
            linktype=rmi.linktype_mgr('resolveByRegName',type);
            objectLabelCheck=true;
        end
    else
        linktype=type;
    end

    if isempty(linktype)
        typeLabel=type;
        return;
    else
        typeLabel=linktype.Label;
    end

    if objectLabelCheck

        typeLabel=regexprep(typeLabel,' Object$','');
    end
end
