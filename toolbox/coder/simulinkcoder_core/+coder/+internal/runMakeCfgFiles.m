function[includeDirs,sourceDirs,addSources,linkLibsObjs,...
    missingPrecomps]=...
    runMakeCfgFiles(lBuildInfo,sfcnMakeCfgFiles,sfcnMakeCfgFilePaths,lGenerateCodeOnly,...
    isPrecompBuild,...
    lTargetPreCompLibLoc,lPrecompTargetLibSuffix)





    includeDirs={};
    sourceDirs={};
    addSources={};
    linkLibsObjs={};



    missingPrecomps=[];


    for i=1:length(sfcnMakeCfgFiles)
        sfunPath=sfcnMakeCfgFilePaths{i};
        sfcnMakeCfgFile=sfcnMakeCfgFiles{i};

        if~isempty(sfcnMakeCfgFile)
            loc_makecfg(lBuildInfo,sfcnMakeCfgFile,sfunPath);
        end
    end



    uniqueSfcnMakeCfgFilePaths=unique(sfcnMakeCfgFilePaths,'stable');
    for i=1:length(uniqueSfcnMakeCfgFilePaths)
        sfunPath=uniqueSfcnMakeCfgFilePaths{i};


        loc_makecfg(lBuildInfo,'makecfg',sfunPath);

        [tmpIncludeDirs,tmpSourceDirs,tmpAddSources,tmpLinkLibsObjs,...
        tmpMissingPrecomps]=...
        i_runMakeCfgFile(lBuildInfo,sfunPath,lGenerateCodeOnly,...
        isPrecompBuild,...
        lTargetPreCompLibLoc,lPrecompTargetLibSuffix);

        includeDirs=[includeDirs,tmpIncludeDirs{:}];%#ok<AGROW>
        sourceDirs=[sourceDirs,tmpSourceDirs{:}];%#ok<AGROW>
        addSources=[addSources,tmpAddSources{:}];%#ok<AGROW>
        linkLibsObjs=[linkLibsObjs,tmpLinkLibsObjs{:}];%#ok<AGROW>
        missingPrecomps=[missingPrecomps,tmpMissingPrecomps(:)];%#ok<AGROW>

    end


    function[includeDirs,sourceDirs,addSources,linkLibsObjs,tmpMissingPrecomps]=...
        i_runMakeCfgFile(lBuildInfo,sfunPath,lGenerateCodeOnly,...
        isPrecompBuild,...
        lTargetPreCompLibLoc,lPrecompTargetLibSuffix)

        includeDirs={};
        sourceDirs={};
        addSources={};
        linkLibsObjs={};
        tmpMissingPrecomps=struct('lib',{},'rtwmakecfgDir',{});



        makeCfgFile='rtwmakecfg';
        fname=fullfile(sfunPath,makeCfgFile);
        if(isfile([fname,'.m'])>0||...
            isfile([fname,'.p'])>0)


            origPath=cd(sfunPath);
            pwdCleanup=onCleanup(@()cd(origPath));

            try


                makeCfgStr=feval(makeCfgFile);
            catch exc
                makeCfgStr=false;
            end
            if islogical(makeCfgStr)&&makeCfgStr==false
                loc_throwMakeConfigError(exc,makeCfgFile);
                return;
            end
            try
                includeDirs=eval('makeCfgStr.includePath');
            catch exc %#ok<NASGU>
                includeDirs={};
            end
            try
                sourceDirs=eval('makeCfgStr.sourcePath');
            catch exc %#ok<NASGU>
                sourceDirs={};
            end
            try
                addSources=eval('makeCfgStr.sources');
            catch exc %#ok<NASGU>
                addSources={};
            end
            try
                linkLibsObjs=eval('makeCfgStr.linkLibsObjs');
            catch exc %#ok<NASGU>
                linkLibsObjs={};
            end





            if isfield(makeCfgStr,'library')



                if isfield(makeCfgStr,'precompile')
                    precomplib=(makeCfgStr.precompile==1);
                else
                    precomplib=false;
                end

                for j=1:length(makeCfgStr.library)
                    try



                        if isfield(makeCfgStr.library(j),'Location')
                            libName=makeCfgStr.library(j).Name;
                            libLoc=makeCfgStr.library(j).Location;
                        else
                            lname=regexprep(makeCfgStr.library(j).Name,...
                            '[\\/]',filesep);
                            delim=find(lname==filesep);
                            if isempty(delim)


                                libName=makeCfgStr.library(j).Name;
                                libLoc='';
                            else
                                libName=makeCfgStr.library(j).Name(delim(end)+1:end);
                                libLoc=makeCfgStr.library(j).Name(1:delim(end)-1);
                            end
                        end




                        specifiedLibLoc=libLoc;



                        if~isempty(lTargetPreCompLibLoc)&&precomplib
                            libLoc=lTargetPreCompLibLoc;
                        end





                        group=libName;

                        plib=lBuildInfo.addLinkObjects(libName,...
                        libLoc,...
                        1000,...
                        precomplib,...
                        false,...
                        group);




                        if isempty(plib)
                            plib=lBuildInfo.findLinkObject(libName);
                        end














                        if~lGenerateCodeOnly&&...
                            ~isPrecompBuild&&...
                            precomplib&&...
                            ~isempty(lTargetPreCompLibLoc)&&...
                            ~isempty(lPrecompTargetLibSuffix)

                            fullLibName=fullfile(libLoc,[libName,lPrecompTargetLibSuffix]);

                            if(exist(fullLibName,'file')~=2)










                                tmpMissingPrecomps(end+1).lib=fullLibName;%#ok<AGROW>


                                tmpMissingPrecomps(end).rtwmakecfgDir=pwd;
                            end
                        end

                        incPaths={};






                        assert(ischar(specifiedLibLoc),...
                        'rtwmakecfg must provide library location as a character array')
                        if contains(specifiedLibLoc,matlabroot)
                            incPaths={...
                            fullfile(matlabroot,'simulink','include'),...
                            fullfile(matlabroot,'extern','include'),...
                            fullfile(matlabroot,'rtw','c','src'),...
                            fullfile(matlabroot,'rtw','c','src','ext_mode','common')};
                        end




                        if isfield(makeCfgStr,'includePath')
                            incPaths=[makeCfgStr.includePath,incPaths{:}];
                        end
                        plib.addLinkObjIncludePaths(incPaths,group);
                        if isfield(makeCfgStr,'sourcePath')
                            plib.addLinkObjSourcePaths(makeCfgStr.sourcePath,group);
                        end



                        if isfield(makeCfgStr.library(j),'Modules')
                            plib.addLinkObjSourceFiles(makeCfgStr.library(j).Modules,'',group);
                        end
                    catch exc


                        DAStudio.error('RTW:buildProcess:badRtwmakecfg',...
                        fullfile(pwd,'rtwmakecfg.m'),exc.message);
                    end
                end
            end
        end






        function loc_makecfg(BuildInfo,makeCfgFile,sfunPath)



            fname=fullfile(sfunPath,makeCfgFile);
            if(isfile([fname,'.m'])>0||...
                isfile([fname,'.p'])>0)


                origPath=cd(sfunPath);
                pwdCleanup=onCleanup(@()cd(origPath));

                try



                    feval(makeCfgFile,BuildInfo);

                catch exc
                    loc_throwMakeConfigError(exc,makeCfgFile);
                end
            end

            function loc_throwMakeConfigError(exc,makeCfgFile)

                msle=MSLException([],message('RTW:buildProcess:makeCfgCallFailed',...
                makeCfgFile,...
                pwd,...
                exc.message));
                msle=msle.addCause(exc);

                throw(msle);

