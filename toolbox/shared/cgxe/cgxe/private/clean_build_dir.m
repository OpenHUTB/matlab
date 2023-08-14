function clean_build_dir(moduleChkSumStrings,targetDir,rebuildAll)



    if rebuildAll
        cgxe_delete_file(fullfile(targetDir,'*.*'));
        return;
    end



    dirStruct=dir(targetDir);
    fileNames={dirStruct.name};


    matchIdx=~cellfun('isempty',regexp(fileNames,...
    '^m_\w+((?<!(_cgxe(_registry)?))\.(c|h|o))'));
    moduleFiles=fileNames(matchIdx);



    for i=1:numel(moduleFiles)
        oldCheckSum=regexp(moduleFiles{i},'^m_(\w+)\.\w+','tokens','once');
        if~ismember(oldCheckSum,moduleChkSumStrings)
            delete(fullfile(targetDir,moduleFiles{i}));
        end
    end
end