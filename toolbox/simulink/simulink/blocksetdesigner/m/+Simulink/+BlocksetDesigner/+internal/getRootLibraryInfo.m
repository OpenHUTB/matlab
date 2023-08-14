function infos=getRootLibraryInfo(slblockfilepath)
    [libNames,libMdls,libFlat,toplevel,libTypes,libChoices,libChildren,libNewParents,libFcns]=...
    LibraryBrowser.internal.getLibInfo(char(slblockfilepath));
    infos='';
    if~isempty(libNames)&&~isempty(libMdls)
        infos={libNames{1},libMdls{1}};
    end
end

