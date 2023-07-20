classdef(Sealed=true)Project<handle






    properties(SetAccess='private')
        mPM=[];
        mDiagnosticActions=[];
    end

    properties(Constant)
    end



    methods

        function h=Project(parent)
            h.mPM=parent;
            h.mDiagnosticActions=h.mPM.mBuildConfigurator.getConfigSetParam('DiagnosticActions');
        end

        function lInstrumentedCodeSubFolder=getInstrumentedSubFolder(~,lBuildInfo)



            lBuildDir=getSourcePaths(lBuildInfo,true,'BuildDir');
            [~,lastPart]=fileparts(lBuildDir{1});
            instrFolder='instrumented';
            lCodeInstrumentationAnchor=lBuildInfo...
            .getSourcePaths(1,'CodeInstrumentationAnchor');
            if~isempty(lCodeInstrumentationAnchor)&&iscell(lCodeInstrumentationAnchor)
                lCodeInstrumentationAnchor=lCodeInstrumentationAnchor{1};
            else
                lCodeInstrumentationAnchor='';
            end
            if strcmp(lastPart,instrFolder)


                lInstrumentedCodeSubFolder=instrFolder;
            elseif strcmp(lCodeInstrumentationAnchor,'..')


                lInstrumentedCodeSubFolder=instrFolder;
            else
                lInstrumentedCodeSubFolder=[];
            end

        end

        function pbi=getProjectBuildInfo(h)
            pbi=h.mPM.mProjectBuildInfo;
        end

        function addLibraries(h,libs)
            if~isempty(libs)&&~iscell(libs)
                libs={libs};
            end
            for i=1:length(libs)
                libs{i}=h.adjustSeperators(libs{i});
                [pathstr,namestr,extstr]=fileparts(libs{i});
                names{i}=[namestr,extstr];%#ok<*AGROW>
                paths{i}=pathstr;
                priority(i)=1000;
                precompiled(i)=1;
                linkonly(i)=0;
                group{i}='linksandtargets';
            end
            if~isempty(libs)
                h.mPM.mProjectBuildInfo.mBuildInfo.addLinkObjects(names,paths,...
                priority,precompiled,linkonly,group);
            end
        end

        function addSourceFiles(h,lst,group)
            if nargin<3
                group='BuildDir';
            end
            if~isempty(lst)

                lst=cellstr(lst);

                numfiles=numel(lst);
                filePathList{numfiles}='';
                fileNameList{numfiles}='';
                fileExtList{numfiles}='';
                for i=1:numfiles
                    lst{i}=h.adjustSeperators(lst{i});
                    [filePathList{i},fileNameList{i},fileExtList{i}]=fileparts(lst{i});
                    fileNameList{i}=[fileNameList{i},fileExtList{i}];
                end

                FileNamesInBuildInfo=get(h.mPM.mProjectBuildInfo.mBuildInfo.Src.Files,'FileName');
                FileGroupsInBuildInfo=get(h.mPM.mProjectBuildInfo.mBuildInfo.Src.Files,'Group');

                skipForSilIdx=strcmp(FileGroupsInBuildInfo,'SkipForSil');
                FileNamesInBuildInfo=FileNamesInBuildInfo(~skipForSilIdx);
                [CommonFileNames,inIndex,biIndex]=intersect(fileNameList,FileNamesInBuildInfo);%#ok<NASGU>
                if(~isempty(CommonFileNames))
                    if strcmp(h.mDiagnosticActions,'error')

                        DAStudio.error('ERRORHANDLER:pjtgenerator:SourceFileReplacedError',CommonFileNames{1});
                    elseif strcmp(h.mDiagnosticActions,'warning')



                        curWarnState=warning('on');%#ok<WNON>
                        for j=1:length(CommonFileNames)
                            MSLDiagnostic('ERRORHANDLER:pjtgenerator:SourceFileReplacedWarning',CommonFileNames{j}).reportAsWarning;
                            if(strcmpi(group,'CustomCode'))


                                h.RemoveFileFromBuildInfoBasedOnNameOnly(h.mPM.mProjectBuildInfo.mBuildInfo,CommonFileNames{j});
                            end
                        end
                        warning(curWarnState);
                    end
                    if(~strcmpi(group,'CustomCode'))
                        for i=1:length(inIndex)
                            fileNameList{inIndex(i)}='';
                            filePathList{inIndex(i)}='';
                        end
                        fileNameList=cellstr(strvcat(fileNameList));%#ok<FPARK>
                        filePathList=cellstr(strvcat(filePathList));%#ok<FPARK>
                    end
                end

                h.mPM.mProjectBuildInfo.mBuildInfo.addSourceFiles(fileNameList,filePathList,group);
            end

        end

        function addIncludePaths(h,lst,option)
            lBuildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;
            if~isempty(lst)


                if nargin==3&&strcmpi(option,'put-on-top')
                    lst=h.createNewIncludePathList(lst);

                    lBuildInfo.Inc.Paths=[];
                end


                lBuildInfo.addIncludePaths(lst);
            end
        end

        function checkAndAddReqdLibraries(h,lst)





            checklist={'dsp_rt','vip_rt','rtw_rt'};

            reqdLibraries={};
            for i=1:length(h.mPM.mProjectBuildInfo.mBuildInfo.LinkObj)
                if~strcmpi(h.mPM.mProjectBuildInfo.mBuildInfo.LinkObj(i).Group,'CustomCode')
                    if(strcmpi(h.mPM.mProjectBuildInfo.mBuildInfo.LinkObj(i).Name,'rtwlib'))
                        reqdLibraries{end+1}='rtw_rt';%#ok<AGROW>
                    else
                        reqdLibraries{end+1}=h.mPM.mProjectBuildInfo.mBuildInfo.LinkObj(i).Name;%#ok<AGROW>
                    end
                end
            end

            for i=1:length(lst)
                addThis=lst{i};
                lst{i}=h.adjustSeperators(addThis);
                [~,fname]=fileparts(addThis);
                lastEl=min(length(fname),6);
                libtoadd=fname(1:lastEl);

                if(ismember(libtoadd,checklist))

                    if(ismember(libtoadd,reqdLibraries))

                        addThis=lst{i};
                        h.hAddLibraries(addThis);
                        h.hDeleteLibraries(libtoadd);
                    end
                else
                    h.hAddLibraries(addThis);
                end
            end


            libs=h.hGetLibraries();
            for j=1:numel(libs)
                libs{j}=h.adjustSeperators(libs{j});
                [~,fname]=fileparts(libs{j});
                if any(strcmpi(fname,checklist))
                    DAStudio.error('ERRORHANDLER:pjtgenerator:MissingRTLibReplacement',upper(fname(1:3)));
                end
            end

        end

        function addPreprocessorSymbols(h,lst)
            delim=h.mPM.mAdaptorRegistry.getPreprocSymbolDelimiter(h.mPM.mProjectBuildInfo.mAdaptorName);
            if~isempty(lst)&&~iscell(lst)
                lst={lst};
            end
            for i=1:length(lst)
                if~isempty(lst{i})
                    h.mPM.mProjectBuildInfo.mBuildInfo.addCompileFlags([delim,'"',lst{i},'"']);
                end
            end
        end

        function addCompilerOption(h,compOption,option)
            lBuildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;
            if~isempty(compOption)

                if nargin==3&&strcmpi(option,'put-on-top')
                    origCompFlags=lBuildInfo.Options.CompileFlags;
                    lBuildInfo.Options.CompileFlags=[];
                    lBuildInfo.addCompileFlags(compOption);
                    for i=1:length(origCompFlags)
                        lBuildInfo.addCompileFlags(origCompFlags(i).Value);
                    end
                else
                    lBuildInfo.addCompileFlags(compOption);
                end
            end
        end

        function addLinkerOption(h,linkOption,option)
            lBuildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;
            group='SkipForSil';
            if~isempty(linkOption)

                if nargin==3&&strcmpi(option,'put-on-top')
                    origLinkFlags=lBuildInfo.Options.LinkFlags;
                    lBuildInfo.Options.LinkFlags=[];
                    lBuildInfo.addLinkFlags(linkOption);
                    for i=1:length(origLinkFlags)
                        lBuildInfo.addLinkFlags(origLinkFlags(i).Value,group);
                    end
                else
                    lBuildInfo.addLinkFlags(linkOption,group);
                end
            end
        end

        function update(h)
            lBuildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;


            lBuildInfo.updateFilePathsAndExtensions;










            h.mPM.mChip.filterOutProject(h);
            h.mPM.mOS.filterOutProject(h);


            h.filterOutProject;





            sharedutilsdir=h.getsharedutildir(lBuildInfo);
            if~isempty(sharedutilsdir)

                h.addIncludePaths(sharedutilsdir);

                sharedutils=h.getsharedutils(sharedutilsdir);

                if ispc
                    group='rtwshared.lib';
                else
                    group='rtwshared.a';
                end
                h.addSourceFiles(sharedutils,group);


                if~isempty(sharedutils)
                    libsToRemove={'rtwshared.lib','rtwshared.a'};
                    h.hDeleteLibraries(libsToRemove);
                end
            end

            fileNames=get(lBuildInfo.Src.Files,'FileName');
            filePaths=get(lBuildInfo.Src.Files,'Path');
            fileGroups=get(lBuildInfo.Src.Files,'Group');
            custindex=find(strcmp(fileGroups,'CustomCode')==1);
            numind=numel(custindex);








            if strcmp(h.mDiagnosticActions,'warning')



                curWarnState=warning('on');%#ok<WNON>
            end
            for i=1:numind

                matchingFileNames=find(strcmp(fileNames,fileNames{custindex(i)})==1);


                for j=1:numel(matchingFileNames)
                    for k=j+1:numel(matchingFileNames)

                        if strcmp(fileGroups{matchingFileNames(j)},fileGroups{matchingFileNames(k)})==0
                            if strcmp(h.mDiagnosticActions,'error')
                                DAStudio.error('ERRORHANDLER:pjtgenerator:SourceFileReplacedError',fileNames{matchingFileNames(j)});
                            elseif strcmp(h.mDiagnosticActions,'warning')
                                MSLDiagnostic('ERRORHANDLER:pjtgenerator:SourceFileReplacedWarning',fileNames{matchingFileNames(j)}).reportAsWarning;
                            end
                            if strcmp(fileGroups{matchingFileNames(j)},'CustomCode')==1



                                h.RemoveFileFromBuildInfo(lBuildInfo,...
                                fileNames{matchingFileNames(k)},...
                                filePaths{matchingFileNames(k)});
                            else



                                h.RemoveFileFromBuildInfo(lBuildInfo,...
                                fileNames{matchingFileNames(j)},...
                                filePaths{matchingFileNames(j)});
                            end
                        else

                            if strcmp(filePaths{matchingFileNames(j)},filePaths{matchingFileNames(k)})==0
                                if strcmp(h.mDiagnosticActions,'warning')
                                    warning(curWarnState);
                                end
                                DAStudio.error('ERRORHANDLER:pjtgenerator:CustomCodeError',...
                                fileNames{matchingFileNames(j)},...
                                h.getPathForDisp(filePaths{matchingFileNames(j)}),...
                                h.getPathForDisp(filePaths{matchingFileNames(k)}));
                            end
                        end
                    end
                end
            end
            if strcmp(h.mDiagnosticActions,'warning')
                warning(curWarnState);
            end
        end

        function lst=getLibraries(h)
            lst=h.hGetLibraries(false);
        end

        function deleted=deleteSourceFiles(h,lst)
            buildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;

            if~isempty(lst)&&~iscell(lst)
                lst={lst};
            end


            idxlst=[];
            for i=1:length(lst)
                lst{i}=h.adjustSeperators(lst{i});
                [pathR,nameR,extR]=fileparts(lst{i});


                for j=1:length(buildInfo.Src.Files)
                    buildInfoFile=fullfile(buildInfo.Src.Files(j).Path,...
                    buildInfo.Src.Files(j).FileName);

                    buildInfoFile=h.adjustSeperators(buildInfoFile);

                    [pathB,nameB,extB]=fileparts(buildInfoFile);
                    pathBT=fileparts(buildInfo.formatPaths(buildInfoFile));



                    if isempty(pathR)||strcmpi(pathR,pathB)||strcmpi(pathR,pathBT)




                        if(strcmpi(nameR,'*')&&strcmpi(extR,''))||...
                            (strcmpi(nameR,'*')&&strcmpi(extR,extB))||...
                            (strcmpi(nameR,nameB)&&(strcmpi(extR,'*')||strcmpi(extR,extB)))||...
                            (strcmpi(lst{i},[nameB,extB]))
                            idxlst(end+1)=j;%#ok<AGROW>
                            break;
                        end
                    end
                end
            end


            idxlst=sort(unique(idxlst),'descend');


            for i=1:length(idxlst)
                buildInfo.Src.Files(idxlst(i))=[];
            end

            deleted=~isempty(idxlst);
        end

        function deleted=deleteIncludePaths(h,pathsToDel)



            buildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;



            if~isempty(pathsToDel)&&~iscell(pathsToDel)
                pathsToDel={pathsToDel};
            end


            idxPathsToDel=[];
            for i=1:length(pathsToDel)
                for j=1:length(buildInfo.Inc.Paths)
                    buildInfoPath=buildInfo.Inc.Paths(j).Value;

                    if strcmpi(pathsToDel{i},buildInfoPath)
                        idxPathsToDel(end+1)=j;%#ok<AGROW>
                        break;
                    end
                end
            end


            idxPathsToDel=sort(idxPathsToDel,'descend');


            for i=1:length(idxPathsToDel)
                buildInfo.Inc.Paths(idxPathsToDel(i))=[];
            end

            deleted=~isempty(idxPathsToDel);
        end

        function deleted=deleteLinkerOption(h,linkOption,option)













            if nargin==2||(nargin==3&&isempty(option))
                option='exact';
            end

            buildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;

            origLinkFlags=buildInfo.getLinkFlags;
            toRemove=[];%#ok<NASGU>
            switch lower(option)
            case 'exact'
                toRemove=find(strcmp(origLinkFlags,linkOption));
            case 'pattern'
                hits=regexp(origLinkFlags,linkOption,'once');
                toRemove=find(~cellfun('isempty',hits));
            otherwise
                DAStudio.error('ERRORHANDLER:pjtgenerator:InvalidDeleteLinkerOptArgument');
            end


            if~isempty(toRemove)
                deleted=true;
                origLinkFlagHandles=buildInfo.Options.LinkFlags;

                buildInfo.Options.LinkFlags=[];

                for j=1:length(origLinkFlagHandles)
                    if any(j~=toRemove)
                        buildInfo.addLinkFlags(origLinkFlagHandles(j).Value);
                    end
                end
            else
                deleted=false;
            end

        end
    end

    methods(Access='private')

        function fullFileName=adjustSeperators(h,fullFileName)%#ok<INUSL>
            if ispc
                fullFileName=strrep(fullFileName,'/',filesep);
            else
                fullFileName=strrep(fullFileName,'\',filesep);
            end
        end

        function filterOutProject(h)
            filesToRemove={};


            filesToRemove{end+1}=fullfile('$(MATLAB_ROOT)','rtw','c','src','matrixmath','*');




            if~strcmpi(h.mPM.mProjectBuildInfo.mModelName,'ert')
                filesToRemove{end+1}='ert_main.c';
            end



            if~strcmpi(h.mPM.mProjectBuildInfo.mModelName,'rt')
                filesToRemove{end+1}='rt_main.c';
            end



            if~strcmpi(h.mPM.mProjectBuildInfo.mModelName,'rt_malloc')
                filesToRemove{end+1}='rt_malloc_main.c';
            end

            if strcmp(h.mPM.mProjectBuildInfo.mBuildAction,'Archive_library')

                libBuildFilesToRemove=h.mPM.mProjectBuildInfo.mRemoveFromLibPjt;
                lBuildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;
                lInstrumentedCodeSubFolder=...
                h.getInstrumentedSubFolder(lBuildInfo);
                libBuildFilesToRemoveInstr={};
                if~isempty(lInstrumentedCodeSubFolder)
                    libBuildFilesToRemoveInstr=libBuildFilesToRemove;
                    for i=1:length(libBuildFilesToRemoveInstr)
                        [pTmp,fTmp,eTmp]=fileparts(libBuildFilesToRemoveInstr{i});
                        libBuildFilesToRemoveInstr{i}=fullfile...
                        (pTmp,lInstrumentedCodeSubFolder,[fTmp,eTmp]);
                    end
                end
                filesToRemove=[filesToRemove,libBuildFilesToRemove,libBuildFilesToRemoveInstr];









                silHostObjDir=fullfile(h.mPM.mProjectBuildInfo.mCodeGenDir,...
                rtw.connectivity.Utils.getSilHostObjSubDir);
                libFilesToSkip=fullfile(silHostObjDir,'libFilesToSkip.txt');
                if exist(libFilesToSkip,'file')
                    fid=fopen(libFilesToSkip);
                    additionalFilesToRemove=[];
                    while 1
                        tline=fgetl(fid);
                        if~ischar(tline),break,end
                        additionalFilesToRemove{end+1}=tline;%#ok<AGROW>
                    end
                    fclose(fid);
                    additionalFilesToRemove=RTW.unique(additionalFilesToRemove);
                    filesToRemove=[filesToRemove,additionalFilesToRemove];
                end
            end


            h.deleteSourceFiles(filesToRemove);
        end



        function sharedutilsdir=getsharedutildir(h,buildInfo)%#ok<INUSL>
            sharedutilsdir='';
            for i=1:length(buildInfo.BuildArgs)
                if strcmpi(buildInfo.BuildArgs(i).Key,'SHARED_SRC_DIR')
                    sharedutilsdir=strtrim(buildInfo.BuildArgs(i).Value);
                end
            end
            if~isempty(sharedutilsdir)
                if~isempty(strfind(sharedutilsdir,'$(START_DIR)'))
                    h2=coder.internal.ModelCodegenMgr.getInstance(h.mPM.mProjectBuildInfo.mModelName);
                    sharedutilsdir=strrep(sharedutilsdir,'$(START_DIR)',h2.StartDirToRestore);
                else
                    sharedutilsdir=fullfile(pwd,sharedutilsdir);
                end
                sharedutilsdir={sharedutilsdir};
            end
        end


        function sharedutils=getsharedutils(h,sharedutilsdir)%#ok<INUSL>
            utils=dir(fullfile(sharedutilsdir{1},'*.c'));
            sharedutils={};
            for i=1:numel(utils)
                sharedutils{i}=fullfile(sharedutilsdir{1},utils(i).name);%#ok<AGROW>
            end
        end



        function pathStr=getPathForDisp(h,inPathStr)%#ok<INUSL>
            pathStr=regexprep(inPathStr,'\\','\\\\');
        end



        function RemoveFileFromBuildInfo(h,hBuildInfo,FileName,FilePath)%#ok<INUSL>

            try
                curMatchingFileNames=strfind(get(hBuildInfo.Src.Files,'FileName'),FileName);
                curMatchingFilePaths=strfind(get(hBuildInfo.Src.Files,'Path'),FilePath);

                match=zeros(1,length(curMatchingFileNames));
                for i=1:length(curMatchingFileNames)
                    if(isempty(curMatchingFileNames{i}))
                        match(i)=false;
                    elseif(isempty(curMatchingFilePaths{i}))
                        match(i)=false;
                    else
                        match(i)=curMatchingFileNames{i}&&curMatchingFilePaths{i};
                    end
                end
                indextodel=find(match);

                hBuildInfo.Src.Files(indextodel(1))=[];
            catch ex
                newex=MException('ERRORHANDLER:pjtgenerator:CustomCodeReplaceError',DAStudio.message('ERRORHANDLER:pjtgenerator:CustomCodeReplaceError',getPathForDisp(fullfile(FilePath,FileName))));
                newex=addCause(newex,ex);
                throwAsCaller(newex);
            end
        end

        function RemoveFileFromBuildInfoBasedOnNameOnly(h,hBuildInfo,FileName)%#ok<INUSL>

            try
                curMatchingFileNames=strfind(get(hBuildInfo.Src.Files,'FileName'),FileName);

                match=zeros(1,length(curMatchingFileNames));
                for i=1:length(curMatchingFileNames)
                    if(isempty(curMatchingFileNames{i}))
                        match(i)=false;
                    else
                        match(i)=curMatchingFileNames{i};
                    end
                end
                indextodel=find(match);

                hBuildInfo.Src.Files(indextodel(1))=[];
            catch ex
                newex=MException('ERRORHANDLER:pjtgenerator:CustomCodeReplaceError',DAStudio.message('ERRORHANDLER:pjtgenerator:CustomCodeReplaceError',FileName));
                newex=addCause(newex,ex);
                throwAsCaller(newex);
            end

        end

    end
    methods(Access='private')
        function pathList=createNewIncludePathList(h,pathList)

            for i=1:numel(h.mPM.mProjectBuildInfo.mBuildInfo.Inc.Paths)
                pathList{end+1}=h.mPM.mProjectBuildInfo.mBuildInfo.Inc.Paths(i).Value;%#ok<AGROW>
            end
        end

        function hAddLibraries(h,libs)
            if~isempty(libs)&&~iscell(libs)
                libs={libs};
            end
            for i=1:length(libs)
                if~ispc
                    libs{i}=strrep(libs{i},'\','/');
                end
                [pathstr,namestr,extstr]=fileparts(libs{i});
                names{i}=[namestr,extstr];
                paths{i}=pathstr;
                priority(i)=1000;
                precompiled(i)=1;
                linkonly(i)=0;
                group{i}='linksandtargets';
            end
            if~isempty(libs)
                h.mPM.mProjectBuildInfo.mBuildInfo.addLinkObjects(names,...
                paths,priority,precompiled,linkonly,group);
            end
        end

        function hDeleteLibraries(h,libs)
            lBuildInfo=h.mPM.mProjectBuildInfo.mBuildInfo;

            if~isempty(libs)&&~iscell(libs)
                libs={libs};
            end


            idxlibs=[];
            for i=1:length(libs)
                if~ispc
                    libs{i}=strrep(libs{i},'\','/');
                end
                [pathR,nameR,extR]=fileparts(libs{i});


                for j=1:length(lBuildInfo.LinkObj)
                    buildInfoFile=fullfile(lBuildInfo.LinkObj(j).Path,...
                    lBuildInfo.LinkObj(j).Name);
                    if~ispc
                        buildInfoFile=strrep(buildInfoFile,'\','/');
                    end

                    [pathB,nameB,extB]=fileparts(buildInfoFile);

                    if isempty(pathR)||strcmpi(pathR,pathB)




                        if(strcmpi(nameR,'*')&&strcmpi(extR,''))||...
                            (strcmpi(nameR,'*')&&strcmpi(extR,extB))||...
                            (strcmpi(nameR,nameB)&&(strcmpi(extR,'*')||strcmpi(extR,extB)))||...
                            (strcmpi(libs{i},[nameB,extB]))
                            idxlibs(end+1)=j;%#ok<AGROW>
                            break;
                        end
                    end
                end
            end


            idxlibs=sort(idxlibs,'descend');


            for i=1:length(idxlibs)
                lBuildInfo.LinkObj(idxlibs(i))=[];
            end
        end

        function list=hGetLibraries(h,expandTokens)
            if nargin==1||~expandTokens
                expandTokens='tokenized';
            else
                expandTokens='expanded';
            end

            list={};
            for i=1:length(h.mPM.mProjectBuildInfo.mBuildInfo.LinkObj)
                libPath=formatPaths(h.mPM.mProjectBuildInfo.mBuildInfo,...
                h.mPM.mProjectBuildInfo.mBuildInfo.LinkObj(i).Path,...
                'format',expandTokens);
                list{i}=fullfile(libPath,...
                h.mPM.mProjectBuildInfo.mBuildInfo.LinkObj(i).Name);%#ok<AGROW>
            end
        end

    end
end




