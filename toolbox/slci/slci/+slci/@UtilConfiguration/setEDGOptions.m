

function setEDGOptions(aObj)


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
    end


    aObj.fEDGOptions.Preprocessor.SystemIncludeDirs{end+1}=...
    fullfile(root_include_dir,'include','include-libc');





    aObj.fEDGOptions.Preprocessor.Defines{end+1}='__OS_LINUX';



    aObj.fEDGOptions.Preprocessor.Defines{end+1}='__MW_I386__';
    aObj.fEDGOptions.Preprocessor.Defines{end+1}='__MW_GNU__';



    aObj.fEDGOptions.RemoveUnneededEntities=false;
    aObj.fEDGOptions.KeepCommentsPosition=true;
    aObj.fEDGOptions.KeepCommentsText=true;

    if~isempty(aObj.getTargetUtilsFolder)
        aObj.incrementHeaderPath(aObj.getTargetUtilsFolder);
    end
    if~isempty(aObj.getBaselineUtilsFolder)
        aObj.incrementHeaderPath(aObj.getBaselineUtilsFolder);
    end

    aObj.incrementHeaderPath(fullfile(matlabroot,'extern','include'));
end