function lst=getCompilerOptions(ProjectBuildInfo,expandTokens)



    delim=ProjectBuildInfo.mIncludePathDelimiter;

    if nargin==1
        expandTokens=false;
    end
    inc=ProjectBuildInfo.mBuildInfo.getIncludePaths(expandTokens);

    lst='';

    for i=1:length(inc)
        inc{i}=getAbsolutePath(inc{i},ProjectBuildInfo);
        if~isempty(inc{i})
            lst=[lst,delim,'"',inc{i},'" '];%#ok<AGROW>
        end
    end

    for i=1:length(ProjectBuildInfo.mBuildInfo.Options.CompileFlags)
        str=ProjectBuildInfo.mBuildInfo.Options.CompileFlags(i).Value;
        lst=[lst,' ',str,' '];%#ok<AGROW>
    end

    delim=ProjectBuildInfo.mPreprocSymbolDelimiter;

    for i=1:length(ProjectBuildInfo.mBuildInfo.Options.Defines)
        str=[ProjectBuildInfo.mBuildInfo.Options.Defines(i).Key,'='...
        ,ProjectBuildInfo.mBuildInfo.Options.Defines(i).Value];
        lst=[lst,' ',delim,'"',str,'" '];%#ok<AGROW>
    end

    function pathName=getAbsolutePath(pathName,ProjectBuildInfo)
        if isRelativePath(pathName)
            pathName=fullfile(ProjectBuildInfo.mCodeGenDir,pathName);
        end

        function resp=isRelativePath(pathName)
            idx=strfind(pathName,['..',filesep]);
            resp=(~isempty(idx)&&idx(1)==1);