function ComputeHeaderPath(aObj)





    if(~aObj.fUseCustomerSetting)


        aObj.setDefaultEDGOptions();
        root_include_dir=fullfile(matlabroot,'polyspace','verifier','cxx');

        if(strcmpi(aObj.getTargetLangSuffix(),'.cpp'))

            aObj.fEDGOptions.Language.LanguageMode='cxx';

            aObj.fEDGOptions.Language.LanguageExtra{end+1}='--enable_decltype';
            aObj.fEDGOptions.Language.LanguageExtra{end+1}='-tused';
            aObj.fEDGOptions.Language.LanguageExtra{end+1}='--type_traits_helpers';
            aObj.fEDGOptions.Language.LanguageExtra{end+1}='--g++';
            aObj.fEDGOptions.Language.LanguageExtra{end+1}='--c++11';

            aObj.fEDGOptions.Preprocessor.SystemIncludeDirs{end+1}=...
            fullfile(root_include_dir,'include','include-libcxx');

            aObj.fEDGOptions.Preprocessor.Defines{end+1}='__MW_POLYSPACE__';
        else
            aObj.fEDGOptions.Language.LanguageExtra{end+1}='--gcc';



            if aObj.fUseCustomParserOptions
                aObj.appendExtraEDGOptions();
            end
        end

        aObj.fEDGOptions.Preprocessor.SystemIncludeDirs{end+1}=...
        fullfile(root_include_dir,'include','include-libc');





        aObj.fEDGOptions.Preprocessor.Defines{end+1}='__OS_LINUX';



        aObj.fEDGOptions.Preprocessor.Defines{end+1}='__MW_I386__';
        aObj.fEDGOptions.Preprocessor.Defines{end+1}='__MW_GNU__';
    end


    aObj.fEDGOptions.RemoveUnneededEntities=false;
    aObj.fEDGOptions.KeepCommentsPosition=true;
    aObj.fEDGOptions.KeepCommentsText=true;



    build_info=aObj.loadBuildInfoFile();

    include_paths=build_info.buildInfo.getIncludePaths(true);
    for i=1:numel(include_paths)
        include_path=include_paths{i};

        if~slci.internal.isAbsolutePath(include_path)
            include_path=fullfile(aObj.getDerivedCodeFolder(),...
            include_path);
        end
        aObj.incrementHeaderPath(include_path);
    end

    [modelPath,~,~]=fileparts(which(aObj.getModelName()));
    aObj.incrementHeaderPath(modelPath);
    aObj.incrementHeaderPath(pwd);
    aObj.incrementHeaderPath(aObj.getDerivedCodeFolder());
    sharedUtilsPath=aObj.SharedUtilitiesFolder();
    if~isempty(sharedUtilsPath)
        aObj.incrementHeaderPath(sharedUtilsPath);
    end
    refMdls=aObj.getRefMdls();
    for i=1:numel(refMdls)
        childModelPath=aObj.ChildModelFolder(refMdls{i});
        if~isempty(childModelPath)
            aObj.incrementHeaderPath(childModelPath);
        end
    end
    aObj.incrementHeaderPath(fullfile(matlabroot,'extern','include'));
end


