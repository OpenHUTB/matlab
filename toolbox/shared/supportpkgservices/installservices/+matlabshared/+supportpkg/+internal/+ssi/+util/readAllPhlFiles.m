function allPhlEntries=readAllPhlFiles(spRoot)












    validateattributes(spRoot,{'char'},{'nonempty'},'readAllPhlFiles','spRoot',1);
    assert(logical(exist(spRoot,'dir')),sprintf('spRoot directory: %s does not exist',spRoot));
    pathToPhlFiles=fullfile(spRoot,'toolbox','local','path');
    allPhlEntries={};

    if~exist(pathToPhlFiles,'dir')
        return;
    end


    phlFiles=dir(fullfile(pathToPhlFiles,'*.phl'));
    for i=1:numel(phlFiles)
        [fid,message]=fopen(fullfile(pathToPhlFiles,phlFiles(i).name),'r');
        if(fid<=0)



            warning('Unable to open PHL files: %s',message);
            continue;
        end
        lines=textscan(fid,'%s','commentStyle','%');
        allPhlEntries=[allPhlEntries;lines{1}];%#ok<AGROW>
        fclose(fid);
    end
    allPhlEntries=cellfun(@(x)fullfile(spRoot,x),allPhlEntries,'UniformOutput',false);
end
