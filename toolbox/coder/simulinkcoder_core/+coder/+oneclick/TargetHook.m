classdef TargetHook<handle








    properties
ModelName
    end

    properties(Hidden)
ConfigSet
        UseTraditionalExtModeInterface=true
    end

    properties(Access=private)
TopModelOrigConfigSet
    end


    methods(Abstract)



        configureExternalModeSettings(this);



        downloadAndRunTargetExecutable(this);



        hardwareName=getHardwareName(this);
    end

    methods
        function this=TargetHook(modelOrCS)
            if isa(modelOrCS,'Simulink.ConfigSet')||...
                isa(modelOrCS,'Simulink.ConfigSetRef')



                this.ConfigSet=modelOrCS;
            else

                assert(ischar(modelOrCS),'input must be a char');
                this.ModelName=modelOrCS;
            end
        end

        function delete(this)








            if isempty(this.ModelName)||~bdIsLoaded(this.ModelName)
                return
            end



            if~isempty(this.TopModelOrigConfigSet)
                origDirtyFlag=get_param(this.ModelName,'Dirty');
                tmpCS=getActiveConfigSet(this.ModelName);
                origCS=this.TopModelOrigConfigSet;
                if~eq(origCS,tmpCS)
                    while isa(origCS,'Simulink.ConfigSetRef')
                        origCS=origCS.getRefConfigSet();
                    end
                    origCS.unlock;
                    slInternal('restoreOrigConfigSetForBuild',...
                    get_param(this.ModelName,'Handle'),...
                    this.TopModelOrigConfigSet,tmpCS);
                end
                set_param(this.ModelName,'Dirty',origDirtyFlag);
            end
        end




        function visible=areExtModeOptionsVisible(this)%#ok<MANU>
            visible=true;
        end



        function preBuild(this)%#ok<MANU>

        end

        function CS=getTemporaryCSForBuild(~,resolvedOrigCS)
            CS=resolvedOrigCS.copy;
        end

        function configureModelIfNecessary(this)

            origDirtyFlag=get_param(this.ModelName,'Dirty');
            modelHandle=get_param(this.ModelName,'Handle');
            this.TopModelOrigConfigSet=getActiveConfigSet(this.ModelName);
            resolvedOrigCS=this.TopModelOrigConfigSet;
            if isa(resolvedOrigCS,'Simulink.ConfigSetRef')
                tmpCS=resolvedOrigCS.getResolvedConfigSetCopy;

                tmpCS=this.getTemporaryCSForBuild(tmpCS);
            else
                tmpCS=this.getTemporaryCSForBuild(resolvedOrigCS);
            end
            slInternal('substituteTmpConfigSetForBuild',...
            modelHandle,this.TopModelOrigConfigSet,tmpCS);
            this.configureReferenceModelsIfNecessary;
            resolvedOrigCS.lock;
            set_param(this.ModelName,'Dirty',origDirtyFlag);
        end

        function configureReferenceModelsIfNecessary(this)%#ok<MANU>

        end

        function preExtModeConnectAction(this)%#ok<MANU>

        end

        function onConnectAction(this)%#ok<MANU>

        end

        function enableExtMode(this)
            cs=getActiveConfigSet(this.ModelName);


            set_param(cs,'ExtMode','on');


            set_param(cs,'OnTargetWaitForStart','on');


            this.configureExternalModeSettings;
        end

        function connected=extModeConnect(this,varargin)


            p=inputParser;
            p.addParameter('ThrowError',true);
            p.addParameter('ConnectTimeout','');
            p.parse(varargin{:});

            cs=getActiveConfigSet(this.ModelName);

            if~coder.internal.xcp.isXCPTarget(cs)

                mexArgs=get_param(this.ModelName,'ExtModeMexArgs');
                restoreMexArgs=onCleanup(@()...
                set_param(this.ModelName,'ExtModeMexArgs',mexArgs));
















                tokens=coder.internal.xcp.tokenizeArgsString(mexArgs);

                idx=get_param(this.ModelName,'ExtModeTransport');
                transport=Simulink.ExtMode.Transports.getExtModeTransport(cs,idx);

                if numel(tokens)<=3&&...
                    (strcmp(transport,Simulink.ExtMode.Transports.TCP.Transport)||...
                    strcmp(transport,Simulink.ExtMode.Transports.Serial.Transport))

                    if numel(tokens)<3

                        bDirInfo=RTW.getBuildDir(this.ModelName);
                        anchorFolder=bDirInfo.CodeGenFolder;

                        connectionParams=coder.internal.xcp.parseExtModeArgs(mexArgs,...
                        transport,this.ModelName,anchorFolder);

                        if strcmp(transport,Simulink.ExtMode.Transports.TCP.Transport)
                            mexArgs=sprintf('''%s'' %d %d',...
                            connectionParams.targetName,...
                            connectionParams.verbosityLevel,...
                            connectionParams.targetPort);
                        else

                            mexArgs=sprintf('%d ''%s'' %d',...
                            connectionParams.verbosityLevel,...
                            connectionParams.portName,...
                            connectionParams.baudRate);
                        end
                    end


                    set_param(this.ModelName,'ExtModeMexArgs',...
                    [mexArgs,' ',p.Results.ConnectTimeout]);

                elseif(numel(tokens)==2&&...
                    strcmp(transport,'commservice'))


                    set_param(this.ModelName,'ExtModeMexArgs',...
                    [mexArgs,' ',p.Results.ConnectTimeout]);
                end
            end

            connected=false;
            hardwareName=this.getHardwareName;


            coder.oneclick.TargetHook.CacheIssuedWarningEvent('clear');

            eventTag='matlab::lang::diagnostic::IssuedEnabledWarningEvent';
            callback=@coder.oneclick.TargetHook.CacheIssuedWarningEvent;

            issuedWarningEventListener=matlab.internal.mvm.eventmgr.MVMEvent.subscribe(eventTag,callback);
            deleteListener=onCleanup(@()delete(issuedWarningEventListener));


            set_param(this.ModelName,'SimulationCommand','connect');


            drawnow;



            noDataUploadWarnOccurred=false;

            cachedWarnings=coder.oneclick.TargetHook.CacheIssuedWarningEvent();
            coder.oneclick.TargetHook.CacheIssuedWarningEvent('clear');

            if~isempty(cachedWarnings)
                noDataUploadWarnOccurred=any(cellfun(@(arg)strcmp(arg.Warning.identifier,...
                'Simulink:Engine:NoDataUploadBlocks'),cachedWarnings));
            end


            pauseInterval=0.1;
            maxAttempts=50;
            nFailedAttempts=0;
            while nFailedAttempts<maxAttempts
                if(isequal(get_param(this.ModelName,'SimulationStatus'),'external')&&...
                    any(strcmp(get_param(this.ModelName,'ExtModeTargetSimStatus'),...
                    {'running','waitingToStart'}))&&...
                    isequal(get_param(this.ModelName,'ExtModeConnected'),'on'))
                    connected=true;
                    break;
                end


                nFailedAttempts=nFailedAttempts+1;
                pause(pauseInterval);
            end


            if~connected
                DAStudio.error('Simulink:Extmode:OneClickConnectFailed',...
                hardwareName,this.ModelName);
            end














            pauseInterval=0.1;
            maxAttempts=50;
            nFailedAttempts=0;
            if strcmp(get_param(this.ModelName,'ExtModeArmWhenConnect'),'on')&&...
                ~noDataUploadWarnOccurred
                while nFailedAttempts<maxAttempts
                    if strcmp(get_param(this.ModelName,'ExtModeUploadStatus'),'armed')
                        break;
                    end

                    nFailedAttempts=nFailedAttempts+1;
                    pause(pauseInterval);
                end
            end


            modelStatus=coder.oneclick.ModelStatus.instance;
            modelStatus.updateProgress('Running',100);

            if~coder.internal.xcp.isXCPTarget(cs)
                restoreMexArgs.delete;
            end
        end
    end

    methods(Static,Sealed=true)
        function obj=createOneClickObjAndConfigureModelForExtModeConnect(modelName)











            if strcmp(get_param(modelName,'BuildInProgress'),'on')



                obj=true;
                return
            end



            obj=coder.oneclick.TargetHook.createOneClickTargetHookObject(modelName);
            obj.configureModelIfNecessary;






            preserve_dirty=Simulink.PreserveDirtyFlag(modelName,'blockDiagram');%#ok<NASGU>


            obj.enableExtMode();

























            cs=getActiveConfigSet(modelName);
            idx=get_param(modelName,'ExtModeTransport');
            transport=Simulink.ExtMode.Transports.getExtModeTransport(cs,idx);

            if strcmp(transport,'commservice')

                mexArgs=get_param(modelName,'ExtModeMexArgs');
                connectTimeout='5';
                set_param(modelName,'ExtModeMexArgs',...
                [mexArgs,' ',connectTimeout]);
            end

            obj.preExtModeConnectAction();
        end

        function obj=createOneClickTargetHookObject(modelOrCS)


            isRTT=coder.oneclick.Utils.isModelRTT(modelOrCS);
            if isequal(get_param(modelOrCS,'IsSLCInUse'),'off')
                if slfeature('UnifiedTargetHardwareSelection')
                    assert(coder.oneclick.Utils.isRTTInstalledOriginal||...
                    coder.oneclick.Utils.isAnySimulinkTargetInstalled||...
                    ~isempty(ver('SerDes')),...
                    ['At least one "Simulink target" support ',...
                    'package must be installed']);
                    if isRTT
                        obj=coder.oneclick.ROTHTargetHook(modelOrCS);
                    else
                        obj=coder.oneclick.CoderTargetHook(modelOrCS);
                    end
                else
                    assert(coder.oneclick.Utils.isRTTInstalledOriginal,...
                    ['At least one "Run on Target Hardware" support ',...
                    'package must be installed']);
                    obj=coder.oneclick.ROTHTargetHook(modelOrCS);
                end

                return;
            end


            isSLDRT=any(strcmp(get_param(modelOrCS,'SystemTargetFile'),...
            {'sldrt.tlc','sldrtert.tlc','rtwin.tlc','rtwinert.tlc'}));
            isCoderTarget=codertarget.target.isCoderTarget(modelOrCS);
            assert(~(isRTT&&isCoderTarget),['A model cannot be ',...
            'for realtime.tlc and Coder target at the same time!']);
            if isRTT
                obj=coder.oneclick.ROTHTargetHook(modelOrCS);
            elseif isSLDRT
                obj=coder.oneclick.SLDRTTargetHook(modelOrCS);
            elseif isCoderTarget
                obj=coder.oneclick.CoderTargetHook(modelOrCS);
            else
                if coder.oneclick.Utils.isCustomHWFeaturedOn

                    obj=coder.oneclick.CustomHWTargetHook(modelOrCS);
                else




                    stf=get_param(modelOrCS,'SystemTargetFile');
                    DAStudio.error('Simulink:Extmode:OneClickUnsupportedModelConfiguration',stf);
                end
            end
        end

        function cachedWarnings=CacheIssuedWarningEvent(aEvent)
            persistent IssuedWarningsCache;
            if isempty(IssuedWarningsCache)
                IssuedWarningsCache={};
            end
            if nargin<1

            elseif strcmpi(aEvent,'clear')
                IssuedWarningsCache={};
            else
                IssuedWarningsCache=...
                [IssuedWarningsCache;{aEvent}];
            end
            cachedWarnings=IssuedWarningsCache;
        end
    end
end




