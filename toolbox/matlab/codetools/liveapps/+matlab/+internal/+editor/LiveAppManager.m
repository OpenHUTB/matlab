classdef LiveAppManager<handle

    properties(Constant)

        % insert request channel 插入请求通道
        INSERT_REQUEST_CHANNEL='/liveapps/insertRequest/';
        CHANGED_REQUEST_CHANNEL='/liveapps/changedRequest/';
        AUTORUN_BACKEND_CHANGED_CHANNEL='/liveapps/autorunBackendChanged/';
        AUTORUN_FRONTEND_CHANGED_CHANNEL='/liveapps/autorunFrontendChanged/';

        GET_CODEGEN_DATA_REQUEST_CHANNEL='/liveapps/getCodegenDataRequest/';
        GET_CODEGEN_DATA_RESPONSE_CHANNEL='/liveapps/getCodegenDataResponse/';

        LOAD_DATA_REQUEST_CHANNEL='/liveapps/loadDataRequest/';
        RESET_REQUEST_CHANNEL='/liveapps/resetRequest/';
        REMOVE_REQUEST_CHANNEL='/liveapps/removeRequest/';

        LIVE_APP_READY_REQUEST='/liveapps/readyRequestChannel/';
        LIVE_APP_READY_RESPONSE='/liveapps/readyResponseChannel/';

        REFACTOR_LIVE_TASK='matlab.internal.editor.RefactorLiveTask';
    end


    methods(Static,Hidden)

        function install(editorId)
            import matlab.internal.editor.LiveAppManager;

            connector.ensureServiceOn;

            store=LiveAppManager.getEditorStore(editorId);
            store('subscribers')=[
            message.subscribe([LiveAppManager.GET_CODEGEN_DATA_REQUEST_CHANNEL,editorId],@(data)LiveAppManager.getCodegenData(editorId,data)),...
            message.subscribe([LiveAppManager.LOAD_DATA_REQUEST_CHANNEL,editorId],@(data)LiveAppManager.loadData(editorId,data)),...
            message.subscribe([LiveAppManager.RESET_REQUEST_CHANNEL,editorId],@(data)LiveAppManager.resetApp(editorId,data)),...
            message.subscribe([LiveAppManager.REMOVE_REQUEST_CHANNEL,editorId],@(data)LiveAppManager.removeApp(editorId,data)),...
            message.subscribe([LiveAppManager.AUTORUN_FRONTEND_CHANGED_CHANNEL,editorId],@(data)LiveAppManager.removeAutorunListener(editorId,data)),...
            message.subscribe([LiveAppManager.LIVE_APP_READY_REQUEST,editorId],@(data)LiveAppManager.isAppReady(editorId,data))
            ];
        end


        function uninstall(editorId)
            import matlab.internal.editor.LiveAppManager;

            store=LiveAppManager.getEditorStore(editorId);
            for subscriberId=store('subscribers')
                message.unsubscribe(subscriberId);
            end

            LiveAppManager.removeEditorStore(editorId);
        end


        function insertApp(appIdentifier)
            import matlab.internal.editor.LiveAppManager;

            data=struct('appIdentifier',appIdentifier);

            activeEditor=matlab.desktop.editor.getActive();

            if isempty(activeEditor)
                return;
            end

            editorId=activeEditor.Editor.RtcId;

            message.publish([LiveAppManager.INSERT_REQUEST_CHANNEL,editorId],data);
        end


        function result=initialize(editorId,data)

            import matlab.internal.editor.LiveAppManager;
            import matlab.internal.editor.LiveTaskUtilities;

            try
                appId=data.appId;
                appIdentifier=data.appIdentifier;
                appState=data.appState;
                initializeData=data.initializeData;

                app=LiveAppManager.createApp(appIdentifier);
                fig=LiveAppManager.getFigure(app);

                if(strcmp(appIdentifier,LiveAppManager.REFACTOR_LIVE_TASK))
                    app.createLayout(data.refactoredTaskMeta);
                end

                if numel(fig.Children)~=1||~isa(fig.Children(1),'matlab.ui.container.GridLayout')
                    error(string(message('rich_text_component:liveApps:componentNotInGridLayout')));
                end

                fig.Internal=true;

                figureData=matlab.ui.internal.FigureServices.getEmbeddedFigurePacket(fig);

                if~isempty(appState)
                    figChildren=fig.Children;

                    w=warning('off','all');
                    isUiFigure=~isempty(struct(fig).Controller);
                    warning(w);
                    if isUiFigure
                        enableGUIBuildingFeatures()
                        try
                            tempFigure=uifigure('Visible','off');
                        catch ME
                            disableGUIBuildingFeatures();
                            rethrow(ME);
                        end
                        disableGUIBuildingFeatures();

                        cleanup=onCleanup(@()delete(tempFigure));
                    else
                        tempFigure=[];
                    end

                    for kChild=1:length(figChildren)
                        figChildren(kChild).Parent=tempFigure;
                    end

                    LiveTaskUtilities.setState(app,appState);

                    for kChild=1:length(figChildren)
                        figChildren(kChild).Parent=fig;
                    end

                else
                    if ismethod(app,'initialize')
                        LiveTaskUtilities.initialize(app,initializeData);
                    end
                end
                clientData.state=LiveTaskUtilities.getState(app);

                clientData.width=fig.Position(3);
                clientData.height=fig.Position(4);
                clientData.name=fig.Name;
                clientData.summary=LiveTaskUtilities.generateSummary(app);
                clientData.autorun=getAutoRunSetting(app);
                clientData.errorMessage='';

                LiveAppManager.setApp(editorId,appId,app);

                LiveAppManager.registerChangedListener(editorId,appId,fig);

                LiveAppManager.registerAutoRunChangedListener(editorId,appId);
            catch ME
                figureData={};
                clientData.dimension={};
                clientData.name='';
                clientData.summary='';
                clientData.errorMessage=ME.message;
                clientData.state='';
            end

            result.clientData=clientData;
            result.figureData=figureData;
            result.appId=appId;
        end
        

        function fig=getFigure(app)
            import matlab.internal.editor.LiveTaskUtilities;
            fig=LiveTaskUtilities.getFigure(app);
        end

        function app=createApp(appIdentifier)

            enableGUIBuildingFeatures();

            try
                eval(['app = ',appIdentifier,';']);
            catch ME


                disableGUIBuildingFeatures();
                rethrow(ME);
            end

            disableGUIBuildingFeatures();
        end

        function resetApp(editorId,data)

            import matlab.internal.editor.LiveAppManager;
            import matlab.internal.editor.LiveTaskUtilities;


            appId=data.appId;

            app=LiveAppManager.getApp(editorId,appId);

            if~isempty(app)
                LiveTaskUtilities.reset(app);
                LiveAppManager.notifyChangedEvent(editorId,appId,'reset');
            end
        end

        function registerChangedListener(editorId,appId,fig)

            import matlab.internal.editor.LiveAppManager;

            map=LiveAppManager.getMap(editorId);
            appContainer=map(appId);
            appContainer.registerChangedListener(...
            @(o,e)LiveAppManager.notifyChangedEvent(editorId,appId,'changed'),fig...
            );
        end

        function result=notifyChangedEvent(editorId,appId,context)

            import matlab.internal.editor.LiveAppManager;


            appContainer=LiveAppManager.getAppContainer(editorId,appId);
            if isempty(appContainer)
                return;
            end


            result=LiveAppManager.getData(editorId,appId);


            result.context=context;



            appContainer.updateCode(result.code);

            message.publish([LiveAppManager.CHANGED_REQUEST_CHANNEL,editorId],result);
        end

        function registerAutoRunChangedListener(editorId,appId)

            import matlab.internal.editor.LiveAppManager;

            map=LiveAppManager.getMap(editorId);
            appContainer=map(appId);
            appContainer.registerAutoRunListener(...
            @(o,e)LiveAppManager.notifyAutoRunChangedEvent(editorId,appId));
        end

        function autorun=notifyAutoRunChangedEvent(editorId,appId)

            import matlab.internal.editor.LiveAppManager;


            appContainer=LiveAppManager.getAppContainer(editorId,appId);
            if isempty(appContainer)
                return;
            end


            app=LiveAppManager.getApp(editorId,appId);
            autorun=getAutoRunSetting(app);

            message.publish([LiveAppManager.AUTORUN_BACKEND_CHANGED_CHANNEL,editorId],autorun);
        end

        function removeAutorunListener(editorId,data)
            import matlab.internal.editor.LiveAppManager;

            appId=data.appId;
            map=LiveAppManager.getMap(editorId);
            appContainer=map(appId);
            appContainer.removeAutorunListener();
        end

        function isAppReady(editorId,data)
            import matlab.internal.editor.LiveAppManager;

            appId=data.appId;
            app=LiveAppManager.getApp(editorId,appId);





            if ismethod(app,'isReady')
                if app.isDataLoaded
                    LiveAppManager.emitAppReadyMessage(editorId,appId);
                else
                    addlistener(app,'AppReady',@(o,e)LiveAppManager.emitAppReadyMessage(editorId,appId));
                end
            else
                LiveAppManager.emitAppReadyMessage(editorId,appId);
            end
        end

        function emitAppReadyMessage(editorId,appId)
            import matlab.internal.editor.LiveAppManager;

            message.publish([LiveAppManager.LIVE_APP_READY_RESPONSE,editorId],appId);
        end

        function result=getData(editorId,appId)

            import matlab.internal.editor.LiveAppManager;
            import matlab.internal.editor.LiveTaskUtilities;

            app=LiveAppManager.getApp(editorId,appId);
            appContainer=LiveAppManager.getAppContainer(editorId,appId);

            if~isempty(app)
                [newBusinessCode,outputs]=LiveTaskUtilities.generateScript(app);
                newVisualizationCode=LiveTaskUtilities.generateVisualizationScript(app);
                newCode=getCombinedCode(newBusinessCode,newVisualizationCode);

                result.code=newCode;




                if isempty(outputs)||all(strcmp(outputs,""))
                    result.outputs={};
                else
                    result.outputs=outputs;
                end

                result.lineOffsetForUpdate=getNumberOfLinesInText(newBusinessCode)-1;

                result.summary=LiveTaskUtilities.generateSummary(app);
                result.state=LiveTaskUtilities.getState(app);





                variableBlackList=evalin('base','whos');
                result.variableBlackList={variableBlackList.name};
            else
                result.code='';
                result.outputs={};
                result.summary='';
                result.state='';
                result.variableBlackList={};
            end

            result.appId=appId;
        end

        function result=getCodegenData(editorId,data)

            import matlab.internal.editor.LiveAppManager;

            result=LiveAppManager.getData(editorId,data.appId);

            message.publish([LiveAppManager.GET_CODEGEN_DATA_RESPONSE_CHANNEL,editorId],result);
        end

        function loadData(editorId,data)

            import matlab.internal.editor.LiveAppManager;
            import matlab.internal.editor.LiveTaskUtilities;


            appId=data.appId;
            appState=data.appState;

            app=LiveAppManager.getApp(editorId,appId);

            if~isempty(app)&&~isempty(appState)
                LiveTaskUtilities.setState(app,appState);
            end
        end

        function setApp(editorId,appId,app)

            import matlab.internal.editor.LiveAppManager;
            import matlab.internal.editor.LiveAppContainer;

            appContainer=LiveAppContainer(app);
            map=LiveAppManager.getMap(editorId);
            map(appId)=appContainer;
        end

        function configureUpdateCallback(data)
            import matlab.internal.editor.LiveAppManager;
            import matlab.internal.editor.LiveTaskUtilities;

            editorId=data.editorId;
            appLineVariableList=data.appLineVariableList;
            callbackMappings=[];

            for i=1:length(appLineVariableList)
                map=appLineVariableList(i);

                appId=map.appId;

                app=LiveAppManager.getApp(editorId,appId);
                if~LiveTaskUtilities.hasUpdateMethod(app)
                    continue;
                end

                appContainer=LiveAppManager.getAppContainer(editorId,appId);
                if isempty(appContainer)
                    continue;
                end

                mapping=struct(...
                'line',map.line,...
                'callback',@(o,e)matlab.internal.editor.LiveAppManager.updateApp(editorId,appId,map.variableMappings)...
                );

                callbackMappings=[callbackMappings,mapping];
            end

            matlab.internal.editor.EODataStore.setEditorField(editorId,'LINE_TO_CALLBACK_MAP',callbackMappings);
        end

        function updateApp(editorId,appId,variableMappings)

            import matlab.internal.editor.LiveAppManager;
            import matlab.internal.editor.LiveTaskUtilities;

            app=LiveAppManager.getApp(editorId,appId);

            if~isempty(app)
                LiveTaskUtilities.updateApp(app,variableMappings);
            end
        end

        function removeApp(editorId,data)


            import matlab.internal.editor.LiveAppManager;


            appId=data.appId;

            map=LiveAppManager.getMap(editorId);
            if isKey(map,appId)
                map.remove(appId);
            end
        end

        function removeAllApps(editorId)

            import matlab.internal.editor.LiveAppManager;
            LiveAppManager.removeEditorStore(editorId);
        end

        function app=getApp(editorId,appId)

            import matlab.internal.editor.LiveAppManager;

            map=LiveAppManager.getMap(editorId);
            if isKey(map,appId)
                appContainer=map(appId);
                app=appContainer.appInstance;
            else
                app=[];
            end
        end

        function appContainer=getAppContainer(editorId,appId)

            import matlab.internal.editor.LiveAppManager;

            map=LiveAppManager.getMap(editorId);
            if isKey(map,appId)
                appContainer=map(appId);
            else
                appContainer=[];
            end
        end

        function map=getMap(editorId)

            import matlab.internal.editor.LiveAppManager;

            store=LiveAppManager.getEditorStore(editorId);
            map=store('appMap');
        end

        function store=getEditorStore(editorId)

            import matlab.internal.editor.LiveAppManager;

            coreMap=LiveAppManager.getCoreMap();
            if~isKey(coreMap,editorId)
                store=containers.Map();
                store('appMap')=containers.Map();
                store('subscribers')=[];
                coreMap(editorId)=store;
            else
                store=coreMap(editorId);
            end
        end

        function removeEditorStore(editorId)

            import matlab.internal.editor.LiveAppManager;

            coreMap=LiveAppManager.getCoreMap();
            if isKey(coreMap,editorId)
                remove(coreMap,editorId);
            end
        end

        function map=getCoreMap()

mlock
            persistent coreMap

            if isempty(coreMap)
                coreMap=containers.Map();
            end
            map=coreMap;
        end

        function appRemoved(editorId,appId)
            import matlab.internal.editor.LiveAppManager;

            app=LiveAppManager.getApp(editorId,appId);
            try
                notify(app,'TaskRemoved');
            catch ME
            end
        end

        function helpLink=getHelpLink(editorId,data)




            import matlab.internal.editor.LiveAppManager;

            helpLink="";
            funcName=data.funcName;
            app=LiveAppManager.getApp(editorId,data.appId);

            if ismethod(app,funcName)
                output=app.(funcName);

                if isstring(output)||ischar(output)
                    helpLink=output;
                end
            end
        end
    end
end

function out=getAutoRunSetting(app)
    if isprop(app,'AutoRun')
        out=app.AutoRun;
    else
        out=true;
    end
end

function code=getCombinedCode(businessCode,visualizationCode)




    code=sprintf(['%s',newline,newline,'%s'],businessCode,visualizationCode);
    code=strtrim(code);
end

function enableGUIBuildingFeatures()

    s=settings;




    s.matlab.ui.figure.ShowEmbedded.TemporaryValue=1;
end

function disableGUIBuildingFeatures()

    s=settings;

    s.matlab.ui.figure.ShowEmbedded.TemporaryValue=0;
end

function numberOfLines=getNumberOfLinesInText(text)

    text=char(text);
    if isempty(text)
        numberOfLines=0;
    else
        numberOfLines=1+sum(text==newline);
    end
end
