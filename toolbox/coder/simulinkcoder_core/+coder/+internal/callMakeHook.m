function makeHookData=callMakeHook(hook,lBuildArgs,lBuildOpts,varargin)






    persistent p
    if isempty(p)
        p=inputParser;
        addParameter(p,'SilentExitHook',false,@islogical);
        addParameter(p,'SkipEcoderHook',false,@islogical);
        addParameter(p,'FolderToRunFrom','');
        addParameter(p,'CodeWasUpToDate',false,@islogical);
        addParameter(p,'SystemTargetFilename','',@ischar);
        addParameter(p,'ModelReferenceTargetType','',@ischar);
        addParameter(p,'BuildDirectory','',@ischar);
        addParameter(p,'ModelName','',@ischar);
        addParameter(p,'BuildInfo',[]);
        addParameter(p,'TemplateMakefile','',@ischar);
        addParameter(p,'MakeRTWHookFile','',@ischar);
        addParameter(p,'Verbose','',@islogical);
        addParameter(p,'DispHook',@disp);
        addParameter(p,'SlBuildProfileIsOn','',@islogical);
        addParameter(p,'UseChecksum',[],@islogical);
        addParameter(p,'GeneratedTLCSubDir','',@ischar);
        addParameter(p,'LocalAnchorFolder','',@ischar);
    end
    parse(p,varargin{:});

    lUseChecksum=p.Results.UseChecksum;
    lGeneratedTLCSubDir=p.Results.GeneratedTLCSubDir;

    mdlRefTgtType=p.Results.ModelReferenceTargetType;
    lBuildDirectory=p.Results.BuildDirectory;
    lModelName=p.Results.ModelName;
    lBuildInfo=p.Results.BuildInfo;
    lTemplateMakefile=p.Results.TemplateMakefile;
    lMakeRTWHookFile=p.Results.MakeRTWHookFile;
    lVerbose=p.Results.Verbose;
    lDispHook=p.Results.DispHook;
    slbuildProfileIsOn=p.Results.SlBuildProfileIsOn;

    if slbuildProfileIsOn
        targetName=slprivate('perf_logger_target_resolution',mdlRefTgtType,lModelName,false,false);
    else
        targetName=mdlRefTgtType;
    end

    PerfTools.Tracer.logSimulinkData('SLbuild',lModelName,...
    targetName,['make_rtw: ',hook],true);

    args=locGetHookArgs(lBuildInfo,lTemplateMakefile,hook);

    skipEcoderHook=p.Results.SkipEcoderHook;
    silentExitHook=p.Results.SilentExitHook&&strcmp(hook,'exit');

    if isequal(hook,'entry')


        makeHookData=coder.internal.MakeHookData;

        if isequal(get_param(lModelName,'SystemTargetFile'),'realtime.tlc')||...
            (isequal(get_param(lModelName,'SystemTargetFile'),'ert.tlc')&&...
            codertarget.target.isCoderTarget(lModelName))
            realtime.accessInternalInfo('initializeRTT');
        end
    end


    if~isempty(lMakeRTWHookFile)


        if~any(strcmp(hook,{'before_make','after_make','exit'}))
            lBuildOpts.codeWasUpToDate=p.Results.CodeWasUpToDate;
        end

        defaultHookArgs={args.RTWroot,...
        args.TMF,lBuildOpts,lBuildArgs,args.buildInfo};


        originalPwd=pwd;


        lFolderToRunFrom=p.Results.FolderToRunFrom;
        if~isempty(lFolderToRunFrom)&&~i_compare_paths(lFolderToRunFrom,pwd)
            cd(lFolderToRunFrom);
        end


        lRestoreOrigFolder=onCleanup(@()i_restore_pwd(originalPwd));


        pwdBeforeInvokingHook=pwd;




        switch(nargin(lMakeRTWHookFile))
        case 6



            hookArgs=[{hook},{lModelName},defaultHookArgs(1:4)];
        case{7,-1}
            hookArgs=[{hook},{lModelName},defaultHookArgs];
        otherwise




            DAStudio.error('RTW:utility:invalidArgCount',...
            'make_rtw_hook function','6');
        end

        try
            feval(lMakeRTWHookFile,hookArgs{:});
        catch exc

            if internal.fmudialog.export.IsFMUTarget(lModelName)
                rethrow(exc);
            end

            errID='RTW:makertw:makeHookError';



            errMsg=rtwprivate('escapeOriginalMessage',exc);
            errMsg=DAStudio.message(errID,lMakeRTWHookFile,...
            hook,errMsg);

            newExc=MSLException([],errID,errMsg);
            newExc=newExc.addCause(exc);
            throw(newExc);
        end


        if~i_compare_paths(pwdBeforeInvokingHook,pwd)
            MSLDiagnostic('RTW:makertw:changeDirNotAllowed',...
            ['''',hook,''' hook call to '''...
            ,lMakeRTWHookFile,''''],pwd,pwdBeforeInvokingHook).reportAsWarning;
        end






        i_legacyRestoreMinfo(lModelName,mdlRefTgtType,hook,lMakeRTWHookFile);


        delete(lRestoreOrigFolder)
    end

    if isempty(lMakeRTWHookFile)


        if strcmp(hook,'entry')||strcmp(hook,'exit')
            switch(mdlRefTgtType)
            case{'SIM','RTW'}



                msg='';
                if strcmp(hook,'entry')
                    if lVerbose
                        if lUseChecksum
                            msg=sl('construct_modelref_message',...
                            'RTW:makertw:enterMdlRefCoderTargetChecksum',...
                            'RTW:makertw:enterMdlRefSIMTargetChecksum',...
                            mdlRefTgtType,lModelName);
                        else
                            msg=sl('construct_modelref_message',...
                            'RTW:makertw:enterMdlRefCoderTarget',...
                            'RTW:makertw:enterMdlRefSIMTarget',...
                            mdlRefTgtType,lModelName);
                        end
                    end
                elseif~lBuildOpts.codeWasUpToDate
                    msg=sl('construct_modelref_message',...
                    'RTW:makertw:exitMdlRefCoderTarget',...
                    'RTW:makertw:exitMdlRefSIMTarget',...
                    mdlRefTgtType,lModelName);
                end
            otherwise
                tgt=get_param(lModelName,'SystemTargetFile');
                switch(tgt)
                case 'accel.tlc'
                    if strcmp(hook,'entry')
                        msgID='RTW:makertw:enterAccelTarget';
                    else
                        msgID='RTW:makertw:exitAccelTarget';
                    end
                case 'raccel.tlc'
                    if isequal(hook,'entry')

                        msgID='';
                    else
                        msgID='Simulink:tools:rapidAccelBuildFinish';
                    end
                otherwise
                    if strcmp(hook,'entry')
                        msgID='RTW:makertw:enterRTWBuild';
                    else
                        if strcmp(get_param(lModelName,'GenCodeOnly'),'off')
                            msgID='RTW:makertw:exitRTWBuild';
                        else
                            msgID='RTW:makertw:exitRTWGenCodeOnly';
                        end
                    end
                end
                if(~silentExitHook&&~isempty(msgID))
                    msg=DAStudio.message(msgID,lModelName);
                else
                    msg='';
                end
            end
            if~isempty(msg)
                feval(lDispHook{:},msg);
            end
        else


            if strcmp(hook,'error')
                msg=DAStudio.message('RTW:makertw:buildAborted',lModelName);
                feval(lDispHook{:},msg);
                return;
            end
        end
    end


    cs=getActiveConfigSet(lModelName);
    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    isMdlRefSim=strcmpi(mdlRefTgtType,'SIM');
    callEcoderHook=isERT&&~skipEcoderHook&&~isMdlRefSim&&...
    any(strcmp(hook,{'entry','before_tlc','after_tlc','exit','error'}));
    if callEcoderHook
        if strcmp(hook,'entry')&&~ecoderinstalled()
            DAStudio.error('RTW:makertw:licenseUnavailable',...
            p.Results.SystemTargetFilename);
        end

        cleanupFcn=make_ecoder_hook(hook,lBuildDirectory,lGeneratedTLCSubDir,lModelName,cs,...
        p.Results.LocalAnchorFolder,mdlRefTgtType);

        if strcmp(hook,'entry')
            addCleanupFunction(makeHookData,cleanupFcn);
        end
    end


    if~(isMdlRefSim||...
        isequal(strtok(get_param(lModelName,'SystemTargetFile'),'.'),'accel')||...
        ~isequal(get_param(lModelName,'RapidAcceleratorSimStatus'),'inactive'))
        coder.internal.invoke_rtwbuild_custom_hook(lModelName,args.customHook,args.buildInfo);
    end
    PerfTools.Tracer.logSimulinkData('SLbuild',lModelName,...
    targetName,['make_rtw: ',hook],false);















    function args=locGetHookArgs(lBuildInfo,lTemplateMakefile,hook)


        args.RTWroot=fullfile(matlabroot,'rtw');
        args.TMF=lTemplateMakefile;
        args.buildInfo=[];
        args.msgID='';

        switch(hook)
        case 'entry'
            args.RTWroot=[];
            args.TMF=[];
            args.buildInfo=[];
            args.customHook='CodeGenEntry';
            args.msgID='RTW:makertw:enterMdlRefTarget';
        case 'before_tlc'
            args.customHook='CodeGenBeforeTLC';
        case 'after_tlc'
            args.buildInfo=lBuildInfo;
            args.customHook='CodeGenAfterTLC';
        case 'before_make'
            args.buildInfo=lBuildInfo;
            args.customHook='CodeGenBeforeMake';
        case 'after_make'
            args.buildInfo=lBuildInfo;
            args.customHook='CodeGenAfterMake';
        case 'exit'
            args.buildInfo=lBuildInfo;
            args.customHook='CodeGenExit';
        case 'error'
            args.RTWroot=[];
            args.TMF=[];
            args.buildInfo=[];
            args.msgID='';
            args.customHook=[];
        otherwise
            DAStudio.error('RTW:makertw:invalidRTWMakeHook',hook);
        end

        function match=i_compare_paths(path1,path2)


            match=strcmp(...
            coder.make.internal.transformPaths(path1,'pathType','full'),...
            coder.make.internal.transformPaths(path2,'pathType','full')...
            );


            function i_restore_pwd(original_pwd)


                if~strcmp(pwd,original_pwd)
                    cd(original_pwd)
                end


                function i_legacyRestoreMinfo(model,mdlRefTgtType,hook,hookFile)

                    if~strcmp(hook,'entry')||~strcmp(mdlRefTgtType,'NONE')||...
                        contains(fileparts(which(hookFile)),matlabroot)
                        return
                    end

                    minfoFileName=coder.internal.infoMATFileMgr...
                    ('getMatFileName','minfo',model,mdlRefTgtType);
                    if~isfile(minfoFileName)
                        if~isfolder(fileparts(minfoFileName))
                            mkdir(fileparts(minfoFileName));
                        end
                        infoStruct=coder.internal.infoMATFileMgr...
                        ('load','minfo',model,mdlRefTgtType);
                        coder.internal.saveMinfoOrBinfo(infoStruct,minfoFileName);
                    end
