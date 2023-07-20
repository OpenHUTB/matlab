




function compilerInfo=getCompilerInfo(feOpts)
    compilerInfo=struct(...
    'language','c',...
    'stdVersion','',...
    'compiler','',...
    'compilerVersion',0,...
    'targetTypes',[],...
    'dialect','');

    if strncmp(feOpts.Language.LanguageMode,'cxx',3)
        compilerInfo.language='c++';
    else
        compilerInfo.language='c';
    end

    compilerInfo.stdVersion=sldv.code.internal.getLanguageStdVersion(feOpts.Language.LanguageMode,feOpts.Language.LanguageExtra);

    compVerOpt='';
    if~isempty(find(strcmp(feOpts.Language.LanguageExtra,'--lcc'),1))
        compilerInfo.compiler='lcc';
    elseif~isempty(find(strcmp(feOpts.Language.LanguageExtra,'--clang'),1))
        compilerInfo.compiler='clang';
        compVerOpt='--clang_version';
    elseif~isempty(find(strcmp(feOpts.Language.LanguageExtra,'--gcc'),1))||...
        ~isempty(find(strcmp(feOpts.Language.LanguageExtra,'--g++'),1))
        compilerInfo.compiler='gcc';
        compVerOpt='--gnu_version';
    elseif~isempty(find(strcmp(feOpts.Language.LanguageExtra,'--microsoft'),1))
        compilerInfo.compiler='msvc';
        compVerOpt='--microsoft_version';
    end
    if~isempty(compVerOpt)
        idx=find(strncmp(feOpts.Language.LanguageExtra,compVerOpt,numel(compVerOpt)),1,'last');
        if~isempty(idx)
            compVer=regexp(feOpts.Language.LanguageExtra{idx},[compVerOpt,'=(\d+)'],'tokens','once');
            if numel(compVer)==1
                compilerInfo.compilerVersion=sscanf(compVer{1},'%d');
            elseif numel(feOpts.Language.LanguageExtra)>idx
                compilerInfo.compilerVersion=sscanf(feOpts.Language.LanguageExtra{idx+1},'%d');
            end
        end
    end
    compilerInfo.dialect=sldv.code.internal.getDialect(compilerInfo.compiler,compilerInfo.compilerVersion);
    compilerInfo.targetTypes=sldv.code.CodeAnalyzer.getTargetTypes(feOpts);


