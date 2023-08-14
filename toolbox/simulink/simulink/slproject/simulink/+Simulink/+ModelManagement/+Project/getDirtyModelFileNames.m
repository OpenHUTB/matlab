function dirtyModelFileNames=getDirtyModelFileNames()




    allBDs=Simulink.allBlockDiagrams();
    dirtyModelFileNames=get_param(...
    allBDs(strcmpi(get_param(allBDs,'Dirty'),'on')),...
    'FileName');
    dirtyModelFileNames=cellstr(dirtyModelFileNames);
    dirtyModelFileNames=dirtyModelFileNames(~cellfun(@isempty,dirtyModelFileNames));
end
