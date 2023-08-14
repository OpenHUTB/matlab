function[resolved,is_relative]=resolveDoc(doc,sys,ref)





    linkType=rmi.linktype_mgr('resolveByRegName',sys);
    if isempty(linkType)
        linkType=rmi.linktype_mgr('resolveByFileExt',doc);
    end
    if~isempty(linkType)&&~isempty(linkType.ResolveDocFcn)
        [resolved,is_relative]=feval(linkType.ResolveDocFcn,doc,ref);
    elseif isempty(linkType)||linkType.IsFile
        resolved=rmi.locateFile(doc,ref);
        is_relative=~strcmp(doc,resolved);
    else
        resolved='';
        is_relative=false;
    end

end
