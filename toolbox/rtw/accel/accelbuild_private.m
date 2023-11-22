function codeWasUpToDate=accelbuild_private(modelName,okToPushNags,codeExecProfTop,codeExecStackTop,varargin)

    if nargin==2
        codeExecProfTop=false;
        codeExecStackTop=false;
    end
    codeWasUpToDate=LocalAccelbuildprivate(modelName,okToPushNags,codeExecProfTop,codeExecStackTop,varargin{:});



    function codeWasUpToDate=LocalAccelbuildprivate(modelName,okToPushNags,codeExecProfTop,codeExecStackTop,varargin)

        p=inputParser;
        p.addParameter('SILModelReferences',[]);
        p.addParameter('PILModelReferences',[]);
        p.addParameter('SILModelReferencesTopModel',[]);
        p.addParameter('PILModelReferencesTopModel',[]);
        p.parse(varargin{:});

        preserve_dirty=Simulink.PreserveDirtyFlag(modelName,'blockDiagram');

        hModel=get_param(modelName,'handle');

        [buildDir,rootDir]=accelBuildDir(modelName,okToPushNags);

        accelSystemTargetFile=get_param(hModel,'AccelSystemTargetFile');
        accelTemplateMakeFile=get_param(hModel,'AccelTemplateMakeFile');
        accelMakeCommand=get_param(hModel,'AccelMakeCommand');
        accelVerboseBuild=get_param(hModel,'AccelVerboseBuild');

        activeConfigSet=getActiveConfigSet(hModel);
        MangleLength=get_param(activeConfigSet,'MangleLength');
        switchTarget(activeConfigSet,accelSystemTargetFile,[]);
        set_param(hModel,'RTWTemplateMakeFile',accelTemplateMakeFile);
        set_param(hModel,'RTWMakeCommand',accelMakeCommand);
        set_param(hModel,'RTWBuildArgs','');
        set_param(hModel,'RTWGenerateCodeOnly','off');
        set_param(hModel,'RTWVerbose',accelVerboseBuild);
        set_param(activeConfigSet,'MangleLength',MangleLength);
        vmBasedExecution=...
        isequal(get_param(hModel,'VmBasedExecution'),'on');
        directEmitCExecution=...
        slfeature('DirectEmitCExecution');
        compileInAccelForNormalMode=...
        isequal(get_param(hModel,'CompileInAccelForNormalMode'),'on');
        noSerializeForJIT=...
        (vmBasedExecution&&...
        slsvTestingHook('VMSimulationsNoSerialization'))||...
        (compileInAccelForNormalMode&&...
        slsvTestingHook('EnhancedNormalModeNoSerialization'));
        if(vmBasedExecution)
            set_param(hModel,'BooleansAsBitfields','off');
            set_param(hModel,'StateBitsets','off');
            set_param(hModel,'DataBitsets','off');
        end
        modelReferenceTargetType=get_param(hModel,'ModelReferenceTargetType');
        vmBasedExecutionOfRefMdl=...
        vmBasedExecution&&~isequal(modelReferenceTargetType,'NONE');
        cleanupModelReferenceTargetType=[];
        if(vmBasedExecutionOfRefMdl)
            if(~isequal(modelReferenceTargetType,'SIM'))
                DAStudio.error(...
                'Simulink:Engine:InvalidModelRefTargetTypeForVmExecution',...
                modelReferenceTargetType);
            end
            if 0~=slfeature('SetMdlRefTgtTypeToNONEForModelRefVMSimulations')
                set_param(hModel,'ModelReferenceTargetType','NONE');


                cleanupModelReferenceTargetType=onCleanup(@()...
                set_param(hModel,'ModelReferenceTargetType',modelReferenceTargetType));
            end
        end

        if~vmBasedExecution||directEmitCExecution
            lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
        end


        tfl=get_param(hModel,'SimTargetFcnLibHandle');
        set_param(hModel,'TargetFcnLibHandle',tfl);
        tfl.doPreRTWBuildProcessing;


        if strcmpi(get_param(hModel,'IsCPPClassGenMode'),'on')
            switch lower(get_param(hModel,'cacheMultiInstanceERTCode'))
            case 'off'
                set_param(hModel,'CodeInterfacePackaging','Nonreusable function');
            otherwise
                set_param(hModel,'CodeInterfacePackaging','Reusable function');
            end
        end


        if strcmp(get_param(0,'AcceleratorUseTrueIdentifier'),'off')
            paramStack=rtw.util.parameterStack(hModel,'ObfuscateCode');%#ok<NASGU>
            set_param(hModel,'ObfuscateCode',1);
        end

        delete(preserve_dirty);

        rtwBuildError='';
        try
            build_stage=locSetupBuildStage(okToPushNags,vmBasedExecution,accelVerboseBuild,modelName);%#ok<NASGU>

            if~vmBasedExecution||directEmitCExecution
                result=sl('slbuild_private',modelName,'StandaloneCoderTarget',...
                'OkayToPushNags',okToPushNags,...
                'TopModelAccelWithTimeProfiling',codeExecProfTop,...
                'TopModelAccelWithStackProfiling',codeExecStackTop,...
                'SILModelReferences',p.Results.SILModelReferences,...
                'PILModelReferences',p.Results.PILModelReferences,...
                'SILModelReferencesTopModel',p.Results.SILModelReferencesTopModel,...
                'PILModelReferencesTopModel',p.Results.PILModelReferencesTopModel,...
                'SlbDefaultCompInfo',lDefaultCompInfo);


                codeWasUpToDate=result.buildResult.codeWasUpToDate;
            else
                if(~noSerializeForJIT)
                    if exist(buildDir,'dir')==7

                        debugDir=fullfile(buildDir,'rtwgen_tlc');
                        if exist(debugDir,'dir')==7
                            [s,msg]=rmdir(debugDir,'s');
                            if~s
                                DAStudio.error('RTW:utility:removeError',msg);
                            end
                        end
                    else
                        mkdir(buildDir)
                    end
                end


                tfl.resetUsageCounts;

                TflStr=get_param(modelName,'CodeReplacementLibrary');
                HwStr=get_param(modelName,'TargetHWDeviceType');
                validateTflHw(tfl,TflStr,HwStr);

                targetLang={get_param(modelName,'TargetLang'),...
                get_param(modelName,'TargetLangStandard')};
                tfl.validateLangConstraint(targetLang);

                exitMsg='';
                if(isequal(accelVerboseBuild,'on'))
                    if(vmBasedExecutionOfRefMdl)
                        enterMsg=...
                        DAStudio.message('RTW:makertw:enterMdlRefSIMTarget',...
                        modelName);
                        exitMsg=...
                        DAStudio.message('RTW:makertw:exitMdlRefSIMTarget',...
                        modelName);
                    else
                        enterMsg=...
                        DAStudio.message('RTW:makertw:enterAccelTarget',...
                        modelName);
                        exitMsg=...
                        DAStudio.message('RTW:makertw:exitAccelTarget',...
                        modelName);
                    end
                    fprintf('%s\n',enterMsg);
                    if(~noSerializeForJIT)
                        buildDirMsg=DAStudio.message('RTW:makertw:generatingCode',...
                        buildDir);
                        fprintf('%s\n',buildDirMsg);
                    end
                end
                if(noSerializeForJIT)
                    [sFcns,buildInfo,modelRefInfo]=...
                    rtwgen(modelName,...
                    'CaseSensitivity','on',...
                    'Language','C',...
                    'NoSerializeForJIT','on');%#ok<ASGLU>
                else
                    [sFcns,buildInfo,modelRefInfo]=...
                    rtwgen(modelName,...
                    'CaseSensitivity','on',...
                    'Language','C',...
                    'OutputDirectory',buildDir);%#ok<ASGLU>
                    markerFile=fullfile(rootDir,fullfile('slprj','sl_proj.tmw'));
                    coder.internal.folders.MarkerFile.create(markerFile);
                end
                codeWasUpToDate=buildInfo.allRequestedChecksumsMatch;

                if(isequal(accelVerboseBuild,'on'))
                    fprintf('%s\n',exitMsg);
                end
                set_param(modelName,'TargetFcnLibHandle',[]);
                rtwgen(modelName,'TerminateCompile','on');










            end
        catch ME
            rtwBuildError=ME;
        end

        delete(cleanupModelReferenceTargetType);


        ffAMSI=fullfile(buildDir,'amsi_serial.mat');
        if exist(buildDir,'dir')>0
            amsi_serial=get_param(hModel,'AMSITableSerialized');%#ok<NASGU>
            save(ffAMSI,'amsi_serial');
        end


        if~isempty(rtwBuildError)

            comp=coder.make.internal.getMexCompilerInfo();
            if isempty(comp)||strcmp(comp.compStr,'LCC-x')
                id_lcc='Simulink:Engine:AccelLCCBuildFailed';
                message=DAStudio.message(id_lcc,modelName);
                err_lcc=MException(id_lcc,'%s',message);
                err_lcc=addCause(err_lcc,rtwBuildError);
                throw(err_lcc);
            elseif strcmp(rtwBuildError.identifier,'MATLAB:MKDIR:OSError')


                mkdirErrId='Simulink:utility:errorCreatingDir';

                message=DAStudio.message(...
                mkdirErrId,...
                buildDir,...
                rtwBuildError.message...
                );

                if(ispc())
                    message=strrep(message,'\','\\');
                end
                newExc=MException(mkdirErrId,message);
                throw(newExc);
            else

                throw(rtwBuildError);
            end
        end

        set_param(modelName,'TargetFcnLibHandle',[]);


        function build_stage=locSetupBuildStage(okToPushNags,vmBasedExecution,accelVerboseBuild,modelName)
            build_stage=[];
            if(~vmBasedExecution&&okToPushNags)||...
                (vmBasedExecution&&okToPushNags&&isequal(accelVerboseBuild,'on'))
                build_stage=Simulink.output.Stage(...
                message('Simulink:SLMsgViewer:Build_Stage_Name').getString(),...
                'ModelName',modelName,'UIMode',okToPushNags);
            end





