classdef ScenarioConnector<handle





























    properties(Access='public',Hidden)





        IS_DEBUG=false
        debugPortDefault=[]
        debugPortAPI=[]
debuggingPort
theDispatcher
Tag




        debugWeb='staConnectorRelease-debug.html'
        debugRelease='staConnectorRelease.html'
FullUrl
CEFWindow
CEFIcon



ConnectorAppID
editorAppID




        IS_UI_DIRTY=false
DlgTitle
        IS_STARTUP_DONE=false;


        Subscriptions=containers.Map;


TopicNames


SignalCellStruct
        ModelToConnectTo=''
owningModelName
owningModelFullPath
        IS_EDIT_MODE=true;
DataSource
CloseCallback
InputSpecification
        Scenario=''
Options


BlockDiagram
        PreCloseCallbackName='scStaPreClose_CB';
        ModelRenameCallbackID='scStaReName_CB';


EventListeners


ScenarioRepo
ModelRepo

CloseCallBackSubscription

        FORCE_EXIT_FROM_MATLAB=false;

        IS_CLOSING=false;

        SCENARIO_TO_RUN_ID_MAP=containers.Map();

        PREF_GROUP='rootinportmapper'

LaunchDebugTools
    end





    methods


        function aConnectorDlg=ScenarioConnector(varargin)


            setappdata(0,'enableEngineCheckVersion1_0',1);


            parseInputArguments(aConnectorDlg,varargin{:});

            if~ispref(aConnectorDlg.PREF_GROUP)
                Simulink.sta.createFactoryPreferences();
            else



                preferenceStruct=Simulink.sta.getMapperPreferences();

                prefNames=fieldnames(preferenceStruct);
                for k=1:length(prefNames)
                    if~Simulink.sta.PreferenceManager.qualifyPrefValue(prefNames{k},preferenceStruct.(prefNames{k}))

                        Simulink.sta.PreferenceManager.restoreFactoryDefaults();
                        break;
                    end
                end
            end



            aConnectorDlg.Tag=genTag(aConnectorDlg);

            hash1=Simulink.sta.InstanceMap.getInstance();
            theConnectorInHash=getUIInstance(hash1,aConnectorDlg.Tag);


            if~isempty(theConnectorInHash)

                aConnectorDlg=theConnectorInHash;

                bringToFront(aConnectorDlg);
                return;
            end





            [IS_CONNECTOR_GOOD,errMsg]=connectorStartUp(aConnectorDlg);


            if~IS_CONNECTOR_GOOD


                error(errMsg);
            end


            generateWebUrl(aConnectorDlg);
            aConnectorDlg.theDispatcher=Simulink.sta.Dispatcher(aConnectorDlg.ConnectorAppID);

            aConnectorDlg.TopicNames=Simulink.sta.ScenarioTopics();

            aConnectorDlg.theDispatcher.baseMsg=aConnectorDlg.TopicNames.BASE_MSG;
            subscribeToMessages(aConnectorDlg);

            signalauthoring.internal.createImportListeners(aConnectorDlg.ConnectorAppID);







            addToHashMap(aConnectorDlg);



            iofile.FeatureControl;

        end


        function show(aConnectorDlg)



            if isvalid(aConnectorDlg)&&isempty(aConnectorDlg.CEFWindow)


                createCEFWindow(aConnectorDlg);


                assignModelCloseCallback(aConnectorDlg);


                assignModelRenameListener(aConnectorDlg);

                aConnectorDlg.CEFWindow.show();
                aConnectorDlg.bringToFront();

                if aConnectorDlg.LaunchDebugTools
                    aConnectorDlg.CEFWindow.executeJS('cefclient.sendMessage("openDevTools");');
                end
            end
        end


        function close(aConnectorDlg)


            if isvalid(aConnectorDlg)
                aConnectorDlg.bringToFront();

                if aConnectorDlg.IS_UI_DIRTY


                    msgTopics=Simulink.sta.ScenarioTopics();
                    ListenerChannel=msgTopics.UNSAVED_ONCLOSE;



                    if aConnectorDlg.theDispatcher.Subscribers.isKey(msgTopics.UNSAVED_ONCLOSE)
                        message.unsubscribe(aConnectorDlg.theDispatcher.Subscribers(msgTopics.UNSAVED_ONCLOSE));
                        aConnectorDlg.theDispatcher.Subscribers.remove(msgTopics.UNSAVED_ONCLOSE);
                    end

                    aConnectorDlg.CloseCallBackSubscription=subscribe(aConnectorDlg.theDispatcher,msgTopics.UNSAVED_ONCLOSE,@aConnectorDlg.handleUnsavedChangesDialog);




                    buttons={DAStudio.message('sl_sta_general:common:Yes'),...
                    DAStudio.message('sl_sta_general:common:No')};

                    aConnectorDlg.DisplayMsgBox(DAStudio.message('sl_sta:sta:UnsavedTitle'),...
                    DAStudio.message('sl_sta:sta:UnsavedText'),...
                    buttons,...
                    0,...
                    ListenerChannel);

                    aConnectorDlg.IS_CLOSING=true;

                else


                    cleanState(aConnectorDlg);

                end

            end
        end


        function iconPath=get.CEFIcon(~)

            arch=computer('arch');
            ext='.png';
            switch arch
            case{'win32','win64'}
                ext='.ico';
            case{'glnx86','glnxa64'}
                ext='.png';
            case{'maci64'}

            end

            iconPath=fullfile(matlabroot,...
            'toolbox',...
            'simulink',...
            'sta',...
            'ui',...
            'images',...
            ['MapSignals_24',...
            ext]);
        end


        function forceMATLABCLOSE(aConnectorDlg)

            aConnectorDlg.FORCE_EXIT_FROM_MATLAB=true;
            publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.FORCE_MATLAB_EXIT,[]);
        end

    end


    methods(Hidden)


        function portNum=getDebugPort(aConnectorDlg)
            portNum=aConnectorDlg.debuggingPort;
        end


        function bringToFront(aConnectorDlg)

            if~isempty(aConnectorDlg.CEFWindow)&&isa(aConnectorDlg.CEFWindow,'matlab.internal.webwindow')

                aConnectorDlg.CEFWindow.bringToFront();
            end
        end


        function setModelName(aConnectorDlg,modelNameToInit)



            aConnectorDlg.ModelToConnectTo=modelNameToInit;
            owningModel='';
            if~isempty(modelNameToInit)&&bdIsLoaded(modelNameToInit)


                isHarnessStr=get_param(modelNameToInit,'IsHarness');

                if strcmp(isHarnessStr,'on')

                    owningFileName=get_param(modelNameToInit,'OwnerFileName');

                    [~,owningModel,~]=fileparts(owningFileName);

                    harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelNameToInit);
                    aConnectorDlg.owningModelFullPath=harnessInfo.ownerFullPath;

                end


            end

            aConnectorDlg.owningModelName=owningModel;


            eng=sdi.Repository(true);
            eng.safeTransaction(@initModel,aConnectorDlg);

        end


        function publishMessage(aConnectorDlg,subChannel,msgVal)


            fullChannel=genChannel(aConnectorDlg,subChannel);

            message.publish(fullChannel,msgVal);
        end


        function fullChannel=genChannel(aConnectorDlg,subChannel)


            fullChannel=sprintf('%s%s/%s',aConnectorDlg.theDispatcher.baseMsg,...
            aConnectorDlg.ConnectorAppID,...
            subChannel);

        end


        function tag=genTag(aConnectorDlg)

            tag=['sta_',aConnectorDlg.ModelToConnectTo];
        end





        function msgcb_open(aConnectorDlg,msgInFilePayLoad)



            connectorMLDATX=sta.InputConnectorMLDATX();

            msgInFile=msgInFilePayLoad.scenarioFullFile;

            try
                mdlName=getModelFromFile(connectorMLDATX,msgInFile);

            catch ME

                throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',ME.message);
                publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.SCENARIO_SESSION_OPENING,false);

                return;
            end


            if~isempty(aConnectorDlg.ModelToConnectTo)






















            else



                removeFromHashMap(aConnectorDlg);

                aConnectorDlg.ModelToConnectTo=mdlName;

                aConnectorDlg.Tag=genTag(aConnectorDlg);

                addToHashMap(aConnectorDlg);


                assignModelCloseCallback(aConnectorDlg);


                assignModelRenameListener(aConnectorDlg);

            end



            try
                publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.SCENARIO_SESSION_OPENING,true);
                connectorMLDATX=sta.InputConnectorMLDATX();
                connectorMLDATX.setTreeOrderStart(msgInFilePayLoad.treeOrderStart);



                if~isempty(aConnectorDlg.ModelRepo)


                    setModelToUse(connectorMLDATX,aConnectorDlg.ModelRepo.ID);

                end

                connectorMLDATX.readFile(msgInFile,aConnectorDlg.ConnectorAppID);
                publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.SCENARIO_SESSION_OPENING,false);


            catch ME

                if strcmp(ME.identifier,'sl_sta_repository:sta_repository:versionsupportwarning')
                    throwWarningDialog(aConnectorDlg,'sl_sta_general:common:Warning',ME.message);
                    publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.SCENARIO_SESSION_OPENING,false);
                else
                    throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',ME.message);
                    publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.SCENARIO_SESSION_OPENING,false);
                end
            end

        end





        function cb_saveMLDATX(aConnectorDlg,msgIn)

            fileLocation=msgIn.fileLocation;
            CLOSE_AFTER_SAVE=msgIn.CLOSE_AFTER_SAVE;
            EXIT_MATLAB=msgIn.EXIT_MATLAB;

            icon_location=fullfile(matlabroot,'toolbox','simulink',...
            'sta','ui','images','SignalAuthoring_16.png');
            mldatx_Writer=sta.InputConnectorMLDATX(icon_location);

            try
                writeToFile(mldatx_Writer,fileLocation,aConnectorDlg.ScenarioRepo.ID);
                aConnectorDlg.Scenario=fileLocation;

                aConnectorDlg.IS_UI_DIRTY=false;
                aConnectorDlg.setTitle();

                msgTopics=Simulink.sta.ScenarioTopics();

                publishMessage(aConnectorDlg,msgTopics.IS_UI_DIRTY,false);

                if(CLOSE_AFTER_SAVE)&&~EXIT_MATLAB

                    cleanState(aConnectorDlg);

                end

            catch ME

                throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',ME.message);
            end

            if EXIT_MATLAB
                aConnectorDlg.forceMATLABCLOSE();
            end


        end



        function msgcb_forceclose(aConnectorDlg,msgIn)

            if msgIn.EXIT_MATLAB
                aConnectorDlg.forceMATLABCLOSE();
            else

                cleanState(aConnectorDlg);
            end
        end




        function onDialogClose(aConnectorDlg,~)

            if isvalid(aConnectorDlg)

                if aConnectorDlg.IS_UI_DIRTY&&~aConnectorDlg.FORCE_EXIT_FROM_MATLAB



                    if~aConnectorDlg.IS_CLOSING




                        msgTopics=Simulink.sta.ScenarioTopics();
                        ListenerChannel=msgTopics.UNSAVED_ONCLOSE;



                        if aConnectorDlg.theDispatcher.Subscribers.isKey(msgTopics.UNSAVED_ONCLOSE)
                            message.unsubscribe(aConnectorDlg.theDispatcher.Subscribers(msgTopics.UNSAVED_ONCLOSE));
                            aConnectorDlg.theDispatcher.Subscribers.remove(msgTopics.UNSAVED_ONCLOSE);
                        end

                        aConnectorDlg.CloseCallBackSubscription=subscribe(aConnectorDlg.theDispatcher,msgTopics.UNSAVED_ONCLOSE,@aConnectorDlg.handleUnsavedChangesDialog);




                        buttons={DAStudio.message('sl_sta_general:common:Yes'),...
                        DAStudio.message('sl_sta_general:common:No'),...
                        DAStudio.message('sl_sta_general:common:Cancel')};

                        aConnectorDlg.DisplayMsgBox(DAStudio.message('sl_sta:sta:UnsavedTitle'),...
                        DAStudio.message('sl_sta:sta:UnsavedText'),...
                        buttons,...
                        0,...
                        ListenerChannel);

                        aConnectorDlg.IS_CLOSING=true;
                    end

                else

                    cleanState(aConnectorDlg);
                end


            end
        end
    end


    methods(Access='private')


        function parseInputArguments(aConnectorDlg,varargin)


            inputStruct=parseStaInput(varargin{:});


            if isstring(inputStruct.DataSource)&&isscalar(inputStruct.DataSource)
                inputStruct.DataSource=char(inputStruct.DataSource);
            end

            if isstring(inputStruct.DataSource)&&~isscalar(inputStruct.DataSource)
                inputStruct.DataSource=cellstr(inputStruct.DataSource);
            end

            aConnectorDlg.DataSource=inputStruct.DataSource;
            aConnectorDlg.SignalCellStruct=inputStruct.ProcessedData;

            if~isempty(inputStruct.Model)
                if isstring(inputStruct.Model)&&isscalar(inputStruct.Model)
                    inputStruct.Model=char(inputStruct.Model);
                end

                aConnectorDlg.ModelToConnectTo=inputStruct.Model;
            end

            aConnectorDlg.CloseCallback=inputStruct.CloseCallback;
            aConnectorDlg.IS_DEBUG=inputStruct.Debug;
            aConnectorDlg.debugPortAPI=inputStruct.DebugPort;
            aConnectorDlg.LaunchDebugTools=inputStruct.LaunchDebugTools;




            if isempty(aConnectorDlg.debugPortAPI)
                aConnectorDlg.debuggingPort=matlab.internal.getDebugPort;
            else
                aConnectorDlg.debuggingPort=aConnectorDlg.debugPortAPI;
            end

            aConnectorDlg.InputSpecification=inputStruct.InputSpecification;


            if~isempty(inputStruct.Scenario)

                if isstring(inputStruct.Scenario)&&isscalar(inputStruct.Scenario)
                    inputStruct.Scenario=char(inputStruct.Scenario);
                end



                connectorMLDATX=sta.InputConnectorMLDATX();

                mdlName=getModelFromFile(connectorMLDATX,inputStruct.Scenario);

                hash1=Simulink.sta.InstanceMap.getInstance();

                uiCount=getOpenTagCount(hash1,mdlName);


                if uiCount>0
                    [~,scFile,scExt]=fileparts(inputStruct.Scenario);
                    DAStudio.error('sl_sta:scenarioconnector:appopenwithmodel',mdlName,[scFile,scExt]);
                end

                aConnectorDlg.Scenario=inputStruct.Scenario;
            end

            aConnectorDlg.Options=inputStruct.Options;
        end


        function[bool,errMsg]=connectorStartUp(aConnectorDlg)


            bool=false;

            try
                connector.ensureServiceOn;
                bool=true;
                errMsg='';
            catch


                errMsg=error(DAStudio.message('sl_sta:sta:ConnectorFailed','CONNECTOR'));
            end


        end


        function generateWebUrl(aConnectorDlg)


            if aConnectorDlg.IS_DEBUG
                aURL=aConnectorDlg.debugWeb;
            else
                aURL=aConnectorDlg.debugRelease;
            end



            aConnectorDlg.FullUrl=connector.getUrl(['/toolbox/simulink/sta/web/SigAuth/Mapper/',...
            aURL]);

            applyConnectorAppID(aConnectorDlg);

        end


        function applyConnectorAppID(aConnectorDlg)

            UniqueId=char(matlab.lang.internal.uuid());

            matches=regexp(UniqueId,'[0-9a-f]*','match');

            assert(~isempty(matches));
            aConnectorDlg.ConnectorAppID=matches{1};


            sep='?';
            if strfind(aConnectorDlg.FullUrl,'?')>1
                sep='&';
            end

            aConnectorDlg.FullUrl=strcat(aConnectorDlg.FullUrl,sep,'UUID=',aConnectorDlg.ConnectorAppID,' ');
        end


        function figPosition=getPosition(~)
            set(0,'Units','pixels');
            scnsize=get(0,'ScreenSize');



            width=1024;
            height=576;



            if(scnsize(3)<1366&&scnsize(4)<768)
                xfraction=0.75;
                yfraction=0.75;
                width=scnsize(3)*xfraction;
                height=scnsize(4)*yfraction;
            end



            xPos=0.5*(scnsize(3)-width);
            yPos=0.5*(scnsize(4)-height);

            figPosition=[xPos,yPos,width,height];
        end


        function setTitle(aConnectorDlg)

            if isempty(aConnectorDlg.Scenario)
                scenarioTitle='untitled';
            else
                [~,scenarioNoExt,~]=fileparts(aConnectorDlg.Scenario);
                scenarioTitle=scenarioNoExt;
            end


            aConnectorDlg.DlgTitle=DAStudio.message('sl_sta:scenarioconnector:figuretitle',...
            scenarioTitle,aConnectorDlg.ModelToConnectTo);

            if aConnectorDlg.IS_UI_DIRTY
                aConnectorDlg.DlgTitle=[aConnectorDlg.DlgTitle,'*'];
            end


            aConnectorDlg.CEFWindow.Title=aConnectorDlg.DlgTitle;
        end


        function onMATLABClose(aConnectorDlg,~)


            if isvalid(aConnectorDlg)
                aConnectorDlg.bringToFront();

                if aConnectorDlg.IS_UI_DIRTY&&~aConnectorDlg.FORCE_EXIT_FROM_MATLAB

                    msgTopics=Simulink.sta.ScenarioTopics();


                    ListenerChannel=msgTopics.MATLAB_EXIT_CALLED;



                    if aConnectorDlg.theDispatcher.Subscribers.isKey(msgTopics.MATLAB_EXIT_CALLED)
                        message.unsubscribe(aConnectorDlg.theDispatcher.Subscribers(msgTopics.MATLAB_EXIT_CALLED));
                        aConnectorDlg.theDispatcher.Subscribers.remove(msgTopics.MATLAB_EXIT_CALLED);
                    end

                    aConnectorDlg.CloseCallBackSubscription=subscribe(aConnectorDlg.theDispatcher,msgTopics.MATLAB_EXIT_CALLED,@aConnectorDlg.handleMATLABExitUnsavedChanges);




                    buttons={DAStudio.message('sl_sta_general:common:Yes'),...
                    DAStudio.message('sl_sta_general:common:No')};

                    aConnectorDlg.DisplayMsgBox(DAStudio.message('sl_sta:sta:UnsavedTitle'),...
                    DAStudio.message('sl_sta:sta:UnsavedText'),...
                    buttons,...
                    0,...
                    ListenerChannel);

                    aConnectorDlg.IS_CLOSING=true;
                else

                    cleanOnMATLABExit(aConnectorDlg);
                    exit();

                end
            else

                cleanOnMATLABExit(aConnectorDlg);
                exit();

            end

        end


        function cleanOnMATLABExit(aConnectorDlg)

            unregisterSubscribers(aConnectorDlg);


            removeModelPreCloseCallback(aConnectorDlg);

            removeModelRenameListener(aConnectorDlg);


            deleteSimEventListeners(aConnectorDlg);


            removeFromHashMap(aConnectorDlg);

            aConnectorDlg.CEFWindow.close();
        end


        function addToHashMap(aConnectorDlg)
            hash1=Simulink.sta.InstanceMap.getInstance();
            addUIInstance(hash1,aConnectorDlg.Tag,aConnectorDlg);
        end


        function removeFromHashMap(aConnectorDlg)
            hash1=Simulink.sta.InstanceMap.getInstance();
            removeTag(hash1,aConnectorDlg.Tag);
        end


        function createCEFWindow(aConnectorDlg)


            figPosition=getPosition(aConnectorDlg);




            aConnectorDlg.CEFWindow=matlab.internal.webwindow(aConnectorDlg.FullUrl,...
            aConnectorDlg.debuggingPort);



            aConnectorDlg.setTitle();


            aConnectorDlg.CEFWindow.Position=[figPosition(1),...
            figPosition(2),...
            figPosition(3),...
            figPosition(4)];



            arch=computer('arch');
            switch arch
            case{'win64','glnx86','glnxa64'}

                aConnectorDlg.CEFWindow.Icon=aConnectorDlg.CEFIcon;
            end


            aConnectorDlg.CEFWindow.CustomWindowClosingCallback=@(evt,src)onDialogClose(aConnectorDlg);
            aConnectorDlg.CEFWindow.MATLABClosingCallback=@(evt,src)onMATLABClose(aConnectorDlg);
        end


        function subscribeToMessages(aConnectorDlg)


            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.START_UP,@aConnectorDlg.msgcb_startup);
            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.IS_UI_DIRTY,@aConnectorDlg.msgcb_isuidirty);



            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.NEW,@aConnectorDlg.msgcb_new);
            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.OPEN,@aConnectorDlg.msgcb_open);



            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.LAUNCH_EDITOR,@aConnectorDlg.cb_launcheditor);
            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.LAUNCH_EDITOR_BLANK,@aConnectorDlg.cb_launcheditor_blank);



            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.SCENARIO_SAVE,@aConnectorDlg.cb_saveMLDATX);
            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.SCENARIO_CREATE_MLDATX,@aConnectorDlg.cb_createScenarioMLDATX);


            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.CREATE_EXTERNAL_INPUTS,@aConnectorDlg.cb_createExternalSource);

            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.FORCE_CLOSE,@aConnectorDlg.msgcb_forceclose);


            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.TIME_OF_MAP,@aConnectorDlg.msgcb_timeofmapping);


            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.CLEAR_CONNECTIONS,@aConnectorDlg.msgcb_clearconnections);


            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.SCENARIO_SDI_RUN_MAP,@aConnectorDlg.msgcb_setRunID);

            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.UPDATE_TREE_ORDER,@aConnectorDlg.msgcb_updateTreeOrder);

            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.BRING_TO_FRONT,@aConnectorDlg.msgcb_bringToFront);



            subscribe(aConnectorDlg.theDispatcher,aConnectorDlg.TopicNames.SET_PREFS,@aConnectorDlg.msgcb_setPreference);
        end


        function sendModel(aConnectorDlg)


            modelStructToSend.modelName=aConnectorDlg.ModelToConnectTo;
            modelStructToSend.modelHandle=get_param(aConnectorDlg.ModelToConnectTo,'Handle');
            modelStructToSend.owningModelName=aConnectorDlg.owningModelName;
            modelStructToSend.owningModelFullPath=aConnectorDlg.owningModelFullPath;

            msgTopics=Simulink.sta.ScenarioTopics();

            publishMessage(aConnectorDlg,msgTopics.MODEL_TO_USE,modelStructToSend);
        end


        function unregisterSubscribers(aConnectorDlg)


            sKeys=aConnectorDlg.Subscriptions.keys;


            for k=1:length(sKeys)
                message.unsubscribe(aConnectorDlg.Subscriptions(sKeys{k}));
                aConnectorDlg.Subscriptions.remove(sKeys{k});
            end

        end


        function initScenario(aConnectorDlg)

            aConnectorDlg.ScenarioRepo=sta.Scenario();
            aConnectorDlg.ScenarioRepo.Description='Empty Description';
            aConnectorDlg.ScenarioRepo.APPid=aConnectorDlg.ConnectorAppID;
        end


        function initExternalSources(aConnectorDlg)

            initExternalSources(aConnectorDlg.SignalCellStruct,...
            aConnectorDlg.ScenarioRepo.ID);
        end


        function initModel(aConnectorDlg)


            if isempty(aConnectorDlg.ModelRepo)
                aConnectorDlg.ModelRepo=initModel(aConnectorDlg.ScenarioRepo.ID,...
                aConnectorDlg.ModelToConnectTo,...
                aConnectorDlg.owningModelName,aConnectorDlg.owningModelFullPath);
            else
                aConnectorDlg.ModelRepo.ScenarioID=aConnectorDlg.ScenarioRepo.ID;
                aConnectorDlg.ModelRepo.Name=aConnectorDlg.ModelToConnectTo;
                aConnectorDlg.ModelRepo.OwningModelName=aConnectorDlg.owningModelName;

                if isempty(aConnectorDlg.ModelRepo.OwningModelName)
                    fileNameLocation=get(get_param(aConnectorDlg.ModelRepo.Name,'Handle'),'FileName');
                    harnessmodelFullPath='';
                else
                    harnessmodelFullPath=aConnectorDlg.owningModelFullPath;
                    fileNameLocation=get(get_param(aConnectorDlg.ModelRepo.OwningModelName,'Handle'),'FileName');
                end

                aConnectorDlg.ModelRepo.HarnessFullPath=harnessmodelFullPath;
                aConnectorDlg.ModelRepo.LastKnownFileLocation=fileNameLocation;
            end
        end



        function msgcb_startup(aConnectorDlg,~)

            aConnectorDlg.IS_STARTUP_DONE=true;


            preferenceStruct=Simulink.sta.getMapperPreferences();
            publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.GET_PREFS,preferenceStruct);

            if isempty(aConnectorDlg.Scenario)




                eng=sdi.Repository(true);
                eng.safeTransaction(@initScenario,aConnectorDlg);

                sessionpayload.scenarioinfo.id=aConnectorDlg.ScenarioRepo.ID;


                publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.SCENARIO_CREATE,sessionpayload);



                if~isempty(aConnectorDlg.ModelToConnectTo)

                    [~,mdlFile,~]=fileparts(aConnectorDlg.ModelToConnectTo);


                    if bdIsLoaded(mdlFile)


                        setModelName(aConnectorDlg,mdlFile);

                    else
                        try
                            load_system(mdlFile);
                            setModelName(aConnectorDlg,mdlFile);
                        catch

                        end
                    end



                    addSimCommandListeners(aConnectorDlg);


                    sendModel(aConnectorDlg);

                end



                if~isempty(aConnectorDlg.SignalCellStruct)

                    fullChannel=sprintf('%s%s/%s',aConnectorDlg.TopicNames.BASE_MSG,aConnectorDlg.ConnectorAppID,'SignalAuthoring/UIModelData');
                    outdata.arrayOfListItems=aConnectorDlg.SignalCellStruct;
                    message.publish(fullChannel,outdata);
                else


                    if~isempty(aConnectorDlg.DataSource)
                        importDataOnStartUp(aConnectorDlg);


                    elseif~isempty(aConnectorDlg.ModelToConnectTo)




                    end
                end


            else

                msgPayLoad.scenarioFullFile=aConnectorDlg.Scenario;
                msgPayLoad.treeOrderStart=0;


                msgcb_open(aConnectorDlg,msgPayLoad);
            end


            publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.START_UP_DONE,[]);
            publishMessage(aConnectorDlg,aConnectorDlg.TopicNames.SCENARIO_SESSION_OPENING,false);
        end


        function msgcb_isuidirty(aConnectorDlg,msg)

            if isvalid(aConnectorDlg)

                aConnectorDlg.IS_UI_DIRTY=msg.isdirty;


                setTitle(aConnectorDlg);


                aConnectorDlg.CEFWindow.Title=aConnectorDlg.DlgTitle;
            end
        end


        function msgcb_new(aConnectorDlg,~)
            disp('msgcb_new');
        end



        function cb_launcheditor(aConnectorDlg,msgIn)

            jsonStruct=msgIn;

            jsonCell=convertClientJsonToServerJson(aConnectorDlg,jsonStruct);

            fileToReStream=jsonCell{1}.FullDataSource;


            hash1=Simulink.sta.InstanceMap.getInstance();
            openTags=hash1.getOpenTags;


            for kInstance=1:length(openTags)

                theInstance=getUIInstance(hash1,openTags{kInstance});

                IS_EDITOR=isa(theInstance,'Simulink.sta.Editor');

                if IS_EDITOR
                    IS_DATASOURCE_EMPTY=isempty(theInstance.DataSource);

                    DOES_DATASOURCE_MATCH=strcmp(theInstance.DataSource,fileToReStream);
                    DATA_SOURCE_NONEMPTY_MATCH=~IS_DATASOURCE_EMPTY&&DOES_DATASOURCE_MATCH;
                    IS_EDITMODE=theInstance.IS_EDIT_MODE==1;
                    DOES_MODEL_MATCH=strcmp(theInstance.ModelForTemplate,aConnectorDlg.ModelToConnectTo);

                    DOES_CONNECTOR_ID_MATCH=~isempty(theInstance.launchingSTAAppID)&&...
                    strcmp(theInstance.launchingSTAAppID,aConnectorDlg.ConnectorAppID);

                    if DATA_SOURCE_NONEMPTY_MATCH&&...
IS_EDITMODE

                        if~DOES_MODEL_MATCH




                            errorMsg=DAStudio.message('sl_sta:scenarioconnector:editorSameFileDiffModel',fileToReStream);
                            throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',errorMsg)
                            return;
                        elseif~DOES_CONNECTOR_ID_MATCH

                            errorMsg=DAStudio.message('sl_sta:scenarioconnector:editorSameFileDiffModel',fileToReStream);
                            throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',errorMsg)
                            return;
                        end
                    end
                end
            end

            EditH=Simulink.sta.Editor(...
            'DataSource',fileToReStream,...
            'UpstreamAppID',aConnectorDlg.ConnectorAppID,...
            'Model',aConnectorDlg.ModelToConnectTo,...
            'RIMSigStruct',jsonCell);
            EditH.show();
            EditH.bringToFront();
        end


        function cb_launcheditor_blank(aConnectorDlg,msgIn)

            EditH=Simulink.sta.Editor(...
            'UpstreamAppID',aConnectorDlg.ConnectorAppID,...
            'Model',aConnectorDlg.ModelToConnectTo);

            EditH.show();
            EditH.bringToFront();
        end



        function cb_createScenarioMLDATX(aConnectorDlg,msgIn)


            aConnectorDlg.ScenarioRepo=sta.Scenario(msgIn.scenarioinfo.id);


            aConnectorDlg.Scenario=aConnectorDlg.ScenarioRepo.FileName;

            if aConnectorDlg.ScenarioRepo.getModelID~=-1

                aConnectorDlg.ModelRepo=sta.Model(aConnectorDlg.ScenarioRepo.getModelID);

                try
                    if~isempty(aConnectorDlg.ModelRepo.OwningModelName)&&~bdIsLoaded(aConnectorDlg.ModelRepo.OwningModelName)
                        load_system(aConnectorDlg.ModelRepo.OwningModelName);


                        Simulink.harness.load(aConnectorDlg.ModelRepo.HarnessFullPath,aConnectorDlg.ModelRepo.Name);
                    end


                    if~bdIsLoaded(aConnectorDlg.ModelRepo.Name)

                        if isempty(aConnectorDlg.ModelRepo.OwningModelName)
                            load_system(aConnectorDlg.ModelRepo.Name);
                        else
                            Simulink.harness.load(aConnectorDlg.ModelRepo.HarnessFullPath,aConnectorDlg.ModelRepo.Name);
                        end

                    end

                catch ME

                    throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',ME.message)

                    return;
                end

                setModelName(aConnectorDlg,aConnectorDlg.ModelRepo.Name);


                sendModel(aConnectorDlg);
            end


            aConnectorDlg.setTitle();
        end


        function cb_createExternalSource(aConnectorDlg,msg)


            repoMgr=sta.RepositoryManager();
            repoMgr.removeExternalSourcesByScenario(aConnectorDlg.ScenarioRepo.ID);

            jsonCell=convertClientJsonToServerJson(aConnectorDlg,msg.jsonStruct);

            eng=sdi.Repository(true);
            eng.safeTransaction(@initExternalSources,jsonCell,aConnectorDlg.ScenarioRepo.ID);
        end


        function msgcb_setRunID(aConnectorDlg,msgIn)

            aConnectorDlg.SCENARIO_TO_RUN_ID_MAP(msgIn.filename)=msgIn.runid;
        end


        function jsonCell=convertClientJsonToServerJson(~,jsonStruct)


            jsonCell=convertClientJsonToServerJson(jsonStruct);

        end




        function throwErrorDialog(aConnectorDlg,errorTitleID,errorMsg)





            msgTopics=Simulink.sta.ScenarioTopics();



            fullChannel=genChannel(aConnectorDlg,msgTopics.DIAGNOSTICS_DLG);

            slwebwidgets.errordlgweb(fullChannel,...
            errorTitleID,...
            errorMsg);

        end


        function throwWarningDialog(aConnectorDlg,errorTitleID,errorMsg)





            msgTopics=Simulink.sta.ScenarioTopics();



            fullChannel=genChannel(aConnectorDlg,msgTopics.DIAGNOSTICS_DLG);

            slwebwidgets.warndlgweb(fullChannel,...
            errorTitleID,...
            errorMsg);

        end


        function handleFromSpreadSheetDiagnostic(aConnectorDlg,errorMsgStruct)






            switch(errorMsgStruct.ErrorId)



            case 'emptyImport'
                throwWarningDialog(aConnectorDlg,'sl_sta_general:common:Warning',errorMsgStruct.ErrorMessage);
            otherwise
                throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',errorMsgStruct.ErrorMessage);
            end



        end


        function importDataOnStartUp(aConnectorDlg)

            msgTopics=Simulink.sta.ScenarioTopics();
            importWarnID='sl_sta_general:common:Warning';


            if~iscell(aConnectorDlg.DataSource)

                [~,~,ext]=fileparts(aConnectorDlg.DataSource);

                if strcmpi(ext,'.mat')

                    [jsonStruct,errorMsg]=importFromMatFile(aConnectorDlg,aConnectorDlg.DataSource,[]);

                    if~isempty(errorMsg)
                        throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',errorMsg);
                        return;
                    end

                else

                    [jsonStruct,errorMsg]=importFromSpreadSheetFile(aConnectorDlg,aConnectorDlg.DataSource,[]);

                    if~isempty(errorMsg)
                        handleFromSpreadSheetDiagnostic(aConnectorDlg,errorMsg);
                        return;
                    end
                end


                if isempty(jsonStruct)

                    throwWarningDialog(aConnectorDlg,importWarnID,...
                    DAStudio.message('sl_sta:editor:datasourceempty',aConnectorDlg.DataSource));

                end

            else

                downselectstruct=struct('name',[],'children',[]);
                fileName=aConnectorDlg.DataSource{1};

                downselectstruct(length(aConnectorDlg.DataSource)-1)=struct('name',[],'children',[]);


                for id=2:length(aConnectorDlg.DataSource)
                    downselectstruct(id-1).name=aConnectorDlg.DataSource{id};
                    downselectstruct(id-1).children='all';
                end

                [~,~,ext]=fileparts(aConnectorDlg.DataSource{1});

                if strcmpi(ext,'.mat')
                    [jsonStruct,errorMsg]=importFromMatFile(aConnectorDlg,fileName,downselectstruct);

                    if~isempty(errorMsg)
                        throwErrorDialog(aConnectorDlg,'sl_sta_general:common:Error',errorMsg);
                        return;
                    end

                else

                    variable=aConnectorDlg.DataSource(2:end);
                    [jsonStruct,errorMsg]=importFromSpreadSheetFile(aConnectorDlg,aConnectorDlg.DataSource{1},variable{:});

                    if~isempty(errorMsg)
                        handleFromSpreadSheetDiagnostic(aConnectorDlg,errorMsg);
                        return;
                    end

                end


                if isempty(jsonStruct)





                    throwWarningDialog(aConnectorDlg,importWarnID,...
                    DAStudio.message('sl_sta:editor:datasourceempty',aConnectorDlg.DataSource{1}));

                end
            end



            aConnectorDlg.SignalCellStruct=jsonStruct;


            fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,aConnectorDlg.ConnectorAppID,'SignalAuthoring/UIModelData');
            outdata.arrayOfListItems=aConnectorDlg.SignalCellStruct;
            message.publish(fullChannel,outdata);


        end


        function[jsonStruct,errorMsg]=importFromMatFile(~,fileName,downselect)
            errorMsg=[];
            jsonStruct={};
            try
                if isempty(downselect)
                    jsonStruct=import2Repository(fileName);
                else
                    jsonStruct=import2Repository(fileName,downselect);
                end

            catch ME

                switch ME.identifier
                case 'MATLAB:load:notBinaryFile'
                    errorMsg=ME.message;
                otherwise
                    errorMsg='Unexpected Error';
                end

            end

        end


        function[jsonStruct,errorMsg]=importFromSpreadSheetFile(~,fileName,downselect)
            jsonStruct={};%#ok<NASGU>
            errorMsg=[];
            tempjsonStruct=[];

            try


                excelReader=sl_iofile.ExcelReader(fileName);

                if isempty(downselect)
                    jsonReturned=excelReader.importAll();
                else
                    jsonReturned=excelReader.import(downselect);
                end



                if~isempty(jsonReturned)
                    json2str=jsondecode(jsonReturned);
                    tempjsonStruct=json2str.arrayOfListItems;
                else
                    tempjsonStruct=[];
                end
            catch ME

                errorMsg=jsondecode(ME.message);
            end



            NUM_SIG=length(tempjsonStruct);
            jsonStruct=cell(1,NUM_SIG);
            for kStruct=1:NUM_SIG
                jsonStruct{kStruct}=tempjsonStruct(kStruct);
            end

        end


        function assignModelCloseCallback(aConnectorDlg)

            mdlName=aConnectorDlg.ModelToConnectTo;


            if~isempty(mdlName)&&bdIsLoaded(mdlName)


                aDiagram=get_param(mdlName,'Object');

                aConnectorDlg.BlockDiagram=aDiagram;


                if~isempty(aConnectorDlg.BlockDiagram)


                    if aConnectorDlg.BlockDiagram.hasCallback('PreClose',aConnectorDlg.PreCloseCallbackName)

                        aConnectorDlg.BlockDiagram.removeCallback('PreClose',aConnectorDlg.PreCloseCallbackName);

                    end

                    aConnectorDlg.BlockDiagram.addCallback('PreClose',...
                    aConnectorDlg.PreCloseCallbackName,...
                    @()aConnectorDlg.close());
                end

            end
        end


        function removeModelPreCloseCallback(aConnectorDlg)

            if~isempty(aConnectorDlg.BlockDiagram)&&bdIsLoaded(aConnectorDlg.ModelToConnectTo)



                if aConnectorDlg.BlockDiagram.hasCallback('PreClose',aConnectorDlg.PreCloseCallbackName)
                    aConnectorDlg.BlockDiagram.removeCallback(...
                    'PreClose',aConnectorDlg.PreCloseCallbackName);
                end
            end

        end


        function assignModelRenameListener(aConnectorDlg)

            if~isempty(aConnectorDlg.BlockDiagram)

                removeModelRenameListener(aConnectorDlg);


                if~isempty(aConnectorDlg.ModelToConnectTo)&&...
                    ~strcmp(' ',aConnectorDlg.ModelToConnectTo)&&...
                    bdIsLoaded(aConnectorDlg.ModelToConnectTo)

                    handle=get_param(aConnectorDlg.ModelToConnectTo,'Handle');
                    bd=get_param(aConnectorDlg.ModelToConnectTo,'Object');

                    bd.addCallback('PostNameChange',aConnectorDlg.ModelRenameCallbackID,@()...
                    doNameChange(aConnectorDlg,handle,aConnectorDlg.ModelRenameCallbackID));
                end


            end

        end


        function removeModelRenameListener(aConnectorDlg)


            if~isempty(aConnectorDlg.ModelToConnectTo)&&...
                ~strcmp(' ',aConnectorDlg.ModelToConnectTo)&&...
                bdIsLoaded(aConnectorDlg.ModelToConnectTo)

                bd=get_param(aConnectorDlg.ModelToConnectTo,'Object');

                if bd.hasCallback('PostNameChange',aConnectorDlg.ModelRenameCallbackID)
                    bd.removeCallback(...
                    'PostNameChange',aConnectorDlg.ModelRenameCallbackID);
                end
            end
        end



        function doNameChange(aConnectorDlg,handle,oldName)




            newname=get_param(handle,'Name');


            setModelName(aConnectorDlg,newname);




            removeFromHashMap(aConnectorDlg);


            aConnectorDlg.Tag=genTag(aConnectorDlg);


            addToHashMap(aConnectorDlg);



            removeModelRenameListener(aConnectorDlg);

            assignModelRenameListener(aConnectorDlg);


            setTitle(aConnectorDlg);


            sendModel(aConnectorDlg);

            msgTopics=Simulink.sta.ScenarioTopics();

            publishMessage(aConnectorDlg,msgTopics.IS_UI_DIRTY,true);


        end




        function addSimCommandListeners(aConnectorDlg)


            if~isempty(aConnectorDlg.ModelToConnectTo)&&~strcmp(' ',aConnectorDlg.ModelToConnectTo)&&bdIsLoaded(aConnectorDlg.ModelToConnectTo)
                mdlHandle=get_param(aConnectorDlg.ModelToConnectTo,'Handle');

                hFcnDisable=@(blkDiagObj,listenerObj)publishSimState(aConnectorDlg,true);
                hFcnEnable=@(blkDiagObj,listenerObj)publishSimState(aConnectorDlg,false);
                hFcnPaused=@(blkDiagObj,listenerObj)handlePausedSimState(aConnectorDlg);
                hFcnCompiled=@(blkDiagObj,listenerObj)handleCompiledSimState(aConnectorDlg);
                aConnectorDlg.EventListeners{1}=...
                Simulink.listener(mdlHandle,'EngineSimStatusRunning',...
                hFcnDisable);

                aConnectorDlg.EventListeners{2}=...
                Simulink.listener(mdlHandle,'EngineSimStatusPaused',...
                hFcnPaused);

                aConnectorDlg.EventListeners{3}=...
                Simulink.listener(mdlHandle,'EngineSimStatusStopped',...
                hFcnEnable);


                aConnectorDlg.EventListeners{4}=...
                Simulink.listener(mdlHandle,'EngineSimStatusCompiled',...
                hFcnCompiled);
            end
        end


        function deleteSimEventListeners(aConnectorDlg)


            for kListener=length(aConnectorDlg.EventListeners):-1:1
                delete(aConnectorDlg.EventListeners{kListener});
            end

        end


        function handlePausedSimState(aConnectorDlg)

            msgTopics=Simulink.sta.ScenarioTopics();

            publishMessage(aConnectorDlg,msgTopics.SIM_STATE_ACTIVE,true);
            publishMessage(aConnectorDlg,msgTopics.FAST_RESTART_ISON,false);

        end


        function handleCompiledSimState(aConnectorDlg)

            rootBD=bdroot(get_param(aConnectorDlg.ModelToConnectTo,'Handle'));

            msgTopics=Simulink.sta.ScenarioTopics();

            publishMessage(aConnectorDlg,msgTopics.SIM_STATE_ACTIVE,false);
            publishMessage(aConnectorDlg,msgTopics.FAST_RESTART_ISON,true);

        end


        function publishFastRestartState(aConnectorDlg)

            if~isempty(aConnectorDlg.ModelToConnectTo)
                mdlHandle=get_param(aConnectorDlg.ModelToConnectTo,'Handle');

                FastRestartStatusIsOn=strcmp(get_param(bdroot(mdlHandle),'FastRestart'),'on')&&...
                strcmpi(get_param(bdroot,'SimulationStatus'),'compiled');

                msgTopics=Simulink.sta.ScenarioTopics();


                if FastRestartStatusIsOn
                    publishMessage(aConnectorDlg,msgTopics.FAST_RESTART_ISON,true);
                else
                    publishMessage(aConnectorDlg,msgTopics.FAST_RESTART_ISON,false);
                end

            end

        end


        function publishSimState(aConnectorDlg,boolActive)
            publishMessage(aConnectorDlg,'sta/modelsimstateactive',boolActive);
            publishFastRestartState(aConnectorDlg);
        end



        function handleUnsavedChangesDialog(aConnectorDlg,evt)




            msgTopics=Simulink.sta.ScenarioTopics();

            if aConnectorDlg.theDispatcher.Subscribers.isKey(msgTopics.UNSAVED_ONCLOSE)
                message.unsubscribe(aConnectorDlg.theDispatcher.Subscribers(msgTopics.UNSAVED_ONCLOSE));
                aConnectorDlg.theDispatcher.Subscribers.remove(msgTopics.UNSAVED_ONCLOSE);
            end

            if(evt.InfoToSend.Choice==0)




                msgTopics=Simulink.sta.ScenarioTopics();
                publishMessage(aConnectorDlg,msgTopics.SAVE_FROM_CLOSE,[]);

            elseif(evt.InfoToSend.Choice==1)



                cleanState(aConnectorDlg);

            else


                aConnectorDlg.IS_CLOSING=false;
            end
        end


        function handleMATLABExitUnsavedChanges(aConnectorDlg,evt)





            msgTopics=Simulink.sta.ScenarioTopics();

            if aConnectorDlg.theDispatcher.Subscribers.isKey(msgTopics.MATLAB_EXIT_CALLED)
                message.unsubscribe(aConnectorDlg.theDispatcher.Subscribers(msgTopics.MATLAB_EXIT_CALLED));
                aConnectorDlg.theDispatcher.Subscribers.remove(msgTopics.MATLAB_EXIT_CALLED);
            end

            if(evt.InfoToSend.Choice==0)




                msgTopics=Simulink.sta.ScenarioTopics();

                payLoad.exitMATLAB=true;
                publishMessage(aConnectorDlg,msgTopics.SAVE_FROM_CLOSE,payLoad);

            else



                forceMATLABCLOSE(aConnectorDlg);
            end

        end


        function DisplayMsgBox(aConnectorDlg,title,msg,buttons,defButton,cb)








            arg.Title=title;
            arg.Msg=msg;
            arg.Buttons=buttons;
            arg.Default=defButton;
            arg.CbChannel=cb;
            arg.CbUserData=char(matlab.lang.internal.uuid());

            msgTopics=Simulink.sta.ScenarioTopics();
            publishMessage(aConnectorDlg,msgTopics.DIALOG_BOX,arg);

        end


        function cleanState(aConnectorDlg)



            if isa(aConnectorDlg.CEFWindow,'matlab.internal.webwindow')

                delete(aConnectorDlg.CEFWindow);
            end



            unregisterSubscribers(aConnectorDlg);


            removeModelPreCloseCallback(aConnectorDlg);

            removeModelRenameListener(aConnectorDlg);


            deleteSimEventListeners(aConnectorDlg);


            removeFromHashMap(aConnectorDlg);

            delete(aConnectorDlg.theDispatcher);
            delete(aConnectorDlg);
        end


        function msgcb_timeofmapping(aConnectorDlg,msgIn)


            aConnectorDlg.ScenarioRepo.TimeOfMapping=strtrim(msgIn.timeOfMap);
        end


        function msgcb_clearconnections(aConnectorDlg,msgIn)

            if ischar(msgIn.idsToClear)

                if strcmp(msgIn.idsToClear,'all')

                    repoMgr=sta.RepositoryManager;
                    inspecIDs=getInputSpecIDsByScenarioID(repoMgr,aConnectorDlg.ScenarioRepo.ID);


                    for kID=1:length(inspecIDs)

                        inSpec=sta.InputSpecification(inspecIDs(kID));
                        inSpec.ScenarioID=-1;
                    end
                end
            else


                for kID=1:length(msgIn.idsToClear)
                    inSpec=sta.InputSpecification(msgIn.idsToClear(kID));
                    inSpec.ScenarioID=-1;
                end

            end
        end


        function msgcb_updateTreeOrder(~,msgIn)

            repoUtil=starepository.RepositoryUtility();
            setMetaDataByName(repoUtil,msgIn.id,'TreeOrder',msgIn.newTreeOrder);
        end


        function msgcb_bringToFront(aConnectorDlg,~)
            bringToFront(aConnectorDlg);
        end


        function msgcb_setPreference(~,msgIn)

            prefNames=fieldnames(msgIn);

            prefVals=cell(1,length(prefNames));

            for k=1:length(prefVals)
                prefVals{k}=msgIn.(prefNames{k});
            end

            Simulink.sta.PreferenceManager.setRootInportMappingPref(prefNames,prefVals);
        end
    end

end


