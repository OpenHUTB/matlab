function dlg=findMemMapperDialog(mdl)
    if ishandle(mdl),mdl=getfullname(mdl);end
    dlg=findDDGByTitle(message('soc:workflow:ReviewMemoryMap_MemMapAppName',mdl).getString());
end
