classdef FigureManager<handle


    events


FigureSnapshotStart



FigureSnapshotEnd



FigureOutputReady
    end

    properties(Constant)
        EDITOR_ROOT_APP_DATA_TAG='ROOT'
        EDITOR_SNAPSHOT_APP_DATA_TAG='SNAPSHOT_'
        EDITOR_LISTEN_APP_DATA_TAG='LISTENER_'
        EDITOR_STORE_APP_DATA_TAG='STORE_'
        EDITOR_STORE_FIGURE_STATE_TAG='FIGURE_STATE_'
        EDITOR_STORE_LINE_NUMBER_MAP_TAG='LINE_NUMBER_MAP_'
        EDITOR_STORE_VISUAL_OUTPUTS_MAP_TAG='VISUAL_OUTPUTS_MAP_'
        EDITOR_REGION_APP_DATA_TAG='REGION'
        EDITOR_FIRST_REGION_APP_DATA_TAG='FIRST_REGION'
        EDITOR_HANDLE_VIS='HANDLE_VISIBILITY'
        FIGURE_UID='FIGURE_UID'
        CAPTURING_FIGURES='CAPTURING_FIGURES'
        InternalEditor_Data='InternalEditor_Data'
        CACHED_FIGURE_LIMIT=30;
        EDITOR_HAS_GRAPHICS='EditorHasGraphics';
        FIGURE_RENDER_WARNING='FIGURE_RENDER_WARNING';
        ORIGINAL_COLOR='ORIGINAL_COLOR';
        PENDING_FIGURE_PROXY='PENDING_FIGURE_PROXY';
        INCOMPLETE_FIGURE='incomplete';
        EDITOR_CURRENT_FIGURE='EDITOR_CURRENT_FIGURE';
        IS_SHOWING_ANIMATION='IsShowingAnimation';
        ANIMATED_FIGURE_UID='ANIMATED_FIGURE_UID';
        ISDEBUGGING='IsDebugging';
        IS_DEBUG_FIGURE_DIRTY='IsDebugFigureDirty';
        EDITOR_LAST_DRAWNOW_TIME='LastDrawnowTime';
        EDITOR_PENDING_DRAWNOW='PendingDrawnow';
        DRAWNOW_THRESHOLD_IN_SEC=2;
        STORE_FIGURE_VISIBLE='StoreFigureVisible';
        STORE_FIGURE_MENUBAR='StoreFigureMenubar';
        STORE_FIGURE_TOOLBAR='StoreFigureToolbar';
        EDITOR_NAMESPACE='Editor';
        EMBEDDED_UIFIGURES_LISTENER='UIFIGURE_LISTENER_';
        PERSISTENT_EDITOR_NAMESPACE='PersitentEditor';
        OWNING_EDITOR_ID_KEY='OWNING_EDITOR_ID_KEY';
        EXTERNAL_FIGURES='ExternalFigures';
        BINARY_CHANNEL_ENABLED='BinaryChannelEnabled'
        MAX_NUM_OF_FIGURES=30;
    end

    properties(Hidden)


        useEmbeddedSetting logical=false;
    end

    properties(Hidden,Access=private)


        enableEmbeddedUIFiguresSetting=false;
    end

    methods(Static)

        function pushEditorFiguresToGCF(editorId)
            import matlab.internal.editor.FigureManager
            figs=myallchild;
            isEditor=FigureManager.isEditorFigure(figs,editorId);
            edFigs=figs(isEditor);
            for k=1:length(edFigs)
                oldHV=FigureManager.safeGetAppData(edFigs(k),FigureManager.EDITOR_HANDLE_VIS);
                if~isempty(oldHV)
                    set(edFigs(k),'HandleVisibility_I',oldHV);
                end
            end
        end

        function pushFiguresToEditor(editorId)
            import matlab.internal.editor.FigureManager
            figs=myallchild;
            isEditor=FigureManager.isEditorFigure(figs,editorId);
            edFigs=figs(isEditor);
            for k=1:length(edFigs)
                if strcmp(edFigs(k).Visible,'off')
                    hv=get(edFigs(k),'HandleVisibility');
                    if strcmp(hv,'on')
                        set(edFigs(k),'HandleVisibility','off');
                    end
                end
            end
        end

        function ret=useEmbeddedFigures()

            s=settings;
            ret=s.matlab.liveeditor.LiveEditorUseEmbeddedFigures.ActiveValue;
        end



        function enableEmbeddedUIFigures()

            fm=matlab.internal.editor.FigureManager.getInstance;

            fm.enableEmbeddedUIFiguresSetting=true;
            fm.useEmbeddedSetting=true;

            import matlab.internal.editor.*
            listener=EODataStore.getRootField(FigureManager.EMBEDDED_UIFIGURES_LISTENER);
            if isempty(listener)


                classObj=?matlab.ui.Figure;
                callback=@(~,ev)tagFigureAsEmbeddedUIFIgure(ev.Instance);
                listener=addlistener(classObj,'InstanceCreated',callback);
                EODataStore.setRootField(FigureManager.EMBEDDED_UIFIGURES_LISTENER,listener);
            end
            listener.Enabled=true;


            s=settings;
            s.matlab.ui.figure.ShowEmbedded.PersonalValue=true;
        end


        function disableEmbeddedUIFigures()


            fm=matlab.internal.editor.FigureManager.getInstance;
            fm.enableEmbeddedUIFiguresSetting=false;
            fm.useEmbeddedSetting=false;

            s=settings;
            s.matlab.ui.figure.ShowEmbedded.PersonalValue=false;

            import matlab.internal.editor.*
            listener=EODataStore.getRootField(FigureManager.EMBEDDED_UIFIGURES_LISTENER);
            if~isempty(listener)
                listener.Enabled=false;
            end
        end

        function requestDrawnow
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.FigureManager

            editorId=EODataStore.getRootField(FigureManager.EDITOR_ROOT_APP_DATA_TAG);
            if isempty(editorId)
                return;
            end
            currentTime=cputime;
            if currentTime-EODataStore.getEditorField(editorId,FigureManager.EDITOR_LAST_DRAWNOW_TIME)>=FigureManager.DRAWNOW_THRESHOLD_IN_SEC



                matlab.graphics.internal.updateVisibleFiguresOnly;
                callYield();
                EODataStore.setEditorField(editorId,FigureManager.EDITOR_LAST_DRAWNOW_TIME,currentTime);
                EODataStore.setEditorField(editorId,FigureManager.EDITOR_PENDING_DRAWNOW,false);
            else


                EODataStore.setEditorField(editorId,FigureManager.EDITOR_PENDING_DRAWNOW,true);
            end
        end

        function processPendingDrawnow
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.FigureManager


            editorId=EODataStore.getRootField(FigureManager.EDITOR_ROOT_APP_DATA_TAG);
            if isempty(editorId)||~EODataStore.getEditorField(editorId,FigureManager.EDITOR_PENDING_DRAWNOW)

                return
            end


            currentTime=cputime;
            if currentTime-EODataStore.getEditorField(editorId,FigureManager.EDITOR_LAST_DRAWNOW_TIME)>=FigureManager.DRAWNOW_THRESHOLD_IN_SEC
                matlab.graphics.internal.updateVisibleFiguresOnly;
                callYield();
                EODataStore.setEditorField(editorId,FigureManager.EDITOR_LAST_DRAWNOW_TIME,currentTime);
                EODataStore.setEditorField(editorId,FigureManager.EDITOR_PENDING_DRAWNOW,false);
            end
        end

        function obj=getInstance()
mlock
            persistent instance
            if isempty(instance)
                instance=matlab.internal.editor.FigureManager();



                matlab.internal.editor.FigureManager.applySettings;
                settingsObj=settings;
                editorSettingsGroup=settingsObj.matlab.editor;
                addlistener(editorSettingsGroup,editorSettingsGroup.findprop('AllowFigureAnimation'),'PostSet',@(e,d)matlab.internal.editor.FigureManager.applySettings);
            end
            obj=instance;
        end

        function applySettings


            import matlab.internal.editor.*
            settingsObj=settings;

            state=settingsObj.matlab.editor.AllowFigureAnimation.ActiveValue;


            EODataStore.setRootField('EmbeddedFiguresForExecution',state);




            isCapturing=EODataStore.getRootField(FigureManager.CAPTURING_FIGURES);
            if~isempty(isCapturing)&&isCapturing
                FigureManager.setUseEmbeddedFigureForExecution(state);
            end
        end

        function state=allowAnimation
            state=matlab.internal.editor.EODataStore.getRootField('EmbeddedFiguresForExecution');
            if isempty(state)


                state=false;
            end
        end

        function setUseEmbeddedFigureForExecution(state)





            if~state
                matlab.ui.internal.EmbeddedWebFigureStateManager.setEnabled(false);
            else
                matlab.ui.internal.EmbeddedWebFigureStateManager.setEnabled(true);
            end
        end

        function enableCaptureFigures(editorId)

            import matlab.internal.editor.*

            EODataStore.setRootField(FigureManager.CAPTURING_FIGURES,true);
            initialValue=feature('useWebGraphicsBinaryChannel');
            EODataStore.setRootField(FigureManager.BINARY_CHANNEL_ENABLED,initialValue);
            EODataStore.setEditorField(editorId,FigureManager.EDITOR_LAST_DRAWNOW_TIME,0);
            EODataStore.setEditorField(editorId,FigureManager.EDITOR_PENDING_DRAWNOW,false);
            if numel(findobjinternal('type','figure'))>FigureManager.MAX_NUM_OF_FIGURES
                feature('useWebGraphicsBinaryChannel',false);
            end







            EODataStore.setEditorField(editorId,FigureManager.ISDEBUGGING,false);
enableCaptureListeners



            if FigureManager.allowAnimation
                FigureManager.setUseEmbeddedFigureForExecution(true);
            end

            setPseudoRoot(editorId);



            matlab.internal.editor.figure.ToolstripSubscriber.getInstance.subscribe(editorId);


            matlab.internal.editor.figure.FigureSnapshotManager.create();

        end

        function clearFigures(editorId)
            import matlab.internal.editor.FigureManager
            FigureManager.closeAllSnapshottedEditorFigures(editorId);
        end

        function cleanupOnEditorClose(editorId)
            import matlab.internal.editor.FigureManager



            matlab.internal.editor.figure.ToolstripSubscriber.getInstance.unsubscribe(editorId);



            FigureManager.clearVisualOutputData(editorId);
        end

        function disableCaptureFigures(editorId)

            import matlab.internal.editor.*

            isCapturing=EODataStore.getRootField(FigureManager.CAPTURING_FIGURES);
            EODataStore.setEditorField(editorId,FigureManager.EDITOR_LAST_DRAWNOW_TIME,0);
            EODataStore.setEditorField(editorId,FigureManager.EDITOR_PENDING_DRAWNOW,false);
            initialBinaryChannelValue=EODataStore.getRootField(FigureManager.BINARY_CHANNEL_ENABLED);
            if~isempty(initialBinaryChannelValue)
                feature('useWebGraphicsBinaryChannel',initialBinaryChannelValue);
            end
            if isempty(isCapturing)||~isCapturing


                return;
            end

            EODataStore.setRootField(FigureManager.CAPTURING_FIGURES,false);

            EODataStore.removeEditorSubMap(editorId,FigureManager.EDITOR_STORE_FIGURE_STATE_TAG);

            clearPseudoRoot(editorId);
disableCaptureListeners

            if FigureManager.allowAnimation
                FigureManager.setUseEmbeddedFigureForExecution(false);
            end
        end

        function cleanupAfterEval(editorId)
            import matlab.internal.editor.*
            EODataStore.removeEditorSubMap(editorId,FigureManager.EDITOR_STORE_LINE_NUMBER_MAP_TAG);



            allEditorFigures=getEditorFigures(editorId);
            for hFig=allEditorFigures'
                FigureManager.safeSetAppData(hFig,FigureManager.FIGURE_UID,editorId,[]);












                isShowingAnimation=FigureManager.safeGetAppData(hFig,FigureManager.IS_SHOWING_ANIMATION,editorId);
                if~isempty(isShowingAnimation)&&isShowingAnimation
                    FigureManager.safeSetAppData(hFig,FigureManager.IS_SHOWING_ANIMATION,editorId,false);
                end
            end



            FigureManager.clearVisualOutputData(editorId);

            builtin('_StructuredFiguresSetEnablement',true);
        end

        function setCurrentRegion(editorId,regionNumber)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.FigureManager
            EODataStore.setEditorField(editorId,FigureManager.EDITOR_REGION_APP_DATA_TAG,regionNumber);
        end

        function figureBeingReset(fig)


            timerGuard=matlab.internal.language.TimerSuspender;%#ok<NASGU>
            matlab.ui.internal.prepareFigureFor(fig,mfilename('fullpath'));
        end

        function figureBeingCleared(fig,context)




            import matlab.internal.editor.*;
            import matlab.internal.editor.figure.FigureUtils;









            matlab.internal.editor.StreamOutputsSignal.stream();


            figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>
            timerGuard=matlab.internal.language.TimerSuspender;%#ok<NASGU>
            warningSuppressor=matlab.internal.editor.LastWarningGuard;%#ok<NASGU>



            builtin('_StructuredFiguresResetFigure',fig);

            s=FigureManager.safeGetAppData(fig,FigureUtils.EDITOR_ID_APP_DATA_TAG);
            if~isempty(s)
                currentEditor=EODataStore.getRootField(FigureManager.EDITOR_ROOT_APP_DATA_TAG);

                if isequal(s,currentEditor)






                    if strcmp(fig.NextPlot,'add')
                        snapshotFigureBeingCleared=hasContentInCurrentAxes(fig,context);
                    else
                        snapshotFigureBeingCleared=hasContentInCurrentFigure(fig,context);
                    end
                    if snapshotFigureBeingCleared
                        snapshotAndResetOnFigureChangeEvent(fig,s);


                        annotationPane=findall(fig,'-depth',1,'type','annotationpane');
                        if~isempty(annotationPane)
                            delete(annotationPane)
                        end
                        if matlab.internal.editor.FigureManager.useEmbeddedFigures








                            if isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)&&~isempty(fig.ModeManager.CurrentMode)
                                activateuimode(fig,'');
                            end



                            figureCallbackArray={'WindowButtonUpFcn','WindowButtonDownFcn','WindowButtonMotionFcn','WindowScrollWheelFcn',...
                            'WindowKeyPressFcn','WindowKeyReleaseFcn','ResizeFcn','CreateFcn','DeleteFcn','KeyPressFcn','KeyReleaseFcn',...
                            'SizeChangedFcn','ButtonDownFcn','CloseRequestFcn'};
                            for arrayIdx=1:numel(figureCallbackArray)
                                if isprop(fig,figureCallbackArray{arrayIdx})&&~isempty(fig.(figureCallbackArray{arrayIdx}))



                                    if~isequal(figureCallbackArray{arrayIdx},'CloseRequestFcn')
                                        fig.(figureCallbackArray{arrayIdx})=[];
                                    else
                                        fig.(figureCallbackArray{arrayIdx})='closereq';
                                    end
                                end
                            end
                        end
                    end
                else


                    FigureManager.reassociateFigure(fig,currentEditor);
                end
            end
        end

        function closeAllSnapshottedEditorFigures(editorId)
            import matlab.internal.editor.*

            figs=myallchild;
            isEditor=FigureManager.isEditorFigure(figs,editorId);

            cachedFigs=cachedFigures(figs(isEditor));
            if~isempty(cachedFigs)
                close(cachedFigs)
            end

            FigureManager.closeFiguresCachedInAppDataTag(editorId);
        end

        function closeAllEditorFigures(editorId)
            import matlab.internal.editor.*

            figs=myallchild;
            isEditor=FigureManager.isEditorFigure(figs,editorId);
            edFigs=invisibleFigures(figs(isEditor));
            if~isempty(edFigs)
                close(edFigs)
            end

            FigureManager.closeFiguresCachedInAppDataTag(editorId);


            EODataStore.removeEditorSubMap(editorId,FigureManager.EDITOR_STORE_LINE_NUMBER_MAP_TAG);
        end

        function closeFiguresCachedInAppDataTag(editorId)
            import matlab.internal.editor.*

            allData=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
            lineMaps=allData.values;
            for k=1:length(lineMaps)
                cellfun(@(figData)delete(figData),lineMaps{k}.values);
                remove(lineMaps{k},lineMaps{k}.keys);
            end
            remove(allData,allData.keys);
        end


        function closeAllInterruptedEditorFigures(editorId)



            import matlab.internal.editor.*

            allData=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
            lineMaps=allData.values;
            for k=1:length(lineMaps)


                figureProxies=lineMaps{k}.values;
                interuptedFigureKeyIndices=cellfun(@(h)isvalid(h)&&isprop(h,'IsFigureRendered')&&~h.IsFigureRendered,figureProxies);
                delete([figureProxies{interuptedFigureKeyIndices}]);



                keys=lineMaps{k}.keys;
                remove(lineMaps{k},keys(interuptedFigureKeyIndices));
            end
        end

        function destroyAllEditorFigureData(editorId)

            import matlab.internal.editor.*


            allData=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
            lineMaps=allData.values;
            for k=1:length(lineMaps)
                cellfun(@(figData)delete(figData),lineMaps{k}.values);
                remove(lineMaps{k},lineMaps{k}.keys);
            end


            EODataStore.removeEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
            EODataStore.clearEditorField(editorId,FigureManager.EDITOR_SNAPSHOT_APP_DATA_TAG);


            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                matlab.internal.editor.figure.FigurePoolManager.editorClosed(editorId);
            end
        end

        function figUid=getUidFromObject(hFig,editorId)
            import matlab.internal.editor.*
            figUid=FigureManager.safeGetAppData(hFig,FigureManager.FIGURE_UID,editorId);
        end

        function fig=getFigureFromUid(figUid,editorId)
            import matlab.internal.editor.*
            figureArray=getEditorFigures(editorId);
            fig=[];
            for k=1:length(figureArray)
                h=figureArray(k);
                if isequal(figUid,FigureManager.getUidFromObject(h,editorId))
                    fig=h;
                    return;
                end
            end
        end

        function attemptShowMenus(hFig)
            if~strcmp(hFig.MenuBarMode,'manual')
                set(hFig,'MenuBar','figure');
            end
            if~strcmp(hFig.ToolBarMode,'manual')
                set(hFig,'ToolBar','auto');
            end
        end

        function figureMarkerToAdd=preprocessEvent(editorId,event,previousEvent)
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.OutputUtilities;
            figureMarkerToAdd=[];

            if~isvalid(event.payload)
                return;
            end

            lineNumber=OutputUtilities.getLineNumberForExecutingFileFrame(event.stack,editorId);
            if lineNumber==-1
                return;
            end
            if isa(event.payload,'matlab.internal.language.VisualOutput')
                figureMarkerToAdd=FigureManager.preprocessVisualOutputEvent(editorId,event,previousEvent,lineNumber);
            else
                figureMarkerToAdd=FigureManager.preprocessFigureEvent(editorId,event,previousEvent,lineNumber);
            end
        end

        function addFigureOutputsAndStream(editorId,figureStructs)


            eventData=matlab.internal.editor.events.FigureReadyEventData(figureStructs,editorId);
            notify(matlab.internal.editor.FigureManager.getInstance,'FigureOutputReady',eventData);
            matlab.internal.editor.StreamOutputsSignal.forceStream();
        end
    end



    methods(Static,Access=public)

        function reassociateFigure(fig,editorId)



            import matlab.internal.editor.FigureManager;
            import matlab.internal.editor.figure.FigureUtils;

            oldHV=FigureManager.safeGetAppData(fig,FigureManager.EDITOR_HANDLE_VIS);
            if~isempty(oldHV)
                set(fig,'HandleVisibility',oldHV);
            end
            FigureManager.safeSetAppData(fig,FigureUtils.EDITOR_ID_APP_DATA_TAG,editorId);
        end

        function reattachListeners(fig,editorId)
            import matlab.internal.editor.*



            figureCreated(fig,editorId);
        end

        function snapshotAllFigures(editorId)
            import matlab.internal.editor.FigureManager;
            import matlab.internal.editor.EODataStore;

            allOutputs=getAllEditorOutputs(editorId);
            for value=allOutputs'
                hObject=value{1};

                lineNumberMapping=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_LINE_NUMBER_MAP_TAG);
                uid=FigureManager.getUidFromObject(hObject,editorId);
                if~lineNumberMapping.isKey(uid)||isempty(lineNumberMapping(uid))
                    continue;
                end

                FigureManager.saveSnapshot(editorId,uid,hObject,false,false);
            end
        end

        function snapshotPendingFigures(editorId)
            import matlab.internal.editor.FigureManager;
            import matlab.internal.editor.EODataStore;
            EODataStore.setEditorField(editorId,FigureManager.ISDEBUGGING,true);
            allOutputs=getAllEditorOutputs(editorId);
            for value=allOutputs'
                hObject=value{1};

                lineNumberMapping=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_LINE_NUMBER_MAP_TAG);
                uid=FigureManager.getUidFromObject(hObject,editorId);



                isDirty=FigureManager.getAppData(hObject,FigureManager.IS_DEBUG_FIGURE_DIRTY);

                if~lineNumberMapping.isKey(uid)||isempty(lineNumberMapping(uid))||(~isempty(isDirty)&&~isDirty)
                    continue;
                end
                FigureManager.setAppData(hObject,FigureManager.IS_DEBUG_FIGURE_DIRTY,false);

                FigureManager.saveSnapshot(editorId,uid,hObject,false,true);
            end

        end


        function setDrawnowSyncEnabled(editorId,isEnabled)
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.EODataStore


            figsmap=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
            figsmapValues=values(figsmap);
            for i=1:length(figsmapValues)
                figmap=figsmapValues{i};
                figmapValues=values(figmap);
                for j=1:length(figmapValues)
                    figProxy=figmapValues{j};

                    figProxy.setDrawnowSyncEnabled(isEnabled)
                end
            end
        end

        function setDrawnowSyncEnabledForFigureID(editorId,figUid,isEnabled)


            import matlab.internal.editor.*

            fig=FigureManager.getFigureFromUid(figUid,editorId);
            if~isempty(fig)
                FigureProxy.setDrawnowSyncEnabledOnCanvas(fig.getCanvas,isEnabled);
            end
        end

        function tookSnapshot=saveSnapshot(editorId,figUID,hObj,isFigureBeingCleared,isPending)
            import matlab.internal.editor.*

            tookSnapshot=false;

            figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>
            timerGuard=matlab.internal.language.TimerSuspender;%#ok<NASGU>

            if~forceSnapshot(hObj)&&(isExcludedByTag(hObj)||isEmbeddedWebFigure(hObj)||shouldNOTSnapshotUIFIGURE(hObj)||isObjectInternal(hObj))



                return
            end

            shouldRejectSnapshot=false;

            if isFigureBeingCleared
                currentRegionNumber=EODataStore.getEditorField(editorId,FigureManager.EDITOR_REGION_APP_DATA_TAG);
                firstRegion=FigureManager.safeGetAppData(hObj,FigureManager.EDITOR_FIRST_REGION_APP_DATA_TAG);
                if isempty(firstRegion)&&~isempty(currentRegionNumber)




                    shouldRejectSnapshot=true;
                else
                    shouldRejectSnapshot=(currentRegionNumber==firstRegion);
                end
            end

            if~isPending
                FigureManager.safeSetAppData(hObj,FigureManager.EDITOR_FIRST_REGION_APP_DATA_TAG,[]);
            end




            if shouldRejectSnapshot
                return;
            end

            figureStruct.figId=figUID;
            figureStruct.hFig=hObj;
            figureStruct.isPending=isPending;

            figureStruct.renderWarning='';

            lineNumberMapping=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_LINE_NUMBER_MAP_TAG);

            if lineNumberMapping.isKey(figUID)
                figureStruct.lineNumbers=lineNumberMapping(figUID);
                if isempty(figureStruct.lineNumbers)
                    return;
                end

                if~isPending
                    lineNumberMapping(figUID)=[];%#ok<NASGU>
                    FigureManager.safeSetAppData(hObj,FigureManager.FIGURE_UID,editorId,[]);
                end
            else
                return;
            end
            if isa(hObj,'matlab.internal.language.Snapshottable')

                figureStruct=handleSnapshottable(figureStruct,hObj,figUID,editorId,isPending);
                if figureStruct.snapshotTaken
                    tookSnapshot=true;
                    FigureManager.getInstance.notify('FigureOutputReady',matlab.internal.editor.events.FigureReadyEventData(figureStruct,editorId));
                end
            else

                try
                    if isprop(hObj,'EmbeddedUIFigure')&&hObj.EmbeddedUIFigure


                        figureStruct=showEmbeddedUIFigure(hObj,figUID,figureStruct.lineNumbers,editorId);
                    else

                        figureStruct=handleSerializedFigureSnapshot(figureStruct,hObj,figUID,editorId,isPending);
                    end
                catch ME
                    if strcmp(ME.identifier,'MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality')

                        return
                    end
                    rethrow(ME)
                end


                if figureStruct.snapshotTaken
                    tookSnapshot=true;




                    renderWarning=FigureManager.safeGetAppData(hObj,FigureManager.FIGURE_RENDER_WARNING,editorId);
                    if~isempty(renderWarning)
                        figureStruct.renderWarning=renderWarning;
                    end
                    FigureManager.safeSetAppData(hObj,FigureManager.FIGURE_RENDER_WARNING,editorId,[])



                    if matlab.graphics.interaction.internal.isAltTextForDocEnabled
                        figureStruct.alt=matlab.graphics.internal.FigureScreenReaderManager.updateFigureAltTextForDoc(hObj);
                        figureStruct.altIsJSON=true;
                    else
                        figureStruct.alt="";
                        figureStruct.altIsJSON=false;
                    end
                    figureStruct.alt=string(figureStruct.alt);


                    FigureManager.getInstance.notify('FigureOutputReady',matlab.internal.editor.events.FigureReadyEventData(figureStruct,editorId));




                    if FigureManager.allowAnimation
                        FigureManager.safeSetAppData(hObj,FigureManager.IS_SHOWING_ANIMATION,editorId,false);




                        if isprop(hObj,'ClientReadyListener')
                            message.unsubscribe(hObj.ClientReadyListener);
                            hObj.ClientReadyListener=[];
                        end
                        FigureProxy.setDrawnowSyncEnabledOnCanvas(hObj.getCanvas,false);
                    end
                end
            end
        end

        function editorFigure=isEditorFigure(figureHandle,editorId)
            editorFigure=matlab.internal.editor.figure.FigureUtils.isEditorFigure(figureHandle,editorId);
        end


        function rgbPixels=getCurrentFigurePixels(h)
            import matlab.internal.editor.*

            rgbPixels=[];
            if~isvalid(h)||h.BeingDeleted
                return
            end



disableCaptureListeners

            oldColor=get(h,'Color');
            oldVisMode=get(h,'VisibleMode');
            isSynchronous=EODataStore.getRootField('SynchronousOutput');
            isSynchronous=~isempty(isSynchronous)&&isSynchronous;
            isColorDefault=isequal(oldColor,get(0,'DefaultFigureColor'));
            if isSynchronous&&isColorDefault&&strcmp(h.ColorMode,'auto')



                h.Color=[1,1,1];
            end

            isGUI=isHandleInvisibleFigure(h);




            if strcmp(h.ColorMode,'auto')
                set(h,'Color_I',get(0,'DefaultFigureColor'));
            end




            if isprop(h,'InternalEditor_Data')
                internalFigureDataListeners=h.InternalEditor_Data.listener;
                internalFigureDataListenersEnabledState=false(size(internalFigureDataListeners));
                for k=1:length(internalFigureDataListeners)
                    if isvalid(internalFigureDataListeners(k))
                        internalFigureDataListenersEnabledState(k)=internalFigureDataListeners(k).Enabled;
                        internalFigureDataListeners(k).Enabled=false;
                    end
                end
            else
                internalFigureDataListeners=[];
            end


            matlab.internal.editor.figure.FigureAnimationsSynchronizer.synchronizeScopeFigure(h);

            pixels=mygetframe(h,isGUI);



            for k=1:length(internalFigureDataListeners)
                if internalFigureDataListenersEnabledState(k)
                    internalFigureDataListeners(k).Enabled=true;
                end
            end


            if isvalid(h)
                set(h,'VisibleMode',oldVisMode)


                if strcmp(h.ColorMode,'auto')
                    set(h,'Color_I',get(0,'DefaultFigureColor'));
                else
                    set(h,'Color',oldColor)
                end
            end

            if EODataStore.getRootField(FigureManager.CAPTURING_FIGURES)
enableCaptureListeners
            end

            if~isempty(pixels.cdata)
                rgbPixels=pixels.cdata;
            end
        end

        function pixelsCData=getVRCurrentFigurePixels(hFig)



            import matlab.internal.editor.FigureManager
            pixelsCData=snap(vr.figure.fromHGFigure(hFig));
        end



        function value=safeGetAppData(h,tag,varargin)



            if isa(h,'matlab.internal.language.VisualOutput')
                if length(varargin)==1
                    namespace=varargin{1};
                else
                    namespace=matlab.internal.editor.FigureManager.EDITOR_NAMESPACE;
                end
                value=h.getVisualOutputData(namespace,tag);
            else
                value=matlab.internal.editor.figure.FigureUtils.safeGetAppData(h,tag,varargin{:});
            end
        end

        function safeSetAppData(h,tag,varargin)



            if isa(h,'matlab.internal.language.VisualOutput')
                if length(varargin)==2
                    namespace=varargin{1};
                    value=varargin{2};
                else
                    namespace=matlab.internal.editor.FigureManager.EDITOR_NAMESPACE;
                    value=varargin{1};
                end
                h.setVisualOutputData(namespace,tag,value);
            else
                matlab.internal.editor.figure.FigureUtils.safeSetAppData(h,tag,varargin{:});
            end
        end

        function value=getAppData(h,tag)
            if isa(h,'matlab.internal.language.VisualOutput')
                value=h.getVisualOutputData(matlab.internal.editor.FigureManager.EDITOR_NAMESPACE,tag);
            else
                value=getappdata(h,tag);
            end
        end

        function setAppData(h,tag,value)
            if isa(h,'matlab.internal.language.VisualOutput')
                h.setVisualOutputData(matlab.internal.editor.FigureManager.EDITOR_NAMESPACE,tag,value);
            else
                setappdata(h,tag,value);
            end
        end

        function clearVisualOutputData(editorId)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.FigureManager

            visualOutputs=getEditorVisualOutputs(editorId);
            for visualOutput=visualOutputs'
                hVisualOutput=visualOutput{1};



                if~isvalid(hVisualOutput)
                    continue;
                end


                hVisualOutput.clearVisualOutputData(editorId);


                hVisualOutput.clearVisualOutputData(FigureManager.EDITOR_NAMESPACE);
            end
            EODataStore.removeEditorSubMap(editorId,FigureManager.EDITOR_STORE_VISUAL_OUTPUTS_MAP_TAG);
        end

        function figureMarkerToAdd=preprocessFigureEvent(editorId,figureEvent,previousEvent,lineNumber)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.figure.*;

            figureMarkerToAdd=[];

            hFig=figureEvent.payload;
            if FigureUtils.isEditorSnapshotFigure(hFig)
                return
            end

            figureMarkerToAdd=FigureManager.processCommonEvent(editorId,figureEvent,previousEvent,lineNumber);

            firstRegion=FigureManager.safeGetAppData(hFig,FigureManager.EDITOR_FIRST_REGION_APP_DATA_TAG);











            if isempty(firstRegion)&&(~isempty(hFig.Children)||~isempty(findobjinternal(hFig,'-depth',1,'-isa','matlab.graphics.primitive.canvas.Canvas')))
                currentRegionNumber=EODataStore.getEditorField(editorId,FigureManager.EDITOR_REGION_APP_DATA_TAG);
                FigureManager.safeSetAppData(hFig,FigureManager.EDITOR_FIRST_REGION_APP_DATA_TAG,currentRegionNumber);
            end
        end

        function figureMarkerToAdd=preprocessVisualOutputEvent(editorId,visualOutputEvent,previousEvent,lineNumber)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.FigureManager

            hVisualOutput=visualOutputEvent.payload;






            owningEditorId=hVisualOutput.getVisualOutputData(FigureManager.PERSISTENT_EDITOR_NAMESPACE,FigureManager.OWNING_EDITOR_ID_KEY);
            if isempty(owningEditorId)
                hVisualOutput.setVisualOutputData(FigureManager.PERSISTENT_EDITOR_NAMESPACE,FigureManager.OWNING_EDITOR_ID_KEY,editorId);
            elseif~strcmp(owningEditorId,editorId)

                figureMarkerToAdd=[];
                return
            end




            map=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_VISUAL_OUTPUTS_MAP_TAG);
            uid=hVisualOutput.getVisualOutputUid();
            if~isKey(map,uid)
                map(uid)=hVisualOutput;
            end

            figureMarkerToAdd=FigureManager.processCommonEvent(editorId,visualOutputEvent,previousEvent,lineNumber);
        end

        function figureMarkerToAdd=processCommonEvent(editorId,event,previousEvent,lineNumber)

            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.FigureManager

            figureMarkerToAdd=[];


            lineNumberMapping=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_LINE_NUMBER_MAP_TAG);

            hObject=event.payload;


            uid=FigureManager.getUidFromObject(hObject,editorId);
            if isempty(uid)
                uid=matlab.lang.internal.uuid;
                FigureManager.safeSetAppData(hObject,FigureManager.FIGURE_UID,editorId,uid);
            end


            if~lineNumberMapping.isKey(uid)

                lineNumberMapping(uid)=[];
            end


            existingLines=lineNumberMapping(uid);
            isNewLine=isempty(find(existingLines==lineNumber,1));
            if isNewLine
                existingLines(end+1)=lineNumber;
                lineNumberMapping(uid)=existingLines;%#ok<NASGU>
            end





            FigureManager.setAppData(hObject,FigureManager.IS_DEBUG_FIGURE_DIRTY,true);



            if isempty(previousEvent)||isNewLine||~strcmp(previousEvent.type,'figure')||~isequal(previousEvent.payload,hObject)
                figureMarkerToAdd=struct('type','figure.placeholder','stack',event.stack,'payload',uid);
            end
        end
    end
end

function figureProxy=saveSnapshottableData(hSnapshottable,lineNumber,imageData,editorId,uid,isPending)
    import matlab.internal.editor.*
    allData=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
    if~isKey(allData,num2str(lineNumber))
        allData(num2str(lineNumber))=containers.Map;
    end
    figData=allData(num2str(lineNumber));



    figureProxy=FigureProxy(uid,lineNumber,true);




    figData(uid)=figureProxy;%#ok<NASGU>

    if isPending
        FigureManager.safeSetAppData(hSnapshottable,FigureManager.PENDING_FIGURE_PROXY,figureProxy);
    else
        FigureManager.safeSetAppData(hSnapshottable,FigureManager.PENDING_FIGURE_PROXY,[]);
    end

    figureManager=FigureManager.getInstance;
    figureManager.notify('FigureSnapshotStart',matlab.internal.editor.figure.FigureManagerEventData(editorId,figureProxy.FigureId));

    figureProxy.createImageFigureSnapshot(imageData);
    figureProxy.ServerID=uid;


    FigureProxy.setGUIClientNotificationListener(@(eventData)figureManager.notify('FigureSnapshotEnd',eventData));
end


function figureProxy=saveFigureData(fig,lineNumber,editorId,uid,isPending)
    import matlab.internal.editor.*
    allData=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
    if~isKey(allData,num2str(lineNumber))
        allData(num2str(lineNumber))=containers.Map;
    end
    figData=allData(num2str(lineNumber));
    hFig=handle(fig);










    isVisible=strcmp(fig.Visible,'on');



    if isVisible
        matlab.ui.internal.prepareFigureFor(hFig,mfilename('fullpath'));
    end



    isSynchronous=EODataStore.getRootField('SynchronousOutput');
    isSynchronous=~isempty(isSynchronous)&&isSynchronous;
    isGUI=checkIfGUI(hFig,isVisible)||isSynchronous;


    oldFigureProxy=FigureManager.safeGetAppData(fig,FigureManager.PENDING_FIGURE_PROXY);
    if~isempty(oldFigureProxy)&&isvalid(oldFigureProxy)
        delete(oldFigureProxy);
    end
    figureProxy=FigureProxy(uid,lineNumber,isGUI);




    figData(uid)=figureProxy;%#ok<NASGU>

    if isPending
        FigureManager.safeSetAppData(fig,FigureManager.PENDING_FIGURE_PROXY,figureProxy);
    else
        FigureManager.safeSetAppData(fig,FigureManager.PENDING_FIGURE_PROXY,[]);
    end



    figureManager=FigureManager.getInstance;
    if~isGUI
        try
            figureProxy.createWebFigureSnapshot(fig);
        catch me
            if strcmp(me.identifier,'MATLAB:handle_graphics:exceptions:UserBreak')
                return
            else
                rethrow(me);
            end
        end
    elseif strcmp(fig.ColorMode,'auto')
        fig.Color_I=get(groot,'DefaultFigureColor');
    end

    if~isVisible
        [modeName,modeStateData]=ModeManager.getModeFromFigure(hFig);
        if~isempty(modeName)
            figureProxy.setServerMode(hFig,lineNumber,modeName,modeStateData);
        end
    end








    if isGUI
        if isSL3D(hFig)






            pixelArray=FigureManager.getVRCurrentFigurePixels(hFig);
        else
            pixelArray=FigureManager.getCurrentFigurePixels(hFig);
        end

        figureProxy.createImageFigureSnapshot(pixelArray);


        FigureProxy.setGUIClientNotificationListener(@(eventData)figureManager.notify('FigureSnapshotEnd',eventData));
    end






    if isGUI

        eventData=matlab.internal.editor.figure.FigureManagerEventData(editorId,figureProxy.FigureId,hFig);
    else
        eventData=matlab.internal.editor.figure.FigureManagerEventData(editorId,figureProxy.FigureId,figureProxy.DeserializedFigure);
    end
    figureManager.notify('FigureSnapshotStart',eventData);


    if~isGUI

        eventData1=matlab.internal.editor.figure.FigureManagerEventData(editorId,figureProxy.FigureId,figureProxy.DeserializedFigure);
        addlistener(figureProxy,'FigureSnapshotDone',@(~,~)figureManager.notify('FigureSnapshotEnd',eventData1));
    end
end

function isGUI=checkIfGUI(hFig,isVisible)
    import matlab.internal.editor.*
    isGUI=(isVisible||isHandleInvisibleFigure(hFig)||...
    (isprop(hFig,'InternalEditor_Data')&&hFig.InternalEditor_Data.IsGUI));
end

function ret=cannotAnimateFigure(hFig)
    ret=false;
    if isa(hFig.getCanvas,'matlab.graphics.primitive.canvas.JavaCanvas')||...
        checkIfGUI(hFig,false)
        ret=true;
    end
end

function setupGCFforRuntimeDisplay(fig,canvas,listener,editorId)


    import matlab.internal.editor.FigureManager;
    import matlab.internal.editor.figure.FigureUtils;
    if~strcmp(fig.Tag,FigureUtils.EDITOR_FIGURE_SNAPSHOT_TAG)
        canvas.ServerSideRendering='on';
        canvas.ErrorCallback=@(~,evt)localErrorCallback(evt,editorId,fig);
        if strcmp(fig.ColorMode,'auto')
            fig.Color_I=[1,1,1];
        end

        listener(end+1)=addlistener(fig.getCanvas,'ObjectChildAdded',@(~,d)canvasChildAdded(d.Child));
    end
end

function enableCaptureListeners
    import matlab.internal.editor.*
    listeners=EODataStore.getRootField(FigureManager.EDITOR_LISTEN_APP_DATA_TAG);
    if isempty(listeners)
        classObj=?matlab.ui.Figure;
        callback=@(~,ev)figureCreated(ev.Instance);
        listeners=addlistener(classObj,'InstanceCreated',callback);
        EODataStore.setRootField(FigureManager.EDITOR_LISTEN_APP_DATA_TAG,listeners);
    end
    listeners.Enabled=true;
end

function setPseudoRoot(editorId)
    import matlab.internal.editor.*




    s=settings;
    if s.matlab.ui.figure.ShowInUIContainer.ActiveValue
        s.matlab.ui.figure.ShowInUIContainer.TemporaryValue=false;
    end



    figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU> 



    externalHandleVisibleFigures=findobj(groot,'type','figure','-depth',1);

    EODataStore.setRootField(FigureManager.EDITOR_ROOT_APP_DATA_TAG,editorId)
    figs=myallchild;
    if~isempty(figs)
        setappdata(groot,FigureManager.EDITOR_HAS_GRAPHICS,1)
    end
    isEditor=FigureManager.isEditorFigure(figs,editorId);
    EODataStore.setEditorField(editorId,FigureManager.STORE_FIGURE_VISIBLE,get(0,'DefaultFigureVisible'));
    EODataStore.setEditorField(editorId,FigureManager.STORE_FIGURE_MENUBAR,get(0,'DefaultFigureMenubar'));
    EODataStore.setEditorField(editorId,FigureManager.STORE_FIGURE_TOOLBAR,get(0,'DefaultFigureToolbar'));
    set(0,'DefaultFigureVisible','off');
    set(0,'DefaultFigureToolbar','none');
    set(0,'DefaultFigureMenubar','none');
    edFigs=figs(isEditor);
    for k=1:length(edFigs)
        oldHV=FigureManager.safeGetAppData(edFigs(k),FigureManager.EDITOR_HANDLE_VIS);
        if~isempty(oldHV)
            set(edFigs(k),'HandleVisibility_I',oldHV);
        end
    end
    curfig=get(groot,'CurrentFigure');

    if~isempty(curfig)
        if~FigureManager.isEditorFigure(curfig,editorId)

            previousCurrentFigure=EODataStore.getEditorField(editorId,FigureManager.EDITOR_CURRENT_FIGURE);
            if isempty(previousCurrentFigure)||~isvalid(previousCurrentFigure)||...
                ~FigureManager.isEditorFigure(previousCurrentFigure,editorId)





                set(groot,'CurrentFigure',[]);








                if~isempty(externalHandleVisibleFigures)
                    EODataStore.setRootField(FigureManager.EXTERNAL_FIGURES,externalHandleVisibleFigures);
                    for k=1:length(externalHandleVisibleFigures)
                        externalHandleVisibleFigures(k).HandleVisibility_I="off";
                    end
                end
            else

                set(groot,'CurrentFigure',previousCurrentFigure);
                EODataStore.setEditorField(editorId,FigureManager.EDITOR_CURRENT_FIGURE,[]);
            end
        else


            isEditorExternal=FigureManager.isEditorFigure(externalHandleVisibleFigures,editorId);
            externalHandleVisibleEditorFigures=externalHandleVisibleFigures(~isEditorExternal);
            EODataStore.setRootField(FigureManager.EXTERNAL_FIGURES,externalHandleVisibleEditorFigures);
            for k=1:length(externalHandleVisibleEditorFigures)
                externalHandleVisibleEditorFigures(k).HandleVisibility_I="off";
            end
        end
    end
end

function clearPseudoRoot(editorId)
    import matlab.internal.editor.*



    figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU> 




    s=settings;
    if hasTemporaryValue(s.matlab.ui.figure.ShowInUIContainer)
        s.matlab.ui.figure.ShowInUIContainer.TemporaryValue=true;
    end

    oldId=EODataStore.getRootField(FigureManager.EDITOR_ROOT_APP_DATA_TAG);
    EODataStore.setRootField(FigureManager.EDITOR_ROOT_APP_DATA_TAG,'');
    currentFigure=get(groot,'CurrentFigure');
    if isempty(currentFigure)||~isvalid(currentFigure)
        currentFigure=[];
    end

    EODataStore.setEditorField(editorId,FigureManager.EDITOR_CURRENT_FIGURE,currentFigure);
    figs=myallchild;
    isEditor=FigureManager.isEditorFigure(figs,oldId);
    edFigs=figs(isEditor);
    for k=1:length(edFigs)
        if strcmp(edFigs(k).Visible,'off')
            hv=get(edFigs(k),'HandleVisibility');
            if strcmp(hv,'on')
                FigureManager.safeSetAppData(edFigs(k),FigureManager.EDITOR_HANDLE_VIS,hv);
                set(edFigs(k),'HandleVisibility','off');
            end
        end
    end
    storeFigureVisible=EODataStore.getEditorField(editorId,FigureManager.STORE_FIGURE_VISIBLE);
    storeFigureMenubar=EODataStore.getEditorField(editorId,FigureManager.STORE_FIGURE_MENUBAR);
    storeFigureToolbar=EODataStore.getEditorField(editorId,FigureManager.STORE_FIGURE_TOOLBAR);
    set(0,'DefaultFigureVisible',storeFigureVisible);
    set(0,'DefaultFigureMenuBar',storeFigureMenubar);
    set(0,'DefaultFigureToolBar',storeFigureToolbar);



    externalHandleVisibleFigures=EODataStore.getRootField(FigureManager.EXTERNAL_FIGURES);
    if~isempty(externalHandleVisibleFigures)
        for k=1:length(externalHandleVisibleFigures)
            if isvalid(externalHandleVisibleFigures(k))
                externalHandleVisibleFigures(k).HandleVisibility_I="on";
            end
        end
        EODataStore.setRootField(FigureManager.EXTERNAL_FIGURES,[]);
    end
end

function figureCreated(fig,editorId)

    import matlab.internal.editor.*;
    import matlab.internal.editor.figure.FigureUtils;

    setappdata(groot,FigureManager.EDITOR_HAS_GRAPHICS,1)

    figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>
    timerGuard=matlab.internal.language.TimerSuspender;%#ok<NASGU>

    builtin('_StructuredFiguresResetFigure',fig);

    if~isJavaFigure(fig)&&isEmbeddedMorphableFigure(fig)&&~isprop(fig,'LiveEditorRunTimeFigure')
        p=addprop(fig,'LiveEditorRunTimeFigure');
        p.Transient=true;
        p.Hidden=true;
        fig.LiveEditorRunTimeFigure=true;





        if~isempty(fig.Name)
            matlab.ui.internal.prepareFigureFor(fig,mfilename('fullpath'));
        end
    end

    if nargin==1
        editorId=EODataStore.getRootField(FigureManager.EDITOR_ROOT_APP_DATA_TAG);
    end

    if~isprop(fig,FigureManager.InternalEditor_Data)
        listener=addlistener(fig,'ObjectChildAdded',@(e,d)figureChildAdded(e,d,editorId));
        listener(2)=addlistener(fig,'WindowStyle','PostSet',@windowStyleChanged);
        listener(3)=addlistener(fig,'Visible','PostSet',@visibleChanged);



        data.listener=listener;
        data.IsGUI=false;



        addHiddenProp(fig,FigureManager.InternalEditor_Data);
        fig.InternalEditor_Data=data;


        FigureManager.safeSetAppData(fig,FigureUtils.EDITOR_ID_APP_DATA_TAG,editorId);


        if strcmp(get(fig,'Visible'),'on')&&strcmp(get(fig,'VisibleMode'),'manual')
            ev=struct();
            ev.AffectedObject=fig;
            visibleChanged([],ev);
        end
    end




    if isUIFigure(fig)&&strcmp(get(fig,'Visible'),'off')&&strcmp(get(fig,'VisibleMode'),'auto')
        fig.Visible_I='on';
        fig.VisibleMode='auto';
    end

end

function disableCaptureListeners
    import matlab.internal.editor.*
    listeners=EODataStore.getRootField(FigureManager.EDITOR_LISTEN_APP_DATA_TAG);

    if~isempty(listeners)
        listeners.Enabled=false;
    end
end

function figs=getAllFigures
    figs=flipud(myallchild);


    figs=findall(figs,'flat','type','figure','-not',{'Tag',matlab.internal.editor.figure.FigureUtils.EDITOR_FIGURE_SNAPSHOT_TAG,'-or','Tag',matlab.internal.editor.figure.FigureUtils.EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG});

end

function figs=getEditorFigures(editorId)
    figs=getAllFigures;
    ok=matlab.internal.editor.FigureManager.isEditorFigure(figs,editorId);
    figs(~ok)=[];
end

function outputs=getAllEditorOutputs(editorId)

    allEditorFigures=getEditorFigures(editorId);
    visualOutputs=getEditorVisualOutputs(editorId);
    outputs=[visualOutputs;num2cell(allEditorFigures)];
end


function outputs=getEditorVisualOutputs(editorId)

    import matlab.internal.editor.EODataStore
    import matlab.internal.editor.FigureManager

    visualOutputsMap=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_VISUAL_OUTPUTS_MAP_TAG);
    outputs=visualOutputsMap.values';
end

function snapshotAndResetOnFigureChangeEvent(h,editorId)


    import matlab.internal.editor.FigureManager
    import matlab.internal.editor.StreamOutputsSignal;


    StreamOutputsSignal.stream();

    figUid=FigureManager.getUidFromObject(h,editorId);


    if isempty(figUid)
        figUid=char(matlab.lang.internal.uuid);
    end




    tookSnapshot=FigureManager.saveSnapshot(editorId,figUid,h,true,false);

    if tookSnapshot










        FigureManager.safeSetAppData(h,FigureManager.FIGURE_UID,editorId,'');
    end
end

function figureStruct=handleSerializedFigureSnapshot(figureStruct,hFig,figId,editorId,isPending)



    import matlab.internal.editor.figure.FigureDataTransporter;
    import matlab.internal.editor.FigureManager;
    hFig=handle(hFig);

    if isfield(figureStruct,'snapshotTaken')

        return
    end

    figureStruct.snapshotTaken=false;

    if isempty(hFig.Children)&&...
        ~hasHandleInvisibleChildren(hFig)&&~isUIFigure(hFig)

        return
    end

    if isInvisibleFigure(hFig)

        return
    end

    pixpos=hgconvertunits(hFig,hFig.Position,hFig.Units,'pixels',hFig.Parent);
    if prod(pixpos(3:4))>1

        figureStruct.snapshotTaken=true;

        figureStruct.figureSize=pixpos(3:end);
        figureProxy=saveFigureData(hFig,figureStruct.lineNumbers(end),editorId,figId,isPending);


        figureStruct.useEmbedded=matlab.internal.editor.FigureManager.useEmbeddedFigures;




        if~figureProxy.ServerSnapshotCreated||~isgraphics(hFig)||hFig.BeingDeleted
            figureStruct.snapshotTaken=false;
            return
        end
        figureStruct.serverID=figureProxy.ServerID;

        if~isempty(figureProxy.ImageData)


            imageData=figureProxy.ImageData;

            figureStruct.figureImage=matlab.internal.editor.figure.Snapshot(imageData);
            figureStruct.figureData=[];
        else

            figureStruct.figureImage=[];







            if~isempty(figureProxy.ModeManager)



                [figureStruct.figureData,figureStruct.mData]=FigureDataTransporter.getFigureMetaData(hFig,[],figureProxy.ModeManager.Mode);
            else
                [figureStruct.figureData,figureStruct.mData]=FigureDataTransporter.getFigureMetaData(hFig);
            end
        end
    end
end



function snapshottableStruct=handleSnapshottable(snapshottableStruct,hSnapshottable,snapshottableId,editorId,isPending)

    hSnapshottable=handle(hSnapshottable);
    if isfield(snapshottableStruct,'snapshotTaken')

        return
    end

    snapshottableStruct.snapshotTaken=false;

    imageData=hSnapshottable.getImageDataForSnapshot();
    [rows,columns,~]=size(imageData);
    if rows*columns>1

        figureProxy=saveSnapshottableData(hSnapshottable,snapshottableStruct.lineNumbers(end),imageData,editorId,snapshottableId,isPending);
        snapshottableStruct.snapshotTaken=true;



        snapshottableStruct.figureImage=matlab.internal.editor.figure.Snapshot(figureProxy.ImageData);

        snapshottableStruct.figureData=[];
        snapshottableStruct.serverID=figureProxy.ServerID;
        snapshottableStruct.figureSize=[columns,rows];
    end
end

function postUpdateFcn(hFig,editorId)









    if cannotAnimateFigure(hFig)
        return;
    end





    import matlab.internal.editor.*;

    figUid=FigureManager.getUidFromObject(hFig,editorId);
    lineNumberMap=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_LINE_NUMBER_MAP_TAG);






    idsMap=EODataStore.getEditorField(editorId,FigureManager.ANIMATED_FIGURE_UID);
    if~isempty(idsMap)
        if isKey(idsMap,figUid)
            countOfFrames=idsMap(figUid);
            idsMap(figUid)=countOfFrames+1;
            EODataStore.setEditorField(editorId,FigureManager.ANIMATED_FIGURE_UID,idsMap);
        end
    end




    pendingFigureProxy=FigureManager.safeGetAppData(hFig,FigureManager.PENDING_FIGURE_PROXY);
    if~isempty(pendingFigureProxy)&&EODataStore.getEditorField(editorId,FigureManager.ISDEBUGGING)
        return;
    end



    lineNumbers=[];
    if~isempty(figUid)&&lineNumberMap.isKey(figUid)
        lineNumbers=lineNumberMap(figUid);
    else










        StreamOutputsSignal.stream();
        figUid=FigureManager.getUidFromObject(hFig,editorId);
        if lineNumberMap.isKey(figUid)
            lineNumbers=lineNumberMap(figUid);
        end
    end

    if~isempty(lineNumbers)
        showWorkingFigure(editorId,hFig,lineNumbers);
    end
end



function figureStruct=showEmbeddedUIFigure(hFig,hFigID,lineNumbers,editorId)


    import matlab.internal.editor.*
    import matlab.internal.editor.figure.*

    allData=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
    if~isKey(allData,num2str(lineNumbers(end)))
        allData(num2str(lineNumbers(end)))=containers.Map;
    end
    figData=allData(num2str(lineNumbers(end)));


    figProxy=matlab.internal.editor.figure.EmbeddedUiFigureFigureProxy(hFigID,lineNumbers(end));




    figData(hFigID)=figProxy;%#ok<NASGU>




    figProxy.createWebFigureSnapshot(hFig);

    figureStruct=figProxy.showEmbeddedUIFigure(editorId);

end

function showWorkingFigure(editorId,hFig,lineNumber)


    if isempty(hFig)||~isvalid(hFig)||isempty(hFig.Children)||...
        (~isempty(FigureManager.safeGetAppData(hFig,FigureManager.IS_SHOWING_ANIMATION,editorId))&&...
        FigureManager.safeGetAppData(hFig,FigureManager.IS_SHOWING_ANIMATION,editorId))
        return
    end

    import matlab.internal.editor.*
    import matlab.internal.editor.figure.*
    figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>


    figUid=FigureManager.getUidFromObject(hFig,editorId);


    idsMap=EODataStore.getEditorField(editorId,FigureManager.ANIMATED_FIGURE_UID);
    if isempty(idsMap)
        idsMap=containers.Map();
    end
    if~isKey(idsMap,figUid)
        idsMap(figUid)=1;
        EODataStore.setEditorField(editorId,FigureManager.ANIMATED_FIGURE_UID,idsMap);
    end

    figureStruct.figId=figUid;
    figureStruct.hFig=hFig;
    figureStruct.isPending=true;
    figureStruct.alt="";
    figureStruct.altIsJSON=false;

    figureStruct.lineNumbers=lineNumber;
    FigureManager.safeSetAppData(hFig,FigureManager.IS_SHOWING_ANIMATION,editorId,true);

    pixpos=hgconvertunits(hFig,hFig.Position,hFig.Units,'pixels',hFig.Parent);
    figureStruct.figureSize=pixpos(3:end);
    figureStruct.serverID=hFig.getCanvas.ServerID;


    figureStruct.figureImage=[];





    if~isprop(hFig,'ClientReadyListener')
        propClientReadyListener=addprop(hFig,'ClientReadyListener');
        propClientReadyListener.Hidden=true;
        propClientReadyListener.Transient=true;
    end
    if isempty(hFig.ClientReadyListener)
        hFig.ClientReadyListener=message.subscribe(['/graphics/',figureStruct.serverID,'/event'],@(evd)animatedFigureDOMNodeAdded(evd,hFig));
    end




    figureData=matlab.internal.editor.figure.FigureData;

    figureStruct.figureData=figureData;
    FigureManager.addFigureOutputsAndStream(editorId,figureStruct);
end


function ch=myallchild

    h=groot;
    origval=h.ShowHiddenHandles;
    h.ShowHiddenHandles='on';
    tmp=onCleanup(@()restoreHidden(h,origval));
    ch=findobjinternal(h,'type','figure','-depth',1);
end

function restoreHidden(h,val)
    h.ShowHiddenHandles=val;
end

function invis=invisibleFigures(figs)
    invis=figs(strcmp(get(figs,'Visible'),'off'));
end

function isInvisible=isInvisibleFigure(hFig)

    isInvisible=strcmp(get(hFig,'Visible'),'off')&&strcmp(get(hFig,'VisibleMode'),'manual');
end

function cachedFigs=cachedFigures(figs)
    import matlab.internal.editor.figure.FigureUtils;
    cachedFigs=figs(cellfun(@(tag)any(strcmp(tag,{FigureUtils.EDITOR_FIGURE_SNAPSHOT_TAG,FigureUtils.EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG})),get(figs,{'Tag'})));
end

function addHiddenProp(obj,name)
    prop=addprop(obj,name);
    prop.Hidden=true;
    prop.Transient=true;
end


function canvasChildAdded(obj)
    isaxes=isa(obj,'matlab.graphics.axis.AbstractAxes');






    if isaxes
        disableDefaultInteractivity(obj);
    end
end

function figureChildAdded(obj,ev,editorId)
    import matlab.internal.editor.*




    if isgraphics(obj,'figure')
        hFig=obj;
    else
        hFig=ancestor(obj,'figure');
    end

    if isequal(ev.Child,findobjinternal(hFig,'-isa','matlab.graphics.primitive.canvas.Canvas'))
        isJavaFigureView=isJavaFigure(hFig);
        if~isJavaFigureView&&isEmbeddedMorphableFigure(hFig)&&strcmp(hFig.VisibleMode,'auto')&&strcmp(hFig.Visible,'off')







            canvas=hFig.getCanvas;



            if~matlab.graphics.interaction.internal.isPublishingTest()
                addlistener(canvas,'PostUpdate',@(e,d)postUpdateFcn(hFig,editorId));
            end




            setupGCFforRuntimeDisplay(hFig,canvas,hFig.InternalEditor_Data.listener,editorId);
        elseif isJavaFigureView




            canvas=hFig.getCanvas;

            canvas.ErrorCallback=@(~,evt)localErrorCallback(evt,editorId,hFig);
        end
    end

    okUI=isa(ev.Child,'matlab.ui.container.ContextMenu')||...
    isa(ev.Child,'matlab.ui.container.Menu')||...
    isa(ev.Child,'matlab.ui.container.Toolbar');
    if~okUI&&strcmp(obj.Visible,'off')


        if~isequal(ev.Child,findobjinternal(hFig,'-depth',1,'-isa','matlab.graphics.primitive.canvas.Canvas'))||...
            isUIFigure(hFig)
            if strcmp(obj.VisibleMode,'auto')
                showAndStopListening(obj);
            else







                matlab.ui.internal.prepareFigureFor(hFig,mfilename('fullpath'));
            end
        end
    elseif okUI
        matlab.ui.internal.prepareFigureFor(hFig,mfilename('fullpath'));
    end
end

function showAndStopListening(fig)
    import matlab.internal.editor.FigureManager





    runtimeFigureProp=findprop(fig,'LiveEditorRunTimeFigure');
    if~isempty(runtimeFigureProp)
        delete(runtimeFigureProp)
    end

    fig.Visible='on';
    fig.InternalEditor_Data.IsGUI=true;
    FigureManager.attemptShowMenus(fig);

    data=fig.InternalEditor_Data;
    delete(data.listener)
end

function windowStyleChanged(~,ev)
    hFig=ev.AffectedObject;
    if~strcmp(hFig.WindowStyle,'normal')&&strcmp(hFig.Visible,'off')&&strcmp(hFig.VisibleMode,'auto')
        showAndStopListening(hFig);
    end
end

function visibleChanged(~,ev)
    import matlab.internal.editor.FigureManager
    hFig=ev.AffectedObject;
    if strcmp(hFig.Visible,'on')
        FigureManager.attemptShowMenus(hFig);
    end
end

function has=hasContentInCurrentAxes(fig,context)







    ax=fig.CurrentAxes;

    has=false;
    if isChartOrAxesWithChildren(ax)


        isInTiledLayout=ancestor(ax,'matlab.graphics.layout.TiledChartLayout','node');
        if~isempty(isInTiledLayout)
            has=strcmp(context,'delete');
            return
        end
        subplotgrid=getappdata(fig,'SubplotGrid');
        has=isempty(subplotgrid)||~any(ax==subplotgrid(:))||strcmp(context,'delete');

    end
end

function has=hasContentInCurrentFigure(fig,context)








    ax=findall(fig,'-isa','matlab.graphics.axis.AbstractAxes','-or','-isa','matlab.graphics.chart.Chart');
    has=false;
    subplotgrid=getappdata(fig,'SubplotGrid');
    deleteContext=strcmp(context,'delete');
    for k=1:length(ax)
        if isChartOrAxesWithChildren(ax(k))
            has=deleteContext||isempty(subplotgrid)||~any(ax==subplotgrid(:));
            if has
                return
            end
        end
    end
end

function res=isChartOrAxesWithChildren(ax)




    res=~isempty(ax)&&(~isprop(ax,'Children')||...
    ~isempty(ax.Children));
end

function result=isSL3D(fig)


    result=~isempty(license('inuse','virtual_reality_toolbox'))&&...
    ~isempty(which('vr.figure'))&&...
    ~isempty(vr.figure.fromHGFigure(fig));
end

function result=isJavaFigure(hFig)

    result=~isempty(matlab.graphics.internal.getFigureJavaFrame(hFig));
end

function result=isUIFigure(hFig)








    result=~isJavaFigure(hFig)&&isWebFigureType(hFig,'UIFigure');
end

function result=isEmbeddedWebFigure(hFig)

    result=~isJavaFigure(hFig)&&isWebFigureType(hFig,'EmbeddedWebFigure');
end

function result=isEmbeddedMorphableFigure(hFig)

    result=isWebFigureType(hFig,'EmbeddedMorphableFigure')&&~isJavaFigure(hFig);
end

function isGUI=isHandleInvisibleFigure(h)
    isGUI=(~strcmp(h.HandleVisibility,'on')&&~any(strcmp(h.Tag,{matlab.internal.editor.figure.FigureUtils.EDITOR_FIGURE_SNAPSHOT_TAG,matlab.internal.editor.figure.FigureUtils.EDITOR_EMBEDDED_FIGURE_SNAPSHOT_TAG})));
end


function hasHandleInvisible=hasHandleInvisibleChildren(hFig)
    invisibleChildren=findall(hFig,'-depth',1,'HandleVisibility','off',...
    {'-isa','matlab.graphics.axis.AbstractAxes','-or',...
    '-isa','matlab.graphics.chart.Chart'});
    hasHandleInvisible=~isempty(invisibleChildren);
end

function pixels=mygetframe(h,isGUI)

    try
        if isGUI&&strcmp(h.Visible,'on')&&~strcmp(h.WindowStyle,'docked')
            pixels=matlab.graphics.internal.getframeWithDecorations(h);
        else
            pixels=getframe(h);
        end
    catch

        pixels.cdata=[];
    end
end

function result=isExcludedByTag(fig)

    specialTags={
    'SFCHART',...
    'DEFAULT_SFCHART',...
    'SFEXPLR',...
    'SF_DEBUGGER',...
    'SF_SAFEHOUSE',...
    'SF_SNR',...
'SIMULINK_SIMSCOPE_FIGURE'
    };
    result=containsTag(fig,specialTags);
end


function ret=forceSnapshot(fig)


    specialTags={'filtervisualizationtool'};
    ret=matlab.graphics.interaction.internal.isPublishingTest&&containsTag(fig,specialTags);
end


function result=containsTag(fig,tags)
    tag='';
    if isprop(fig,'Tag')
        tag=fig.Tag;
    end
    result=~isempty(tag)&&any(strcmp(tag,tags));
end

function localErrorCallback(evt,editorId,fig)

    import matlab.internal.editor.*

    [id,warnMsg]=matlab.graphics.internal.prepareDefaultErrorCallbackWarning(evt);
    w=warning('query',id);

    if~isEmbeddedMorphableFigure(fig)&&strcmp(w.state,'on')
        FigureManager.safeSetAppData(fig,FigureManager.FIGURE_RENDER_WARNING,editorId,sprintf(warnMsg));
    end
end

function animatedFigureDOMNodeAdded(evd,hFig)




    if strcmp(evd.Event,'NewClient')
        matlab.internal.editor.FigureProxy.setDrawnowSyncEnabledOnCanvas(hFig.getCanvas,true);
    end
end

function callYield()


    if matlab.internal.editor.FigureManager.useEmbeddedFigures
        matlab.internal.yield;
    end
end


function ret=shouldNOTSnapshotUIFIGURE(hFig)


    ret=isUIFigure(hFig)&&(isempty(findobjinternal(allchild(hFig),'flat','-property','Visible','Visible','on'))||...
    ~isempty(findobjinternal(hFig,'-isa','matlab.ui.control.HTML')));
end


function ret=isObjectInternal(hObj)
    ret=isprop(hObj,'Internal')&&hObj.Internal==1;
end


function tagFigureAsEmbeddedUIFIgure(fig)


    if isUIFigure(fig)
        if~isprop(fig,'EmbeddedUIFigure')
            p=addprop(fig,'EmbeddedUIFigure');
            fig.EmbeddedUIFigure=true;
            p.Hidden=true;
            p.Transient=true;
        end
    end
end
