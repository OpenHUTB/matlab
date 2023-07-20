function emitProject(h,ProjectBuildInfo)




    projectName=fullfile(pwd,ProjectBuildInfo.mProjectName);


    warn_state=warning;
    warning off;%#ok<WNOFF>
    try
        h.close(projectName,'project');
    catch clException %#ok<NASGU>
    end
    warning(warn_state);


    if(strcmp(ProjectBuildInfo.mBuildAction,'Archive_library'))
        h.new(projectName,'projlib');
    else
        h.new(projectName,'project');
    end


    h.new([ProjectBuildInfo.mBuildConfig,'MW'],'buildcfg');


    SetBuildOptions(h,ProjectBuildInfo);


    AddSourceFiles(h,ProjectBuildInfo);


    AddLibraryFiles(h,ProjectBuildInfo);

    ModifyBuildOptions(h,ProjectBuildInfo);


    function AddSourceFiles(h,ProjectBuildInfo)
        srcs=ProjectBuildInfo.mBuildInfo.getSourceFiles(true,true);
        tokens=ProjectBuildInfo.mTokens;
        for i=1:length(srcs)
            if~isempty(srcs{i})
                src=tgtLibEvalTokens(srcs{i},tokens,'src',true);
                h.add(src);
            end
        end


        function AddLibraryFiles(h,ProjectBuildInfo)
            libs={};
            tokens=ProjectBuildInfo.mTokens;

            for i=1:length(ProjectBuildInfo.mBuildInfo.LinkObj)
                libPath=formatPaths(ProjectBuildInfo.mBuildInfo,ProjectBuildInfo.mBuildInfo.LinkObj(i).Path,'format','expanded');
                libs{i}=fullfile(libPath,ProjectBuildInfo.mBuildInfo.LinkObj(i).Name);%#ok<AGROW>
            end

            for i=1:length(libs)
                if~isempty(libs)
                    lib=tgtLibEvalTokens(libs{i},tokens,'src',true);
                    h.add(lib,'lib');
                end
            end


            function SetBuildOptions(h,ProjectBuildInfo)
                tokens=[ProjectBuildInfo.mTokens];

                linkerOpts=tgtLibEvalTokens(linkfoundation.autointerface.baselink.getLinkerOptions(ProjectBuildInfo),tokens,'linkerOption',true);
                if(~isempty(linkerOpts)&&(~strcmpi(ProjectBuildInfo.mBuildAction,'Archive_library')))
                    h.setbuildopt('Linker',linkerOpts);
                end

                compilerOpts=tgtLibEvalTokens(linkfoundation.autointerface.baselink.getCompilerOptions(ProjectBuildInfo,true),tokens,'compilerOption',true);
                if(~isempty(compilerOpts))
                    h.setbuildopt('Compiler',compilerOpts);
                end

                h.setAdditionalBuildOptions();