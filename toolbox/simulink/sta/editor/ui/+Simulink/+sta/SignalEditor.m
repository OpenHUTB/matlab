classdef SignalEditor<Simulink.sta.SlappFigure&Simulink.sta.ProjectHelperMixin




    events
FileSavedEvent
    end

    methods(Static)
        function out=setGetFeatureOn(data)
            persistent Var;

            if nargin
                Var=data;
                out=Var;
                return;
            end

            if isempty(Var)
                Var=false;
            end

            out=Var;


        end
    end



    properties
        MinSize=[625,120];

Tag


FullUrl


CEFWindow


IS_DEBUG
LaunchDebugTools
SIGNAL_EDITOR_BLOCK


        MacIcon=fullfile(matlabroot,...
        'toolbox',...
        'simulink',...
        'sta',...
        'ui',...
        'images',...
        'macSignalAuthoring_24.ico')
        PcIcon=fullfile(matlabroot,...
        'toolbox',...
        'simulink',...
        'sta',...
        'ui',...
        'images',...
        'SignalAuthoring_24.ico')
        LinuxIcon=fullfile(matlabroot,...
        'toolbox',...
        'simulink',...
        'sta',...
        'ui',...
        'images',...
        'SignalAuthoring_24.png')

        editorBaseMessage='staeditor'

theDispatcher

DataSource
ModelForTemplate

debuggingPort

IS_UI_DIRTY

ScenarioRepo
SignalCellStruct

CloseCallBackSubscription

        Helpcommand='editor'
    end



    properties(Hidden)

StaWebScopeMessageHandler

FORCE_DIRTY

editorAppID
IS_STARTUP_DONE

Subscriptions
    end



    methods(Access=public)


        function aEditor=SignalEditor(varargin)
            aEditor.IS_UI_DIRTY=false;

            aEditor.Subscriptions=containers.Map;

            parseInputArguments(aEditor,varargin{:});


            hash1=Simulink.sta.InstanceMap.getInstance();
            openTags=hash1.getOpenTags;


            for kInstance=1:length(openTags)

                theInstance=getUIInstance(hash1,openTags{kInstance});


                IS_EDITOR=isa(theInstance,'Simulink.sta.SignalEditor');



                if IS_EDITOR

                    IS_DATASOURCE_EMPTY=isempty(aEditor.DataSource);

                    if iscell(aEditor.DataSource)
                        current_DataSource=aEditor.DataSource{1};
                    else
                        current_DataSource=aEditor.DataSource;
                    end

                    if iscell(theInstance.DataSource)
                        suspect_DataSource=theInstance.DataSource{1};
                    else
                        suspect_DataSource=theInstance.DataSource;
                    end

                    DOES_DATASOURCE_MATCH=strcmp(current_DataSource,suspect_DataSource);
                    DATA_SOURCE_NONEMPTY_MATCH=~IS_DATASOURCE_EMPTY&&DOES_DATASOURCE_MATCH;

                    if DATA_SOURCE_NONEMPTY_MATCH

                        aEditor=theInstance;
                        bringToFront(aEditor);
                        return;

                    end
                end
            end



            connectorStartUp(aEditor);


            startUpStreamServices(aEditor);


            getUrlFromConnector(aEditor);



            if isempty(aEditor.Tag)

                aEditor.Tag=hash1.generateTag(aEditor.editorAppID);

            end


            addUIInstance(hash1,aEditor.Tag,aEditor);



            subscribeToMessages(aEditor);
        end


        function isDirty=getIsUIDirty(aEditor)
            isDirty=aEditor.IS_UI_DIRTY;
            return;
        end


        function fileName=getFileName(aEditor)

            fileName=aEditor.DataSource;
            return;
        end


        function discardChangesAndClose(aEditor)

            aEditor.IS_UI_DIRTY=false;
            onDialogClose(aEditor,[]);
        end


        function saveChangesAndClose(aEditor)


            repoUtil=starepository.RepositoryUtility();
            topIDsOrdered=getTopLevelIDsInTreeOrder(repoUtil,aEditor.ScenarioRepo.ID);


            [gotSaved,saveErrMsg]=Simulink.sta.exportdialog.exportToFile(topIDsOrdered,aEditor.DataSource,false);
            if gotSaved
                aEditor.IS_UI_DIRTY=false;
                onDialogClose(aEditor,[]);
            else
                throw(MException('sl_sta:editor:cmdLineFailOnClose',saveErrMsg));
            end
        end

    end




    methods(Access='protected')

        function parseInputArguments(aEditor,varargin)
            inputStruct=parseEditorInputs(varargin{:});

            aEditor.IS_DEBUG=inputStruct.Debug;

            aEditor.FORCE_DIRTY=inputStruct.ForceDirty;
            aEditor.LaunchDebugTools=inputStruct.LaunchDebugTools;
            aEditor.SIGNAL_EDITOR_BLOCK=inputStruct.SignalEditorBlock;

            if~isempty(inputStruct.DataSource)

                if isstring(inputStruct.DataSource)&&isscalar(inputStruct.DataSource)
                    inputStruct.DataSource=char(inputStruct.DataSource);
                end

                if isstring(inputStruct.DataSource)&&~isscalar(inputStruct.DataSource)
                    inputStruct.DataSource=cellstr(inputStruct.DataSource);
                end

                if ischar(inputStruct.DataSource)

                    aEditor.DataSource=inputStruct.DataSource;

                    [aDir,~,~]=fileparts(aEditor.DataSource);
                    whichFile=which(aEditor.DataSource);

                    if isempty(aDir)&&~isempty(whichFile)
                        aEditor.DataSource=whichFile;
                    end





                end
            else
                aEditor.DataSource='';
            end


            if isstring(inputStruct.Model)&&isscalar(inputStruct.Model)
                modelAsChar=char(inputStruct.Model);

                [~,modelOnlyName,~]=fileparts(modelAsChar);

                inputStruct.Model=modelOnlyName;
            end

            aEditor.ModelForTemplate=inputStruct.Model;
        end


        function connectorStartUp(aEditor)
            try
                connector.ensureServiceOn;
                aEditor.debuggingPort=matlab.internal.getDebugPort;
            catch
                throw(DAStudio.message('sl_sta:sta:ConnectorFailed','EDITOR'));
            end

        end


        function startUpStreamServices(aEditor)








            Simulink.sdi.internal.startConnector();


            aEditor.StaWebScopeMessageHandler=Simulink.stawebscope.initializeStaWebScope;
        end


        function getUrlFromConnector(aEditor)


            aURL=getReleaseHTML(aEditor);

            if aEditor.IS_DEBUG

                aURL=getDebugHTML(aEditor);
            end



            aEditor.FullUrl=connector.getUrl(aURL);






            aEditor.editorAppID=generateAppId(aEditor);


            sep='?';
            if strfind(aEditor.FullUrl,'?')>1
                sep='&';
            end

            aEditor.FullUrl=strcat(aEditor.FullUrl,sep,'UUID=',aEditor.editorAppID,' ');
        end


        function subscribeToMessages(aEditor)

            aEditor.theDispatcher=Simulink.sta.Dispatcher(aEditor.editorAppID);
            aEditor.theDispatcher.baseMsg=aEditor.editorBaseMessage;

            msgTopics=Simulink.sta.EditorTopics();


            aEditor.Subscriptions(msgTopics.START_UP)=subscribe(aEditor.theDispatcher,msgTopics.START_UP,@aEditor.msgcb_startup);

            aEditor.Subscriptions(msgTopics.NEW)=subscribe(aEditor.theDispatcher,msgTopics.NEW,@aEditor.msgcb_new);
            aEditor.Subscriptions(msgTopics.OPEN)=subscribe(aEditor.theDispatcher,msgTopics.OPEN,@aEditor.msgcb_open);
            aEditor.Subscriptions(msgTopics.IS_UI_DIRTY)=subscribe(aEditor.theDispatcher,msgTopics.IS_UI_DIRTY,@aEditor.msgcb_isuidirty);

            aEditor.Subscriptions(msgTopics.EDITOR_UPDATED)=subscribe(aEditor.theDispatcher,msgTopics.EDITOR_UPDATED,@aEditor.msgcb_editorUpdated);


            aEditor.Subscriptions(msgTopics.LAUNCH_HELP)=subscribe(aEditor.theDispatcher,msgTopics.LAUNCH_HELP,@aEditor.msgcb_help);


            subscribe(aEditor.theDispatcher,msgTopics.FORCE_CLOSE,@aEditor.msgcb_forceclose);
        end


        function unregisterSubscribers(aEditor)


            sKeys=aEditor.Subscriptions.keys;


            for k=1:length(sKeys)
                message.unsubscribe(aEditor.Subscriptions(sKeys{k}));
                aEditor.Subscriptions.remove(sKeys{k});
            end

        end


        function publishMessage(aEditor,subChannel,msgVal)


            fullChannel=genChannel(aEditor,subChannel);

            message.publish(fullChannel,msgVal);
        end


        function fullChannel=genChannel(aEditor,subChannel)


            fullChannel=sprintf('/%s%s/%s',aEditor.editorBaseMessage,...
            aEditor.editorAppID,...
            subChannel);

        end


        function cleanState(aEditor)

            if~isempty(aEditor.CEFWindow)
                try
                    SignalEditorPreferences.getInstance.addFigureSize(aEditor.CEFWindow.Position);
                catch



                end
            end

            delete(aEditor.CEFWindow);


            unregisterSubscribers(aEditor);

            delete(aEditor.theDispatcher);


            hash1=Simulink.sta.InstanceMap.getInstance();
            removeTag(hash1,aEditor.Tag);
            delete(aEditor);

        end


        function msgcb_startup(aEditor,~)

            aEditor.IS_STARTUP_DONE=true;

            msgTopics=Simulink.sta.EditorTopics();


            setUITitle(aEditor,getUITitleFromParams(aEditor));

            initializeEditingDataModel(aEditor);

            processDataSourceOnStartup(aEditor);


            modelInfo.model=aEditor.ModelForTemplate;
            modelInfo.signalEditorBlock=aEditor.SIGNAL_EDITOR_BLOCK;
            publishMessage(aEditor,msgTopics.MODEL_TO_USE,modelInfo);


            publishMessage(aEditor,msgTopics.START_UP_DONE,[]);
        end

    end

    methods(Access=protected)


        function initializeEditingDataModel(aEditor)





            eng=sdi.Repository(true);
            eng.safeTransaction(@initScenario,aEditor);

            sessionpayload.scenarioinfo.id=aEditor.ScenarioRepo.ID;


            ScenarioTopicNames=Simulink.sta.ScenarioTopics();
            publishMessage(aEditor,ScenarioTopicNames.SCENARIO_CREATE,sessionpayload);
        end


        function initScenario(aEditor)

            aEditor.ScenarioRepo=sta.Scenario();
            aEditor.ScenarioRepo.Description='Empty Description';
            aEditor.ScenarioRepo.APPid=aEditor.editorAppID;
        end


        function processDataSourceOnStartup(aEditor)

            if~isempty(aEditor.DataSource)


                openDataOnStartUp(aEditor);
            else

                aEditor.DataSource='untitled.mat';

            end

            msgTopics=Simulink.sta.EditorTopics();
            publishMessage(aEditor,msgTopics.MAT_FILE_UPDATE,aEditor.DataSource)
        end


        function openDataOnStartUp(aEditor)
            importWarnID='sl_sta_general:common:Warning';

            FI_WARN_THROWN=false;
            warnMsgB4After=[];
            warnIDAfter=[];



            if~isempty(aEditor.DataSource)




                errorMsg=[];
                jsonStruct={};
                try
                    [warnMsgB4Load,warnIDB4Fload]=lastwarn;



                    jsonStruct=import2Repository(aEditor.DataSource);
                    [warnMsgB4After,warnIDAfter]=lastwarn;%#ok<ASGLU> 




                catch ME

                    switch ME.identifier
                    case 'MATLAB:load:notBinaryFile'
                        errorMsg=ME.message;
                    otherwise
                        errorMsg='Unexpected Error';
                    end

                end

                if~isempty(errorMsg)
                    throwErrorDialog(aEditor,'sl_sta_general:common:Error',errorMsg);
                    return;
                end

                ENUM_WARN_THROWN=false;


                if isempty(warnIDAfter)&&~isempty(warnIDB4Fload)
                    lastwarn(warnMsgB4Load,warnIDB4Fload);
                elseif~isempty(warnIDAfter)


                    if strcmp(warnIDAfter,'fixed:fi:licenseCheckoutFailed')







                        tempWarnText=DAStudio.message('sl_sta:editor:fixedpointwarningonload',aEditor.DataSource);
                        throwWarningDialog(aEditor,importWarnID,...
                        tempWarnText);
                        FI_WARN_THROWN=true;
                        lastwarn(warnMsgB4Load,warnIDB4Fload);
                    elseif strcmpi('MATLAB:class:EnumerableClassNotFound',warnIDAfter)||...
                        strcmpi('MATLAB:class:EnumerationNameMissing',warnIDAfter)||...
                        strcmpi('MATLAB:class:EnumerationValueChanged',warnIDAfter)



                        tempWarnText=warnMsgB4After;
                        throwWarningDialog(aEditor,importWarnID,...
                        tempWarnText);
                        ENUM_WARN_THROWN=true;
                        lastwarn(warnMsgB4Load,warnIDB4Fload);
                    end
                end




                if isempty(jsonStruct)&&~FI_WARN_THROWN&&~ENUM_WARN_THROWN

                    throwWarningDialog(aEditor,importWarnID,...
                    DAStudio.message('sl_sta:editor:datasourceempty',aEditor.DataSource));

                end

                aEditor.SignalCellStruct=jsonStruct;

                msgTopics=Simulink.sta.EditorTopics();
                fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,aEditor.editorAppID,'SignalAuthoring/UIModelData');
                outdata.arrayOfListItems=aEditor.SignalCellStruct;
                message.publish(fullChannel,outdata);

                eng=sdi.Repository(true);
                eng.safeTransaction(@initExternalSources,...
                aEditor.SignalCellStruct,...
                aEditor.ScenarioRepo.ID);

            end
        end


        function throwErrorDialog(aEditor,errorTitleID,errorMsg)





            msgTopics=Simulink.sta.EditorTopics();



            fullChannel=genChannel(aEditor,msgTopics.DIAGNOSTICS_DLG);

            slwebwidgets.errordlgweb(fullChannel,...
            errorTitleID,...
            errorMsg);

        end


        function throwWarningDialog(aEditor,errorTitleID,errorMsg)





            msgTopics=Simulink.sta.EditorTopics();



            fullChannel=genChannel(aEditor,msgTopics.DIAGNOSTICS_DLG);

            slwebwidgets.warndlgweb(fullChannel,...
            errorTitleID,...
            errorMsg);

        end
    end



    methods(Hidden)


        function outTitle=initCEFTitle(aEditor)
            outTitle=getUITitleFromParams(aEditor);
        end

        function uiTitle=getUITitleFromParams(aEditor)


            if isempty(aEditor.DataSource)
                fileForTitle='untitled';
            else
                [~,fileForTitle,~]=fileparts(aEditor.DataSource);
            end


            if aEditor.IS_UI_DIRTY
                fileForTitle=[fileForTitle,'*'];
            end



            if isempty(aEditor.ModelForTemplate)||aEditor.SIGNAL_EDITOR_BLOCK
                uiTitle=DAStudio.message('sl_sta:editor:figuretitle',fileForTitle);
                return;
            end


            if~isempty(aEditor.ModelForTemplate)
                uiTitle=DAStudio.message('sl_sta:editor:figuretitle_wModel',fileForTitle,aEditor.ModelForTemplate);
            end
        end


        function setUITitle(aEditor,title)


            if isStringScalar(title)
                title=char(title);
            end

            if~ischar(title)
                DAStudio.error('sl_sta:editor:titlemustbechar');
            end


            uiInfo.title=title;
            msgTopics=Simulink.sta.EditorTopics();
            publishMessage(aEditor,msgTopics.SET_UI_TITLE,uiInfo);

        end


        function outTitle=getUITitle(aEditor)

            if isvalid(aEditor.CEFWindow)
                outTitle=aEditor.CEFWindow.Title;
            else
                outTitle='';
            end
        end


        function outPort=getDebugPort(aEditor)
            outPort=aEditor.debuggingPort;
        end



        function appID=generateAppId(aEditor)


            appID=aEditor.StaWebScopeMessageHandler.ClientId;
        end



        function pageToServe=getDebugHTML(~)
            pageToServe='/toolbox/simulink/sta/web/SigAuth/EditorDesktop/indexRelease-debug.html';
        end



        function pageToServe=getReleaseHTML(~)
            pageToServe='/toolbox/simulink/sta/web/SigAuth/EditorDesktop/indexRelease.html';
        end



        function onMATLABExit(aEditor)




            cleanState(aEditor);
        end


        function onMATLABClose(aEditor,~)
        end


        function onDialogClose(aEditor,~)


            cleanState(aEditor);
        end


        function onClose(aEditor)
            if aEditor.IS_UI_DIRTY

                msgTopics=Simulink.sta.EditorTopics();

                ListenerChannel=msgTopics.UNSAVED_ONCLOSE;


                if aEditor.theDispatcher.Subscribers.isKey(msgTopics.UNSAVED_ONCLOSE)
                    message.unsubscribe(aEditor.theDispatcher.Subscribers(msgTopics.UNSAVED_ONCLOSE));
                    aEditor.theDispatcher.Subscribers.remove(msgTopics.UNSAVED_ONCLOSE);
                end

                aEditor.CloseCallBackSubscription=subscribe(aEditor.theDispatcher,msgTopics.UNSAVED_ONCLOSE,@aEditor.handleUnsavedChangesDialog);


                buttons={DAStudio.message('sl_sta_general:common:Yes'),...
                DAStudio.message('sl_sta_general:common:No'),...
                DAStudio.message('sl_sta_general:common:Cancel')};


                unSavedMsgText=DAStudio.message('sl_sta:editor:UnsavedTextStandAlone');


                aEditor.DisplayMsgBox(DAStudio.message('sl_sta:sta:UnsavedTitle'),...
                unSavedMsgText,...
                buttons,...
                0,...
                ListenerChannel);
            else

                cleanState(aEditor);
            end
        end



        function handleUnsavedChangesDialog(aEditor,evt)




            msgTopics=Simulink.sta.EditorTopics();

            if aEditor.theDispatcher.Subscribers.isKey(msgTopics.UNSAVED_ONCLOSE)
                message.unsubscribe(aEditor.theDispatcher.Subscribers(msgTopics.UNSAVED_ONCLOSE));
                aEditor.theDispatcher.Subscribers.remove(msgTopics.UNSAVED_ONCLOSE);
            end

            if(evt.InfoToSend.Choice==0)




                msgTopics=Simulink.sta.EditorTopics();
                payLoad.exitMATLAB=false;
                publishMessage(aEditor,msgTopics.SAVE_FROM_CLOSE,[]);

            elseif(evt.InfoToSend.Choice==1)


                cleanState(aEditor);
            else


            end

        end


        function msgcb_new(aEditor,~)
            hash1=Simulink.sta.InstanceMap.getInstance();
            tagForNew=hash1.generateTag(aEditor.editorAppID);


            if isempty(aEditor.ModelForTemplate)
                aNewEditor=Simulink.sta.SignalEditor(...
                'Tag',tagForNew);
            else
                aNewEditor=Simulink.sta.SignalEditor(...
                'Model',aEditor.ModelForTemplate,...
                'Tag',tagForNew);
            end
            aNewEditor.show();

            aNewEditor.bringToFront();
        end
    end


    methods(Hidden)

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


        function msgcb_open(aEditor,msg)

            hash1=Simulink.sta.InstanceMap.getInstance();
            tagForNew=hash1.generateTag(aEditor.editorAppID);

            try

                if isempty(aEditor.ModelForTemplate)
                    anOpenEditor=Simulink.sta.SignalEditor(...
                    'DataSource',msg.fileToOpen,...
                    'Tag',tagForNew);
                else
                    anOpenEditor=Simulink.sta.SignalEditor(...
                    'DataSource',msg.fileToOpen,...
                    'Model',aEditor.ModelForTemplate,...
                    'Tag',tagForNew);
                end
                anOpenEditor.show();
                anOpenEditor.bringToFront();
            catch ME


                if strcmp(ME.identifier,'sl_sta:sta:InvalidInputValue')

                    errorMsg=DAStudio.message('sl_iofile:matfile:invalidFileType',msg.fileToOpen);

                    throwErrorDialog(aEditor,'sl_sta_general:common:Error',errorMsg);
                elseif strcmp(ME.identifier,'sl_sta:sta:FileDoesNotExist')


                    throwErrorDialog(aEditor,'sl_sta_general:common:Error',DAStudio.message('sl_sta:sta:FileDoesNotExist',msg.fileToOpen));
                end
            end
        end


        function msgcb_isuidirty(aEditor,msg)


            aEditor.IS_UI_DIRTY=msg.isdirty;




        end

        function msgcb_editorUpdated(aEditor,msg)

            fireFileSavedEvent(aEditor,msg.data);
        end


        function msgcb_help(aEditor,msgIn)

            if~isempty(msgIn)&&~isempty(fieldnames(msgIn))
                Simulink.sta.editor.cb_help(msgIn.Helpcommand);
            else
                Simulink.sta.editor.cb_help(aEditor.Helpcommand);
            end


        end


        function DisplayMsgBox(aEditor,title,msg,buttons,defButton,cb)








            arg.Title=title;
            arg.Msg=msg;
            arg.Buttons=buttons;
            arg.Default=defButton;
            arg.CbChannel=cb;
            arg.CbUserData=char(matlab.lang.internal.uuid());

            msgTopics=Simulink.sta.EditorTopics();
            publishMessage(aEditor,msgTopics.DIALOG_BOX,arg);

        end


        function msgcb_forceclose(aEditor,~)

            cleanState(aEditor);
        end

        function fireFileSavedEvent(aEditor,savedFileName)
            payLoad=Simulink.sta.FileSavedEventData(savedFileName);
            notify(aEditor,'FileSavedEvent',payLoad);
        end
    end
end
