classdef FigureProxy<matlab.internal.editor.figure.AbstractFigureProxy





    events


FigureSnapshotDone
    end

    properties
        SerializedFigureState;
        IsDefaultFigureColor=false;
        MessageSubscription;
        ModeManager;
        IsGUI=false;
        ImageData;
        CodeGenerator;
        ActionManager;
        ActionRegistrator;
        UndoRedoManager;
        ModelessManager;
        ClientReadyListener;
        SpringLoadedModeClearListener;
        IsFigureRendered=false;
        ServerSnapshotCreated=false;
        FigureFocusedListener;
        FigureCurrentAxesListener;
        CodeGenerationProxy;
        CodeGenerationProxyListener;
    end

    methods(Static)
        function setGUIClientNotificationListener(callback)



mlock
            persistent guiClientReadyListener;
            if isempty(guiClientReadyListener)
                guiClientReadyListener=message.subscribe('/graphics/guiclientready',@(evd)localGUIclientReady(evd,callback),'enableDebugger',false);
            end
        end

        function setDrawnowSyncEnabledOnCanvas(can,isEnabled)




            if isprop(can,'LiveEditorDrawnowSyncReady')
                figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>
                can.LiveEditorDrawnowSyncReady=isEnabled;
            end
        end




        function removeAnimatedOutput(editorId)
            import matlab.internal.editor.FigureManager;
            import matlab.internal.editor.EODataStore;

            idsMap=EODataStore.getEditorField(editorId,FigureManager.ANIMATED_FIGURE_UID);
            message.publish('/liveeditor/removePendingOutput/animation',idsMap);
        end
    end

    methods
        function this=FigureProxy(figureId,line,isGUI)

            this.FigureId=figureId;
            this.Line=line;
            this.IsGUI=isGUI;


            if~isGUI
                this.MessageSubscription=message.subscribe(this.getChannel,@(msg)this.callback(msg),'enableDebugger',false);
                this.SerializedFigureState=matlab.internal.editor.figure.SerializedFigureState;
            end
        end



        function createWebFigureSnapshot(this,fig)
            import matlab.internal.editor.*
            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>

            this.SerializedFigureState.serialize(fig);
            this.IsDefaultFigureColor=isequal(fig.Color,get(0,'DefaultFigureColor'));



            this.createNewWebFigureFromSerializedData;

            if FigureManager.useEmbeddedFigures
                this.FigureFocusedListener=message.subscribe(join(['/graphics/',this.FigureId,'/event'],''),@(evt)this.figureFocused(evt),'enableDebugger',true);
                hAx=findobj(fig,'-isa','matlab.graphics.axis.AbstractAxes');
                if numel(hAx)>1
                    this.FigureCurrentAxesListener=message.subscribe(join(['/graphics/',this.FigureId,'/setcurrentaxes'],''),@(evt)this.setCurrentAxes(evt),'enableDebugger',true);
                end
                packet=mls.internal.fromJSON(this.ServerID);
                this.ClientReadyListener=message.subscribe(['/graphics/',packet.channel,'/clientReady'],@(evt)this.notifySnapshotDone(),'enableDebugger',true);
            else

                this.ClientReadyListener=message.subscribe(['/graphics/',this.ServerID,'/event'],@(evt)this.clientReady(),'enableDebugger',false);
            end

            this.ServerSnapshotCreated=true;
        end

        function createImageFigureSnapshot(this,pixelArray)
            this.ImageData=pixelArray;

            this.ServerSnapshotCreated=true;
        end





        function figureFocused(this,evt)
            if isempty(this.DeserializedFigure)||~isgraphics(this.DeserializedFigure)
                return
            end

            localEnableDefaultInteractivity(this.DeserializedFigure);


            if isempty(this.ActionRegistrator)
                this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
            end
            if isempty(this.CodeGenerator)
                this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.DeserializedFigure,this.ActionRegistrator);
            end
            if isempty(this.UndoRedoManager)
                this.UndoRedoManager=matlab.internal.editor.figure.UndoRedoManager(this.DeserializedFigure,this.CodeGenerator);
            end



            message.unsubscribe(this.FigureFocusedListener);
            this.FigureFocusedListener=[];
        end



        function setCurrentAxes(this,evt)



            try
                if isempty(this.DeserializedFigure)||~isgraphics(this.DeserializedFigure)
                    return
                end
                hAx=findobj(this.DeserializedFigure,'-isa','matlab.graphics.axis.AbstractAxes');
                if numel(hAx)>1
                    if isfield(evt,'xPos')&&isfield(evt,'yPos')

                        pointerPos=[evt.xPos,evt.yPos];

                        figPos=getpixelposition(this.DeserializedFigure);


                        for axObj=hAx'

                            axObjPos=getpixelposition(axObj);






                            axesXPosition=axObjPos(1);
                            axesXEndPosition=axObjPos(1)+axObjPos(3);
                            axesYPosition=figPos(4)-(axObjPos(2)+axObjPos(4));
                            axesYEndPosition=axesYPosition+axObjPos(4);






                            if((pointerPos(1)>=axesXPosition)&&(pointerPos(1)<=axesXEndPosition)&&...
                                (pointerPos(2)>=axesYPosition)&&(pointerPos(2)<axesYEndPosition))
                                this.DeserializedFigure.CurrentAxes=axObj;
                                break;
                            end
                        end
                    end
                end
            catch
            end
        end

        function clientReady(this)
            import matlab.internal.editor.*



            if isempty(this.DeserializedFigure)||~ishghandle(this.DeserializedFigure)
                return
            end



            if numel(findobjinternal(groot,'-depth',1,'type','figure'))>FigureManager.CACHED_FIGURE_LIMIT




                this.SerializedFigureState.serialize(this.DeserializedFigure);

                delete(this.DeserializedFigure);
                this.DeserializedFigure=[];



                message.publish(sprintf('/graphics/%s/command',this.ServerID),struct('cmd','disconnect'))

            end


            this.notifySnapshotDone();
        end

        function delete(this)

            message.unsubscribe(this.ClientReadyListener);
            message.unsubscribe(this.FigureFocusedListener);
            message.unsubscribe(this.FigureCurrentAxesListener);
            this.FigureCurrentAxesListener=[];
            if~isempty(this.MessageSubscription)
                message.unsubscribe(this.MessageSubscription);
            end
            delete@matlab.internal.editor.figure.AbstractFigureProxy(this);
        end

        function channel=getChannel(this)

            channel=sprintf('/liveeditor/figure/%s',this.FigureId);
        end

        function callback(this,msg)

            msgData=jsondecode(msg);
            feval(msgData.method,this,msgData.args);
        end



        function success=printToFile(this,args)
            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>
            success=true;
            import matlab.internal.editor.*;
            drawnow update
            try

                if isempty(this.DeserializedFigure)||~isvalid(this.DeserializedFigure)
                    this.deserializeFigure;
                end






                if FigureManager.useEmbeddedFigures
                    exportFuncHandle=@()matlab.graphics.internal.export.exportTo(this.DeserializedFigure.getCanvas,args{:});
                    matlab.ui.internal.dialog.DialogHelper.dispatchWhenViewIsReady(this.DeserializedFigure,exportFuncHandle);
                else
                    matlab.graphics.internal.export.exportTo(this.DeserializedFigure.getCanvas,args{:});
                end
            catch
                success=false;
            end
            message.publish([this.getChannel(),'/printed'],success);
        end


        function actionInteractionCallback(this,actionID,varargin)
            if isempty(this.ActionManager)
                this.initActionManager;
            end
            if isempty(this.DeserializedFigure)||~isvalid(this.DeserializedFigure)
                this.deserializeFigure;
            end
            this.ActionManager.performActionCallback(actionID,this.DeserializedFigure,this.FigureId,varargin{:});
        end

        function setDrawnowSyncEnabled(this,isEnabled)
            if~isempty(this.Canvas)&&isvalid(this.Canvas)
                matlab.internal.editor.FigureProxy.setDrawnowSyncEnabledOnCanvas(...
                this.Canvas,isEnabled);
            end
        end


        function initActionManager(this)
            import matlab.internal.editor.FigureManager;



            if isempty(this.DeserializedFigure)||~isvalid(this.DeserializedFigure)
                this.deserializeFigure;
            end


            if FigureManager.useEmbeddedFigures
                if isempty(this.CodeGenerator)
                    if isempty(this.ActionRegistrator)
                        this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
                    end
                    this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.DeserializedFigure,this.ActionRegistrator);
                end
            else
                if isempty(this.CodeGenerator)
                    this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
                    this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.DeserializedFigure,this.ActionRegistrator);
                end
            end


            if isempty(this.UndoRedoManager)
                this.UndoRedoManager=matlab.internal.editor.figure.UndoRedoManager(this.DeserializedFigure,this.CodeGenerator);
            end
            this.ActionManager=matlab.internal.editor.ActionManager(this.CodeGenerator,this.UndoRedoManager);
        end


        function modeLessInteractionCallback(this,clientEvent)
            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>
            if isempty(this.DeserializedFigure)||~isvalid(this.DeserializedFigure)




                this.deserializeFigure;
            end

            if isempty(this.CodeGenerator)

                if isempty(this.ActionRegistrator)
                    this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
                end
                this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.DeserializedFigure,this.ActionRegistrator);
            end
            if isempty(this.UndoRedoManager)
                this.UndoRedoManager=matlab.internal.editor.figure.UndoRedoManager(this.DeserializedFigure,this.CodeGenerator);
            end
            if isempty(this.ModelessManager)
                this.ModelessManager=matlab.internal.editor.ModelessManager(this.CodeGenerator,this.UndoRedoManager);
                this.ModelessManager.setFigure(this.DeserializedFigure,this.FigureId,...
                this.SerializedFigureState.SerializedModeState);
            end





            if isempty(this.ModelessManager.Figure)||~isvalid(this.ModelessManager.Figure)
                this.ModelessManager.setFigure(this.DeserializedFigure,this.FigureId,...
                this.SerializedFigureState.SerializedModeState);
            end
            this.ModelessManager.performCallback(clientEvent);
        end

        function modeInteractionCallback(this,clientEvent)




            if(isempty(this.ModeManager.Figure)||~isvalid(this.ModeManager.Figure))
                if isempty(this.DeserializedFigure)||~isvalid(this.DeserializedFigure)
                    this.deserializeFigure;
                end

                this.ModeManager.setFigure(this.DeserializedFigure);


                this.ModeManager.setSerializedModeState(this.SerializedFigureState.SerializedModeState);
            end

            if isempty(this.ModeManager)
                this.initModeManager('');
            end
            this.ModeManager.interactionCallback(clientEvent);
        end

        function setFigureId(this,figureId)


            if strcmp(figureId,this.FigureId)
                return
            end
            if~isempty(this.MessageSubscription)
                message.unsubscribe(this.MessageSubscription);
            end
            this.FigureId=figureId;
            this.MessageSubscription=message.subscribe(this.getChannel,@(msg)this.callback(msg),'enableDebugger',false);
        end


        function launchFigure(this,args)
            import matlab.internal.editor.*;
            import matlab.internal.editor.figure.FigureUtils;
            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>



            assert(~this.IsGUI);



            editorId=args.editorId;
            runningEditorId=EODataStore.getRootField('RunningEditor');
            isRunning=isequal(EODataStore.getRootField(FigureManager.CAPTURING_FIGURES),true)&&...
            strcmp(editorId,runningEditorId);
            if isRunning
                return;
            end

            fig=figure('NumberTitle','off','NumberTitleMode','auto',...
            'Name','Figure','IntegerHandle','on');



            if~isempty(this.DeserializedFigure)&&isvalid(this.DeserializedFigure)



                webgraphicsrestrictionWarning=warning('off','MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality');
                this.SerializedFigureState.serialize(this.DeserializedFigure);
                warning(webgraphicsrestrictionWarning);
            end

            this.SerializedFigureState.deserializeFigureLaunch(fig);


            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                localEnableDefaultInteractivity(fig);


                set(fig,'Toolbar','auto','MenuBar','figure');
                hAx=findobj(this.DeserializedFigure,'-depth',1,'-isa','matlab.graphics.axis.AbstractAxes');






                if numel(hAx)==1
                    switch(hAx.InteractionContainer.CurrentMode)
                    case{'pan'}
                        pan(fig,'on');
                    case{'zoom'}
                        zoom(fig,'on');
                    case{'rotate'}
                        rotate3d(fig,'ON');
                    end
                end



                fig.Position=this.DeserializedFigure.Packet.Position;
            else


                if~isempty(this.ModeManager)
                    this.ModeManager.setModeOnPopOutFigure(fig);
                end
            end




            if this.IsDefaultFigureColor
                fig.Color=get(0,'DefaultFigureColor');
            end




            if~isempty(this.SerializedFigureState.SerializedModeState)
                this.SerializedFigureState.SerializedModeState.deserializeForPoppedOutFigure(fig);
            end





            set(fig,'Visible','on','Handlevisibility','on',...
            'IntegerHandle','on')
            FigureUtils.safeRemoveAppData(fig,FigureUtils.EDITOR_APP_DATA_TAG);
        end

        function setMode(this,mode)

            assert(~this.IsGUI);

            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>




            this.initModeManager(mode);

        end



        function initModeManager(this,mode)
            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>


            assert(~this.IsGUI);



            if isempty(this.DeserializedFigure)||~isvalid(this.DeserializedFigure)
                this.deserializeFigure;
            end

            import matlab.internal.editor.*
            import matlab.internal.editor.figure.FigureDataTransporter

            if isempty(this.ModeManager)

                if isempty(this.CodeGenerator)
                    if isempty(this.ActionRegistrator)
                        this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
                    end
                    this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.DeserializedFigure,this.ActionRegistrator);
                end
                if isempty(this.UndoRedoManager)
                    this.UndoRedoManager=matlab.internal.editor.figure.UndoRedoManager(this.DeserializedFigure,this.CodeGenerator);
                end
                this.ModeManager=matlab.internal.editor.ModeManager(this.FigureId,this.Line,mode,this.CodeGenerator,this.UndoRedoManager);
            end

            if~isempty(mode)
                this.ModeManager.setMode(mode);
            end
            this.ModeManager.setFigure(this.DeserializedFigure);


            this.ModeManager.setSerializedModeState(this.SerializedFigureState.SerializedModeState);






            cachedHandleVisibility=this.DeserializedFigure.HandleVisibility;
            this.DeserializedFigure.HandleVisibility='on';




            figureData=FigureDataTransporter.getFigureMetaData(this.DeserializedFigure);
            FigureDataTransporter.transportFigureData(this.FigureId,figureData);


            this.DeserializedFigure.HandleVisibility=cachedHandleVisibility;
        end

        function fig=deserializeFigure(this)



            this.createNewWebFigureFromSerializedData;

            import matlab.internal.editor.figure.FigureDataTransporter;
            import matlab.internal.editor.FigureManager;
            import matlab.internal.editor.figure.FigureUtils;
            figureData=matlab.internal.editor.figure.FigureData;
            drawnow update
            figureData.setServerID(this.Canvas.ServerID);
            FigureDataTransporter.transportFigureData(this.FigureId,figureData);
            fig=this.DeserializedFigure;
            if isappdata(fig,FigureUtils.EDITOR_APP_DATA_TAG)
                rmappdata(fig,FigureUtils.EDITOR_APP_DATA_TAG)
            end
        end

        function springLoadedModeAction(this,eventData)

            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>





            import matlab.internal.editor.figure.FigureDataTransporter




            if strcmp(eventData.type,'clearMode')



                if~isempty(this.DeserializedFigure)&&isvalid(this.DeserializedFigure)&&...
                    isactiveuimode(this.DeserializedFigure,eventData.clearedMode)
                    activateuimode(this.DeserializedFigure,'');
                    FigureDataTransporter.transportFigureDataForRendering(this.FigureId,this.DeserializedFigure);

                end
                return
            end















            if~(isfield(eventData,'retainMode')&&eventData.retainMode)&&...
                isactiveuimode(this.DeserializedFigure,eventData.mode)
                activateuimode(this.DeserializedFigure,'');
            end

            this.actionInteractionCallback(eventData.type,eventData.configurationData,eventData.axesIndex);
        end



        function undoRedoInteractionCallback(this,args)

            if isempty(this.CodeGenerator)
                if isempty(this.ActionRegistrator)
                    this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
                end
                this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.DeserializedFigure,this.ActionRegistrator);
            end

            if isempty(this.UndoRedoManager)
                this.UndoRedoManager=matlab.internal.editor.figure.UndoRedoManager(this.DeserializedFigure,this.CodeGenerator);
            end

            this.UndoRedoManager.performUndoRedoCallback(this.DeserializedFigure,this.FigureId,args);
        end


        function paletteActionInteractionCallback(this,clientEvent)




            if isempty(this.ActionManager)
                if isempty(this.DeserializedFigure)||~isvalid(this.DeserializedFigure)
                    this.deserializeFigure;
                end

                import matlab.internal.editor.*
                import matlab.internal.editor.figure.FigureDataTransporter

                if isempty(this.ActionManager)

                    if isempty(this.CodeGenerator)
                        if isempty(this.ActionRegistrator)
                            this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
                        end
                        this.CodeGenerator=matlab.internal.editor.CodeGenerator(this.DeserializedFigure,this.ActionRegistrator);
                    end
                    if isempty(this.UndoRedoManager)
                        this.UndoRedoManager=matlab.internal.editor.figure.UndoRedoManager(this.DeserializedFigure,this.CodeGenerator);
                    end
                    this.ActionManager=matlab.internal.editor.ActionManager(this.CodeGenerator,this.UndoRedoManager);
                end
            end

            this.ActionManager.actionInteractionCallback(this.DeserializedFigure,clientEvent,this.FigureId);
        end

        function popupSpringLoadedModeButton(this,eventData,buttonPopup)

            if strcmp('off',eventData.AffectedObject.Enable)
                feval(buttonPopup)
            end

            delete(this.SpringLoadedModeClearListener);
        end

        function createNewWebFigureFromSerializedData(this)




            import matlab.internal.editor.*;
            import matlab.internal.editor.figure.FigureUtils;

            if FigureManager.useEmbeddedFigures
                this.createNewEmbeddedFigureFromSerializedData();
                return
            end
            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>




            this.suspendFigureCreationListeners;


            controllerInfo.ControllerClassName='matlab.ui.internal.controller.FigureController';
CreateUIFigure
            try
                this.DeserializedFigure=appwindowfactory(...
                'Visible','on',...
                'WindowStyle','normal',...
                'DockControls','off',...
                'HandleVisibility','off',...
                'IntegerHandle','off',...
                'MenuBar','none',...
                'NumberTitle','off',...
                'Toolbar','none',...
                'ToolbarMode','auto',...
                'MenuBarMode','auto',...
                'ControllerInfo',controllerInfo,...
                'AutoResizeChildren','off',...
                'Color',[1,1,1],...
                'Internal',true,...
                'Tag',FigureUtils.EDITOR_FIGURE_SNAPSHOT_TAG);
CreateUIFigureReset
                canvas=hg2gcv(this.DeserializedFigure);
                canvas.ErrorCallback=@(~,evt)this.localWarnCallback(evt);
                canvas.ServerSideRendering='on';
                this.Canvas=canvas;
                this.ServerID=canvas.ServerID;




                addprop(this.DeserializedFigure,'LiveEditorFigureSnapshot');
                this.DeserializedFigure.LiveEditorFigureSnapshot=true;

                this.SerializedFigureState.deserialize(this.DeserializedFigure);
                if FigureManager.allowAnimation
                    matlab.internal.editor.FigureManager.requestDrawnow();
                else
                    matlab.graphics.internal.updateVisibleFiguresOnly;
                end

                this.restoreFigureCreationListeners;

            catch me
CreateUIFigureReset
                if strcmp(me.identifier,'MATLAB:handle_graphics:exceptions:UserBreak')
                    delete(this.DeserializedFigure);
                    return
                end
                rethrow(me);
            end
        end

        function createNewEmbeddedFigureFromSerializedData(this)




            import matlab.internal.editor.*
            import matlab.internal.editor.figure.FigureUtils;
            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>




            this.suspendFigureCreationListeners;
            try
                editorId=EODataStore.getRootField(FigureManager.EDITOR_ROOT_APP_DATA_TAG);

                this.DeserializedFigure=matlab.internal.editor.figure.FigurePoolManager.getFigure(editorId);
                if isempty(this.DeserializedFigure)

                    this.DeserializedFigure=matlab.internal.editor.figure.FigurePoolManager.createEmbeddedFigure();
                    this.DeserializedFigure.Visible='on';
                    this.DeserializedFigure.editorID=editorId;
                end
                this.DeserializedFigure.Internal=false;
                this.SerializedFigureState.deserialize(this.DeserializedFigure);
                this.createCallbackWarningIfRequired();




                this.DeserializedFigure.Packet.Position=this.DeserializedFigure.Position;







                idsMap=[];
                if~isempty(editorId)
                    idsMap=EODataStore.getEditorField(editorId,FigureManager.ANIMATED_FIGURE_UID);
                end
                canvas=this.DeserializedFigure.getCanvas;
                if~isempty(idsMap)&&isKey(idsMap,this.FigureId)
                    canvas.ServerSideRendering='on';
                end

                this.ServerID=mls.internal.toJSON(this.DeserializedFigure.Packet);
                canvas.ErrorCallback=@(~,evt)this.localWarnCallback(evt);

                if FigureManager.allowAnimation
                    matlab.internal.editor.FigureManager.requestDrawnow();
                else
                    matlab.graphics.internal.updateVisibleFiguresOnly;
                end

                this.initCodeGenerationProxy();

                this.restoreFigureCreationListeners;
            catch me
                if strcmp(me.identifier,'MATLAB:handle_graphics:exceptions:UserBreak')
                    delete(this.DeserializedFigure);
                    return
                end
                rethrow(me);
            end
        end


        function initCodeGenerationProxy(this)

            if isempty(this.ActionRegistrator)
                this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
            end



            this.CodeGenerationProxy=matlab.internal.editor.CodeGenerationProxy(this.ActionRegistrator);
            this.CodeGenerationProxyListener=event.listener(this.CodeGenerationProxy,'InteractionOccured',@(e,d)this.codeGenerationProxyClb(d));

            if~isprop(this.DeserializedFigure,'CodeGenerationProxy')
                p=addprop(this.DeserializedFigure,'CodeGenerationProxy');
                p.Transient=1;
            else
                delete(this.DeserializedFigure.CodeGenerationProxy);
            end

            this.DeserializedFigure.CodeGenerationProxy=this.CodeGenerationProxy;
        end


        function codeGenerationProxyClb(this,eventData)

            if eventData.IsUndoable

                this.UndoRedoManager.registerUndoRedoAction(eventData.Object,eventData.ActionToRegister);
            end

            [generatedCode,isFakeCode]=this.CodeGenerator.generateCode;



            import com.mathworks.mde.embeddedoutputs.figures.*
            import matlab.internal.editor.figure.FigureDataTransporter
            [figureData,~]=FigureDataTransporter.getFigureMetaData(this.DeserializedFigure,generatedCode);
            figureData.setCode(generatedCode);
            figureData.setFakeCode(isFakeCode);

            figureData.iFigureInteractionData.iShowCode=~isempty(generatedCode);

            figureData.iFigureInteractionData.iClearCode=isempty(generatedCode);


            if eventData.IsUndoable&&eventData.DoRegisterLEUndoRedo
                figureData.iFigureInteractionData.iRegisterAction=~isempty(generatedCode);
            end

            FigureDataTransporter.transportFigureData(this.FigureId,figureData);
        end


        function setServerMode(this,hFig,lineNumber,currentModeName,currentModeStateData)

            if isempty(this.CodeGenerator)
                if isempty(this.ActionRegistrator)
                    this.ActionRegistrator=matlab.internal.editor.figure.Registrator();
                end
                this.CodeGenerator=matlab.internal.editor.CodeGenerator(hFig,this.ActionRegistrator);
            end

            if isempty(this.UndoRedoManager)
                this.UndoRedoManager=matlab.internal.editor.figure.UndoRedoManager(hFig,this.CodeGenerator);
            end

            this.ModeManager=matlab.internal.editor.ModeManager(this.FigureId,lineNumber,currentModeName,...
            this.CodeGenerator,this.UndoRedoManager);

            this.ModeManager.setServerMode(currentModeName,currentModeStateData);






            if~isempty(this.DeserializedFigure)&&isvalid(this.DeserializedFigure)
                cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>
                this.SerializedFigureState.SerializedModeState.deserialize(this.DeserializedFigure,currentModeName);
                this.ModeManager.setFigure(this.DeserializedFigure);
            end
        end

        function clearSpringLoadedModeFromJavaScript(this,actionID)


            if isempty(this.DeserializedFigure)||~isvalid(this.DeserializedFigure)
                return;
            end
            I=strfind(actionID,'.');
            if~isempty(I)
                actionID=actionID(I+1:end);
            end
            ploteditMode=getuimode(this.DeserializedFigure,'Standard.EditPlot');
            if~isempty(ploteditMode)&&strcmp(ploteditMode.ModeStateData.CreateMode.ModeStateData.ObjectName,actionID)
                matlab.internal.editor.ActionManager.clearPlotEditMode(this.DeserializedFigure);
            end
        end
    end

    methods(Static)

        function figureData=activateSpringLoadedMode(javaAction,figureID,editorID,lineNumber,modeName,actionID)


            buttonPopup=@()javaMethodEDT('setSelected',javaAction,false);
            figureData=matlab.internal.editor.FigureProxy.activateSpringLoadedModeFromJavaScript(buttonPopup,figureID,editorID,lineNumber,modeName,actionID);
        end

        function figureData=activateSpringLoadedModeFromJavaScript(buttonPopup,figureID,editorID,lineNumber,modeName,actionID)



            import matlab.internal.editor.*
            figureData=[];
            if matlab.internal.editor.FigureManager.useEmbeddedFigures



                for k=1:length(figureID)
                    figProxy=FigureProxy.lookupFigureProxy(lineNumber{k}+1,editorID,figureID{k});
                    if isempty(figProxy)






                        return
                    end
                end








                I=strfind(actionID,'.');
                if~isempty(I)
                    actionID=actionID(I+1:end);
                end

                figProxy.actionInteractionCallback(actionID,buttonPopup);
            else
                for k=1:length(figureID)
                    figProxy=FigureProxy.lookupFigureProxy(lineNumber{k}+1,editorID,figureID{k});
                    if isempty(figProxy)






                        return
                    end
                    figProxy.initModeManager(struct('mode',modeName,'direction',''));
                end


                springLoadedMode=figProxy.DeserializedFigure.ModeManager.CurrentMode;
                if~isempty(buttonPopup)
                    if ModeManager.isSpringLoadedModeApplied(springLoadedMode.Name,figProxy.DeserializedFigure)
                        feval(buttonPopup)
                        return;
                    end
                    figProxy.SpringLoadedModeClearListener=event.proplistener(springLoadedMode,...
                    springLoadedMode.findprop('Enable'),'PostSet',...
                    @(e,eventData)figProxy.popupSpringLoadedModeButton(eventData,buttonPopup));
                end
            end
        end

        function clearAllSpringLoadedModes(figureID,editorID,lineNumber)



            import matlab.internal.editor.*

            for k=1:length(figureID)
                figProxy=FigureProxy.lookupFigureProxy(lineNumber{k}+1,editorID,figureID{k});


                if~isempty(figProxy)&&isvalid(figProxy)
                    if matlab.internal.editor.FigureManager.useEmbeddedFigures


                        if isactiveuimode(figProxy.DeserializedFigure,'Standard.EditPlot')
                            activateuimode(figProxy.DeserializedFigure,'');
                        end
                    else

                        if isprop(figProxy.DeserializedFigure,'ModeManager')
                            currentMode=figProxy.DeserializedFigure.ModeManager.CurrentMode;
                            if~isempty(currentMode)
                                springLoadedModeNames=ModeManager.getSpringLoadedModeNames;
                                isSpringLoadedMode=find(strcmpi(springLoadedModeNames,currentMode.Name),1);
                                if isSpringLoadedMode
                                    figProxy.initModeManager(struct('mode','','direction',''));
                                end
                            end
                        end
                    end
                end
            end
        end


        function figureData=refreshCurrentFigureForAction(actionID,figureID,editorID,lineNumber,varargin)



            import matlab.internal.editor.*





            FigureProxy.clearAllSpringLoadedModes(figureID,editorID,lineNumber)

            for k=1:length(figureID)
                figProxy=FigureProxy.lookupFigureProxy(lineNumber{k}+1,editorID,figureID{k});
                if isempty(figProxy)
                    return
                end
                figProxy.actionInteractionCallback(actionID,varargin{:});
            end

            figureData=[];
        end

        function data=lookupFigureProxy(line,editorId,uid)
            import matlab.internal.editor.*
            data=[];
            allData=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
            if~isKey(allData,num2str(line))
                return;
            end
            figData=allData(num2str(line));
            if isKey(figData,uid)
                data=figData(uid);
            end
        end

        function updateSnapshotDataUpdateToken(editorId,fig)
            import matlab.internal.editor.*
            cachedSnapshotFigures=EODataStore.getEditorField(editorId,FigureManager.EDITOR_SNAPSHOT_APP_DATA_TAG);
            if isfield(cachedSnapshotFigures,'figure')
                I=cachedSnapshotFigures.figure==fig;
                if any(I)
                    drawnow update
                    [cachedSnapshotFigures.data(I)]=deal(fig.UpdateToken);
                    EODataStore.setEditorField(editorId,FigureManager.EDITOR_SNAPSHOT_APP_DATA_TAG,cachedSnapshotFigures);
                end
            end
        end
    end

    methods(Access={?tFigureProxy,?tFigureCallbackSupportInLiveEditor})
        function localWarnCallback(this,evt)
            import matlab.internal.editor.*
            if~isprop(this.DeserializedFigure,'LiveEditorCallbackWarning')||...
                (isvalid(this.DeserializedFigure.LiveEditorCallbackWarning)&&isempty(this.DeserializedFigure.LiveEditorCallbackWarning.WarningText))
                [id,warnMsg]=matlab.graphics.internal.prepareDefaultErrorCallbackWarning(evt);
                w=warning('query',id);
                if strcmp(w.state,'on')
                    can=this.DeserializedFigure.getCanvas;
                    can.ErrorCallback=[];
                    if~isprop(this.DeserializedFigure,'LiveEditorRenderWarning')
                        p=addprop(this.DeserializedFigure,'LiveEditorRenderWarning');
                        p.Transient=1;
                    end
                    this.DeserializedFigure.LiveEditorRenderWarning=matlab.internal.editor.figure.WarningGraphicsIcon(this.DeserializedFigure,sprintf(warnMsg));
                end
            end
        end

        function createCallbackWarningIfRequired(this)





            if~isempty(this.DeserializedFigure.CallbackNotSupportedWarning)&&this.DeserializedFigure.CallbackNotSupportedWarning
                if~isprop(this.DeserializedFigure,'LiveEditorCallbackWarning')
                    p=addprop(this.DeserializedFigure,'LiveEditorCallbackWarning');
                    p.Transient=1;
                end
                this.DeserializedFigure.LiveEditorCallbackWarning=matlab.internal.editor.figure.WarningGraphicsIcon(this.DeserializedFigure,getString(message('rich_text_component:embeddedOutputs:figuresCallbackWarning')));
            end
        end
    end

    methods(Access=private)
        function notifySnapshotDone(this)
            try

                this.notify('FigureSnapshotDone');
                this.IsFigureRendered=true;
            catch
            end
        end
    end
end


function cleanupHandle=clearWebGraphicsRestriction



    webGraphicsRestriction=feature('WebGraphicsRestriction');
    if webGraphicsRestriction
        feature('WebGraphicsRestriction',false);
        cleanupHandle=onCleanup(@()feature('WebGraphicsRestriction',true));
    else
        cleanupHandle=[];
    end
end

function localGUIclientReady(evd,callback)
    eventData1=matlab.internal.editor.figure.FigureManagerEventData(evd.EditorID,evd.FigureID);
    feval(callback,eventData1);
end


function localEnableDefaultInteractivity(hFig)
    hAx=matlab.internal.editor.figure.ChartAccessor.getAllAxes(hFig);

    for i=1:numel(hAx)



        tb=hAx(i).Toolbar;








        if~isempty(hAx(i).Toolbar_IS)
            tb.setTrueParent(hAx(i));
        end
        if isempty(tb)&&strcmp(hAx(i).ToolbarMode,'auto')

            hAx(i).Toolbar=matlab.graphics.controls.ToolbarController.getDefaultToolbar(hAx(i));
        end

        matlab.graphics.interaction.internal.UnifiedAxesInteractions.createInteractionsForTitlesAndLabels(hAx(i));




        HWCallbacksExist=matlab.graphics.interaction.internal.UnifiedAxesInteractions.checkIfHWCallbacksExist(hAx(i),hFig);

        if~HWCallbacksExist&&isempty(hAx(i).InteractionContainer.List)&&strcmpi(hAx(i).InteractionContainer.Enabled,'on')
            enableDefaultInteractivity(hAx(i));
            hAx(i).InteractionContainer.EnabledMode='auto';
        end
    end
end