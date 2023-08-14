function varargout=fileGenControl(iAction,varargin)





    persistent FileGenConfig;
    persistent CurFileGenConfig;
    persistent ParallelFileGenConfig;
    persistent BuildInProgress;
    persistent ParallelBuildInProgress;
    persistent MainInputParser;
    persistent TransformPaths;


    mlock;


    if isempty(FileGenConfig)


        defaultFileGenConfig=locCreateDefaultFileGenConfig();
    end


    cleanupFileGenControlInProgress=locFileGenControlExecutionInProgress('check');%#ok<NASGU>

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if isempty(MainInputParser)


        optFields={{'createDir',false,@islogical}...
        ,{'keepPreviousPath',false,@islogical}...
        };
    end

    if isempty(TransformPaths)
        transPath=which('coder.make.internal.transformPaths');
        TransformPaths=~isempty(transPath);
    end

    action=lower(iAction);


    switch(action)


    case{'get',...
        'getinternalvalue'}
        if(length(varargin)~=1)
            DAStudio.error('RTW:utility:invalidArgCountForAction',action,'1');
        end

        if isempty(MainInputParser)
            [opts,args,~,MainInputParser]=locParseInput(optFields,true,...
            'checkArgs',...
            'singleArg',...
            varargin{1});
        else
            [opts,args,]=locParseInput(MainInputParser,true,'checkArgs',...
            'singleArg',varargin{1});
        end


    otherwise
        if isempty(MainInputParser)
            [opts,args,~,MainInputParser]=locParseInput(optFields,true,...
            'checkArgs',...
            varargin{:});
        else
            [opts,args]=locParseInput(MainInputParser,true,...
            'checkArgs',varargin{:});
        end
    end


    if isempty(FileGenConfig)
        FileGenConfig=defaultFileGenConfig;
        CurFileGenConfig=[];
        ParallelFileGenConfig=[];
        BuildInProgress=false;
        ParallelBuildInProgress=false;


        oldPaths={'',''};
        newPaths={FileGenConfig.CacheFolder,FileGenConfig.CodeGenFolder};
        try
            newPaths{1}=locCheckFolderExists(newPaths{1},'CacheFolder',opts.createDir);
            newPaths{2}=locCheckFolderExists(newPaths{2},'CodeGenFolder',opts.createDir);
            [cacheFolder,codeGenFolder]=locUpdatePath(oldPaths,newPaths,opts.keepPreviousPath);
        catch exc %#ok<NASGU>
            MSLDiagnostic('RTW:buildProcess:BadFolderPreferences').reportAsWarning;
            cacheFolder='';
            codeGenFolder='';
        end

        FileGenConfig.CacheFolder=cacheFolder;
        FileGenConfig.CodeGenFolder=codeGenFolder;
    end

    switch(action)

    case 'setbuildinprogress'
        locVerifyNargoutCount(action,nargout,1);
        if(nargout>=1)
            varargout{1}=BuildInProgress;
        end

        if~BuildInProgress
            CurFileGenConfig=locGetSafeConfigCopy(FileGenConfig,false,TransformPaths);
            CurFileGenConfig.ReadOnly=true;
            BuildInProgress=true;
        end

    case 'setparallelbuildinprogress'
        locVerifyNargoutCount(action,nargout,0);

        ParallelFileGenConfig=locGetSafeConfigCopy(FileGenConfig,false,true);

        oldPaths={FileGenConfig.CacheFolder,FileGenConfig.CodeGenFolder};
        newPaths={args.CacheFolder,args.CodeGenFolder};
        newPaths{1}=locCheckFolderExists(newPaths{1},'CacheFolder',opts.createDir);
        newPaths{2}=locCheckFolderExists(newPaths{2},'CodeGenFolder',opts.createDir);
        [cacheFolder,codeGenFolder]=locUpdatePath(oldPaths,newPaths,opts.keepPreviousPath);

        ParallelFileGenConfig.CacheFolder=cacheFolder;
        ParallelFileGenConfig.CodeGenFolder=codeGenFolder;
        ParallelFileGenConfig.ReadOnly=true;

        ParallelBuildInProgress=true;



    case 'getparallelbuildinprogress'
        locVerifyNargoutCount(action,nargout,1);
        varargout{1}=ParallelBuildInProgress;


    case 'clearbuildinprogress'
        locVerifyNargoutCount(action,nargout,0);
        CurFileGenConfig=[];
        BuildInProgress=false;


        ParallelFileGenConfig=[];
        ParallelBuildInProgress=false;

    case 'clearparallelbuildinprogress'
        locVerifyNargoutCount(action,nargout,0);
        ParallelFileGenConfig=[];
        ParallelBuildInProgress=false;


    case 'setconfig'
        locCheckBuildInProgress(BuildInProgress,ParallelBuildInProgress);
        locVerifyNargoutCount(action,nargout,0);


        argFields={{'config',[],@(x)isa(x,'Simulink.FileGenConfig')}};
        args=locParseInput(argFields,false,action,args);


        oldPaths={FileGenConfig.CacheFolder,FileGenConfig.CodeGenFolder};
        newPaths={args.config.CacheFolder,args.config.CodeGenFolder};

        newPaths{1}=locCheckFolderExists(newPaths{1},'CacheFolder',opts.createDir);
        newPaths{2}=locCheckFolderExists(newPaths{2},'CodeGenFolder',opts.createDir);
        [cacheFolder,codeGenFolder]=locUpdatePath(oldPaths,newPaths,opts.keepPreviousPath);


        FileGenConfig=copy(args.config);

        FileGenConfig.CacheFolder=cacheFolder;
        FileGenConfig.CodeGenFolder=codeGenFolder;


    case 'getconfig'
        locVerifyNargoutCount(action,nargout,1);

        locErrorIfAdditionalArgs(action,args)


        if ParallelBuildInProgress
            varargout{1}=ParallelFileGenConfig;
        else
            if BuildInProgress
                varargout{1}=CurFileGenConfig;
            else
                varargout{1}=locGetSafeConfigCopy(FileGenConfig,false,TransformPaths);
            end
        end

    case 'reset'
        locCheckBuildInProgress(BuildInProgress,ParallelBuildInProgress);
        locVerifyNargoutCount(action,nargout,0);

        locErrorIfAdditionalArgs(action,args)


        oldCacheFolder=FileGenConfig.CacheFolder;
        oldCodeGenFolder=FileGenConfig.CodeGenFolder;

        FileGenConfig=locCreateDefaultFileGenConfig();



        oldPaths={oldCacheFolder,oldCodeGenFolder};
        newPaths={FileGenConfig.CacheFolder,FileGenConfig.CodeGenFolder};

        try
            newPaths{1}=locCheckFolderExists(newPaths{1},'CacheFolder',opts.createDir);
            newPaths{2}=locCheckFolderExists(newPaths{2},'CodeGenFolder',opts.createDir);
            [cacheFolder,codeGenFolder]=locUpdatePath(oldPaths,newPaths,opts.keepPreviousPath);
        catch exc %#ok<NASGU>
            MSLDiagnostic('RTW:buildProcess:BadFolderPreferences').reportAsWarning;
            cacheFolder='';
            codeGenFolder='';
        end


        FileGenConfig.CacheFolder=cacheFolder;
        FileGenConfig.CodeGenFolder=codeGenFolder;


    case 'set'
        locCheckBuildInProgress(BuildInProgress,ParallelBuildInProgress);
        locVerifyNargoutCount(action,nargout,0);

        argFields=Simulink.FileGenConfig.getPropListsForInputParser();
        [args,~,defs]=locParseInput(argFields,false,action,args);

        aFields=fieldnames(args);

        aFields=setdiff(aFields,defs);

        oldCacheFolder=FileGenConfig.CacheFolder;
        oldCodeGenFolder=FileGenConfig.CodeGenFolder;

        tmpConfig=copy(FileGenConfig);

        for i=1:length(aFields)
            tmpConfig.(aFields{i})=args.(aFields{i});
        end

        newCacheFolder=tmpConfig.CacheFolder;
        newCodeGenFolder=tmpConfig.CodeGenFolder;

        oldPaths={oldCacheFolder,oldCodeGenFolder};
        newPaths={'',''};



        if~ismember('CacheFolder',defs)
            newPaths{1}=locCheckFolderExists(newCacheFolder,'CacheFolder',opts.createDir);
        else
            newPaths{1}=oldCacheFolder;
        end
        if~ismember('CodeGenFolder',defs)
            newPaths{2}=locCheckFolderExists(newCodeGenFolder,'CodeGenFolder',opts.createDir);
        else
            newPaths{2}=oldCodeGenFolder;
        end


        [cacheFolder,codeGenFolder]=locUpdatePath(oldPaths,newPaths,opts.keepPreviousPath);


        FileGenConfig=copy(tmpConfig);



        if~ismember('CacheFolder',defs)
            FileGenConfig.CacheFolder=cacheFolder;
        end
        if~ismember('CodeGenFolder',defs)
            FileGenConfig.CodeGenFolder=codeGenFolder;
        end


    case 'get'
        locVerifyNargoutCount(action,nargout,1);

        prop=locParseProperty(action,args.singleArg);



        if ParallelBuildInProgress
            tmpCfg=ParallelFileGenConfig;
        else
            if BuildInProgress
                tmpCfg=CurFileGenConfig;
            else
                tmpCfg=locGetSafeConfigCopy(FileGenConfig,false,TransformPaths);
            end
        end

        varargout{1}=tmpCfg.(prop);


    case 'getinternalvalue'
        locVerifyNargoutCount(action,nargout,1);

        argFields=Simulink.FileGenConfig.getPropListsForInputParser();
        [args,~,defs]=locParseInput(argFields,false,action,...
        args.singleArg,args.singleArg);

        aFields=fieldnames(args);

        aFields=setdiff(aFields,defs);

        if(length(aFields)~=1)
            DAStudio.error('RTW:utility:invalidArgCountForAction',action,'1');
        end

        varargout{1}=FileGenConfig.(aFields{1});


    case 'getinternalconfig'
        locCheckBuildInProgress(BuildInProgress,ParallelBuildInProgress);
        locVerifyNargoutCount(action,nargout,1);

        locErrorIfAdditionalArgs(action,args)

        varargout{1}=copy(FileGenConfig);

    otherwise
        DAStudio.error('RTW:buildProcess:unknownBuildControlAction',action);
    end

end

















function cleanup=locFileGenControlExecutionInProgress(action)
    persistent fileGenControlExecutionInProgress;
    switch action
    case 'check'

        if fileGenControlExecutionInProgress
            DAStudio.error('RTW:buildProcess:InFileGenControl');
        else

            cleanup=onCleanup(@()locFileGenControlExecutionInProgress('clear'));
            fileGenControlExecutionInProgress=true;
        end
    case 'clear'

        cleanup=[];
        fileGenControlExecutionInProgress=false;
    otherwise
        assert(false,'Unknown action: %s',action);
    end
end
















function[args,unmatched,defs,p]=locParseInput(pFields,...
    keepUnmatched,...
    action,...
    varargin)


    if~isa(pFields,'inputParser')

        p=inputParser;
        p.KeepUnmatched=true;
        p.StructExpand=true;
        p.CaseSensitive=false;

        for i=1:length(pFields)

            if~isempty(pFields{i}{3})
                p.addParameter(pFields{i}{1},pFields{i}{2},pFields{i}{3});
            else
                p.addParameter(pFields{i}{1},pFields{i}{2});
            end
        end
    else
        p=pFields;
    end

    p.parse(varargin{:});

    args=p.Results;
    unmatched=p.Unmatched;
    defs=p.UsingDefaults;

    if~keepUnmatched
        locErrorIfAdditionalArgs(action,unmatched);
    end

end














function property=locParseProperty(action,propertyCandidate)

    argFields=Simulink.FileGenConfig.getPropListsForInputParser();

    validProperties=cellfun(@(a)a{1},argFields,'UniformOutput',false);
    property=validProperties(strcmpi(propertyCandidate,validProperties));

    if isempty(property)
        DAStudio.error('RTW:buildProcess:badArgsForAction',action,propertyCandidate);
    else
        property=property{1};
    end
end









function normalizedFolderName=locCheckFolderExists(folderName,folderType,createDirIfNonExistent)
    curPWD=pwd;












    if isempty(folderName)
        normalizedFolderName='';
    else
        d=dir(folderName);
        if isempty(d)

            if createDirIfNonExistent
                builtin('mkdir',folderName);
            else
                DAStudio.error('RTW:buildProcess:rootBuildDirDoesNotExist',...
                folderType,folderName);
            end
        end







        cd(folderName);
        normalizedFolderName=coder.make.internal.transformPaths(pwd,'pathType','full');
        cd(curPWD);
    end
end

function locValidateCacheFolder(cacheDir)


    canonicalTmpDir=builtin('_canonicalizepath',tempdir);
    canonicalCacheDir=builtin('_canonicalizepath',cacheDir);
    if startsWith(canonicalTmpDir,canonicalCacheDir)
        DAStudio.error('RTW:buildProcess:cacheDirContainsTmpDir',...
        canonicalTmpDir,canonicalCacheDir);
    end
end









function[cacheFolder,codeGenFolder]=locUpdatePath(oldPaths,newPaths,keepPreviousPaths)
    cacheFolder=newPaths{1};
    codeGenFolder=newPaths{2};


    if isfolder(cacheFolder)
        locValidateCacheFolder(cacheFolder);
    end





    if~keepPreviousPaths


        pathsToRemove=setdiff(oldPaths,newPaths);
        for i=1:length(pathsToRemove)

            if isempty(pathsToRemove{i})
                continue;
            end




            pat=locCreatePathPat(pathsToRemove{i});
            if~isempty(regexp(path,pat,'once'))

                rmpath(pathsToRemove{i});
            end
        end
    end


    pathsToAdd=setdiff(newPaths,oldPaths);

    for i=1:length(pathsToAdd)
        if~isempty(pathsToAdd{i})

            addpath(pathsToAdd{i});
        end
    end
end














function locErrorIfAdditionalArgs(action,unmatched)

    f=fields(unmatched);
    if isempty(f)
        return;
    end

    badFields=sprintf('%s\n',f{:});

    DAStudio.error('RTW:buildProcess:badArgsForAction',action,badFields);

end














function locVerifyNargoutCount(action,actual,expected)

    if(actual>expected)
        DAStudio.error('RTW:buildProcess:badNargCountForAction',action);
    end

end















function pat=locCreatePathPat(p)

    esc_p=regexptranslate('escape',p);
    patFront=['^',esc_p,pathsep];
    patMid=[pathsep,esc_p,pathsep];
    patEnd=[pathsep,esc_p,'$'];

    pat=['(',patFront,')|(',patMid,')|(',patEnd,')'];

end














function FileGenConfig=locCreateDefaultFileGenConfig()

    FileGenConfig=Simulink.FileGenConfig;
    FileGenConfig.CacheFolder=get_param(0,'CacheFolder');
    FileGenConfig.CodeGenFolder=get_param(0,'CodeGenFolder');
    FileGenConfig.CodeGenFolderStructure=Simulink.filegen.CodeGenFolderStructure.fromString(get_param(0,'CodeGenFolderStructure'));
    return;
end














function cfg=locGetSafeConfigCopy(srcCfg,forcePWD,transformPWD)

    cfg=copy(srcCfg);
    if(forcePWD||isempty(cfg.CacheFolder))
        if transformPWD
            f=coder.make.internal.transformPaths(pwd,'pathType','full');
        else
            f=pwd;
        end
        cfg.CacheFolder=f;
    end
    if(forcePWD||isempty(cfg.CodeGenFolder))
        if transformPWD
            f=coder.make.internal.transformPaths(pwd,'pathType','full');
        else
            f=pwd;
        end
        cfg.CodeGenFolder=f;
    end
    return;
end










function locCheckBuildInProgress(BuildInProgress,ParallelBuildInProgress)

    if(BuildInProgress||ParallelBuildInProgress)


        msg=sprintf('''%s''\n','getConfig','get');
        DAStudio.error('RTW:buildProcess:BuildInProgress',msg);
    end
end






