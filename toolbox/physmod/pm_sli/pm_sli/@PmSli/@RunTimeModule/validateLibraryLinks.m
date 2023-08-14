function validateLibraryLinks(this,mdl)




    validateFcn=pmsl_private('pmsl_verifylibrarylinks');

    blockList=validateFcn(mdl);

    if~isempty(blockList)
        configData=RunTimeModule_config;
        errorData=configData.Error;
        blockNames=sprintf('''%s''',blockList{1});
        for idx=2:numel(blockList)
            blockNames=sprintf('%s\n''%s''',blockNames,blockList{idx});
        end
        pm_error(errorData.UnresolvedLibraryLinks_templ_msgid,blockNames);
    end

end


