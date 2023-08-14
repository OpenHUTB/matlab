classdef SequenceDiagramViewer<handle



    properties
        title;
        addressRoot='/toolbox/shared/dastudio/seqdiagram/web/index%s.html?%s&%s';
        lifelineSettings='';
        filterSettings='';
        port;
        address='';
        dialogH=[];
        blockH=[];
        modelH=[];
        channel;
        timings;
        timingMode='off';
        taskStyle='taskStyle';
        configDialogSettings=[];
        isOnToolstrip=false;
        logEvents=false;
        viewerSettings=[];
    end

    properties(Constant)
        titlePrefix='Sequence Viewer - ';
    end


    properties
        loaded=false;
        isDebug=false;
        highlightedLifeline=[];
        log={};
    end

    methods
        function flagError(this,messageId)
            this.publish('FlagError',messageId);
        end

        function logEvent(this,id,kind,key,port,actor)
            event=struct('id',id,'kind',kind,'key',key,'port',port,'actor',actor);
            count=length(this.log);
            this.log{count+1}=event;
        end
    end

    methods

        function this=SequenceDiagramViewer(source,isDebug,timingMode)
            if ischar(source)
                model=get_param(source,'Object');
                this.channel=['/',model.Name,'singletonchannel'];
                this.title=[this.titlePrefix,model.Name];
                this.blockH=[];
            else

                this.blockH=source;
                obj=get_param(source,'Object');
                this.channel=get_param(this.blockH,'ChannelName');
                this.title=[this.titlePrefix,obj.name];
                model=get_param(gcs,'Object');
            end

            while(~isa(model,'Simulink.BlockDiagram'))
                model=model.getParent();
            end
            this.modelH=model.handle;

            if(nargin>1)
                this.isDebug=isDebug;
            end

            hostInfo=SequenceDiagramViewer.startConnector;

            if(nargin>2&&strcmp(timingMode,'on'))
                this.enableTiming();
            end

            this.port=hostInfo.securePort;

        end

        function channel=getStatusChannel(this)
            channel=[this.channel,'$Timing'];
        end

        function address=getAddress(this)
            channelString=['channel=',this.channel];
            timingModeString=['timingMode=',this.timingMode];

            if(this.isDebug)
                debugString='-debug';
            else
                debugString='';
            end
            address=sprintf(this.addressRoot,debugString,channelString,timingModeString);
            address=this.checkForLifelineFeatures(address);
            address=this.checkForFilterFeatures(address);
            if(slfeature('TaskSchedulingViewer')>0)
                address=[address,'&viewMode=',get_param(this.blockH,'viewMode')];
            else
                address=[address,'&viewMode=disabled'];
            end
            address=connector.getBaseUrl(address);
        end

        function closeViewer(this)
            if(~this.isDebug&&~isempty(this.blockH))
                set_param(this.blockH,'viewerStatus','off');
            end
            if~isempty(this.blockH)
                set_param(this.blockH,'WindowSettings',this.dialogH.WindowPosOnClose);
            end
            if~isempty(this.configDialogSettings)
                this.configDialogSettings.closeDialog();
            end

            if this.isOnToolstrip
                this.viewerSettings.WindowSettings=this.dialogH.WindowPosOnClose;
                set_param(this.modelH,'SequenceViewerSettings',this.viewerSettings);
            end

            delete(this.dialogH);
        end

        function delete(this)
            if~isempty(this.dialogH)&&isvalid(this.dialogH)
                delete(this.dialogH);
            end
            if~isempty(this.blockH)
                set_param(this.blockH,'viewerStatus','off');
            end

            if~isempty(this.configDialogSettings)
                this.configDialogSettings.closeDialog();
                this.configDialogSettings=[];
            end
            MessageViewerRegistry.getInstance().removeViewer(this);
        end
    end

    methods
        function updateLifelineSettings(this,showAllLifelines,autoLayout,showExternalLifelines,lifelineDisplaySettings,rootId)
            if this.isOnToolstrip
                this.viewerSettings.AutoLayout=strcmpi(autoLayout,'on');
                this.viewerSettings.ShowAllLifelines=strcmpi(showAllLifelines,'on');
                this.viewerSettings.ShowExternalLifelines=strcmpi(showExternalLifelines,'on');
                this.viewerSettings.LifelineDisplaySettings=lifelineDisplaySettings;
                set_param(this.modelH,'SequenceViewerSettings',this.viewerSettings);
            else
                set_param(this.blockH,'showAllLifelines',showAllLifelines);
                set_param(this.blockH,'autoLayout',autoLayout);
                set_param(this.blockH,'showExternalLifelines',showExternalLifelines);
                if(~isempty(rootId))
                    set_param(this.blockH,'savedRootPath',rootId);
                end
                if(~isempty(lifelineDisplaySettings))
                    set_param(this.blockH,'lifelineDisplaySettings',lifelineDisplaySettings);
                end
            end
        end

        function updateFilterSettings(this,showEvents,showMessages,showFunctions,showStateInfo)
            if this.isOnToolstrip
                this.viewerSettings.ShowEvents=strcmpi(showEvents,'on');
                this.viewerSettings.ShowMessages=strcmpi(showMessages,'on');
                this.viewerSettings.ShowFunctions=strcmpi(showFunctions,'on');
                this.viewerSettings.ShowStateInfo=strcmpi(showStateInfo,'on');
                set_param(this.modelH,'SequenceViewerSettings',this.viewerSettings);
            else
                if~strcmp(get_param(this.blockH,'showEvents'),showEvents)
                    set_param(this.blockH,'showEvents',showEvents);
                end
                if~strcmp(get_param(this.blockH,'showMessages'),showMessages)
                    set_param(this.blockH,'showMessages',showMessages);
                end
                if~strcmp(get_param(this.blockH,'showFunctions'),showFunctions)
                    set_param(this.blockH,'showFunctions',showFunctions);
                end
                if~strcmp(get_param(this.blockH,'showStateInfo'),showStateInfo)
                    set_param(this.blockH,'showStateInfo',showStateInfo);
                end
            end
        end

        function configure(this)
            if~isempty(this.blockH)
                open_system(this.blockH,'parameter');
            else
                this.configDialogSettings.showConfigureDialog();
            end

        end

        function issueSimulationCommand(this,command)
            status=get_param(this.modelH,'SimulationStatus');
            if strcmp(command,'Ctrl-D')
                if strcmp(status,'stopped')
                    set_param(this.modelH,'SimulationCommand','update');
                end
            elseif strcmp(command,'Ctrl-T')
                if strcmp(status,'stopped')
                    set_param(this.modelH,'SimulationCommand','start');
                elseif strcmp(status,'paused')
                    set_param(this.modelH,'SimulationCommand','continue');
                elseif strcmp(status,'running')
                    set_param(this.modelH,'SimulationCommand','pause');
                end
            elseif strcmp(command,'Shift-Ctrl-T')
                if strcmp(status,'running')||strcmp(status,'paused')
                    set_param(this.modelH,'SimulationCommand','stop');
                end
            end
        end
    end

    methods
        function address=getDebugAddress(this)
            address=this.getAddress();
            address=connector.applyNonce(address);
        end

        function newAddress=checkForLifelineFeatures(this,address)
            newAddress=[address,this.lifelineSettings];
        end

        function newAddress=checkForFilterFeatures(this,address)
            newAddress=[address,this.filterSettings];
        end

        function highlightTask(this,taskId)
            h=Simulink.SampleTimeLegend;
            h.clearHilite(bdroot)
            mdlName=get_param(this.modelH,'Name');
            a={'Rate',taskId,mdlName};
            b=h.rateHighlight(a);
            h.hilite_system_legend(b);
        end

        function highlightSystem(this,id)
            persistent highlightedLifeline;
            if~isempty(highlightedLifeline)&&ishandle(highlightedLifeline)
                set_param(highlightedLifeline,'Selected','off');
            end


            mdlName=get_param(this.modelH,'Name');
            editor=GLUE2.Util.findAllEditors(mdlName);

            if(~isempty(editor))
                studio=editor.getStudio();
                if(~isempty(studio))
                    sid=builtin('_seqviewer_internal_get_origblk_sid',id{1});
                    if(isempty(sid))
                        sid=id{1};
                    end

                    lifeline=Simulink.ID.getHandle(sid);

                    if~isempty(lifeline)&&isa(lifeline,'double')
                        o=get_param(lifeline,'Object');

                        if(o.isHierarchical&&strcmp(o.Mask,'off'))


                            c=o.getHierarchicalChildren();

                            if length(c)==1&&sf('get',c.Id,'.isa')==1&&sf('get',c.Id,'chart.type')==2


                                parent=o.getParent();
                                parent.view;
                                object=diagram.resolver.resolve(lifeline);

                                if~isempty(object)

                                    studio.App.hiliteAndFadeObject(object);
                                end
                            else
                                open_system(lifeline);
                            end
                        else
                            object=diagram.resolver.resolve(lifeline);


                            if~isempty(object)
                                parent=o.Parent;
                                if~isempty(parent)
                                    open_system(parent);
                                end

                                studio.App.hiliteAndFadeObject(object);
                            end
                        end
                        set_param(lifeline,'Selected','on');
                        highlightedLifeline=lifeline;
                    else
                        sfObjHandle=lifeline;

                        chartSID=Simulink.ID.getSimulinkParent(sid);
                        chartObjId=sfObjHandle.Chart.Id;


                        sf('Open',chartObjId,chartSID);

                        parentObj=sfObjHandle.getParent();
                        if isa(parentObj,'Stateflow.Object')
                            parentObj.view();
                        end

                        ids=sfObjHandle.Id;
                        for i=2:length(id)
                            sfObjHandle=Simulink.ID.getHandle(id{i});
                            ids=[ids,sfObjHandle.Id];%#ok<AGROW>
                        end
                        sf('FitToView',chartObjId,ids);
                        sf('Highlight',sfObjHandle.Chart.Id,ids);
                    end
                    studio.show();
                end
            end
        end

        function created=open(this)
            if isempty(this.dialogH)||~isvalid(this.dialogH)
                this.address=this.getAddress();
                currentWindowSettings=get_param(this.blockH,'WindowSettings');
                if isempty(currentWindowSettings)
                    currentWindowSettings=[100,100,500,500];
                end
                this.dialogH=MessageViewerHMI(...
                this.getAddress(),this.title,currentWindowSettings,...
                [],true,this.isDebug);
                this.dialogH.setCloseCallBack(this);
                this.dialogH.show;
                created=true;
            else
                created=false;
            end

        end

        function initializeSingleton(this)
            hasSavedSettings=false;
            this.logEvents=strcmpi(get_param(this.modelH,'EventLogging'),'on');

            this.viewerSettings=get_param(this.modelH,'SequenceViewerSettings');
            if isempty(this.viewerSettings)
                this.viewerSettings=SequenceViewerSettings();
            end

            this.applyInitialSettings(this.viewerSettings.AutoLayout,...
            this.viewerSettings.ShowAllLifelines,...
            this.viewerSettings.ShowExternalLifelines,...
            this.viewerSettings.ShowEvents,...
            this.viewerSettings.ShowMessages,...
            this.viewerSettings.ShowFunctions,...
            this.viewerSettings.ShowStateInfo,...
hasSavedSettings...
            );


            builtin('_createSingletonViewManager',...
            this.modelH,...
            this.channel,...
            ':24',...
            '',...
            get_param(this.modelH,'Name'),...
            this.viewerSettings.LifelineDisplaySettings,...
            [],...
            this.viewerSettings.AutoLayout,...
            this.viewerSettings.ShowAllLifelines,...
            this.viewerSettings.ShowExternalLifelines,...
            this.viewerSettings.ShowEvents,...
            this.viewerSettings.ShowMessages,...
            this.viewerSettings.ShowStateInfo,...
            this.viewerSettings.ShowFunctions,...
            get_param(this.modelH,'SequenceViewerTimePrecision'),...
            get_param(this.modelH,'SequenceViewerHistory'),...
            this.logEvents);
        end

        function created=openSingleton(this)
            hasSavedSettings=false;
            this.logEvents=strcmpi(get_param(this.modelH,'EventLogging'),'on');

            this.viewerSettings=get_param(this.modelH,'SequenceViewerSettings');
            if isempty(this.viewerSettings)
                this.viewerSettings=SequenceViewerSettings();
            end

            this.applyInitialSettings(this.viewerSettings.AutoLayout,...
            this.viewerSettings.ShowAllLifelines,...
            this.viewerSettings.ShowExternalLifelines,...
            this.viewerSettings.ShowEvents,...
            this.viewerSettings.ShowMessages,...
            this.viewerSettings.ShowFunctions,...
            this.viewerSettings.ShowStateInfo,...
hasSavedSettings...
            );

            if isempty(this.configDialogSettings)
                this.configDialogSettings=SequenceViewerConfigureDialog(this.modelH);
            end



            set_param(this.modelH,'EventLoggingDataAvailable','off');

            if isempty(this.dialogH)||~isvalid(this.dialogH)


                builtin('_createSingletonViewManager',...
                this.modelH,...
                this.channel,...
                ':24',...
                '',...
                get_param(this.modelH,'Name'),...
                this.viewerSettings.LifelineDisplaySettings,...
                [],...
                this.viewerSettings.AutoLayout,...
                this.viewerSettings.ShowAllLifelines,...
                this.viewerSettings.ShowExternalLifelines,...
                this.viewerSettings.ShowEvents,...
                this.viewerSettings.ShowMessages,...
                this.viewerSettings.ShowStateInfo,...
                this.viewerSettings.ShowFunctions,...
                get_param(this.modelH,'SequenceViewerTimePrecision'),...
                get_param(this.modelH,'SequenceViewerHistory'),...
                this.logEvents);

                this.address=this.getAddress();

                currentWindowSettings=this.viewerSettings.WindowSettings;
                this.dialogH=MessageViewerHMI(...
                this.getAddress(),this.title,currentWindowSettings,...
                [],true,this.isDebug);
                this.dialogH.setCloseCallBack(this);
                this.dialogH.show;
                created=true;
            else
                created=false;
            end
        end

        function viewerLoaded(this)
            if(this.isTiming())
                this.toc('loaded');
            end
            set_param(this.blockH,'viewerStatus','on');
        end
    end

    methods
        function timing=getTiming(this)
            timing=this.timings;
        end

        function ret=isTiming(this)
            ret=strcmp(this.timingMode,'on');
        end

        function enableTiming(this)

            this.timingMode='on';
            message.subscribe(this.getStatusChannel(),@(msg)SequenceDiagramViewer.loc_handleMsg(msg));
        end

        function tic(this)
            this.timings=struct('ticHandle',tic);
        end

        function toc(this,field)
            s=this.timings;
            s.(field)=toc(s.ticHandle);
            this.timings=s;
        end

    end

    methods
        function collapse(this,lifelineId)
            this.publish('ToggleCollapseForTiming',struct('lifelineId',lifelineId));
        end

        function publish(this,cmd,msg)
            msgStruct.command=cmd;
            msgStruct.parameters=msg;
            message.publish(this.channel,msgStruct);
        end

        function applyInitialSettings(this,autoLayout,...
            showInactive,...
            showExternal,...
            showEvents,...
            showMessages,...
            showStateInfo,...
            showFunctions,...
            hasSavedSettings)
            if(showInactive)
                this.lifelineSettings='&showLifelines=true';
            else
                this.lifelineSettings='&showLifelines=false';
            end

            if(showExternal)
                this.lifelineSettings=[this.lifelineSettings,'&showExternalLifelines=true'];
            else
                this.lifelineSettings=[this.lifelineSettings,'&showExternalLifelines=false'];
            end

            if(autoLayout)
                this.lifelineSettings=[this.lifelineSettings,'&autoLayout=true'];
            else
                this.lifelineSettings=[this.lifelineSettings,'&autoLayout=false'];
            end

            if(hasSavedSettings)
                this.lifelineSettings=[this.lifelineSettings,'&savedSettings=true'];
            else
                this.lifelineSettings=[this.lifelineSettings,'&savedSettings=false'];
            end

            if(showEvents)
                this.filterSettings='&showEvents=true';
            else
                this.filterSettings='&showEvents=false';
            end

            if(showMessages)
                this.filterSettings=[this.filterSettings,'&showMessages=true'];
            else
                this.filterSettings=[this.filterSettings,'&showMessages=false'];
            end

            if(showFunctions)
                this.filterSettings=[this.filterSettings,'&showFunctions=true'];
            else
                this.filterSettings=[this.filterSettings,'&showFunctions=false'];
            end

            if(showStateInfo)
                this.filterSettings=[this.filterSettings,'&showStateInfo=true'];
            else
                this.filterSettings=[this.filterSettings,'&showStateInfo=false'];
            end
        end
    end

    methods(Static)
        function[enumSize,enumValues]=convertEnums(enums)
            enumValues={};
            if(numel(enums)>0)
                enumValues={char(enums(1))};
                for e=2:numel(enums)
                    enumValues{end+1}=char(enums(e));
                end
            end
            enumSize=size(enums);
        end

        function hostInfo=startConnector
            hostInfo=connector.ensureServiceOn();
        end

        function eventLogFcn(blk,id,kind,key,port,actor)
            ud=get_param(blk,'SequenceDiagramViewer');
            ud.logEvent(id,kind,key,port,actor);
        end

        function dumpEvent(handle,time,eventtype,msgid,msgKey,payload,portName,lifelinesid)
            logger=MessageViewerRegistry.getInstance.getLogger();
            if(~isempty(logger)&&isvalid(logger))
                logger.LogEvent(handle,time,eventtype,msgid,lifelinesid);
            end
        end

        function dumpLifelines(lifelines)
            logger=MessageViewerRegistry.getInstance.getLogger();
            if(~isempty(logger)&&isvalid(logger))
                logger.LogLifelines(lifelines);
            end
        end

        function ud=createSDV(blk)
            ud=get_param(blk,'SequenceDiagramViewer');
            if(isempty(ud)||~isvalid(ud))
                ud=SequenceDiagramViewer.factory(get_param(blk,'handle'),false);
                set_param(blk,'SequenceDiagramViewer',ud);
            end
        end

        function ud=createSingletonSDV(modelName,isDebug)
            ud=SequenceDiagramViewer.factory(modelName,isDebug);
        end

        function ud=createCustomSDV(blk,isDebug,timingMode)
            ud=get_param(blk,'SequenceDiagramViewer');
            if(isempty(ud)||~isvalid(ud))
                ud=SequenceDiagramViewer.factory(get_param(blk,'handle'),isDebug,timingMode);
                set_param(blk,'SequenceDiagramViewer',ud);
            end
        end


        function openFcn(blk,...
            autoLayout,...
            showInactive,...
            showExternal,...
            showEvents,...
            showMessages,...
            showStateInfo,...
            showFunctions,...
hasSavedSettings...
            )

            ud=get_param(blk,'SequenceDiagramViewer');
            if(isempty(ud)||~isvalid(ud))

                ud=SequenceDiagramViewer.createSDV(blk);
            end

            ud.applyInitialSettings(autoLayout,...
            showInactive,...
            showExternal,...
            showEvents,...
            showMessages,...
            showStateInfo,...
            showFunctions,...
hasSavedSettings...
            );



            if strcmp(get_param(blk,'viewerStatus'),'off')
                ud.open();
            else

                ud.dialogH.bringToFront
            end

        end

        function closeSingleton(channel)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);
            if~isempty(sd)
                sd.delete();
            end
        end

        function closeFcn(blk)
            paramName='SequenceDiagramViewer';

            ud=get_param(blk,paramName);
            if(~isempty(ud)&&isvalid(ud))
                if(~isempty(ud.dialogH)&&isvalid(ud.dialogH))
                    set_param(blk,'WindowSettings',ud.dialogH.CEFWindow.Position);
                end
                ud.delete();
                set_param(blk,paramName,[]);
            end
        end

        function nameChangeFcn(blk,newName)
            ud=get_param(blk,'SequenceDiagramViewer');
            if~isempty(ud)&&isvalid(ud)
                ud.title=[ud.titlePrefix,newName];
                if~isempty(ud.dialogH)&&isvalid(ud.dialogH)
                    ud.dialogH.setTitle(ud.title);
                end
            end
        end

        function preCompileFcn(blk)




            SequenceDiagramViewer.createSDV(blk);
        end

        function dataNameAndValuePairs=getTransitionInformation(transitionId,blockHandle)

            [~,dataNameAndValuePairs]=sfprivate('getHoverDataInformation',transitionId,blockHandle);
        end
    end

    methods(Static)
        function address=setupDebugMode(blk)
            ud=get_param(blk,'SequenceDiagramViewer');
            if(isempty(ud)||~isvalid(ud))

                ud=SequenceDiagramViewer.createSDV(blk);
            end

            ud.isDebug=true;
            address=ud.getDebugAddress();
        end
    end

    methods(Static)
        function errorHandled(channel)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);

            if~isempty(sd)
                logger=MessageViewerRegistry.getInstance.getLogger();
                if(~isempty(logger)&&isvalid(logger))
                    logger.finish();
                end
            end
        end

        function loc_handleMsg(msg)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(msg.channel);

            if~isempty(sd)
                sd.toc(msg.kind);
            end
        end

        function highlightSystemStatic(channel,id)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);

            if~isempty(sd)
                sd.highlightSystem(id);
            end
        end

        function highlightTaskStatic(channel,id)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);

            if~isempty(sd)
                sd.highlightTask(id);
            end
        end

        function[r,g,b]=getTaskRGB(mdlName,taskId)
            h=Simulink.SampleTimeLegend;
            a={'Rate',num2str(taskId),mdlName};
            b=h.rateHighlight(a);
            r=b.colorRGB(1);
            g=b.colorRGB(2);
            b=b.colorRGB(3);
        end

        function viewerLoadedStatic(channel)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);

            if~isempty(sd)
                sd.viewerLoaded();
            end
        end

        function commandStatic(channel,command)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);

            if~isempty(sd)
                sd.issueSimulationCommand(command);
            end
        end

        function configureStatic(channel)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);
            if~isempty(sd)
                sd.configure();
            end
        end

        function updateLifelineSettingsStatic(channel,showInactiveLifelines,autoLayout,showExternalLifelines,lifelineDisplaySettings,rootId)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);
            if~isempty(sd)
                sd.updateLifelineSettings(showInactiveLifelines,autoLayout,showExternalLifelines,lifelineDisplaySettings,rootId);
            end
        end

        function updateFilterSettingsStatic(channel,showEvents,showFunctions,showMessages,showStateInfo)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);
            if~isempty(sd)
                sd.updateFilterSettings(showEvents,showFunctions,showMessages,showStateInfo);
            end
        end

        function timingDataStatic(channel,kind)
            sd=MessageViewerRegistry.getInstance().findViewerFromChannel(channel);
            if~isempty(sd)
                sd.toc(kind);
            end
        end

        function helpStaticUI()
            if license('test','SimEvents')
                helpview(fullfile(docroot,'simevents','helptargets.map'),'MessageViewer_ug');
            elseif license('test','Stateflow')
                helpview(fullfile(docroot,'stateflow','stateflow.map'),'MessageViewer_ug');
            elseif license('test','Simulink_Test')
                helpview(fullfile(docroot,'sltest','helptargets.map'),'MessageViewer_ug');
            end
        end










        function turnOnEventLogging(modelHandle)
            set_param(modelHandle,'EventLogging','on');
            seqViewer=MessageViewerRegistry.getInstance().findViewerOnToolstripWithModelHandler(modelHandle);
            seqViewer.publish('Reset',struct('isFull','true','showBanner','true','showToolstripBanner','false'));
        end
    end

    methods(Static)

        function cleanUp()
            MessageViewerRegistry.getInstance().cleanUp();
        end

        function viewer=factory(varargin)
            viewer=SequenceDiagramViewer(varargin{:});
            MessageViewerRegistry.getInstance().addViewer(viewer);
        end

    end

end
