classdef TargetLaunchersManager<handle






    properties(Constant,Access=private)
        Instance=coder.oneclick.TargetLaunchersManager;
    end

    properties(GetAccess=private,SetAccess=immutable)
        LauncherMap;
    end

    methods(Access=private)
        function this=TargetLaunchersManager()
            mlock;
            this.LauncherMap=containers.Map('KeyType','double','ValueType','any');
        end

        function data=get(this,modelHandle)
            data=[];


            if this.LauncherMap.isKey(modelHandle)
                data=this.LauncherMap(modelHandle);
            end
        end

        function set(this,modelHandle,data)

            if this.LauncherMap.isKey(modelHandle)
                this.remove(modelHandle);
            end


            this.LauncherMap(modelHandle)=data;
        end

        function data=remove(this,modelHandle)
            data=this.LauncherMap(modelHandle);
            this.LauncherMap.remove(modelHandle);
        end

        function contexts=allLaunchers(this)
            contexts=values(this.LauncherMap);
        end
    end

    methods(Static,Access=private)
        function data=createNewLauncher(modelName,...
            anchorFolder,...
            componentCodePath,...
            targetName,...
            boardWithLauncher,...
            configs,...
            toolchainInfo)%#ok            
            data.Board=[];
            data.ConfigRegistry='';
            data.Config='';



            ExtModeConfig=coder.oneclick.TargetLaunchersManager.getExtModeConfig(modelName);









            componentArgs=rtw.connectivity.ComponentArgs(modelName,...
            componentCodePath,...
            modelName,...
            '');
            componentArgs.setAnchorFolder(anchorFolder);

            cs=getActiveConfigSet(modelName);

            if~isempty(boardWithLauncher)

                data.Board=boardWithLauncher;
                exeName=...
                coder.oneclick.TargetLaunchersManager.getDefaultTargetExecutableFullName(...
                componentArgs,toolchainInfo);
                data.Launcher=coder.oneclick.TargetFrameworkLauncher(modelName,...
                boardWithLauncher,...
                componentCodePath,...
                anchorFolder,...
                exeName);
            elseif~isempty(configs)




                isSILAndPWS=false;
                defaultMexCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
                xilCompInfo=coder.internal.utils.XilCompInfo.slCreateXilCompInfo...
                (cs,defaultMexCompInfo,isSILAndPWS);
                componentArgs.setXilCompInfo(xilCompInfo);



                assert(numel(configs)==1,'Invalid configs detected');

                data.ConfigRegistry=configs(1);
                data.Config=feval(configs(1).ConfigClass,componentArgs);
                assert(~isempty(data.Config),'Unable to create a Config Class');

                data.Launcher=coder.oneclick.ConnectivityLauncher(data.Config.getLauncher);
                assert(~isempty(data.Launcher),'Unable to retrieve a launcher');





                try
                    exe=data.Launcher.getExe();
                    isExeAvailable=~isempty(exe);
                catch ME
                    if strcmp(ME.identifier,'Connectivity:target:EmptyExeError')
                        isExeAvailable=false;
                    else
                        rethrow(ME);
                    end
                end

                if~isExeAvailable


                    exeName=coder.oneclick.TargetLaunchersManager.getDefaultTargetExecutableFullName(componentArgs,toolchainInfo);
                    data.Launcher.setExe(exeName);
                end
            else



                launcher=coder.oneclick.TargetLaunchersManager.createHostBasedLauncher(modelName,...
                ExtModeConfig,...
                anchorFolder,...
                componentArgs,...
                toolchainInfo,...
                cs);

                data.Launcher=coder.oneclick.ConnectivityLauncher(launcher);
            end
            assert(~isempty(data.Launcher),'Launcher must be created');

            data.ExtModeConfig=ExtModeConfig;
        end

        function data=createDummyMexArgsErrorLauncher(modelName)
            data.Board=[];
            data.ConfigRegistry='';
            data.Config='';

            extModeConfig=coder.oneclick.TargetLaunchersManager....
            getExtModeConfig(modelName);

            data.Launcher=coder.oneclick.DummyMexArgsErrorLauncher(...
            extModeConfig.MexArgs);
            data.ExtModeConfig=extModeConfig;
        end

        function hostLauncher=createHostBasedLauncher(modelName,...
            ExtModeConfig,...
            anchorFolder,...
            componentArgs,...
            toolchainInfo,...
            cs)


            connectionParams=coder.internal.xcp.parseExtModeArgs(ExtModeConfig.MexArgs,...
            ExtModeConfig.TransportName,modelName,anchorFolder);

            tokens=coder.internal.xcp.tokenizeArgsString(ExtModeConfig.MexArgs);
            connectionCommandLineArgs='';

            if(strcmp(ExtModeConfig.TransportName,Simulink.ExtMode.Transports.XCPTCP.Transport)||...
                strcmp(ExtModeConfig.TransportName,Simulink.ExtMode.Transports.TCP.Transport))

                if~isa(cs,'Simulink.ConfigSetRef')








                    hostLauncher=coder.oneclick.TCPIPHostLauncher(componentArgs);
                else
                    if(connectionParams.targetPort==0)




                        DAStudio.error('Simulink:Extmode:DefaultHostBasedTargetCannotUsePortZeroWithConfigSetRef');
                    end

                    if~strcmp(connectionParams.targetName,'localhost')&&...
                        ~startsWith(connectionParams.targetName,'127.')&&...
                        ~isempty(connectionParams.targetName)&&...
                        ~strcmp(connectionParams.targetName,'[]')




                        DAStudio.error('Simulink:Extmode:DefaultHostBasedTargetMustUseLocalHostWithConfigSetRef');
                    end


                    hostLauncher=rtw.connectivity.HostLauncher(componentArgs);

                    targetPortExplicitlySet=(numel(tokens)>2);

                    if targetPortExplicitlySet
                        connectionCommandLineArgs=[' -port ',num2str(connectionParams.targetPort)];
                    end
                end
            else







                hostLauncher=rtw.connectivity.HostLauncher(componentArgs);

                if(strcmp(ExtModeConfig.TransportName,Simulink.ExtMode.Transports.XCPSerial.Transport)||...
                    strcmp(ExtModeConfig.TransportName,Simulink.ExtMode.Transports.Serial.Transport))



                    baudRateExplicitlySet=(numel(tokens)>2);

                    if baudRateExplicitlySet
                        connectionCommandLineArgs=[' -baud ',num2str(connectionParams.baudRate)];
                    end
                end
            end

            exeName=coder.oneclick.TargetLaunchersManager.getDefaultTargetExecutableFullName(componentArgs,toolchainInfo);
            hostLauncher.setExe(exeName);





            [~,commandLineArgs]=hostLauncher.getCommand;
            commandLineArgs=[commandLineArgs,' -w'];




            purelyIntegerCode=strcmp(ExtModeConfig.PurelyIntegerCode,'on');
            stopTime=str2double(ExtModeConfig.StopTime);
            baseRate=str2double(ExtModeConfig.FixedStepSize);

            if purelyIntegerCode&&~isinf(stopTime)&&~isnan(baseRate)





                stopTimeInTicks=stopTime/baseRate;

                if(stopTimeInTicks>intmax('int32'))
                    maxStopTime=intmax('int32')*baseRate;
                    DAStudio.error('Simulink:Extmode:MaxStopTimeExceededForPurelyIntegerCode',maxStopTime);
                end

                stopTimeCommandLineArgs=sprintf(' -tf %d',stopTimeInTicks);
                commandLineArgs=[commandLineArgs,stopTimeCommandLineArgs];
            end

            commandLineArgs=[commandLineArgs,connectionCommandLineArgs];

            hostLauncher.setArgString(commandLineArgs)

        end



        function configs=getConnectivityConfigs(modelName)
            assert(ischar(modelName)||isStringScalar(modelName),'invalid model name');

            configSet=getActiveConfigSet(modelName);
            clientInterface=coder.connectivity.SimulinkInterface;
            configInterface=clientInterface.createConfigInterface(...
            configSet,modelName);

            targetRegistry=RTW.TargetRegistry.getInstance;
            configs=coder.internal.getConnectivityConfigs(targetRegistry,configInterface);
        end

        function exeFullName=getDefaultTargetExecutableFullName(ComponentArgs,toolchainInfo)
            exeFullName=fullfile(ComponentArgs.getAnchorFolder,...
            ComponentArgs.getComponentCodeName);
            if isempty(toolchainInfo)


                DAStudio.error(...
                'Simulink:Extmode:LauncherCannotDetermineExecutableExtension',...
                exeFullName);
            else

                tools=coder.make.internal.getToolchainBuildTools(toolchainInfo);
                exeExt=tools.ld.getFileExtension('Executable');
            end
            exeFullName=[exeFullName,exeExt];
        end
    end

    methods(Static,Access=public,Hidden=true)

        function ExtModeConfig=getExtModeConfig(modelName)
            assert(ischar(modelName)||isStringScalar(modelName),'invalid model name');



            cs=getActiveConfigSet(modelName);
            idx=get_param(modelName,'ExtModeTransport');

            [transport,mex,interface]=Simulink.ExtMode.Transports.getExtModeTransport(cs,idx);
            args=get_param(modelName,'ExtModeMexArgs');






            purelyIntegerCode=get_param(modelName,'PurelyIntegerCode');
            stopTime=get_param(modelName,'StopTime');
            fixedStepSize=get_param(modelName,'CompiledStepSize');

            ExtModeConfig.TransportName=transport;
            ExtModeConfig.MexFile=mex;
            ExtModeConfig.IntrfLevel=interface;
            ExtModeConfig.MexArgs=args;
            ExtModeConfig.PurelyIntegerCode=purelyIntegerCode;
            ExtModeConfig.StopTime=stopTime;
            ExtModeConfig.FixedStepSize=fixedStepSize;
        end



        function launcher=getCurrentLauncher(modelName,targetName)
            launcher=[];

            assert(ischar(modelName)||isStringScalar(modelName),'invalid model name');
            assert(ischar(targetName)||isStringScalar(targetName),'invalid target name');

            modelHandle=locConvertToHandle(modelName);
            assert(ishandle(modelHandle),'invalid model handle');

            manager=coder.oneclick.TargetLaunchersManager.Instance;
            data=manager.get(modelHandle);

            if~isempty(data)
                launcher=data.Launcher;
            end
        end

        function isMatch=launcherComponentCodePathMatches(launcher,componentCodePath)


            launcherComponentCodePath=launcher.getComponentCodePath;
            isMatch=strcmp(launcherComponentCodePath,componentCodePath);
        end





        function hasConfigChanged=extModeConfigChangeDetected(modelName,targetName)
            hasConfigChanged=true;

            assert(ischar(modelName)||isStringScalar(modelName),'invalid model name');
            assert(ischar(targetName)||isStringScalar(targetName),'invalid target name');

            modelHandle=locConvertToHandle(modelName);
            assert(ishandle(modelHandle),'invalid model handle');

            manager=coder.oneclick.TargetLaunchersManager.Instance;
            data=manager.get(modelHandle);

            if~isempty(data)

                ExtModeConfig=coder.oneclick.TargetLaunchersManager.getExtModeConfig(modelName);

                hasConfigChanged=...
                ~strcmp(data.ExtModeConfig.TransportName,ExtModeConfig.TransportName)||...
                ~strcmp(data.ExtModeConfig.MexFile,ExtModeConfig.MexFile)||...
                ~strcmp(data.ExtModeConfig.IntrfLevel,ExtModeConfig.IntrfLevel)||...
                ~strcmp(data.ExtModeConfig.MexArgs,ExtModeConfig.MexArgs)||...
                ~strcmp(data.ExtModeConfig.PurelyIntegerCode,ExtModeConfig.PurelyIntegerCode)||...
                (strcmp(ExtModeConfig.PurelyIntegerCode,'on')&&...
                (~strcmp(data.ExtModeConfig.StopTime,ExtModeConfig.StopTime)||...
                ~strcmp(data.ExtModeConfig.FixedStepSize,ExtModeConfig.FixedStepSize)));
            end
        end
    end

    methods(Static,Access=public)







        function launcher=getLauncher(modelName,targetName,forceApplicationStop)
            narginchk(2,3);

            if(nargin==2)


                forceApplicationStop=false;
            end

            modelHandle=locConvertToHandle(modelName);
            assert(ishandle(modelHandle),'invalid model handle');

            currentLauncher=coder.oneclick.TargetLaunchersManager.getCurrentLauncher(modelName,targetName);


            if~isempty(currentLauncher)


                status=currentLauncher.getApplicationStatus();

                isCurrentLauncherRunning=...
                (status==rtw.connectivity.LauncherApplicationStatus.RUNNING);

                if isCurrentLauncherRunning
                    if forceApplicationStop
                        currentLauncher.stopApplication;
                    else


                        launcher=currentLauncher;
                        return;
                    end
                end
            end

            boardWithLauncher=[];
            isTFTarget=false;
            if coder.internal.connectivity.featureOn('ExtModeTargetFramework')
                [isTFTarget,board]=codertarget.utils.isTargetFrameworkTarget(...
                get_param(modelName,'HardwareBoard'));
                if isTFTarget

                    tool=coder.oneclick.TargetFrameworkLauncher.getFinalExecutionTool(board);
                    if~isempty(tool)
                        boardWithLauncher=board;
                    end
                end
            end


            if~isempty(boardWithLauncher)
                configs=[];
            else

                configs=coder.oneclick.TargetLaunchersManager.getConnectivityConfigs(modelName);



                if numel(configs)>1
                    DAStudio.error('Simulink:Extmode:TooManyTargetConnectivityConfig',modelName);
                end
            end

            [isHostBased,toolchainInfo]=coder.internal.isHostBasedTarget(modelName);



            isHostBasedWithValidBoard=isHostBased&&...
            (isTFTarget||strcmp(get_param(modelName,'HardwareBoard'),'None'));

            cs=getActiveConfigSet(modelName);
            simulinkCoderAvailable=coder.oneclick.Utils.isSimulinkCoderInstalledAndLicensed();

            isLauncherSupported=coder.oneclick.Utils.isCustomHWFeaturedOn&&...
            coder.oneclick.Utils.isOnTargetOneClickEnabled(cs,simulinkCoderAvailable)&&...
            (isHostBasedWithValidBoard||~isempty(configs)||~isempty(boardWithLauncher));

            if isLauncherSupported
                bDirInfo=RTW.getBuildDir(modelName);
                anchorFolder=bDirInfo.CodeGenFolder;
                componentCodePath=bDirInfo.BuildDirectory;

                manager=coder.oneclick.TargetLaunchersManager.Instance;
                data=manager.get(modelHandle);

                if isempty(currentLauncher)

                    needToCreateNewLauncher=true;
                else

                    extModeConfigChangeDetected=...
                    coder.oneclick.TargetLaunchersManager.extModeConfigChangeDetected(modelName,targetName);

                    newLauncherRequired=false;
                    if~isempty(boardWithLauncher)

                        if isempty(data.Board)||~isequal(boardWithLauncher,data.Board)||...
extModeConfigChangeDetected
                            newLauncherRequired=true;
                        end
                    elseif~isempty(configs)

                        if isempty(data.ConfigRegistry)||...
                            ~strcmp(data.ConfigRegistry.ConfigClass,configs.ConfigClass)
                            newLauncherRequired=true;
                        end
                    else

                        if~isempty(data.ConfigRegistry)||...
                            ~isempty(data.Board)||...
extModeConfigChangeDetected
                            newLauncherRequired=true;
                        end
                    end

                    if~coder.oneclick.TargetLaunchersManager.launcherComponentCodePathMatches(...
                        data.Launcher,...
                        componentCodePath)
                        newLauncherRequired=true;
                    end



                    if newLauncherRequired
                        needToCreateNewLauncher=true;
                    else


                        needToCreateNewLauncher=false;
                        launcher=currentLauncher;
                    end
                end

                if needToCreateNewLauncher


                    try
                        newData=manager.createNewLauncher(modelName,...
                        anchorFolder,...
                        componentCodePath,...
                        targetName,...
                        boardWithLauncher,...
                        configs,...
                        toolchainInfo);
                    catch ME
                        if forceApplicationStop||~strcmp(ME.identifier,...
                            'coder_xcp:host:ExtModeMexArgsUnbalancedQuote')


                            rethrow(ME);
                        end



                        newData=manager.createDummyMexArgsErrorLauncher(modelName);
                    end
                    assert(~isempty(newData),'Unable to create a launcher');


                    if~isempty(data)
                        eventSource=struct;
                        eventSource.Handle=get_param(modelName,'Handle');
                        locCloseCallback(eventSource,[]);
                    end


                    listener=Simulink.listener(...
                    get_param(modelName,'Handle'),...
                    'CloseEvent',...
                    @locCloseCallback);

                    newData.CloseListener=listener;
                    manager.set(modelHandle,newData);

                    launcher=newData.Launcher;
                end
            else
                if~isempty(currentLauncher)


                    eventSource=struct;
                    eventSource.Handle=get_param(modelName,'Handle');
                    locCloseCallback(eventSource,[]);
                end
                launcher=[];
            end
        end

        function result=hasLauncher(modelName,targetName)%#ok for now we only check modelName,
            modelHandle=locConvertToHandle(modelName);
            assert(ishandle(modelHandle),'invalid handle');

            manager=coder.oneclick.TargetLaunchersManager.Instance;
            result=manager.LauncherMap.isKey(modelHandle);
        end

        function launchers=getAllLaunchers()
            manager=coder.oneclick.TargetLaunchersManager.Instance;
            launchers=cellfun(@(x)x.Context,manager.allLaunchers(),'UniformOutput',false);
        end
    end
end

function locCloseCallback(eventSrc,~)
    manager=coder.oneclick.TargetLaunchersManager.Instance;
    data=manager.remove(eventSrc.Handle);

    if~isempty(data)
        if~isempty(data.Config)
            delete(data.Config);
        end
        if~isempty(data.Launcher)
            delete(data.Launcher);
        end
        delete(data.CloseListener);
    end
end


function modelHandle=locConvertToHandle(modelName)

    if ischar(modelName)||isStringScalar(modelName)
        modelHandle=get_param(modelName,'Handle');
    elseif ishandle(modelName)
        modelHandle=modelName;
    else
        assert(false,'You must provide either a model name or its handle.');
    end
end


