function b=saveLinkSet(absoluteLinkFilePath)
    linkSet=slreq.find("Type","LinkSet",...
    "Filename",fullfile(absoluteLinkFilePath));

    if~isempty(linkSet)
        linkSet.save();
        b=true;
    else
        b=false;
    end
end
