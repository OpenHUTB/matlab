classdef Editor<Simulink.sta.ProjectHelperMixin












    properties(Access='public',Hidden)


Tag
ViewInput




        IS_DEBUG=false
        debugPortDefault=[]
        debugPortAPI=[]
debuggingPort
theDispatcher




        debugWeb='staEditorRelease-debug.html'
        debugRelease='staEditorRelease.html'
FullUrl
CEFWindow
CEFIcon


        launchingSTAAppID=[]

editorAppID


        editorBaseMessage='staeditor'



        IS_UI_DIRTY=false;
        DlgTitle=DAStudio.message('sl_sta:editor:figuretitle','untitled');
        DataSourceDefault='untitled.mat';
        IS_STARTUP_DONE=false;
        USE_IOFILE_OBJECT=false;


        Subscriptions;


SignalCellStruct
ModelForTemplate
        IS_EDIT_MODE=true;
        IS_STAND_ALONE=false;
DataSource
        SIGNAL_EDITOR_BLOCK=false;


CloseCallBackSubscription
afterSaveUISubscriber



ScenarioRepo

        TopicNames=Simulink.sta.EditorTopics;
        ScenarioTopicNames=Simulink.sta.ScenarioTopics;

        Helpcommand='editor'
        FORCE_EXIT_FROM_MATLAB=false;
RIMSigStruct

        SDIrunID=[];

        workingSignalID=[];

        FORCE_DIRTY=false;

        OnCleanupFunctionList={};
TableServer


StaWebScopeMessageHandler

LaunchDebugTools
    end





    methods


        function aEditorDlg=Editor(varargin)
            aEditorDlg.Subscriptions=containers.Map;

            initWebAndReleaseUrl(aEditorDlg);

            slwebwidgets.qualifyDataTypeCombobox('double');


            parseInputArguments(aEditorDlg,varargin{:});


            hash1=Simulink.sta.InstanceMap.getInstance();
            openTags=hash1.getOpenTags;


            for kInstance=1:length(openTags)

                theInstance=getUIInstance(hash1,openTags{kInstance});

                IS_EDITOR=isa(theInstance,'Simulink.sta.Editor');




                if IS_EDITOR

                    IS_DATASOURCE_EMPTY=isempty(aEditorDlg.DataSource);

                    if iscell(aEditorDlg.DataSource)
                        current_DataSource=aEditorDlg.DataSource{1};
                    else
                        current_DataSource=aEditorDlg.DataSource;
                    end

                    if iscell(theInstance.DataSource)
                        suspect_DataSource=theInstance.DataSource{1};
                    else
                        suspect_DataSource=theInstance.DataSource;
                    end

                    DOES_DATASOURCE_MATCH=strcmp(current_DataSource,suspect_DataSource);
                    DATA_SOURCE_NONEMPTY_MATCH=~IS_DATASOURCE_EMPTY&&DOES_DATASOURCE_MATCH;
                    BOTH_IN_EDITMODE=aEditorDlg.IS_EDIT_MODE==1&&theInstance.IS_EDIT_MODE==1;

                    if DATA_SOURCE_NONEMPTY_MATCH&&...
BOTH_IN_EDITMODE

                        DOES_CONNECTOR_ID_MATCH=~isempty(theInstance.launchingSTAAppID)&&...
                        strcmp(theInstance.launchingSTAAppID,aEditorDlg.launchingSTAAppID);


                        if DOES_CONNECTOR_ID_MATCH
                            aEditorDlg=theInstance;
                            bringToFront(aEditorDlg);
                            return;
                        else

                            error(message('sl_sta:scenarioconnector:editorSameFileDiffModel',current_DataSource));
                        end
                    end
                end

            end


            if aEditorDlg.IS_EDIT_MODE
                aEditorDlg.Helpcommand='editor';
            else
                aEditorDlg.Helpcommand='preview';
            end

            if aEditorDlg.IS_STAND_ALONE
                aEditorDlg.Helpcommand='standalone_editor';
            end

            if~isempty(aEditorDlg.ViewInput)&&~aEditorDlg.IS_EDIT_MODE

                theNames=fieldnames(aEditorDlg.ViewInput);
                setTitle(aEditorDlg,theNames{1});
            else
                setTitle(aEditorDlg);
            end





            [IS_CONNECTOR_GOOD,errMsg]=connectorStartUp(aEditorDlg);


            if~IS_CONNECTOR_GOOD


                error(errMsg);
            end



            aEditorDlg.StaWebScopeMessageHandler=Simulink.stawebscope.initializeStaWebScope;


            generateWebUrl(aEditorDlg);
            aEditorDlg.theDispatcher=Simulink.sta.Dispatcher(aEditorDlg.editorAppID);
            aEditorDlg.theDispatcher.baseMsg=aEditorDlg.editorBaseMessage;
            subscribeToMessages(aEditorDlg);
            aEditorDlg.TableServer=slwebwidgets.tableeditor.TableServer(aEditorDlg.theDispatcher);



            hash1=Simulink.sta.InstanceMap.getInstance();

            if isempty(aEditorDlg.Tag)

                aEditorDlg.Tag=hash1.generateTag(aEditorDlg.editorAppID);

            end


            addUIInstance(hash1,aEditorDlg.Tag,aEditorDlg);

        end


        function initWebAndReleaseUrl(aEditorDlg)

            aEditorDlg.debugWeb='staEditorRelease-debug.html';
            aEditorDlg.debugRelease='staEditorRelease.html';

        end


        function setTitle(aEditorDlg,varargin)








            if~isempty(varargin)
                if ischar(varargin{1})
                    aEditorDlg.DlgTitle=varargin{1};
                else
                    DAStudio.error('sl_sta:editor:titlemustbechar');
                end
            else

                if aEditorDlg.IS_EDIT_MODE


                    if~isempty(aEditorDlg.DataSource)

                        if iscell(aEditorDlg.DataSource)
                            [~,file,~]=fileparts(aEditorDlg.DataSource{1});
                        else
                            [~,file,~]=fileparts(aEditorDlg.DataSource);
                        end

                        fileForTitle=file;

                    else
                        [~,file,~]=fileparts(aEditorDlg.DataSourceDefault);
                        fileForTitle=file;
                    end

                    if aEditorDlg.IS_UI_DIRTY
                        fileForTitle=[fileForTitle,'*'];
                    end

                    if isempty(aEditorDlg.ModelForTemplate)||aEditorDlg.SIGNAL_EDITOR_BLOCK
                        aEditorDlg.DlgTitle=DAStudio.message('sl_sta:editor:figuretitle',fileForTitle);
                    else
                        aEditorDlg.DlgTitle=DAStudio.message('sl_sta:editor:figuretitle_wModel',fileForTitle,aEditorDlg.ModelForTemplate);
                    end
                end
            end




            if~isempty(aEditorDlg.CEFWindow)
                updateFigureTitle(aEditorDlg);
            end
        end


        function show(aEditorDlg)


            if isvalid(aEditorDlg)&&isempty(aEditorDlg.CEFWindow)


                createCEFWindow(aEditorDlg);
                updateFigureTitle(aEditorDlg);
                aEditorDlg.CEFWindow.show();
                aEditorDlg.bringToFront();

                if aEditorDlg.LaunchDebugTools
                    aEditorDlg.CEFWindow.executeJS('cefclient.sendMessage("openDevTools");');
                end
            end

        end


        function close(aEditorDlg)
            if isvalid(aEditorDlg)
                onDialogClose(aEditorDlg,[]);
            end
        end


        function iconPath=get.CEFIcon(~)

            iconFileName='SignalAuthoring_24.ico';

            if ismac()
                iconFileName='macSignalAuthoring_24.ico';
            elseif~ispc()&&~ismac()
                iconFileName='SignalAuthoring_24.png';
            end

            iconPath=fullfile(matlabroot,...
            'toolbox',...
            'simulink',...
            'sta',...
            'ui',...
            'images',...
            iconFileName);
        end


        function bringToFront(aEditorDlg)


            if~isempty(aEditorDlg.CEFWindow)
                aEditorDlg.CEFWindow.bringToFront();
            end

        end

        function addOnCleanup(aEditorDlg,cleanupFcnHandle)






            if isa(cleanupFcnHandle,'function_handle')
                aEditorDlg.OnCleanupFunctionList{end+1}=onCleanup(cleanupFcnHandle);
            else
                throw(MException(message('sl_sta:editor:InvalidInputToaddOnCleanup')));
            end
        end


        function isDirty=getIsUIDirty(aEditorDlg)
            isDirty=aEditorDlg.IS_UI_DIRTY;
            return;
        end


        function fileName=getFileName(aEditorDlg)

            fileName=aEditorDlg.DataSource;
            return;
        end


        function discardChangesAndClose(aEditorDlg)

            aEditorDlg.IS_UI_DIRTY=false;
            onDialogClose(aEditorDlg,[]);
        end


        function saveChangesAndClose(aEditorDlg)


            repoUtil=starepository.RepositoryUtility();
            topIDsOrdered=getTopLevelIDsInTreeOrder(repoUtil,aEditorDlg.ScenarioRepo.ID);


            [gotSaved,saveErrMsg]=Simulink.sta.exportdialog.exportToFile(topIDsOrdered,aEditorDlg.DataSource,false);
            if gotSaved
                aEditorDlg.IS_UI_DIRTY=false;
                onDialogClose(aEditorDlg,[]);
            else
                throw(MException('sl_sta:editor:cmdLineFailOnClose',saveErrMsg));
            end
        end
    end


    methods(Hidden)


        function portNum=getDebugPort(aEditorDlg)
            portNum=aEditorDlg.debuggingPort;
        end


        function figTitle=getFigureTitle(aEditorDlg)

            figTitle=aEditorDlg.CEFWindow.Title;
        end


        function publishMessage(aEditorDlg,subChannel,msgVal)


            fullChannel=genChannel(aEditorDlg,subChannel);

            message.publish(fullChannel,msgVal);
        end


        function publishMessageToSta(aEditorDlg,subChannel,msgVal)


            fullChannel=sprintf('/sta%s/%s',...
            aEditorDlg.launchingSTAAppID,...
            subChannel);


            message.publish(fullChannel,msgVal);
        end


        function fullChannel=genChannel(aEditorDlg,subChannel)


            fullChannel=sprintf('/%s%s/%s',aEditorDlg.editorBaseMessage,...
            aEditorDlg.editorAppID,...
            subChannel);

        end


        function msgcb_open(aEditorDlg,msg)

            hash1=Simulink.sta.InstanceMap.getInstance();
            tagForNew=hash1.generateTag(aEditorDlg.editorAppID);

            try

                if isempty(aEditorDlg.ModelForTemplate)
                    anOpenEditor=Simulink.sta.Editor(...
                    'UpstreamAppID',aEditorDlg.launchingSTAAppID,...
                    'DataSource',msg.fileToOpen,...
                    'Tag',tagForNew,...
                    'StandAlone',aEditorDlg.IS_STAND_ALONE);
                else
                    anOpenEditor=Simulink.sta.Editor(...
                    'UpstreamAppID',aEditorDlg.launchingSTAAppID,...
                    'DataSource',msg.fileToOpen,...
                    'Model',aEditorDlg.ModelForTemplate,...
                    'Tag',tagForNew,...
                    'StandAlone',aEditorDlg.IS_STAND_ALONE);
                end
                anOpenEditor.show();
                anOpenEditor.bringToFront();
            catch ME


                if strcmp(ME.identifier,'sl_sta:sta:InvalidInputValue')

                    errorMsg=DAStudio.message('sl_iofile:matfile:invalidFileType',msg.fileToOpen);

                    throwErrorDialog(aEditorDlg,'sl_sta_general:common:Error',errorMsg);
                elseif strcmp(ME.identifier,'sl_sta:sta:FileDoesNotExist')


                    throwErrorDialog(aEditorDlg,'sl_sta_general:common:Error',DAStudio.message('sl_sta:sta:FileDoesNotExist',msg.fileToOpen));
                end
            end
        end


        function initScenario(aEditorDlg)

            aEditorDlg.ScenarioRepo=sta.Scenario();
            aEditorDlg.ScenarioRepo.Description='Empty Description';
            aEditorDlg.ScenarioRepo.APPid=aEditorDlg.editorAppID;
        end


        function saveScreenshot(aEditorDlg,imData,msg)
            if~isempty(imData)
                rectangleStruct=msg.clientRect;
                filename=msg.filename;
                if(isfield(msg,'doCrop')&&msg.doCrop)
                    axeslocation=[rectangleStruct.left,rectangleStruct.top,rectangleStruct.width,rectangleStruct.height];
                    imData=imcrop(imData,axeslocation);
                end
                imwrite(imData,filename);
            else
                errMsg=message('sl_sta:editor:screenshotdesktoponly').getString;
                throwErrorDialog(aEditorDlg,'sl_sta_general:common:Error',errMsg);
            end
        end

    end


    methods(Access='protected')


        function updateFigureTitle(aEditorDlg)





            aEditorDlg.CEFWindow.Title=aEditorDlg.DlgTitle;

        end


        function parseInputArguments(aEditorDlg,varargin)

            inputStruct=parseEditorInputs(varargin{:});

            aEditorDlg.IS_DEBUG=inputStruct.Debug;
            aEditorDlg.debugPortAPI=inputStruct.DebugPort;
            aEditorDlg.FORCE_DIRTY=inputStruct.ForceDirty;
            aEditorDlg.LaunchDebugTools=inputStruct.LaunchDebugTools;
            aEditorDlg.SIGNAL_EDITOR_BLOCK=inputStruct.SignalEditorBlock;




            if isempty(aEditorDlg.debugPortAPI)
                aEditorDlg.debuggingPort=matlab.internal.getDebugPort;
            else
                aEditorDlg.debuggingPort=aEditorDlg.debugPortAPI;
            end

            aEditorDlg.SignalCellStruct=inputStruct.Signals;
            aEditorDlg.ViewInput=inputStruct.ViewInput;
            aEditorDlg.launchingSTAAppID=inputStruct.UpstreamAppID;

            if~isempty(inputStruct.DataSource)

                if isstring(inputStruct.DataSource)&&isscalar(inputStruct.DataSource)
                    inputStruct.DataSource=char(inputStruct.DataSource);
                end

                if isstring(inputStruct.DataSource)&&~isscalar(inputStruct.DataSource)
                    inputStruct.DataSource=cellstr(inputStruct.DataSource);
                end


                if ischar(inputStruct.DataSource)

                    aEditorDlg.DataSource=inputStruct.DataSource;

                    [aDir,~,~]=fileparts(aEditorDlg.DataSource);
                    whichFile=which(aEditorDlg.DataSource);

                    if isempty(aDir)&&~isempty(whichFile)
                        aEditorDlg.DataSource=whichFile;
                    end

                elseif iscell(inputStruct.DataSource)

                    aEditorDlg.DataSource{1}=inputStruct.DataSource{1};
                    aEditorDlg.DataSource{2}=inputStruct.DataSource{2};

                    if ischar(aEditorDlg.DataSource{1})
                        [aDir,~,~]=fileparts(aEditorDlg.DataSource{1});
                        whichFile=which(aEditorDlg.DataSource{1});

                        if isempty(aDir)&&~isempty(whichFile)
                            aEditorDlg.DataSource{1}=whichFile;
                        end
                    elseif isa(aEditorDlg.DataSource{1},'iofile.File')



                        aEditorDlg.USE_IOFILE_OBJECT=true;

                    end


                end
            else
                aEditorDlg.DataSource='';
            end



            if~isempty(aEditorDlg.SignalCellStruct)&&isempty(aEditorDlg.DataSource)
                aEditorDlg.DataSource=aEditorDlg.SignalCellStruct{1}.FullDataSource;
            end

            if isstring(inputStruct.Model)&&isscalar(inputStruct.Model)
                modelAsChar=char(inputStruct.Model);

                [~,modelOnlyName,~]=fileparts(modelAsChar);

                inputStruct.Model=modelOnlyName;
            end

            aEditorDlg.ModelForTemplate=inputStruct.Model;
            aEditorDlg.IS_EDIT_MODE=inputStruct.EditMode;
            aEditorDlg.Tag=inputStruct.Tag;

            if~isempty(inputStruct.StandAlone)
                aEditorDlg.IS_STAND_ALONE=inputStruct.StandAlone;
            end

            aEditorDlg.RIMSigStruct=inputStruct.RIMSigStruct;

        end


        function[bool,errMsg]=connectorStartUp(~)


            bool=false;

            try
                connector.ensureServiceOn;
                bool=true;
                errMsg='';




                Simulink.sdi.internal.startConnector();
            catch


                errMsg=error(DAStudio.message('sl_sta:sta:ConnectorFailed','EDITOR'));
            end


        end


        function generateWebUrl(aEditorDlg)


            if aEditorDlg.IS_DEBUG
                aURL=aEditorDlg.debugWeb;
            else
                aURL=aEditorDlg.debugRelease;
            end



            aEditorDlg.FullUrl=connector.getUrl(['/toolbox/simulink/sta/web/SigAuth/Editor/',...
            aURL]);

            applyEditorAppID(aEditorDlg);

        end


        function applyEditorAppID(aEditorDlg)

            aEditorDlg.editorAppID=aEditorDlg.StaWebScopeMessageHandler.ClientId;


            sep='?';
            if strfind(aEditorDlg.FullUrl,'?')>1
                sep='&';
            end

            aEditorDlg.FullUrl=strcat(aEditorDlg.FullUrl,sep,'UUID=',aEditorDlg.editorAppID,' ');
        end


        function figPosition=getPosition(~)
            set(0,'Units','pixels');
            scnsize=get(0,'ScreenSize');



            xfraction=0.75;
            yfraction=0.75;


            xPos=0.5*scnsize(3)*(1-xfraction);
            yPos=0.5*scnsize(4)*(1-yfraction);

            width=scnsize(3)*xfraction;
            height=scnsize(4)*yfraction;
            figPosition=[xPos,yPos,width,height];



            try


                tmpFigPosition=SignalEditorPreferences.getInstance.getFigureSizePreference();
            catch



                tmpFigPosition=[];
            end

            if isempty(tmpFigPosition)
                tmpFigPosition=figPosition;



                try

                    SignalEditorPreferences.getInstance.setPreference(SignalEditorPreferences.getInstance.FigureSizePref,figPosition);
                catch

                end
            end

            figPosition=tmpFigPosition;


        end


        function onDialogClose(aEditorDlg,~)


            if aEditorDlg.IS_UI_DIRTY&&aEditorDlg.IS_EDIT_MODE


                msgTopics=Simulink.sta.EditorTopics();


                ListenerChannel=msgTopics.UNSAVED_ONCLOSE;


                if aEditorDlg.theDispatcher.Subscribers.isKey(msgTopics.UNSAVED_ONCLOSE)
                    message.unsubscribe(aEditorDlg.theDispatcher.Subscribers(msgTopics.UNSAVED_ONCLOSE));
                    aEditorDlg.theDispatcher.Subscribers.remove(msgTopics.UNSAVED_ONCLOSE);
                end




                aEditorDlg.CloseCallBackSubscription=subscribe(aEditorDlg.theDispatcher,msgTopics.UNSAVED_ONCLOSE,@aEditorDlg.handleUnsavedChangesDialog);


                buttons={DAStudio.message('sl_sta_general:common:Yes'),...
                DAStudio.message('sl_sta_general:common:No'),...
                DAStudio.message('sl_sta_general:common:Cancel')};

                unSavedMsgText=DAStudio.message('sl_sta:editor:UnsavedText');

                if aEditorDlg.IS_STAND_ALONE
                    unSavedMsgText=DAStudio.message('sl_sta:editor:UnsavedTextStandAlone');
                end

                aEditorDlg.DisplayMsgBox(DAStudio.message('sl_sta:sta:UnsavedTitle'),...
                unSavedMsgText,...
                buttons,...
                0,...
                ListenerChannel);
            else


                cleanState(aEditorDlg);


            end


        end


        function cleanState(aEditorDlg)

            if~isempty(aEditorDlg.CEFWindow)
                try
                    SignalEditorPreferences.getInstance.addFigureSize(aEditorDlg.CEFWindow.Position);
                catch



                end
            end

            delete(aEditorDlg.CEFWindow);


            unregisterSubscribers(aEditorDlg);


            hash1=Simulink.sta.InstanceMap.getInstance();
            removeTag(hash1,aEditorDlg.Tag);
            delete(aEditorDlg);
        end


        function cleanOnMATLABExit(aEditorDlg)


            unregisterSubscribers(aEditorDlg);


            hash1=Simulink.sta.InstanceMap.getInstance();
            removeTag(hash1,aEditorDlg.Tag);
            if~isempty(aEditorDlg.CEFWindow)
                try
                    SignalEditorPreferences.getInstance.addFigureSize(aEditorDlg.CEFWindow.Position);
                catch



                end
            end
            aEditorDlg.CEFWindow.close;
        end



        function handleUnsavedChangesDialog(aEditorDlg,evt)




            msgTopics=Simulink.sta.EditorTopics();

            if aEditorDlg.theDispatcher.Subscribers.isKey(msgTopics.UNSAVED_ONCLOSE)
                message.unsubscribe(aEditorDlg.theDispatcher.Subscribers(msgTopics.UNSAVED_ONCLOSE));
                aEditorDlg.theDispatcher.Subscribers.remove(msgTopics.UNSAVED_ONCLOSE);
            end

            if(evt.InfoToSend.Choice==0)




                msgTopics=Simulink.sta.EditorTopics();
                payLoad.exitMATLAB=false;
                publishMessage(aEditorDlg,msgTopics.SAVE_FROM_CLOSE,[]);

            elseif(evt.InfoToSend.Choice==1)


                cleanState(aEditorDlg);
            else


            end

        end


        function createCEFWindow(aEditorDlg)


            figPosition=getPosition(aEditorDlg);






            aEditorDlg.CEFWindow=matlab.internal.webwindow(aEditorDlg.FullUrl,...
            aEditorDlg.debuggingPort);


            aEditorDlg.CEFWindow.Position=[figPosition(1),...
            figPosition(2),...
            figPosition(3),...
            figPosition(4)];

            aEditorDlg.CEFWindow.setMinSize([625,120]);

            aEditorDlg.CEFWindow.Title=aEditorDlg.DlgTitle;



            arch=computer('arch');
            switch arch
            case{'win64','glnx86','glnxa64'}

                aEditorDlg.CEFWindow.Icon=aEditorDlg.CEFIcon;
            end


            aEditorDlg.CEFWindow.CustomWindowClosingCallback=@(evt,src)onDialogClose(aEditorDlg);
            aEditorDlg.CEFWindow.MATLABClosingCallback=@(evt,src)onMATLABClose(aEditorDlg);
        end


        function subscribeToMessages(aEditorDlg)


            msgTopics=Simulink.sta.EditorTopics();


            subscribe(aEditorDlg.theDispatcher,msgTopics.START_UP,@aEditorDlg.msgcb_startup);
            subscribe(aEditorDlg.theDispatcher,msgTopics.IS_UI_DIRTY,@aEditorDlg.msgcb_isuidirty);



            subscribe(aEditorDlg.theDispatcher,msgTopics.NEW,@aEditorDlg.msgcb_new);
            subscribe(aEditorDlg.theDispatcher,msgTopics.OPEN,@aEditorDlg.msgcb_open);
            subscribe(aEditorDlg.theDispatcher,msgTopics.CONNECT,@aEditorDlg.msgcb_connect);


            subscribe(aEditorDlg.theDispatcher,msgTopics.FORCE_CLOSE,@aEditorDlg.msgcb_forceclose);
            subscribe(aEditorDlg.theDispatcher,msgTopics.MAT_FILE_UPDATE,@aEditorDlg.msgcb_updatematfile);


            subscribe(aEditorDlg.theDispatcher,msgTopics.SIGNAL_INSERT,@aEditorDlg.msgcb_insertsignal);
            subscribe(aEditorDlg.theDispatcher,msgTopics.SIGNAL_PASTE,@aEditorDlg.msgcb_copyNPaste);


            subscribe(aEditorDlg.theDispatcher,msgTopics.MOVE_ITEM,@aEditorDlg.msgcb_moveitem);


            subscribe(aEditorDlg.theDispatcher,msgTopics.LAUNCH_HELP,@aEditorDlg.msgcb_help);

            subscribe(aEditorDlg.theDispatcher,msgTopics.SET_RUNID,@aEditorDlg.msgcb_setRunID);

            subscribe(aEditorDlg.theDispatcher,msgTopics.UPDATE_WORKING_ID,@aEditorDlg.msgcb_setWorkingID);




            subscribe(aEditorDlg.theDispatcher,msgTopics.AUTHOR_INSERT,@aEditorDlg.msgcb_authorAndInsert);
            subscribe(aEditorDlg.theDispatcher,msgTopics.RE_AUTHOR_INSERT,@aEditorDlg.msgcb_reauthorSignal);

            subscribe(aEditorDlg.theDispatcher,'screenshot',@aEditorDlg.msgcb_screenshot);

        end


        function unregisterSubscribers(aEditorDlg)


            sKeys=aEditorDlg.Subscriptions.keys;


            for k=1:length(sKeys)
                message.unsubscribe(aEditorDlg.Subscriptions(sKeys{k}));
                aEditorDlg.Subscriptions.remove(sKeys{k});
            end

        end



        function msgcb_startup(aEditorDlg,~)

            aEditorDlg.IS_STARTUP_DONE=true;

            msgTopics=Simulink.sta.EditorTopics();


            fullChannelEditMode=sprintf('%s%s/%s',msgTopics.BASE_MSG,aEditorDlg.editorAppID,msgTopics.IS_EDIT_MODE);
            outdataMode.isEditMode=aEditorDlg.IS_EDIT_MODE;
            outdataMode.isDatasetPlot=~isempty(aEditorDlg.ViewInput);
            outdataMode.isStandAlone=aEditorDlg.IS_STAND_ALONE;
            message.publish(fullChannelEditMode,outdataMode);


            eng=sdi.Repository(true);
            eng.safeTransaction(@initScenario,aEditorDlg);

            sessionpayload.scenarioinfo.id=aEditorDlg.ScenarioRepo.ID;


            publishMessage(aEditorDlg,aEditorDlg.ScenarioTopicNames.SCENARIO_CREATE,sessionpayload);



            if~isempty(aEditorDlg.SignalCellStruct)

                fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,aEditorDlg.editorAppID,'SignalAuthoring/UIModelData');
                outdata.arrayOfListItems=aEditorDlg.SignalCellStruct;
                message.publish(fullChannel,outdata);
            else


                if~isempty(aEditorDlg.DataSource)||~isempty(aEditorDlg.ViewInput)

                    importDataOnStartUp(aEditorDlg);

                end
            end

            modelInfo.model=aEditorDlg.ModelForTemplate;
            modelInfo.signalEditorBlock=aEditorDlg.SIGNAL_EDITOR_BLOCK;
            publishMessage(aEditorDlg,msgTopics.MODEL_TO_USE,modelInfo);

            if isempty(aEditorDlg.DataSource)
                aEditorDlg.DataSource=aEditorDlg.DataSourceDefault;
            elseif iscell(aEditorDlg.DataSource)
                if isa(aEditorDlg.DataSource{1},'iofile.File')



                    publishMessage(aEditorDlg,msgTopics.MAT_FILE_UPDATE,aEditorDlg.DataSource{1}.FileName);
                else
                    publishMessage(aEditorDlg,msgTopics.MAT_FILE_UPDATE,aEditorDlg.DataSource{1});
                end
            else
                publishMessage(aEditorDlg,msgTopics.MAT_FILE_UPDATE,aEditorDlg.DataSource);
            end

            if aEditorDlg.FORCE_DIRTY

                publishMessage(aEditorDlg,msgTopics.FORCE_DIRTY,true);
            end


            publishMessage(aEditorDlg,msgTopics.START_UP_DONE,[]);
        end


        function msgcb_isuidirty(aEditorDlg,msg)


            aEditorDlg.IS_UI_DIRTY=msg.isdirty;


            setTitle(aEditorDlg);

        end








        function msgcb_new(aEditorDlg,~)
            hash1=Simulink.sta.InstanceMap.getInstance();
            tagForNew=hash1.generateTag(aEditorDlg.editorAppID);


            if isempty(aEditorDlg.ModelForTemplate)
                aNewEditor=Simulink.sta.Editor(...
                'UpstreamAppID',aEditorDlg.launchingSTAAppID,...
                'Tag',tagForNew,...
                'StandAlone',aEditorDlg.IS_STAND_ALONE);
            else
                aNewEditor=Simulink.sta.Editor(...
                'UpstreamAppID',aEditorDlg.launchingSTAAppID,...
                'Model',aEditorDlg.ModelForTemplate,...
                'Tag',tagForNew,...
                'StandAlone',aEditorDlg.IS_STAND_ALONE);
            end
            aNewEditor.show();

            aNewEditor.bringToFront();
        end


        function msgcb_connect(aEditorDlg,msg)

            jsonStruct=msg.data;


            if~isempty(aEditorDlg.launchingSTAAppID)&&~aEditorDlg.IS_UI_DIRTY


                jsonCell=convertClientJsonToServerJson(aEditorDlg,jsonStruct);



                for kCell=1:length(jsonCell)

                    jsonCell{kCell}.IS_LINKED=true;

                end

                aEditorDlg.SignalCellStruct=jsonCell;




                msgTopics=Simulink.sta.EditorTopics();

                payloadConnect.IS_CONNECTING=true;
                publishMessage(aEditorDlg,msgTopics.IS_UI_CONNECTING,payloadConnect);


                fileName_Now=msg.filesavedto;
                [~,fileNow_OnlyName,fileNow_OnlyExt]=fileparts(fileName_Now);
                fileOnlyName_Now=[fileNow_OnlyName,fileNow_OnlyExt];

                if~isempty(aEditorDlg.RIMSigStruct)&&...
                    strcmp(fileName_Now,aEditorDlg.RIMSigStruct{1}.FullDataSource)
                    repoUtil=starepository.RepositoryUtility;
                    for kRim=1:length(aEditorDlg.RIMSigStruct)

                        rimID=aEditorDlg.RIMSigStruct{kRim}.ID;
                        rimName=aEditorDlg.RIMSigStruct{kRim}.Name;
                        rimParentID=aEditorDlg.RIMSigStruct{kRim}.ParentID;


                        if strcmpi(rimParentID,'input')
                            for kEdit=1:length(aEditorDlg.SignalCellStruct)


                                if strcmpi(aEditorDlg.SignalCellStruct{kEdit}.ParentID,'input')...
                                    &&strcmp(rimName,aEditorDlg.SignalCellStruct{kEdit}.Name)

                                    WAS_EDITED=repoUtil.getMetaDataByName(aEditorDlg.SignalCellStruct{kEdit}.ID,'IS_EDITED');

                                    if isempty(WAS_EDITED)||~WAS_EDITED

                                        msgOut.OldRimID=rimID;
                                        msgOut.NewRimID=aEditorDlg.SignalCellStruct{kEdit}.ID;


                                        publishMessageToSta(aEditorDlg,msgTopics.RE_ASSIGN_MAPPING,msgOut);

                                        repoUtil.setMetaDataByName(aEditorDlg.SignalCellStruct{kEdit}.ID,'IS_EDITED',0);

                                    end


                                    break;
                                else



                                    repoUtil.setMetaDataByName(aEditorDlg.SignalCellStruct{kEdit}.ID,'IS_EDITED',0);
                                end
                            end
                        end

                    end
                else
                    for kSource=1:length(aEditorDlg.SignalCellStruct)
                        aEditorDlg.SignalCellStruct{kSource}.FullDataSource=fileName_Now;
                        aEditorDlg.SignalCellStruct{kSource}.DataSource=fileOnlyName_Now;
                    end
                end

                msgToSend.arrayOfListItems=aEditorDlg.SignalCellStruct;


                aEditorDlg.RIMSigStruct=aEditorDlg.SignalCellStruct;

                publishMessageToSta(aEditorDlg,msgTopics.CONNECTOR_ONUIMODEL,msgToSend);



                if~isempty(aEditorDlg.SignalCellStruct)


                    repoUtil=starepository.RepositoryUtility;
                    [aEditorDlg.SignalCellStruct,~,~]=copyAndReplaceEditorScenario(repoUtil,...
                    aEditorDlg.SignalCellStruct,aEditorDlg.ScenarioRepo.ID);

                    newIDStruct(length(aEditorDlg.SignalCellStruct)).oldID=-1;
                    newIDStruct(length(aEditorDlg.SignalCellStruct)).newID=-1;
                    newIDStruct(length(aEditorDlg.SignalCellStruct)).newParentID=-1;

                    for k=length(aEditorDlg.SignalCellStruct):-1:1
                        newIDStruct(k).oldID=jsonCell{k}.ID;
                        newIDStruct(k).newID=aEditorDlg.SignalCellStruct{k}.ID;
                        newIDStruct(k).newParentID=aEditorDlg.SignalCellStruct{k}.ParentID;



                        if~isempty(aEditorDlg.workingSignalID)&&...
                            (aEditorDlg.workingSignalID==jsonCell{k}.ID)

                            payload.workingSignalID=newIDStruct(k).newID;
                            publishMessage(aEditorDlg,msgTopics.UPDATE_WORKING_ID,payload);

                        end

                    end



                    publishMessage(aEditorDlg,msgTopics.REPLACE_OLD_ID,newIDStruct);
                else
                    msgPayLoad.filename=aEditorDlg.DataSource;
                    publishMessageToSta(aEditorDlg,msgTopics.UNLINK_FILE,msgPayLoad);
                end


                hash1=Simulink.sta.InstanceMap.getInstance();
                theConnectorInHash=getUIInstance(hash1,genRIMTag(aEditorDlg));
                payloadConnect.RIM_AVAILABLE=true;
                if isempty(theConnectorInHash)
                    payloadConnect.RIM_AVAILABLE=false;
                end


                payloadConnect.IS_CONNECTING=false;
                publishMessage(aEditorDlg,msgTopics.IS_UI_CONNECTING,payloadConnect);
                bringToFrontMsg.isTrue=true;
                publishMessageToSta(aEditorDlg,msgTopics.BRING_TO_FRONT,bringToFrontMsg);
            end


        end


        function tag=genRIMTag(aEditor)

            tag=['sta_',aEditor.ModelForTemplate];
        end


        function msgcb_setWorkingID(aEditorDlg,msg)

            aEditorDlg.workingSignalID=msg.workingSignalID;

        end


        function msgcb_screenshot(aEditorDlg,msg)

            try
                imData=aEditorDlg.CEFWindow.getScreenshot();

                saveScreenshot(aEditorDlg,imData,msg);
            catch ME

                errMsg=ME.message;
                if isempty(aEditorDlg.CEFWindow)
                    errMsg=message('sl_sta:editor:screenshotdesktoponly').getString;
                end

                throwErrorDialog(aEditorDlg,'sl_sta_general:common:Error',errMsg);
            end
        end


        function msgcb_forceclose(aEditorDlg,~)

            cleanState(aEditorDlg);
        end


        function msgcb_updatematfile(aEditorDlg,msgFromClient)

            aEditorDlg.DataSource=msgFromClient.filename;
            setTitle(aEditorDlg);
        end


        function msgcb_help(aEditorDlg,msgIn)

            if~isempty(msgIn)&&~isempty(fieldnames(msgIn))
                Simulink.sta.editor.cb_help(msgIn.Helpcommand);
            else
                Simulink.sta.editor.cb_help(aEditorDlg.Helpcommand);
            end


        end


        function jsonCell=convertClientJsonToServerJson(~,jsonStruct)


            jsonCell=convertClientJsonToServerJson(jsonStruct);

        end


        function throwErrorDialog(aEditorDlg,errorTitleID,errorMsg)





            msgTopics=Simulink.sta.EditorTopics();



            fullChannel=genChannel(aEditorDlg,msgTopics.DIAGNOSTICS_DLG);

            slwebwidgets.errordlgweb(fullChannel,...
            errorTitleID,...
            errorMsg);

        end


        function throwWarningDialog(aEditorDlg,errorTitleID,errorMsg)





            msgTopics=Simulink.sta.EditorTopics();



            fullChannel=genChannel(aEditorDlg,msgTopics.DIAGNOSTICS_DLG);

            slwebwidgets.warndlgweb(fullChannel,...
            errorTitleID,...
            errorMsg);

        end


        function importDataOnStartUp(aEditorDlg)

            msgTopics=Simulink.sta.EditorTopics();
            importWarnID='sl_sta_general:common:Warning';


            if~iscell(aEditorDlg.DataSource)&&~isempty(aEditorDlg.DataSource)

                [~,~,ext]=fileparts(aEditorDlg.DataSource);

                FI_WARN_THROWN=false;
                if strcmpi(ext,'.mat')
                    [warnMsgB4Load,warnIDB4Fload]=lastwarn;
                    lastwarn('');
                    [jsonStruct,errorMsg]=importFromMatFile(aEditorDlg,aEditorDlg.DataSource,[]);
                    [warnMsgB4After,warnIDAfter]=lastwarn;%#ok<ASGLU> 

                    if~isempty(errorMsg)
                        throwErrorDialog(aEditorDlg,'sl_sta_general:common:Error',errorMsg);
                        return;
                    end

                    ENUM_WARN_THROWN=false;


                    if isempty(warnIDAfter)&&~isempty(warnIDB4Fload)
                        lastwarn(warnMsgB4Load,warnIDB4Fload);
                    elseif~isempty(warnIDAfter)


                        if strcmp(warnIDAfter,'fixed:fi:licenseCheckoutFailed')







                            tempWarnText=DAStudio.message('sl_sta:editor:fixedpointwarningonload',aEditorDlg.DataSource);
                            throwWarningDialog(aEditorDlg,importWarnID,...
                            tempWarnText);
                            FI_WARN_THROWN=true;
                        elseif strcmpi('MATLAB:class:EnumerableClassNotFound',warnIDAfter)||...
                            strcmpi('MATLAB:class:EnumerationNameMissing',warnIDAfter)||...
                            strcmpi('MATLAB:class:EnumerationValueChanged',warnIDAfter)



                            tempWarnText=warnMsgB4After;
                            throwWarningDialog(aEditorDlg,importWarnID,...
                            tempWarnText);
                            ENUM_WARN_THROWN=true;
                        end
                    end

                end




                if isempty(jsonStruct)&&~FI_WARN_THROWN&&~ENUM_WARN_THROWN

                    throwWarningDialog(aEditorDlg,importWarnID,...
                    DAStudio.message('sl_sta:editor:datasourceempty',aEditorDlg.DataSource));

                end

            elseif iscell(aEditorDlg.DataSource)

                downselectstruct=struct('name',[],'children',[]);
                fileName=aEditorDlg.DataSource{1};

                downselectstruct(length(aEditorDlg.DataSource)-1)=struct('name',[],'children',[]);


                for id=2:length(aEditorDlg.DataSource)
                    downselectstruct(id-1).name=aEditorDlg.DataSource{id};
                    downselectstruct(id-1).children='all';
                end

                ext='';
                if~aEditorDlg.USE_IOFILE_OBJECT
                    [~,~,ext]=fileparts(aEditorDlg.DataSource{1});
                end
                if strcmpi(ext,'.mat')||aEditorDlg.USE_IOFILE_OBJECT
                    [jsonStruct,errorMsg]=importFromMatFile(aEditorDlg,fileName,downselectstruct);

                    if~isempty(errorMsg)
                        throwErrorDialog(aEditorDlg,'sl_sta_general:common:Error',errorMsg);
                        return;
                    end

                end


                if isempty(jsonStruct)



                    if aEditorDlg.USE_IOFILE_OBJECT
                        dataSource=aEditorDlg.DataSource{1}.FileName;
                    else
                        dataSource=aEditorDlg.DataSource{1};
                    end
                    throwWarningDialog(aEditorDlg,importWarnID,...
                    DAStudio.message('sl_sta:editor:datasourceempty',dataSource));

                end
            else

                try
                    varFile=iofile.Variable(aEditorDlg.ViewInput);
                    theNames=fieldnames(aEditorDlg.ViewInput);


                    [jsonStruct,aEditorDlg.SDIrunID]=import2Repository(varFile);

                    if~aEditorDlg.IS_EDIT_MODE
                        setTitle(aEditorDlg,theNames{1});
                        aEditorDlg.Helpcommand='ds_plot';
                    end
                catch ME
                    jsonStruct={};

                    throwErrorDialog(aEditorDlg,'sl_sta_general:common:Error',ME.message);

                end

            end



            aEditorDlg.SignalCellStruct=jsonStruct;

            fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,aEditorDlg.editorAppID,'SignalAuthoring/UIModelData');
            outdata.arrayOfListItems=aEditorDlg.SignalCellStruct;
            message.publish(fullChannel,outdata);

            eng=sdi.Repository(true);
            eng.safeTransaction(@initExternalSources,...
            aEditorDlg.SignalCellStruct,...
            aEditorDlg.ScenarioRepo.ID);


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










































































        function DisplayMsgBox(aEditorDlg,title,msg,buttons,defButton,cb)








            arg.Title=title;
            arg.Msg=msg;
            arg.Buttons=buttons;
            arg.Default=defButton;
            arg.CbChannel=cb;
            arg.CbUserData=char(matlab.lang.internal.uuid());

            msgTopics=Simulink.sta.EditorTopics();
            publishMessage(aEditorDlg,msgTopics.DIALOG_BOX,arg);

        end


        function onMATLABClose(aEditorDlg,~)


            if isvalid(aEditorDlg)


                if aEditorDlg.IS_UI_DIRTY&&~aEditorDlg.FORCE_EXIT_FROM_MATLAB
                    aEditorDlg.bringToFront();

                    msgTopics=Simulink.sta.EditorTopics();


                    ListenerChannel=msgTopics.MATLAB_EXIT_CALLED;



                    if aEditorDlg.theDispatcher.Subscribers.isKey(msgTopics.MATLAB_EXIT_CALLED)
                        message.unsubscribe(aEditorDlg.theDispatcher.Subscribers(msgTopics.MATLAB_EXIT_CALLED));
                        aEditorDlg.theDispatcher.Subscribers.remove(msgTopics.MATLAB_EXIT_CALLED);
                    end


                    aEditorDlg.CloseCallBackSubscription=subscribe(aEditorDlg.theDispatcher,...
                    msgTopics.MATLAB_EXIT_CALLED,@aEditorDlg.handleMATLABExitUnsavedChanges);

                    buttons={DAStudio.message('sl_sta_general:common:Yes'),...
                    DAStudio.message('sl_sta_general:common:No')};

                    aEditorDlg.DisplayMsgBox(DAStudio.message('sl_sta:sta:UnsavedTitle'),...
                    DAStudio.message('sl_sta:sta:UnsavedText'),...
                    buttons,...
                    0,...
                    ListenerChannel);
                else

                    cleanOnMATLABExit(aEditorDlg);
                    exit();
                end

            else
                cleanOnMATLABExit(aEditorDlg);
                exit();
            end

        end


        function handleMATLABExitUnsavedChanges(aEditorDlg,evt)


            if aEditorDlg.theDispatcher.Subscribers.isKey(aEditorDlg.TopicNames.MATLAB_EXIT_CALLED)
                message.unsubscribe(aEditorDlg.theDispatcher.Subscribers(aEditorDlg.TopicNames.MATLAB_EXIT_CALLED));
                aEditorDlg.theDispatcher.Subscribers.remove(aEditorDlg.TopicNames.MATLAB_EXIT_CALLED);
            end


            switch evt.InfoToSend.Choice
            case 0

                payLoad.exitMATLAB=true;
                publishMessage(aEditorDlg,aEditorDlg.TopicNames.SAVE_FROM_CLOSE,payLoad);
            case 1

                forceMATLABCLOSE(aEditorDlg);
            end

        end


        function forceMATLABCLOSE(aEditorDlg)
            aEditorDlg.FORCE_EXIT_FROM_MATLAB=true;
            publishMessage(aEditorDlg,aEditorDlg.TopicNames.FORCE_MATLAB_EXIT,[]);
        end
    end

end


