function hMode=plotSelectMode(hFig)




    if ishghandle(hFig,'figure')||ishghandle(hFig,'uipanel')||ishghandle(hFig,'uitab')
        hFig=plotedit(hFig,'getmode');
    end

    hMode=getuimode(hFig,'Standard.PlotSelect');
    if~isempty(hMode)
        return;
    end

    hMode=uimode(hFig,'Standard.PlotSelect');
    set(hMode,'WindowButtonMotionFcn',{@localNonDragWindowButtonMotionFcn,hMode});
    set(hMode,'WindowButtonDownFcn',{@localWindowButtonDownFcn,hMode});
    set(hMode,'WindowButtonUpFcn',{@localWindowButtonUpFcn,hMode});
    set(hMode,'WindowKeyPressFcn',{@localKeyPressFcn,hMode});
    set(hMode,'ModeStartFcn',{@localStartFcn,hMode});
    set(hMode,'ModeStopFcn',{@localStopFcn,hMode});

    if~hMode.LiveEditorFigure
        hMode.UIContextMenu=uicontextmenu('Parent',hMode.FigureHandle,'HandleVisibility','off',...
        'Serializable','off');
    end



    hMode.UseContextMenu='off';

    hMode.UIControlInterrupt=true;

    hMode.ModeStateData.SelectedObjects=handle(hMode.FigureHandle([]));


    hMode.ModeStateData.CurrPoint=[];


    hMode.ModeStateData.ChangedObjectHandles=handle(hMode.FigureHandle([]));

    hMode.ModeStateData.ChangedObjectProxy=string.empty;

    hMode.ModeStateData.OperationName='';
    hMode.ModeStateData.OperationData=[];

    hMode.ModeStateData.MovePossible=false;
    hMode.ModeStateData.MoveVector=[];
    hMode.ModeStateData.CutCopyPossible=false;
    hMode.ModeStateData.CutCopyVector=[];
    hMode.ModeStateData.PastePossible=false;
    hMode.ModeStateData.PasteVector=[];
    hMode.ModeStateData.DeleteVector=[];
    hMode.ModeStateData.DeletePossible=false;
    hMode.ModeStateData.IsHomogeneous=true;
    hMode.ModeStateData.CurrentClasses={};

    hMode.ModeStateData.NonScribeMoveMode='none';


    hMode.ModeStateData.MovingTextHandles=handle(hMode.FigureHandle([]));


    hMode.ModeStateData.CurrentUIContextMenuObject=[];
    hMode.ModeStateData.AddedUIContextMenuHandles=[];
    hMode.ModeStateData.CachedUIContextMenu=[];

    hMode.ModeStateData.isMoving=false;
    hMode.ModeStateData.isDragging=false;

    hProps={'Selected';...
    'SelectionHighlight'};

    hList=addlistener(handle(hMode.FigureHandle),hProps,'PostSet',@localNoop);
    matlab.graphics.internal.setListenerState(hList,'off');
    hList.Callback=@(obj,evd)(localFigureSelect(obj,evd,hMode));
    hMode.ModeStateData.FigureSelectionListener=hList;
    hMode.ModeStateData.FigureSelectionHandles=[];










    if~isempty(hFig.CanvasContainerHandle)
        CC=hFig.CanvasContainerHandle;
    else
        CC=hFig.FigureHandle;
    end
    sv=CC.getCanvas;
    hMode.ModeStateData.PlotManagerListener=...
    event.listener(sv,'PostUpdate',@(obj,evd)(localPlotFunctionDone(obj,evd,hMode)));
    hMode.ModeStateData.PlotManagerListener.Enabled=false;

    function localFigureSelect(obj,evd,hMode)%#ok<INUSL>




        hFig=evd.AffectedObject;
        selHandles=hMode.ModeStateData.FigureSelectionHandles;

        if isempty(selHandles)
            selHandles=createMCOSSelectionHandles(hFig);
        end
        hMode.ModeStateData.FigureSelectionHandles=selHandles;



        if strcmpi(get(hFig,'Selected'),'on')
            for i=1:numel(selHandles)
                if~isempty(selHandles(i))
                    set(selHandles(i),'Visible',get(hFig,'SelectionHighlight'));
                end
            end
        else
            for i=1:numel(selHandles)
                if~isempty(selHandles(i))
                    set(selHandles(i),'Visible','off');
                    delete(selHandles(i));
                    hMode.ModeStateData.FigureSelectionHandles=[];
                end
            end
        end



        function localUIObjectSelect(~,evd)



            hFig=ancestor(evd.AffectedObject,'figure');


            if~isprop(hFig,'UISelectionHandles')
                p=addprop(hFig,'UISelectionHandles');
                p.Transient=true;
                hFig.UISelectionHandles=matlab.graphics.internal.SelectionHandles.empty;

            end



            deletedIndices=[];
            selectionHandlesFound=false;

            for k=1:length(hFig.UISelectionHandles)
                if isvalid(hFig.UISelectionHandles(k))&&hFig.UISelectionHandles(k).TrueParent==evd.AffectedObject
                    if strcmp('off',evd.AffectedObject.Selected)
                        delete(hFig.UISelectionHandles(k));
                        deletedIndices=[deletedIndices;k];%#ok<AGROW>
                    else
                        hFig.UISelectionHandles(k).Visible='on';
                    end
                    selectionHandlesFound=true;
                elseif~isvalid(hFig.UISelectionHandles(k))
                    deletedIndices=[deletedIndices;k];%#ok<AGROW>
                end
            end
            hFig.UISelectionHandles(deletedIndices)=[];


            if~selectionHandlesFound&&strcmp('on',evd.AffectedObject.Selected)
                hFig.UISelectionHandles(end+1)=createMCOSSelectionHandles(evd.AffectedObject);
                hFig.UISelectionHandles(end).Visible='on';
            end


            function localStartFcn(hMode)


                set(hMode.FigureHandle,'pointer','arrow');


                localFixSelectedObjs(hMode);


                matlab.graphics.internal.setListenerState(hMode.ModeStateData.FigureSelectionListener,'on');
                evd.AffectedObject=hMode.FigureHandle;
                localFigureSelect([],evd,hMode);




                if isempty(hMode.ModeStateData.SelectedObjects)
                    if~isempty(hMode.FigureHandle.CurrentAxes)&&~isUIComponentInUIFigure(hMode.FigureHandle.CurrentAxes)
                        selectobject(hMode.FigureHandle.CurrentAxes,'replace');
                    else
                        selectobject(hMode.FigureHandle,'replace');
                    end
                end
                setSelected(hMode.ModeStateData.SelectedObjects,'on');

                tipsInd=arrayfun(@(h)isa(h,'matlab.graphics.shape.internal.PointDataTip'),hMode.ModeStateData.SelectedObjects);

                if any(tipsInd)
                    localSelectSiblingTips(hMode,hMode.ModeStateData.SelectedObjects(tipsInd(1)).DataSource);
                end

                hMode.ModeStateData.PlotManagerListener.Enabled=true;

                if isWebFigureType(hMode.FigureHandle,'EmbeddedMorphableFigure')
                    matlab.graphics.internal.PlotEditDnd.updatePlotEdit(hMode.FigureHandle,true);
                end



                localAddSelectionListeners(hMode.FigureHandle,hMode);







                function localStopFcn(hMode)


                    localFixSelectedObjs(hMode);


                    setSelected(hMode.ModeStateData.SelectedObjects,'off');

                    matlab.graphics.internal.setListenerState(hMode.ModeStateData.FigureSelectionListener,'off');


                    hObjs=findall(hMode.FigureHandle,'Type','Text','-or','Type','textboxshape',...
                    '-or','Type','textarrowshape','Editing','on');
                    set(hObjs,'Editing','off');

                    localDeselectAllDatatips(hMode.FigureHandle);


                    localRestoreUIContextMenu(hMode);

                    hMode.ModeStateData.PlotManagerListener.Enabled=false;




                    selectionHandlesProp=hMode.FigureHandle.findprop('UISelectionHandles');
                    if~isempty(selectionHandlesProp)
                        hMode.FigureHandle.UISelectionHandles=[];
                        delete(selectionHandlesProp)
                    end

                    if isWebFigureType(hMode.FigureHandle,'EmbeddedMorphableFigure')
                        matlab.graphics.internal.PlotEditDnd.updatePlotEdit(hMode.FigureHandle,false);
                    end

                    localRemoveSelectionListeners(hMode.FigureHandle)


                    function localDeselectAllDatatips(hFig)
                        allTips=findall(hFig,'-isa','matlab.graphics.shape.internal.PointDataTip');
                        set(allTips,'Selected','off');


                        function localSelectSiblingTips(hMode,hDatasource)
                            siblingTips=findall(hMode.FigureHandle,'-isa','matlab.graphics.shape.internal.PointDataTip',...
                            'DataSource',hDatasource);


                            hMode.ModeStateData.SelectedObjects=siblingTips;
                            set(siblingTips,'Selected','on');


                            function setSelected(handles,value)




                                handlesLogical=arrayfun(@(x)~isprop(x,'Selected'),handles);
                                handles(handlesLogical)=[];
                                set(handles,'Selected',value);


                                function localKeyPressFcn(fig,evd,hMode)


                                    doExclude=localExcludeSelectedObjects(hMode);
                                    if doExclude
                                        return
                                    end



                                    key=evd.Character;
                                    if~ismac
                                        accelModifier='control';
                                    else
                                        accelModifier='command';
                                    end

                                    isWebFigure=matlab.ui.internal.isUIFigure(fig);
                                    if ismac||isWebFigure

                                        undoKey='z';
                                        redoKey='y';
                                        cutKey='x';
                                        copyKey='c';
                                        pasteKey='v';
                                        selectAllKey='a';
                                    else
                                        undoKey=26;
                                        redoKey=25;
                                        cutKey=24;
                                        copyKey=3;
                                        pasteKey=22;
                                        selectAllKey=1;
                                    end


                                    currKey=evd.Key;

                                    if localIsArrowKey(currKey)

                                        if~hMode.ModeStateData.MovePossible
                                            return;
                                        end
                                        curmod=evd.Modifier;
                                        if isempty(curmod)
                                            if~hMode.ModeStateData.isMoving
                                                hMode.ModeStateData.OperationName='Move';
                                                hMode.ModeStateData.OperationData.Handles=handle(hMode.ModeStateData.SelectedObjects);
                                                hMode.ModeStateData.OperationData.Positions=get(hMode.ModeStateData.SelectedObjects,{'Position'});
                                                hMode.ModeStateData.OperationData.Locations(isprop(hMode.ModeStateData.SelectedObjects,'Location'))...
                                                =get(hMode.ModeStateData.SelectedObjects(isprop(hMode.ModeStateData.SelectedObjects,'Location')),{'Location'});
                                                hMode.ModeStateData.isMoving=true;
                                            end
                                            if strcmpi(currKey,'uparrow')
                                                delta=[0,1];
                                            elseif strcmpi(currKey,'downarrow')
                                                delta=[0,-1];
                                            elseif strcmpi(currKey,'leftarrow')
                                                delta=[-1,0];
                                            else
                                                delta=[1,0];
                                            end

                                            if strcmpi('on',getappdata(fig,'scribegui_snaptogrid'))&&...
                                                isappdata(fig,'scribegui_snapgridstruct')
                                                gridstruct=getappdata(fig,'scribegui_snapgridstruct');
                                                if delta(1)==0
                                                    delta(2)=delta(2)*gridstruct.yspace;
                                                else
                                                    delta(1)=delta(1)*gridstruct.xspace;
                                                end
                                                selObjs=hMode.ModeStateData.SelectedObjects;
                                                delta=repmat(delta,length(selObjs),1);
                                                localDoSnapMove(hMode,delta,false);
                                            else
                                                localDoMove(hMode,delta,false);
                                            end


                                            set(hMode,'WindowKeyReleaseFcn',{@localDragComplete,hMode});
                                            return;
                                        end
                                    elseif localIsDeleteOrBackspaceKey(currKey)

                                        if hMode.ModeStateData.DeletePossible
                                            hAnnotation=[];
                                            hSelected=getselectobjects(fig);






                                            hAnnotation=findobj(hSelected,'flat','-isa','matlab.graphics.shape.internal.OneDimensional');
                                            for i=1:numel(hAnnotation)
                                                matlab.graphics.interaction.generateLiveCode(hAnnotation(i),matlab.internal.editor.figure.ActionID.ANNOTATION_REMOVED);
                                            end



                                            selectedLegends=findobj(hSelected,'flat','-isa','matlab.graphics.illustration.Legend');
                                            selectedColorBars=findobj(hSelected,'flat','-isa','matlab.graphics.illustration.ColorBar');


                                            if~isempty(selectedLegends)
                                                for idx=1:numel(selectedLegends)
                                                    leg=selectedLegends(idx);
                                                    matlab.graphics.interaction.generateLiveCode(leg.Axes,matlab.internal.editor.figure.ActionID.LEGEND_REMOVED);
                                                end
                                            end

                                            if~isempty(selectedColorBars)
                                                for idx=1:numel(selectedColorBars)
                                                    cb=selectedColorBars(idx);
                                                    matlab.graphics.interaction.generateLiveCode(cb.Axes,matlab.internal.editor.figure.ActionID.COLORBAR_REMOVED);
                                                end
                                            end




                                            hObjectBeingEdited=findobj(hSelected,'flat','Editing','on');
                                            if isempty(hObjectBeingEdited)
                                                scribeccp(fig,'Delete');


                                                if~isempty(hAnnotation)
                                                    matlab.graphics.interaction.generateLiveCode(fig,matlab.internal.editor.figure.ActionID.ANNOTATION_REMOVED);
                                                end
                                            end



                                            if isprop(fig,'FigureCodeGenController')
                                                fig.FigureCodeGenController.CodeGenerationProxy.notify('InteractionOccured');
                                            end
                                        end

                                        return
                                    end

                                    if isempty(key)
                                        return
                                    else
                                        curmod=evd.Modifier;
                                        if isempty(curmod)||any(strcmp(curmod,'shift'))
                                            matlab.graphics.interaction.internal.FigureKeyPressManager.forwardToCommandWindow(fig,evd);
                                        elseif strcmpi(curmod,accelModifier)
                                            if key==undoKey

                                                hUndoMenu=findall(fig,'Type','UIMenu','Tag','figMenuEditUndo');
                                                if isempty(hUndoMenu)
                                                    uiundo(hMode.FigureHandle,'execUndo');
                                                end
                                            elseif key==redoKey

                                                hRedoMenu=findall(fig,'Type','UIMenu','Tag','figMenuEditRedo');
                                                if isempty(hRedoMenu)
                                                    uiundo(hMode.FigureHandle,'execRedo');
                                                end


                                            elseif(key==copyKey)||(key==cutKey)

                                                if isempty(findall(fig,'Type','UIMenu','Tag','figMenuEditCopy'))||...
                                                    isempty(findall(fig,'Type','UIMenu','Tag','figMenuEditCut'))


                                                    if hMode.ModeStateData.CutCopyPossible
                                                        if key==copyKey
                                                            scribeccp(fig,'Copy');
                                                        else
                                                            if hMode.ModeStateData.DeletePossible
                                                                hAnnotation=[];



                                                                hSelected=getselectobjects(fig);
                                                                hAnnotation=findobj(hSelected,'flat','-isa','matlab.graphics.shape.internal.OneDimensional');
                                                                for i=1:numel(hAnnotation)
                                                                    matlab.graphics.interaction.generateLiveCode(hAnnotation(i),matlab.internal.editor.figure.ActionID.ANNOTATION_REMOVED);
                                                                end
                                                                scribeccp(fig,'Cut');


                                                                if~isempty(hAnnotation)
                                                                    matlab.graphics.interaction.generateLiveCode(fig,matlab.internal.editor.figure.ActionID.ANNOTATION_REMOVED);
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            elseif key==pasteKey

                                                if isempty(findall(fig,'Type','UIMenu','Tag','figMenuEditPaste'))


                                                    penable=false;

                                                    if~isempty(getappdata(0,'ScribeCopyBuffer'))
                                                        penable=hMode.ModeStateData.PastePossible;
                                                    end
                                                    if isWebFigure&&~penable



                                                        selectobject(fig,'replace');
                                                        penable=hMode.ModeStateData.PastePossible;
                                                    end
                                                    if penable
                                                        scribeccp(fig,'Paste');
                                                    end
                                                end
                                            elseif key==selectAllKey
                                                if isempty(findall(fig,'Type','UIMenu','Tag','figMenuEditSelectAll'))
                                                    localSelectAll(hMode)
                                                end
                                            end
                                        end
                                    end


                                    function res=localIsArrowKey(key)


                                        res=false;
                                        if strcmpi(key,'uparrow')||strcmpi(key,'downarrow')||...
                                            strcmpi(key,'leftarrow')||strcmpi(key,'rightarrow')
                                            res=true;
                                        end

                                        function res=localIsDeleteOrBackspaceKey(key)
                                            res=false;
                                            if strcmpi(key,'delete')||strcmpi(key,'backspace')
                                                res=true;
                                            end

                                            function localSelectAll(hMode)

                                                matlab.graphics.annotation.internal.scribeSelectAll(hMode.FigureHandle);


                                                function localWindowButtonDownFcn(obj,evd,hMode)




                                                    localRestoreUIContextMenu(hMode);
                                                    currObj=evd.HitObject;
                                                    currFig=ancestor(currObj,'figure');






                                                    currObj=getHitObjectPlotSelect(hMode,evd,currObj);

                                                    if isempty(currObj)||~ishghandle(currObj)||~isprop(currObj,'Selected')||isUIComponentInUIFigure(currObj)

                                                        if isempty(currFig)
                                                            return
                                                        end
                                                        currObj=currFig;
                                                    end




                                                    uiContextObj=currObj;

                                                    extraArgs={};
                                                    clickedObject=handle(ancestor(currObj,{'hggroup','hgtransform'},extraArgs{:}));
                                                    if~isempty(clickedObject)
                                                        currObj=clickedObject;
                                                    end

                                                    figMod=get(obj,'CurrentModifier');


                                                    localFixSelectedObjs(hMode);

                                                    selType=get(obj,'SelectionType');






                                                    hitobj=evd.HitObject;
                                                    uipanelParent=ancestor(hitobj,{'uipanel','uitab'});
                                                    if ishghandle(uipanelParent)
                                                        scribeax=matlab.graphics.annotation.internal.findAllScribeLayers(uipanelParent);
                                                    else
                                                        scribeax=matlab.graphics.annotation.internal.findAllScribeLayers(currFig);
                                                    end

                                                    if isprop(hitobj,'NClickPoint')
                                                        hitobj.NClickPoint=localGetNormalizedPoint(obj);
                                                    end


                                                    if isempty(currObj)
                                                        return;
                                                    end



                                                    buttonDownHandled=false;
                                                    if isempty(hMode.ModeStateData.SelectedObjects)
                                                        shape=[];
                                                    else
                                                        shape=hMode.ModeStateData.SelectedObjects(currObj==hMode.ModeStateData.SelectedObjects);
                                                    end
                                                    if~isempty(hMode.ModeStateData.SelectedObjects)&&isscalar(hMode.ModeStateData.SelectedObjects)&&~isempty(shape)
                                                        b=hggetbehavior(shape,'Plotedit','-peek');
                                                        if~isempty(b)
                                                            bd=b.ButtonDownFcn;
                                                            if~isempty(bd)
                                                                buttonDownHandled=feval(bd,shape,evd);
                                                            end
                                                        end
                                                    end

                                                    if buttonDownHandled
                                                        return;
                                                    end



                                                    if strcmpi(selType,'normal')||strcmpi(selType,'Extend')


                                                        if isscalar(hMode.ModeStateData.SelectedObjects)&&...
                                                            ishghandle(hMode.ModeStateData.SelectedObjects,'figure')
                                                            figMod=[];
                                                        end

                                                        if isscalar(figMod)&&(strcmpi(figMod,'shift')||strcmpi(figMod,'command'))


                                                            if ishghandle(currObj,'figure')
                                                                return;
                                                            end


                                                            doExclude=localExcludeSelectedObjects(hMode);
                                                            if doExclude||isa(currObj,'matlab.graphics.shape.internal.PointDataTip')
                                                                return
                                                            end

                                                            if strcmpi(get(currObj,'Selected'),'on')
                                                                selectobject(currObj,'off');


                                                                if isempty(hMode.ModeStateData.SelectedObjects)
                                                                    selectobject(obj,'replace');
                                                                end
                                                            else
                                                                prevObjects=getselectobjects(currFig);
                                                                localMoveScribeObjectToFront(currObj,prevObjects);
                                                                selectobject(currObj,'on');




                                                                if hMode.ModeStateData.MovePossible
                                                                    if findMethod(currObj,'findMoveMode')
                                                                        moveType=currObj.findMoveMode(evd);
                                                                    else
                                                                        moveType=localFindMoveModeNonScribeObject(currObj,localGetPixelPoint(obj),hMode);
                                                                    end
                                                                    if strcmpi(moveType,'mouseover')
                                                                        localBeginMove(hMode,scribeax);
                                                                        setptr(obj,localConvertMoveType('mouseover'));
                                                                    end
                                                                end
                                                            end
                                                        else

                                                            if strcmpi(currObj.Selected,'off')||~any(hMode.ModeStateData.SelectedObjects==currObj)
                                                                doExclude=localExcludeSelectedObjects(hMode);

                                                                if doExclude
                                                                    localDeselectAllDatatips(hMode.FigureHandle);
                                                                end
                                                                prevObjects=getselectobjects(currFig);
                                                                selectobject(currObj,'replace');


                                                                if isa(currObj,'matlab.graphics.shape.internal.PointDataTip')

                                                                    localSelectSiblingTips(hMode,currObj.DataSource);
                                                                end


                                                                localMoveScribeObjectToFront(currObj,prevObjects);




                                                                if hMode.ModeStateData.MovePossible
                                                                    if findMethod(currObj,'findMoveMode')
                                                                        moveType=currObj.findMoveMode(evd);
                                                                    else
                                                                        b=hggetbehavior(currObj,'Plotedit','-peek');
                                                                        buttonDownHandled=false;
                                                                        if~isempty(b)
                                                                            cb=b.MouseOverFcn;
                                                                            if~isempty(cb)
                                                                                if~isempty(cb)
                                                                                    cursor=feval(cb,hMode.ModeStateData.SelectedObjects,evd);
                                                                                end
                                                                                scribecursors(obj,cursor)
                                                                            end
                                                                            bd=b.ButtonDownFcn;
                                                                            if~isempty(bd)
                                                                                buttonDownHandled=feval(bd,currObj,evd);
                                                                            end
                                                                        end
                                                                        if~buttonDownHandled&&(isempty(b)||b.Enable)
                                                                            moveType=localFindMoveModeNonScribeObject(currObj,localGetPixelPoint(obj),hMode);
                                                                        else
                                                                            moveType='none';
                                                                        end
                                                                    end
                                                                    if strcmpi(moveType,'mouseover')
                                                                        localBeginMove(hMode,scribeax);
                                                                        setptr(obj,localConvertMoveType('mouseover'));
                                                                    end
                                                                end

                                                            else
                                                                moveProp='MoveStyle';
                                                                if findMethod(currObj,'findMoveMode')
                                                                    if~isscalar(hMode.ModeStateData.SelectedObjects)&&...
                                                                        ~strcmpi(currObj.(moveProp),'none')
                                                                        moveType='mouseover';
                                                                    else
                                                                        moveType=currObj.(moveProp);
                                                                    end
                                                                else
                                                                    moveType=hMode.ModeStateData.NonScribeMoveMode;
                                                                end


                                                                if strcmpi(moveType,'none')||~hMode.ModeStateData.MovePossible
                                                                elseif strcmpi(moveType,'mouseover')
                                                                    localBeginMove(hMode,scribeax);
                                                                else


                                                                    hMode.ModeStateData.OperationName='Resize';
                                                                    hMode.ModeStateData.OperationData.Handles=hMode.ModeStateData.SelectedObjects;
                                                                    hMode.ModeStateData.OperationData.Positions=get(hMode.ModeStateData.SelectedObjects,{'Position'});
                                                                    hMode.ModeStateData.OperationData.Locations(isprop(hMode.ModeStateData.SelectedObjects,'Location'))...
                                                                    =get(hMode.ModeStateData.SelectedObjects(isprop(hMode.ModeStateData.SelectedObjects,'Location')),{'Location'});

                                                                    if strcmpi('on',getappdata(ancestor(scribeax,'figure'),'scribegui_snaptogrid'))&&...
                                                                        isappdata(ancestor(scribeax,'figure'),'scribegui_snapgridstruct')
                                                                        set(hMode,'WindowButtonMotionFcn',{@localSnapResizeWindowButtonMotionFcn,hMode});
                                                                    else
                                                                        set(hMode,'WindowButtonMotionFcn',{@localResizeWindowButtonMotionFcn,hMode});
                                                                    end
                                                                    set(hMode,'WindowButtonUpFcn',{@localDragComplete,hMode});
                                                                end
                                                            end
                                                        end

                                                    elseif strcmpi(selType,'alt')


                                                        if~strcmpi(get(currObj,'Selected'),'on')
                                                            selectobject(currObj,'replace');
                                                        end


                                                        if isempty(hMode.ModeStateData.SelectedObjects)
                                                            return;
                                                        end


                                                        if isscalar(hMode.ModeStateData.SelectedObjects)
                                                            hB=hggetbehavior(currObj,'Plotedit','-peek');
                                                            if~isempty(hB)&&hB.KeepContextMenu
                                                                return;
                                                            end
                                                        end

                                                        hChil=findall(hMode.UIContextMenu);
                                                        hChil=hChil(2:end);
                                                        set(hChil,'Visible','off','Enable','off');
                                                        mergeMenus=false;
                                                        allMenus=[];






                                                        if isscalar(hMode.ModeStateData.SelectedObjects)&&...
                                                            isprop(uiContextObj,'UIContextMenu')&&...
                                                            ~isempty(get(uiContextObj,'UIContextMenu'))
                                                            sep='on';
                                                            mergeMenus=true;
                                                        else
                                                            sep='off';
                                                        end



                                                        if isscalar(hMode.ModeStateData.SelectedObjects)&&...
                                                            ishghandle(hMode.ModeStateData.SelectedObjects,'axes')&&...
                                                            ~isempty(matlab.graphics.internal.getFigureJavaFrame(hMode.FigureHandle))
                                                            if usejava('awt')
                                                                hAddDataItem=localGetMenu(hMode,'AddData');
                                                                set(hAddDataItem,'Separator',sep);
                                                                set(hAddDataItem,'Visible','on','Enable','on');
                                                                sep='on';
                                                                allMenus(end+1)=hAddDataItem;
                                                            end
                                                        end


                                                        cutMenu=localGetMenu(hMode,'Cut');
                                                        if hMode.ModeStateData.CutCopyPossible
                                                            set(cutMenu,'Separator',sep,'Visible','on','Enable','on');
                                                            allMenus(end+1)=cutMenu;
                                                            sep='off';
                                                        else
                                                            set(cutMenu,'Visible','off');
                                                        end
                                                        copyMenu=localGetMenu(hMode,'Copy');
                                                        if hMode.ModeStateData.CutCopyPossible
                                                            set(copyMenu,'Separator',sep,'Visible','on','Enable','on');
                                                            allMenus(end+1)=copyMenu;
                                                            sep='off';
                                                        else
                                                            set(copyMenu,'Visible','off');
                                                        end
                                                        pasteMenu=localGetMenu(hMode,'Paste');
                                                        if hMode.ModeStateData.PastePossible
                                                            set(pasteMenu,'Separator',sep,'Visible','on','Enable','on');
                                                            allMenus(end+1)=pasteMenu;

                                                            if~isappdata(0,'ScribeCopyBuffer')||isempty(getappdata(0,'ScribeCopyBuffer'))
                                                                set(pasteMenu,'Enable','off');
                                                            else
                                                                set(pasteMenu,'Enable','on');
                                                            end
                                                            sep='off';
                                                        else
                                                            set(pasteMenu,'Visible','off');
                                                        end
                                                        clearAxesMenu=localGetMenu(hMode,'ClearAxes');
                                                        if isscalar(hMode.ModeStateData.SelectedObjects)&&...
                                                            ishghandle(hMode.ModeStateData.SelectedObjects,'axes')
                                                            set(clearAxesMenu,'Separator',sep,'Visible','on','Enable','on');
                                                            sep='off';
                                                            allMenus(end+1)=clearAxesMenu;
                                                        else
                                                            set(clearAxesMenu,'Visible','off');
                                                        end
                                                        deleteMenu=localGetMenu(hMode,'Delete');
                                                        if hMode.ModeStateData.DeletePossible
                                                            set(deleteMenu,'Separator',sep,'Visible','on','Enable','on');
                                                            allMenus(end+1)=deleteMenu;
                                                        else
                                                            set(deleteMenu,'Visible','off');
                                                        end



                                                        hChil=[];
                                                        if isscalar(hMode.ModeStateData.SelectedObjects)
                                                            if isprop(currObj,'PinContextMenu')
                                                                hChil=double(currObj.PinContextMenu);
                                                            elseif findMethod(currObj,'getPinMenus')
                                                                hChil=double(currObj.getPinMenus);
                                                            end
                                                            if~isempty(hChil)
                                                                set(hChil(1),'Separator','on');
                                                                set(findall(hChil),'Visible','on','Enable','on');
                                                            end
                                                        end
                                                        allMenus=[allMenus(:);hChil(:)];



                                                        hChil=[];
                                                        if isscalar(hMode.ModeStateData.SelectedObjects)||...
                                                            hMode.ModeStateData.IsHomogeneous
                                                            if isprop(currObj,'ScribeContextMenu')
                                                                hChil=double(currObj.ScribeContextMenu);
                                                            elseif findMethod(currObj,'getScribeMenus')
                                                                hChil=double(currObj.getScribeMenus);
                                                            else
                                                                hChil=localGetNonScribeScribeContextMenu(hMode,currObj);
                                                                localUpdateNonScribeContextMenu(currObj,hChil);
                                                            end
                                                            if~isempty(hChil)
                                                                set(hChil(1),'Separator','on');
                                                                set(findall(hChil),'Visible','on','Enable','on');
                                                            end
                                                            localPostEnableUpdateContextMenu(currObj,hMode,hChil);
                                                        end
                                                        allMenus=[allMenus(:);hChil(:)];


                                                        hPropMenu=localGetPropEditMenu(hMode);
                                                        if~isempty(hPropMenu)
                                                            allMenus(end+1)=hPropMenu;
                                                            set(hPropMenu,'Separator','on');
                                                            set(hPropMenu,'Visible','on','Enable','on');
                                                        end


                                                        hMCodeMenu=localGetMCodeMenu(hMode);
                                                        set(hMCodeMenu,'Separator','on');

                                                        if(isscalar(hMode.ModeStateData.SelectedObjects)&&~is_uiFig(hMode.ModeStateData.SelectedObjects))
                                                            allMenus(end+1)=hMCodeMenu;
                                                            set(hMCodeMenu,'Visible','on','Enable','on');
                                                        else
                                                            set(hMCodeMenu,'Visible','off');
                                                        end


                                                        allMenus=allMenus(:);
                                                        allChil=findall(hMode.UIContextMenu,'-depth',1);
                                                        nonChil=setdiff(double(allChil(2:end)),allMenus);
                                                        set(hMode.UIContextMenu,'Children',[allMenus(end:-1:1);nonChil(end:-1:1)]);








                                                        if~isa(uiContextObj,'matlab.graphics.shape.internal.PointDataTip')
                                                            localUpdateUIContextMenu(hMode,uiContextObj,mergeMenus);
                                                        end
                                                    end

                                                    function retval=is_uiFig(h)

                                                        retval=false;
                                                        f=ancestor(h,'figure');
                                                        if isa(f,'matlab.ui.Figure')
                                                            if(isWebFigureType(f,'UIFigure'))
                                                                retval=true;
                                                            end
                                                        end


                                                        function localMoveScribeObjectToFront(obj,prevObjects)

                                                            if isa(obj,'matlab.graphics.shape.internal.ScribeObject')


                                                                textObjs=findobjinternal(prevObjects,'-isa','matlab.graphics.primitive.Text');
                                                                if~isempty(textObjs)
                                                                    for k=1:numel(textObjs)
                                                                        textObjs(k).Editing='off';
                                                                    end
drawnow
                                                                end
                                                                hPar=obj.Parent;
                                                                hChil=findall(hPar,'-depth',1);
                                                                hChil(hChil==obj)=[];


                                                                hChil=[obj;hChil(2:end)];
                                                                hPar.Children=hChil;
                                                            end

                                                            function doExclude=localExcludeSelectedObjects(hMode)
                                                                doExclude=false;
                                                                anyTips=any(arrayfun(@(h)isa(h,'matlab.graphics.shape.internal.PointDataTip'),hMode.ModeStateData.SelectedObjects));
                                                                if anyTips
                                                                    doExclude=true;
                                                                end


                                                                function localBeginMove(hMode,scribeax)


                                                                    obj=hMode.FigureHandle;



                                                                    hMode.ModeStateData.OperationName='Move';
                                                                    hMode.ModeStateData.OperationData.Handles=handle(hMode.ModeStateData.SelectedObjects);
                                                                    hMode.ModeStateData.OperationData.Positions=get(hMode.ModeStateData.SelectedObjects,{'Position'});
                                                                    hMode.ModeStateData.OperationData.Locations(isprop(hMode.ModeStateData.SelectedObjects,'Location'))...
                                                                    =get(hMode.ModeStateData.SelectedObjects(isprop(hMode.ModeStateData.SelectedObjects,'Location')),{'Location'});


                                                                    if strcmpi('on',getappdata(ancestor(scribeax,'figure'),'scribegui_snaptogrid'))&&...
                                                                        isappdata(ancestor(scribeax,'figure'),'scribegui_snapgridstruct')
                                                                        set(hMode,'WindowButtonMotionFcn',{@localSnapMoveWindowButtonMotionFcn,hMode});




                                                                        hMode.ModeStateData.BasePoints=repmat(localGetPixelPoint(obj),length(hMode.ModeStateData.SelectedObjects),1);
                                                                    else
                                                                        set(hMode,'WindowButtonMotionFcn',{@localMoveWindowButtonMotionFcn,hMode});


                                                                        hMode.ModeStateData.CurrPoint=localGetPixelPoint(obj);
                                                                    end
                                                                    set(hMode,'WindowButtonUpFcn',{@localDragComplete,hMode});


                                                                    function localUpdateUIContextMenu(hMode,objHandle,mergeMenus)




                                                                        hMode.ModeStateData.CurrentUIContextMenuObject=objHandle;


                                                                        if~isprop(objHandle,'UIContextMenu')
                                                                            currentMenu=[];
                                                                        else
                                                                            currentMenu=get(objHandle,'UIContextMenu');
                                                                        end
                                                                        if(~mergeMenus||isempty(currentMenu))&&isprop(objHandle,'UIContextMenu')
                                                                            hMode.ModeStateData.AddedUIContextMenuHandles=[];
                                                                            hMode.ModeStateData.CachedUIContextMenu=currentMenu;
                                                                            set(objHandle,'UIContextMenu',hMode.UIContextMenu);







                                                                            drawnow update
                                                                        else


                                                                            if isempty(hMode.ModeStateData.AddedUIContextMenuHandles)
                                                                                hMenuEntries=findall(hMode.UIContextMenu,'-depth',1);

                                                                                hMenuEntries=hMenuEntries(end:-1:2);
                                                                                set(hMenuEntries,'Parent',currentMenu);
                                                                                hMode.ModeStateData.AddedUIContextMenuHandles=hMenuEntries;
                                                                            end
                                                                        end


                                                                        function localRestoreUIContextMenu(hMode)


                                                                            if isempty(hMode.ModeStateData.CurrentUIContextMenuObject)||...
                                                                                ~ishandle(hMode.ModeStateData.CurrentUIContextMenuObject)
                                                                                return;
                                                                            end



                                                                            if isempty(hMode.ModeStateData.AddedUIContextMenuHandles)
                                                                                if isprop(hMode.ModeStateData.CurrentUIContextMenuObject,'UIContextMenu')
                                                                                    set(hMode.ModeStateData.CurrentUIContextMenuObject,'UIContextMenu',...
                                                                                    hMode.ModeStateData.CachedUIContextMenu);
                                                                                end
                                                                                hMode.ModeStateData.CachedUIContextMenu=[];
                                                                            else
                                                                                hMenuEntries=hMode.ModeStateData.AddedUIContextMenuHandles;
                                                                                hMenuEntries(~ishandle(hMenuEntries))=[];
                                                                                set(hMenuEntries,'Parent',hMode.UIContextMenu);
                                                                                hMode.ModeStateData.AddedUIContextMenuHandles=[];
                                                                            end



                                                                            hMode.ModeStateData.CurrentUIContextMenuObject=[];


                                                                            function hMenu=localGetMCodeMenu(hMode)


                                                                                if isdeployed
                                                                                    hMenu=[];
                                                                                    return;
                                                                                end

                                                                                hMenu=findall(hMode.UIContextMenu,'Tag','ScribeMCodeGeneration');
                                                                                if~isempty(hMenu)
                                                                                    return;
                                                                                end

                                                                                hMenu=uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
                                                                                'Label',getString(message('MATLAB:uistring:scribemenu:ShowCode')),'Callback',{@localGenerateMCode,hMode},...
                                                                                'Tag','ScribeMCodeGeneration','Visible','off');


                                                                                function localGenerateMCode(obj,evd,hMode)%#ok<INUSL>


                                                                                    makemcode(hMode.ModeStateData.SelectedObjects,'Output','-editor')


                                                                                    function hMenu=localGetPropEditMenu(hMode)


                                                                                        if isdeployed||~usejava('awt')
                                                                                            hMenu=[];
                                                                                            return;
                                                                                        end

                                                                                        hMenu=findall(hMode.UIContextMenu,'Tag','ScribePropertyInspector');
                                                                                        if~isempty(hMenu)
                                                                                            return;
                                                                                        end


                                                                                        hMenu=uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
                                                                                        'Label',getString(message('MATLAB:uistring:scribemenu:OpenPropertyInspector')),'Callback',{@localOpenPropertyInspector,hMode},...
                                                                                        'Tag','ScribePropertyInspector','Visible','off');


                                                                                        function localOpenPropertyInspector(~,~,hMode)

                                                                                            matlab.graphics.internal.propertyinspector.propertyinspector('show',hMode.ModeStateData.SelectedObjects);


                                                                                            function hMenu=localGetMenu(hMode,action)



                                                                                                hMenu=findall(hMode.UIContextMenu,'Tag',sprintf('ScribeGenericAction%s',action));
                                                                                                if~isempty(hMenu)
                                                                                                    return;
                                                                                                end


                                                                                                hCutMenu=uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
                                                                                                'Label',getString(message('MATLAB:uistring:scribemenu:Cut')),'Callback',{@localCallFunction,hMode,@scribeccp,'Cut'},...
                                                                                                'Tag','ScribeGenericActionCut','Visible','off');
                                                                                                if strcmpi(action,'Cut')
                                                                                                    hMenu=hCutMenu;
                                                                                                end

                                                                                                hCopyMenu=uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
                                                                                                'Label',getString(message('MATLAB:uistring:scribemenu:Copy')),'Callback',{@localCallFunction,hMode,@scribeccp,'Copy'},...
                                                                                                'Tag','ScribeGenericActionCopy','Visible','off');
                                                                                                if strcmpi(action,'Copy')
                                                                                                    hMenu=hCopyMenu;
                                                                                                end

                                                                                                hPasteMenu=uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
                                                                                                'Label',getString(message('MATLAB:uistring:scribemenu:Paste')),'Callback',{@localCallFunction,hMode,@scribeccp,'Paste'},...
                                                                                                'Tag','ScribeGenericActionPaste','Visible','off');
                                                                                                if strcmpi(action,'Paste')
                                                                                                    hMenu=hPasteMenu;
                                                                                                end

                                                                                                hClearMenu=uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
                                                                                                'Label',getString(message('MATLAB:uistring:scribemenu:ClearAxes')),'Callback',{@localClearAxes,hMode},...
                                                                                                'Tag','ScribeGenericActionClearAxes','Visible','off');
                                                                                                if strcmpi(action,'ClearAxes')
                                                                                                    hMenu=hClearMenu;
                                                                                                end

                                                                                                hDeleteMenu=uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
                                                                                                'Label',getString(message('MATLAB:uistring:scribemenu:Delete')),'Callback',{@localCallFunction,hMode,@scribeccp,'Delete'},...
                                                                                                'Tag','ScribeGenericActionDelete');
                                                                                                if strcmpi(action,'Delete')
                                                                                                    hMenu=hDeleteMenu;
                                                                                                end

                                                                                                hAddDataMenu=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'AddData',getString(message('MATLAB:uistring:scribemenu:AddData')),'','');
                                                                                                set(hAddDataMenu,'Parent',hMode.UIContextMenu,'Tag','ScribeGenericActionAddData');
                                                                                                if strcmpi(action,'AddData')
                                                                                                    hMenu=hAddDataMenu;
                                                                                                end


                                                                                                function localClearAxes(obj,evd,hMode)%#ok<INUSL>

                                                                                                    hFig=hMode.FigureHandle;
                                                                                                    cla(hMode.ModeStateData.SelectedObjects);

                                                                                                    uiundo(hFig,'clear');


                                                                                                    function localCallFunction(obj,evd,hMode,varargin)%#ok<INUSL>

                                                                                                        localRestoreUIContextMenu(hMode);

                                                                                                        hFig=hMode.FigureHandle;
                                                                                                        hSelected=getselectobjects(hFig);





                                                                                                        hAnnotation=findobj(hSelected,'flat','-isa','matlab.graphics.shape.internal.OneDimensional');

                                                                                                        feval(varargin{1},hMode.FigureHandle,varargin{2:end});
                                                                                                        action=varargin{2};
                                                                                                        if~isempty(hAnnotation)&&ismember(action,{'Cut','Delete'})
                                                                                                            matlab.graphics.interaction.generateLiveCode(hFig,matlab.internal.editor.figure.ActionID.ANNOTATION_REMOVED);
                                                                                                        end


                                                                                                        function localSnapResizeWindowButtonMotionFcn(obj,evd,hMode)




                                                                                                            if isempty(hMode.ModeStateData.SelectedObjects)||...
                                                                                                                ~ishghandle(hMode.ModeStateData.SelectedObjects(1))
                                                                                                                return;
                                                                                                            end


                                                                                                            currObj=hMode.ModeStateData.SelectedObjects(1);
                                                                                                            propName='Point';
                                                                                                            currPoint=hgconvertunits(obj,[evd.(propName),0,0],obj.Units,'pixels',obj);
                                                                                                            currPoint=currPoint(1:2);
                                                                                                            hAncestor=handle(get(currObj,'Parent'));
                                                                                                            if~ishghandle(hAncestor,'figure')&&~ishghandle(hAncestor,'uipanel')
                                                                                                                hAncestor=handle(obj);
                                                                                                            end
                                                                                                            if~ishghandle(hAncestor,'figure')
                                                                                                                ancPos=getpixelposition(hAncestor,true);
                                                                                                                currPoint=currPoint-ancPos(1:2);
                                                                                                            end
                                                                                                            currPoint=hgconvertunits(obj,[currPoint,0,0],'pixels','normalized',hAncestor);
                                                                                                            currPoint=currPoint(1:2);
                                                                                                            if currPoint(1)<0.0||currPoint(1)>1.0||...
                                                                                                                currPoint(2)<0.0||currPoint(2)>1.0
                                                                                                                return
                                                                                                            end



                                                                                                            gridstruct=getappdata(obj,'scribegui_snapgridstruct');
                                                                                                            xspace=gridstruct.xspace;
                                                                                                            yspace=gridstruct.yspace;
                                                                                                            influ=gridstruct.influence;

                                                                                                            moveProp='MoveStyle';
                                                                                                            if isprop(currObj,moveProp)
                                                                                                                MoveType=lower(get(currObj,moveProp));
                                                                                                            else
                                                                                                                MoveType=lower(hMode.ModeStateData.NonScribeMoveMode);
                                                                                                            end




                                                                                                            propName='Point';
                                                                                                            currPoint=hgconvertunits(obj,[evd.(propName),0,0],obj.Units,'pixels',obj);
                                                                                                            currPoint=currPoint(1:2);


                                                                                                            switch MoveType
                                                                                                            case{'topleft','topright','bottomleft','bottomright'}


                                                                                                                xPoint=false;
                                                                                                                yPoint=false;
                                                                                                                xoff=mod(currPoint(1),xspace);
                                                                                                                yoff=mod(currPoint(2),yspace);
                                                                                                                if xoff>(xspace/2)
                                                                                                                    xoff=xoff-xspace;
                                                                                                                end
                                                                                                                if xoff<influ
                                                                                                                    currPoint(1)=(round(currPoint(1)/xspace)*xspace);
                                                                                                                    xPoint=true;
                                                                                                                end
                                                                                                                if yoff>(yspace/2)
                                                                                                                    yoff=yoff-yspace;
                                                                                                                end
                                                                                                                if yoff<influ
                                                                                                                    currPoint(2)=(round(currPoint(2)/yspace)*yspace);
                                                                                                                    yPoint=true;
                                                                                                                end

                                                                                                                if~(xPoint&&yPoint)
                                                                                                                    return;
                                                                                                                end
                                                                                                            case{'left','right'}
                                                                                                                xPoint=false;
                                                                                                                xoff=mod(currPoint(1),xspace);
                                                                                                                if xoff>(xspace/2)
                                                                                                                    xoff=xoff-xspace;
                                                                                                                end
                                                                                                                if xoff<influ
                                                                                                                    currPoint(1)=(round(currPoint(1)/xspace)*xspace);
                                                                                                                    xPoint=true;
                                                                                                                end

                                                                                                                if~xPoint
                                                                                                                    return;
                                                                                                                end
                                                                                                            case{'top','bottom'}
                                                                                                                yPoint=false;
                                                                                                                yoff=mod(currPoint(2),yspace);
                                                                                                                if yoff>(yspace/2)
                                                                                                                    yoff=yoff-yspace;
                                                                                                                end
                                                                                                                if yoff<influ
                                                                                                                    currPoint(2)=(round(currPoint(2)/yspace)*yspace);
                                                                                                                    yPoint=true;
                                                                                                                end

                                                                                                                if~yPoint
                                                                                                                    return;
                                                                                                                end
                                                                                                            otherwise
                                                                                                                return;
                                                                                                            end

                                                                                                            if findMethod(currObj,'resize')

                                                                                                                currObj.resize(currPoint);
                                                                                                            else
                                                                                                                localResizeNonScribeObject(currObj,currPoint,hMode.ModeStateData.NonScribeMoveMode);
                                                                                                            end

                                                                                                            drawnow update


                                                                                                            function localResizeWindowButtonMotionFcn(obj,evd,hMode)




                                                                                                                localFixSelectedObjs(hMode);

                                                                                                                if isempty(hMode.ModeStateData.SelectedObjects)||...
                                                                                                                    ~ishghandle(hMode.ModeStateData.SelectedObjects(1))
                                                                                                                    return;
                                                                                                                end




                                                                                                                matlab.graphics.internal.setListenerState(hMode.UIControlSuspendListener,'off');


                                                                                                                currObj=hMode.ModeStateData.SelectedObjects(1);


                                                                                                                if isprop(obj,'UISelectionHandles')
                                                                                                                    if ishghandle(obj.UISelectionHandles)
                                                                                                                        set(obj.UISelectionHandles,'Visible','off');
                                                                                                                    end
                                                                                                                end

                                                                                                                propName='Point';
                                                                                                                currPoint=hgconvertunits(obj,[evd.(propName),0,0],obj.Units,'pixels',obj);
                                                                                                                currPoint=currPoint(1:2);
                                                                                                                hAncestor=handle(ancestor(get(currObj,'Parent'),{'uicontainer','uipanel','figure','uitab'}));
                                                                                                                if~ishghandle(hAncestor,'figure')
                                                                                                                    ancPos=getpixelposition(hAncestor,true);
                                                                                                                    currPoint=currPoint-ancPos(1:2);
                                                                                                                end
                                                                                                                currPoint=hgconvertunits(obj,[currPoint(1:2),0,0],'pixels','normalized',hAncestor);
                                                                                                                currPoint=currPoint(1:2);
                                                                                                                if currPoint(1)<0.0||currPoint(1)>1.0||...
                                                                                                                    currPoint(2)<0.0||currPoint(2)>1.0
                                                                                                                    return
                                                                                                                end
                                                                                                                if findMethod(currObj,'resize')
                                                                                                                    currPoint=hgconvertunits(obj,[currPoint,0,0],'normalized','pixels',hAncestor);
                                                                                                                    currObj.resize(currPoint(1:2));
                                                                                                                    matlab.graphics.interaction.generateLiveCode(ancestor(obj,'figure'),matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED);
                                                                                                                    matlab.graphics.interaction.generateLiveCode(obj,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED);
                                                                                                                else
                                                                                                                    localResizeNonScribeObject(currObj,evd.(propName),hMode.ModeStateData.NonScribeMoveMode);
                                                                                                                end



                                                                                                                drawnow update



                                                                                                                function localDragComplete(obj,evd,hMode)


                                                                                                                    if isfield(hMode.ModeStateData,'LastMouseDragPoint')&&...
                                                                                                                        ~isempty(hMode.ModeStateData.LastMouseDragPoint)
                                                                                                                        hMode.ModeStateData.LastMouseDragPoint=[];
                                                                                                                    end


                                                                                                                    if~ishghandle(obj,'figure')
                                                                                                                        obj=hMode.FigureHandle;
                                                                                                                    end

                                                                                                                    set(hMode,'WindowButtonUpFcn',{@localWindowButtonUpFcn,hMode});
                                                                                                                    set(hMode,'WindowButtonMotionFcn',{@localNonDragWindowButtonMotionFcn,hMode});

                                                                                                                    set(hMode,'WindowKeyReleaseFcn','');

                                                                                                                    hMode.ModeStateData.isMoving=false;


                                                                                                                    hTextHandles=hMode.ModeStateData.MovingTextHandles;
                                                                                                                    hTextHandles(ishghandle(hTextHandles));
                                                                                                                    hMode.ModeStateData.MovingTextHandles=handle(obj([]));


                                                                                                                    buttonUpHandled=false;


                                                                                                                    localFixSelectedObjs(hMode);

                                                                                                                    if isscalar(hMode.ModeStateData.SelectedObjects)
                                                                                                                        shape=hMode.ModeStateData.SelectedObjects;
                                                                                                                        if~isempty(shape)&&all(ishghandle(shape))
                                                                                                                            b=hggetbehavior(shape,'Plotedit','-peek');
                                                                                                                            if~isempty(b)
                                                                                                                                cb=b.ButtonUpFcn;
                                                                                                                                if~isempty(cb)
                                                                                                                                    buttonUpHandled=feval(cb,shape,evd);
                                                                                                                                end
                                                                                                                            else
                                                                                                                                buttonUpHandled=localHandleButtonUp(hMode);
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end

                                                                                                                    if buttonUpHandled||isempty(hMode.ModeStateData.OperationData)


                                                                                                                        return;
                                                                                                                    end



                                                                                                                    hObjs=hMode.ModeStateData.OperationData.Handles;
                                                                                                                    positions=hMode.ModeStateData.OperationData.Positions;
                                                                                                                    positions(~ishghandle(hObjs))=[];
                                                                                                                    hObjs=hObjs(ishghandle(hObjs));
                                                                                                                    hMode.ModeStateData.OperationData.Handles=hObjs;
                                                                                                                    hMode.ModeStateData.OperationData.Positions=positions;
                                                                                                                    if isempty(hObjs)
                                                                                                                        return;
                                                                                                                    end
                                                                                                                    newPos=get(hObjs,{'Position'});
                                                                                                                    if~isequal(newPos,positions)
                                                                                                                        localConstructPositionalUndo(hMode);
                                                                                                                    end



                                                                                                                    if strcmpi(get(obj,'SelectionType'),'Open')
                                                                                                                        localWindowButtonUpFcn(obj,evd,hMode);
                                                                                                                    end



                                                                                                                    hMode.ModeStateData.PlotManagerListener.Enabled=true;
                                                                                                                    matlab.graphics.internal.setListenerState(hMode.UIControlSuspendListener,'on');



                                                                                                                    if isprop(obj,'UISelectionHandles')
                                                                                                                        if ishghandle(obj.UISelectionHandles)
                                                                                                                            set(obj.UISelectionHandles,'Visible','on')
                                                                                                                        end
                                                                                                                    end

                                                                                                                    hMode.ModeStateData.isDragging=false;


                                                                                                                    function localWindowButtonUpFcn(obj,evd,hMode)




                                                                                                                        localFixSelectedObjs(hMode);


                                                                                                                        buttonUpHandled=false;
                                                                                                                        if isscalar(hMode.ModeStateData.SelectedObjects)
                                                                                                                            shape=hMode.ModeStateData.SelectedObjects;
                                                                                                                            if~isempty(shape)
                                                                                                                                if findMethod(shape,'scribeButtonUpFcn')
                                                                                                                                    point=localGetNormalizedPoint(obj);
                                                                                                                                    buttonUpHandled=shape.scribeButtonUpFcn(point);
                                                                                                                                else
                                                                                                                                    b=hggetbehavior(shape,'Plotedit','-peek');
                                                                                                                                    if~isempty(b)
                                                                                                                                        cb=b.ButtonUpFcn;
                                                                                                                                        if~isempty(cb)
                                                                                                                                            buttonUpHandled=feval(cb,shape,evd);
                                                                                                                                        end
                                                                                                                                    else
                                                                                                                                        buttonUpHandled=localHandleButtonUp(hMode);
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end

                                                                                                                        if buttonUpHandled
                                                                                                                            return;
                                                                                                                        end

                                                                                                                        selType=get(obj,'SelectionType');

                                                                                                                        if strcmpi(selType,'Open')
                                                                                                                            if usejava('awt')
                                                                                                                                plotedit(ancestor(obj,'figure'),'showinspector');
                                                                                                                            end
                                                                                                                        end


                                                                                                                        function handled=localHandleButtonUp(hMode)





                                                                                                                            handled=false;
                                                                                                                            shape=hMode.ModeStateData.SelectedObjects;
                                                                                                                            if ishghandle(shape,'text')&&...
                                                                                                                                strcmpi(get(hMode.FigureHandle,'SelectionType'),'open')
                                                                                                                                handled=true;
                                                                                                                                set(shape,'Editing','on');



                                                                                                                                hMode.ModeStateData.CutCopyPossible=false;

                                                                                                                                registerTextEditUndoRedo(shape);
                                                                                                                            elseif isa(shape,'matlab.graphics.shape.internal.ScribeObject')
                                                                                                                                handled=shape.handleScribeButtonUp;
                                                                                                                                if isprop(shape,'Editing')
                                                                                                                                    if handled&&strcmp(shape.Editing,'on')

                                                                                                                                        registerTextEditUndoRedo(shape);
                                                                                                                                        hMode.ModeStateData.CutCopyPossible=false;
                                                                                                                                    elseif~handled&&~hMode.ModeStateData.CutCopyPossible


                                                                                                                                        hMode.ModeStateData.CutCopyPossible=true;
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            elseif isa(shape,'matlab.graphics.shape.internal.PointDataTip')



                                                                                                                                handled=true;
                                                                                                                                hMode.ModeStateData.CutCopyPossible=false;
                                                                                                                                hMode.ModeStateData.PastePossible=false;
                                                                                                                                hMode.ModeStateData.DeletePossible=false;
                                                                                                                            end



                                                                                                                            function point=localGetNormalizedPoint(hFig)


                                                                                                                                y=hgconvertunits(hFig,[get(hFig,'CurrentPoint'),1,1],get(hFig,'Units'),...
                                                                                                                                'normalized',hFig);
                                                                                                                                point=y(1:2);


                                                                                                                                function point=localGetPixelPoint(hFig)


                                                                                                                                    y=hgconvertunits(hFig,[get(hFig,'CurrentPoint'),1,1],get(hFig,'Units'),...
                                                                                                                                    'Pixels',hFig);
                                                                                                                                    point=y(1:2);


                                                                                                                                    function localConstructPositionalUndo(hMode)



                                                                                                                                        hObjs=hMode.ModeStateData.OperationData.Handles;



                                                                                                                                        oldValues.Position=hMode.ModeStateData.OperationData.Positions;
                                                                                                                                        if isfield(hMode.ModeStateData.OperationData,'Locations')
                                                                                                                                            oldValues.Location=hMode.ModeStateData.OperationData.Locations;
                                                                                                                                        end

                                                                                                                                        cmd=matlab.uitools.internal.uiundo.UndoRedoCommandStructureFactory.createUndoRedoStruct(hObjs,...
                                                                                                                                        hMode,hMode.ModeStateData.OperationName,'Position',hMode.ModeStateData.OperationData.Positions,get(hObjs,{'Position'}),oldValues);


                                                                                                                                        uiundo(hMode.FigureHandle,'function',cmd);

                                                                                                                                        hMode.ModeStateData.OperationData=[];


                                                                                                                                        function localNonDragWindowButtonMotionFcn(obj,evd,hMode)



                                                                                                                                            propName='HitObject';
                                                                                                                                            pointPropName='Point';
                                                                                                                                            currObj=hMode.ModeStateData.SelectedObjects(evd.(propName)==hMode.ModeStateData.SelectedObjects);

                                                                                                                                            if isempty(currObj)
                                                                                                                                                hitObj=getHitObjectPlotSelect(hMode,evd,[]);
                                                                                                                                                if~isempty(hitObj)&&isprop(hitObj,'Selected')&&strcmpi(hitObj.Selected,'on')









                                                                                                                                                    currObj=hitObj;
                                                                                                                                                end
                                                                                                                                            end




                                                                                                                                            motionHandled=false;
                                                                                                                                            if isscalar(hMode.ModeStateData.SelectedObjects)
                                                                                                                                                shape=currObj;
                                                                                                                                                if~isempty(shape)
                                                                                                                                                    b=hggetbehavior(shape,'Plotedit','-peek');
                                                                                                                                                    if~isempty(b)
                                                                                                                                                        cb=b.MouseMotionFcn;
                                                                                                                                                        if~isempty(cb)
                                                                                                                                                            motionHandled=feval(cb,shape,evd);
                                                                                                                                                        end


                                                                                                                                                        moCb=b.MouseOverFcn;
                                                                                                                                                        if~isempty(moCb)
                                                                                                                                                            cursor=feval(moCb,shape,evd);
                                                                                                                                                            scribecursors(obj,cursor);
                                                                                                                                                        end
                                                                                                                                                    end
                                                                                                                                                end
                                                                                                                                            end

                                                                                                                                            if motionHandled
                                                                                                                                                return;
                                                                                                                                            end


                                                                                                                                            cursor=0;

                                                                                                                                            if~isempty(currObj)&&~ishghandle(currObj,'figure')&&hMode.ModeStateData.MovePossible



                                                                                                                                                if findMethod(currObj,'findMoveMode')
                                                                                                                                                    moveType=currObj.findMoveMode(evd);
                                                                                                                                                else



                                                                                                                                                    if isscalar(hMode.ModeStateData.SelectedObjects)
                                                                                                                                                        b=hggetbehavior(hMode.ModeStateData.SelectedObjects,'Plotedit','-peek');
                                                                                                                                                        if~isempty(b)
                                                                                                                                                            cb=b.MouseOverFcn;
                                                                                                                                                            if~isempty(cb)
                                                                                                                                                                cursor=feval(cb,hMode.ModeStateData.SelectedObjects,evd);
                                                                                                                                                            end
                                                                                                                                                        end
                                                                                                                                                    end
                                                                                                                                                    if isequal(cursor,0)
                                                                                                                                                        moveType=localFindMoveModeNonScribeObject(currObj,evd.(pointPropName),hMode);
                                                                                                                                                    end
                                                                                                                                                end


                                                                                                                                                if~isscalar(hMode.ModeStateData.SelectedObjects)&&...
                                                                                                                                                    ~strcmpi(moveType,'none')
                                                                                                                                                    moveType='mouseover';
                                                                                                                                                end
                                                                                                                                                if isequal(cursor,0)
                                                                                                                                                    setptr(obj,localConvertMoveType(moveType));
                                                                                                                                                else
                                                                                                                                                    scribecursors(obj,cursor);
                                                                                                                                                end
                                                                                                                                            else
                                                                                                                                                setptr(obj,'arrow');
                                                                                                                                            end


                                                                                                                                            function localSnapMoveWindowButtonMotionFcn(~,evd,hMode)





                                                                                                                                                localFixSelectedObjs(hMode);
                                                                                                                                                propName='Point';
                                                                                                                                                currentMousePoint=evd.(propName);



                                                                                                                                                if~isfield(hMode.ModeStateData,'LastMouseDragPoint')||...
                                                                                                                                                    isempty(hMode.ModeStateData.LastMouseDragPoint)
                                                                                                                                                    hMode.ModeStateData.LastMouseDragPoint=currentMousePoint;
                                                                                                                                                    return;
                                                                                                                                                end


                                                                                                                                                gridstruct=getappdata(hMode.FigureHandle,'scribegui_snapgridstruct');
                                                                                                                                                xspace=gridstruct.xspace;
                                                                                                                                                yspace=gridstruct.yspace;


                                                                                                                                                lastMousePoint=hMode.ModeStateData.LastMouseDragPoint;
                                                                                                                                                diff=currentMousePoint-lastMousePoint;
                                                                                                                                                delta=[0,0];



                                                                                                                                                if abs(diff(1))>=xspace
                                                                                                                                                    delta(1)=round(diff(1)/xspace)*xspace;
                                                                                                                                                end



                                                                                                                                                if abs(diff(2))>=yspace
                                                                                                                                                    delta(2)=round(diff(2)/yspace)*yspace;
                                                                                                                                                end


                                                                                                                                                if isempty(find(abs(delta)>0,1))
                                                                                                                                                    return;
                                                                                                                                                end




                                                                                                                                                if abs(delta(1))>0
                                                                                                                                                    lastMousePoint(1)=currentMousePoint(1);
                                                                                                                                                end
                                                                                                                                                if abs(delta(2))>0
                                                                                                                                                    lastMousePoint(2)=currentMousePoint(2);
                                                                                                                                                end
                                                                                                                                                hMode.ModeStateData.LastMouseDragPoint=lastMousePoint;


                                                                                                                                                selObjs=hMode.ModeStateData.SelectedObjects;

                                                                                                                                                delta=repmat(delta,length(selObjs),1);

                                                                                                                                                localDoSnapMove(hMode,delta,false);



                                                                                                                                                function localDoSnapMove(hMode,delta,updatePoint,currPoints)


                                                                                                                                                    mayMove=true;
                                                                                                                                                    selObjs=hMode.ModeStateData.SelectedObjects;

                                                                                                                                                    updateBasePoint=false(length(selObjs),1);
                                                                                                                                                    hFig=hMode.FigureHandle;

                                                                                                                                                    for i=1:length(selObjs)
                                                                                                                                                        [willSnap,delta(i,:)]=localWillSnap(hFig,selObjs(i),delta(i,:));
                                                                                                                                                        if willSnap
                                                                                                                                                            updateBasePoint(i)=true;
                                                                                                                                                        else
                                                                                                                                                            continue;
                                                                                                                                                        end
                                                                                                                                                        if findMethod(selObjs(i),'mayMove')
                                                                                                                                                            if~selObjs(i).mayMove(delta(i,:))
                                                                                                                                                                mayMove=false;
                                                                                                                                                                break;
                                                                                                                                                            end
                                                                                                                                                        else


                                                                                                                                                            if ishghandle(selObjs(i),'text')&&strcmpi(get(selObjs(i),'Units'),'Data')
                                                                                                                                                                hMode.ModeStateData.MovingTextHandles(end+1)=handle(selObjs(i));
                                                                                                                                                                set(selObjs(i),'Units','pixels');
                                                                                                                                                            end
                                                                                                                                                            if~localMayMoveNonScribeObject(selObjs(i),delta(i,:))
                                                                                                                                                                mayMove=false;
                                                                                                                                                                break;
                                                                                                                                                            end
                                                                                                                                                        end
                                                                                                                                                    end

                                                                                                                                                    if~mayMove
                                                                                                                                                        return;
                                                                                                                                                    end

                                                                                                                                                    for i=1:length(selObjs)
                                                                                                                                                        if~updateBasePoint(i)
                                                                                                                                                            continue;
                                                                                                                                                        end

                                                                                                                                                        if updatePoint
                                                                                                                                                            hMode.ModeStateData.BasePoints(i,:)=currPoints(i,:);
                                                                                                                                                        end
                                                                                                                                                        if findMethod(selObjs(i),'move')
                                                                                                                                                            move(selObjs(i),delta(i,:));
                                                                                                                                                        else
                                                                                                                                                            localMoveNonScribeObject(selObjs(i),delta(i,:));
                                                                                                                                                        end
                                                                                                                                                    end

                                                                                                                                                    drawnow update


                                                                                                                                                    function[update,delta]=localWillSnap(hFig,h,delta)




                                                                                                                                                        gridstruct=getappdata(hFig,'scribegui_snapgridstruct');
                                                                                                                                                        snaptype=gridstruct.snapType;
                                                                                                                                                        xspace=gridstruct.xspace;
                                                                                                                                                        yspace=gridstruct.yspace;
                                                                                                                                                        influ=gridstruct.influence;


                                                                                                                                                        hAncestor=handle(get(h,'Parent'));
                                                                                                                                                        hFig=ancestor(h,'Figure');
                                                                                                                                                        if~ishghandle(hAncestor,'figure')&&~ishghandle(hAncestor,'uipanel')
                                                                                                                                                            hAncestor=hFig;
                                                                                                                                                        end

                                                                                                                                                        if ishghandle(h,'text')
                                                                                                                                                            tUnits=get(h,'Units');
                                                                                                                                                            set(h,'Units','Pixels');
                                                                                                                                                            tPos=get(h,'Position');
                                                                                                                                                            set(h,'Units',tUnits);
                                                                                                                                                            hppos(1:2)=tPos(1:2);
                                                                                                                                                            ext=get(h,'extent');

                                                                                                                                                            hppos(3)=ext(3);hppos(4)=ext(4);
                                                                                                                                                        else
                                                                                                                                                            hppos=hgconvertunits(hFig,get(h,'Position'),get(h,'Units'),'Pixels',hAncestor);
                                                                                                                                                        end


                                                                                                                                                        HPX=hppos(1)+hppos(3)/2;HPY=hppos(2)+hppos(4)/2;
                                                                                                                                                        PX=HPX;PY=HPY;


                                                                                                                                                        IPX=PX+delta(1);
                                                                                                                                                        IPY=PY+delta(2);


                                                                                                                                                        switch snaptype
                                                                                                                                                        case 'top'
                                                                                                                                                            SX=IPX;
                                                                                                                                                            SY=IPY+hppos(4)/2;
                                                                                                                                                        case 'bottom'
                                                                                                                                                            SX=IPX;
                                                                                                                                                            SY=IPY-hppos(4)/2;
                                                                                                                                                        case 'left'
                                                                                                                                                            SX=IPX-hppos(3)/2;
                                                                                                                                                            SY=IPY;
                                                                                                                                                        case 'right'
                                                                                                                                                            SX=IPX+hppos(3)/2;
                                                                                                                                                            SY=IPY;
                                                                                                                                                        case 'center'
                                                                                                                                                            SX=IPX;
                                                                                                                                                            SY=IPY;
                                                                                                                                                        case 'topleft'
                                                                                                                                                            SX=IPX-hppos(3)/2;
                                                                                                                                                            SY=IPY+hppos(4)/2;
                                                                                                                                                        case 'topright'
                                                                                                                                                            SX=IPX+hppos(3)/2;
                                                                                                                                                            SY=IPY+hppos(4)/2;
                                                                                                                                                        case 'bottomleft'
                                                                                                                                                            SX=IPX-hppos(3)/2;
                                                                                                                                                            SY=IPY-hppos(4)/2;
                                                                                                                                                        case 'bottomright'
                                                                                                                                                            SX=IPX+hppos(3)/2;
                                                                                                                                                            SY=IPY-hppos(4)/2;
                                                                                                                                                        end

                                                                                                                                                        xoff=mod(SX,xspace);
                                                                                                                                                        yoff=mod(SY,yspace);
                                                                                                                                                        if xoff>(xspace/2)
                                                                                                                                                            xoff=xoff-xspace;
                                                                                                                                                        end
                                                                                                                                                        if yoff>(yspace/2)
                                                                                                                                                            yoff=yoff-yspace;
                                                                                                                                                        end
                                                                                                                                                        update=false;

                                                                                                                                                        if xoff<influ

                                                                                                                                                            switch snaptype
                                                                                                                                                            case{'top','bottom','center'}
                                                                                                                                                                PX=(round(SX/xspace)*xspace);
                                                                                                                                                            case{'left','topleft','bottomleft'}
                                                                                                                                                                PX=(round(SX/xspace)*xspace)+hppos(3)/2;
                                                                                                                                                            case{'right','topright','bottomright'}
                                                                                                                                                                PX=(round(SX/xspace)*xspace)-hppos(3)/2;
                                                                                                                                                            end
                                                                                                                                                            if abs(HPX-PX)>1
                                                                                                                                                                update=true;
                                                                                                                                                            end
                                                                                                                                                        elseif abs(IPX-HPX)>1
                                                                                                                                                            PX=IPX;
                                                                                                                                                            update=true;
                                                                                                                                                        end

                                                                                                                                                        if yoff<influ

                                                                                                                                                            switch snaptype
                                                                                                                                                            case{'top','topleft','topright'}
                                                                                                                                                                PY=(round(SY/yspace)*yspace)-hppos(4)/2;
                                                                                                                                                            case{'bottom','bottomleft','bottomright'}
                                                                                                                                                                PY=(round(SY/yspace)*yspace)+hppos(4)/2;
                                                                                                                                                            case{'left','right','center'}
                                                                                                                                                                PY=(round(SY/yspace)*yspace);
                                                                                                                                                            end
                                                                                                                                                            if abs(HPY-PY)>1
                                                                                                                                                                update=true;
                                                                                                                                                            end
                                                                                                                                                        elseif abs(IPY-PY)>1
                                                                                                                                                            PY=IPY;
                                                                                                                                                            update=true;
                                                                                                                                                        end


                                                                                                                                                        if update
                                                                                                                                                            newX=PX-hppos(3)/2;
                                                                                                                                                            newY=PY-hppos(4)/2;
                                                                                                                                                            delta=[newX-hppos(1),newY-hppos(2)];
                                                                                                                                                        end


                                                                                                                                                        function localMoveWindowButtonMotionFcn(obj,evd,hMode)



                                                                                                                                                            propName='Point';
                                                                                                                                                            currPoint=hgconvertunits(obj,[evd.(propName),0,0],obj.Units,'pixels',obj);
                                                                                                                                                            currPoint=currPoint(1:2);

                                                                                                                                                            delta=currPoint-hMode.ModeStateData.CurrPoint;
                                                                                                                                                            if max(abs(delta))<1





                                                                                                                                                                return
                                                                                                                                                            end


                                                                                                                                                            localDoMove(hMode,delta,true,currPoint);



                                                                                                                                                            drawnow update


                                                                                                                                                            function localDoMove(hMode,delta,updatePoint,currPoint)




                                                                                                                                                                if~hMode.ModeStateData.isDragging
                                                                                                                                                                    hMode.ModeStateData.PlotManagerListener.Enabled=false;
                                                                                                                                                                    matlab.graphics.internal.setListenerState(hMode.UIControlSuspendListener,'off');
                                                                                                                                                                    if isprop(hMode.FigureHandle,'UISelectionHandles')&&~isempty(hMode.FigureHandle.UISelectionHandles)&&all(ishghandle(hMode.FigureHandle.UISelectionHandles))
                                                                                                                                                                        set(hMode.FigureHandle.UISelectionHandles,'Visible','off')
                                                                                                                                                                    end

                                                                                                                                                                    hMode.ModeStateData.isDragging=true;



                                                                                                                                                                    hMode.ModeStateData.SelectedObjectsHasMayMoveMethod=false(length(hMode.ModeStateData.SelectedObjects),1);
                                                                                                                                                                    for k=1:length(hMode.ModeStateData.SelectedObjects)
                                                                                                                                                                        hMode.ModeStateData.SelectedObjectsHasMayMoveMethod(k)=findMethod(hMode.ModeStateData.SelectedObjects(k),'mayMove');
                                                                                                                                                                        hMode.ModeStateData.SelectedObjectsHasMoveMethod(k)=findMethod(hMode.ModeStateData.SelectedObjects(k),'move');
                                                                                                                                                                    end
                                                                                                                                                                end




                                                                                                                                                                mayMove=true;
                                                                                                                                                                selObjs=hMode.ModeStateData.SelectedObjects;


                                                                                                                                                                for i=1:length(selObjs)
                                                                                                                                                                    if hMode.ModeStateData.SelectedObjectsHasMayMoveMethod(i)&&findMethod(hMode.ModeStateData.SelectedObjects(i),'mayMove')
                                                                                                                                                                        if~selObjs(i).mayMove(delta)
                                                                                                                                                                            mayMove=false;
                                                                                                                                                                            break;
                                                                                                                                                                        end
                                                                                                                                                                    else
                                                                                                                                                                        if~localMayMoveNonScribeObject(selObjs(i),delta)
                                                                                                                                                                            mayMove=false;
                                                                                                                                                                            break;
                                                                                                                                                                        end
                                                                                                                                                                    end
                                                                                                                                                                end

                                                                                                                                                                if~mayMove
                                                                                                                                                                    return;
                                                                                                                                                                end

                                                                                                                                                                if updatePoint

                                                                                                                                                                    modeStateData=hMode.ModeStateData;
                                                                                                                                                                    modeStateData.CurrPoint=currPoint;
                                                                                                                                                                    hMode.ModeStateData=modeStateData;
                                                                                                                                                                end

                                                                                                                                                                for i=1:length(selObjs)
                                                                                                                                                                    if hMode.ModeStateData.SelectedObjectsHasMoveMethod(i)&&findMethod(hMode.ModeStateData.SelectedObjects(i),'move')
                                                                                                                                                                        move(selObjs(i),delta);
                                                                                                                                                                        matlab.graphics.interaction.generateLiveCode(ancestor(selObjs(i),'figure'),matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED);
                                                                                                                                                                        matlab.graphics.interaction.generateLiveCode(selObjs(i),matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED);
                                                                                                                                                                    else
                                                                                                                                                                        localMoveNonScribeObject(selObjs(i),delta);
                                                                                                                                                                    end
                                                                                                                                                                end


                                                                                                                                                                function moveType=localFindMoveModeNonScribeObject(obj,point,hMode)





                                                                                                                                                                    moveType='none';



                                                                                                                                                                    if ishghandle(obj,'text')
                                                                                                                                                                        moveType='mouseover';
                                                                                                                                                                        hMode.ModeStateData.NonScribeMoveMode=moveType;
                                                                                                                                                                        return;
                                                                                                                                                                    end


                                                                                                                                                                    hAncestor=handle(get(obj,'Parent'));
                                                                                                                                                                    hFig=ancestor(obj,'Figure');

                                                                                                                                                                    if~strcmpi(hFig.Units,'Pixels')

                                                                                                                                                                        pointPixels=hgconvertunits(hFig,[hFig.Position(1:2),point],hFig.Units,'Pixels',hFig);
                                                                                                                                                                        px=pointPixels(3);
                                                                                                                                                                        py=pointPixels(4);
                                                                                                                                                                    else
                                                                                                                                                                        px=point(1);
                                                                                                                                                                        py=point(2);
                                                                                                                                                                    end




                                                                                                                                                                    if isa(obj,'matlab.graphics.axis.AbstractAxes')
                                                                                                                                                                        selectionHandlePixelPositions=localSelectionHandlePixelPositions(obj);


                                                                                                                                                                        if~isempty(selectionHandlePixelPositions)
                                                                                                                                                                            XL=min(selectionHandlePixelPositions(1,:));
                                                                                                                                                                            XR=max(selectionHandlePixelPositions(1,:));
                                                                                                                                                                            YL=min(selectionHandlePixelPositions(2,:));
                                                                                                                                                                            YU=max(selectionHandlePixelPositions(2,:));
                                                                                                                                                                            XC=mean([XL,XR]);
                                                                                                                                                                            YC=mean([YL,YU]);
                                                                                                                                                                        else
                                                                                                                                                                            moveType='none';
                                                                                                                                                                            return
                                                                                                                                                                        end
                                                                                                                                                                    else

                                                                                                                                                                        objPos=getpixelposition(obj,true);


                                                                                                                                                                        XC=objPos(1)+objPos(3)/2;
                                                                                                                                                                        YC=objPos(2)+objPos(4)/2;


                                                                                                                                                                        XL=objPos(1);
                                                                                                                                                                        XR=objPos(1)+objPos(3);
                                                                                                                                                                        YU=objPos(2)+objPos(4);
                                                                                                                                                                        YL=objPos(2);
                                                                                                                                                                    end





                                                                                                                                                                    a2=6;


                                                                                                                                                                    if XL<=px&&px<=XR&&...
                                                                                                                                                                        YL<=py&&py<=YU
                                                                                                                                                                        moveType='mouseover';

                                                                                                                                                                        if ishghandle(obj,'axes')
                                                                                                                                                                            hB=hggetbehavior(obj,'Plotedit','-peek');


                                                                                                                                                                            if isempty(hB)||~hB.AllowInteriorMove
                                                                                                                                                                                moveType='none';
                                                                                                                                                                            end
                                                                                                                                                                        end
                                                                                                                                                                    end


                                                                                                                                                                    if(any(abs([XL,XR]-px)<=a2)&&YL<=py&&py<=YU)||...
                                                                                                                                                                        (any(abs([YL,YU]-py)<=a2)&&XL<=px&&px<=XR)
                                                                                                                                                                        moveType='mouseover';
                                                                                                                                                                    end




                                                                                                                                                                    if XL-a2<=px&&px<=XL+a2&&...
                                                                                                                                                                        YU-a2<=py&&py<=YU+a2
                                                                                                                                                                        moveType='topleft';

                                                                                                                                                                    elseif XR-a2<=px&&px<=XR+a2&&...
                                                                                                                                                                        YU-a2<=py&&py<=YU+a2
                                                                                                                                                                        moveType='topright';

                                                                                                                                                                    elseif XR-a2<=px&&px<=XR+a2&&...
                                                                                                                                                                        YL-a2<=py&&py<=YL+a2
                                                                                                                                                                        moveType='bottomright';

                                                                                                                                                                    elseif XL-a2<=px&&px<=XL+a2&&...
                                                                                                                                                                        YL-a2<=py&&py<=YL+a2
                                                                                                                                                                        moveType='bottomleft';

                                                                                                                                                                    elseif XL-a2<=px&&px<=XL+a2&&...
                                                                                                                                                                        YC-a2<=py&&py<=YC+a2
                                                                                                                                                                        moveType='left';

                                                                                                                                                                    elseif XC-a2<=px&&px<=XC+a2&&...
                                                                                                                                                                        YU-a2<=py&&py<=YU+a2
                                                                                                                                                                        moveType='top';

                                                                                                                                                                    elseif XR-a2<=px&&px<=XR+a2&&...
                                                                                                                                                                        YC-a2<=py&&py<=YC+a2
                                                                                                                                                                        moveType='right';

                                                                                                                                                                    elseif XC-a2<=px&&px<=XC+a2&&...
                                                                                                                                                                        YL-a2<=py&&py<=YL+a2
                                                                                                                                                                        moveType='bottom';
                                                                                                                                                                    end

                                                                                                                                                                    hMode.ModeStateData.NonScribeMoveMode=moveType;


                                                                                                                                                                    function res=localMayMoveNonScribeObject(obj,delta)






                                                                                                                                                                        delta(1)=delta(1)+4*sign(delta(1));
                                                                                                                                                                        delta(2)=delta(2)+4*sign(delta(2));


                                                                                                                                                                        hFig=ancestor(obj,'figure');
                                                                                                                                                                        delta=hgconvertunits(hFig,[0,0,delta],'pixels','normalized',hFig);
                                                                                                                                                                        delta=delta(3:4);

                                                                                                                                                                        hContainer=ancestor(obj,{'figure','uipanel','uitab','uicontainer'});







                                                                                                                                                                        if ishghandle(obj,'text')
                                                                                                                                                                            oldUnits=obj.Units;


                                                                                                                                                                            obj.Units='Pixels';

                                                                                                                                                                            objPos=obj.Extent;
                                                                                                                                                                            hPar=obj.Parent;
                                                                                                                                                                            if isprop(hPar,'Units')&&isprop(hPar,'Position')
                                                                                                                                                                                parentPos=hgconvertunits(hFig,hPar.Position,hPar.Units,'Pixels',hContainer);
                                                                                                                                                                                objPos(1:2)=objPos(1:2)+parentPos(1:2);
                                                                                                                                                                            end


                                                                                                                                                                            objPos=hgconvertunits(hFig,objPos,'Pixels','Normalized',hContainer);

                                                                                                                                                                            obj.Units=oldUnits;
                                                                                                                                                                        else
                                                                                                                                                                            objPos=hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'normalized',hContainer);
                                                                                                                                                                        end

                                                                                                                                                                        selData=[objPos(1),objPos(2);...
                                                                                                                                                                        objPos(1),objPos(2)+objPos(4)/2;...
                                                                                                                                                                        objPos(1),objPos(2)+objPos(4);...
                                                                                                                                                                        objPos(1)+objPos(3)/2,objPos(2);...
                                                                                                                                                                        objPos(1)+objPos(3)/2,objPos(2)+objPos(4)/2;...
                                                                                                                                                                        objPos(1)+objPos(3)/2,objPos(2)+objPos(4);...
                                                                                                                                                                        objPos(1)+objPos(3),objPos(2);...
                                                                                                                                                                        objPos(1)+objPos(3),objPos(2)+objPos(4)/2;...
                                                                                                                                                                        objPos(1)+objPos(3),objPos(2)+objPos(4)];


                                                                                                                                                                        delta=repmat(delta,size(selData,1),1);
                                                                                                                                                                        selData=selData+delta;



                                                                                                                                                                        clippedData=[~(selData(:,1)<0),~(selData(:,1)>1),...
                                                                                                                                                                        ~(selData(:,2)<0),~(selData(:,2)>1)];



                                                                                                                                                                        res=any(min(clippedData,[],2));



                                                                                                                                                                        function localMoveNonScribeObject(obj,delta)




                                                                                                                                                                            if isempty(obj)||~isvalid(obj)
                                                                                                                                                                                return;
                                                                                                                                                                            end


                                                                                                                                                                            hFig=ancestor(obj,'figure');
                                                                                                                                                                            hAncestor=handle(ancestor(get(obj,'Parent'),'matlab.ui.internal.mixin.CanvasHostMixin'));






                                                                                                                                                                            if ishghandle(obj,'text')
                                                                                                                                                                                oldUnits=get(obj,'Units');

                                                                                                                                                                                set(obj,'Units','Pixels');

                                                                                                                                                                                objPos=get(obj,'Position');
                                                                                                                                                                                objPos(1:2)=objPos(1:2)+delta;

                                                                                                                                                                                set(obj,'Position',objPos);

                                                                                                                                                                                set(obj,'Units',oldUnits);
                                                                                                                                                                            else
                                                                                                                                                                                if isvalid(hFig)&&isvalid(hAncestor)
                                                                                                                                                                                    pixPos=hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'pixels',hAncestor);
                                                                                                                                                                                    pixPos(1:2)=pixPos(1:2)+delta;

                                                                                                                                                                                    detachFromLayoutManagement(obj,hAncestor);
                                                                                                                                                                                    set(obj,'Position',hgconvertunits(hFig,pixPos,'pixels',get(obj,'Units'),hAncestor));
                                                                                                                                                                                end
                                                                                                                                                                            end


                                                                                                                                                                            function localResizeNonScribeObject(obj,point,moveType)




                                                                                                                                                                                hFig=ancestor(obj,'Figure');
                                                                                                                                                                                hAncestor=handle(ancestor(get(obj,'Parent'),'matlab.ui.internal.mixin.CanvasHostMixin'));




                                                                                                                                                                                if~strcmpi(hFig.Units,'Pixels')

                                                                                                                                                                                    pointPix=hgconvertunits(hFig,[hFig.Position(1:2),point],hFig.Units,'Pixels',hFig);
                                                                                                                                                                                    point=pointPix(3:4);
                                                                                                                                                                                end


                                                                                                                                                                                insets=[];

                                                                                                                                                                                if is3DAxes(obj)
                                                                                                                                                                                    selectionHandlePixelPositions=localSelectionHandlePixelPositions(obj);


                                                                                                                                                                                    if isempty(selectionHandlePixelPositions)
                                                                                                                                                                                        return
                                                                                                                                                                                    end
                                                                                                                                                                                    XL=min(selectionHandlePixelPositions(1,:));
                                                                                                                                                                                    XR=max(selectionHandlePixelPositions(1,:));
                                                                                                                                                                                    YL=min(selectionHandlePixelPositions(2,:));
                                                                                                                                                                                    YU=max(selectionHandlePixelPositions(2,:));
                                                                                                                                                                                    objPos=hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'Pixels',hAncestor);
                                                                                                                                                                                    insets=[XL-objPos(1),YL-objPos(2),objPos(3)-(XR-XL),objPos(4)-(YU-YL)];
                                                                                                                                                                                    objPos=[XL,YL,XR-XL,YU-YL];
                                                                                                                                                                                else
                                                                                                                                                                                    objPos=hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'Pixels',hAncestor);
                                                                                                                                                                                    if~ishghandle(hAncestor,'figure')
                                                                                                                                                                                        ancPos=getpixelposition(hAncestor,true);
                                                                                                                                                                                        point=point-ancPos(1:2);
                                                                                                                                                                                    end


                                                                                                                                                                                    XL=objPos(1);
                                                                                                                                                                                    XR=objPos(1)+objPos(3);
                                                                                                                                                                                    YU=objPos(2)+objPos(4);
                                                                                                                                                                                    YL=objPos(2);
                                                                                                                                                                                end

                                                                                                                                                                                minWidth=2;
                                                                                                                                                                                minHeight=2;
                                                                                                                                                                                if~is3DAxes(obj)&&localIsPolarOrLockedPlotBox(obj)



                                                                                                                                                                                    li=GetLayoutInformation(obj);
                                                                                                                                                                                    obj.Position=hgconvertunits(hFig,li.PlotBox,'Pixels',get(obj,'Units'),hAncestor);
                                                                                                                                                                                    objPos=getPositionForLockedPlotBox(obj,moveType,point);
                                                                                                                                                                                else





                                                                                                                                                                                    switch moveType
                                                                                                                                                                                    case 'topleft'


                                                                                                                                                                                        XL=min(point(1),floor(XR)-minWidth);
                                                                                                                                                                                        YU=max(point(2),ceil(YL));
                                                                                                                                                                                    case 'topright'
                                                                                                                                                                                        XR=max(point(1),floor(XL));
                                                                                                                                                                                        YU=max(point(2),ceil(YL));
                                                                                                                                                                                    case 'bottomright'
                                                                                                                                                                                        XR=max(point(1),ceil(XL));
                                                                                                                                                                                        YL=min(point(2),floor(YU)-minHeight);
                                                                                                                                                                                    case 'bottomleft'
                                                                                                                                                                                        XL=min(point(1),floor(XR)-minWidth);
                                                                                                                                                                                        YL=min(point(2),floor(YU)-minHeight);
                                                                                                                                                                                    case 'left'
                                                                                                                                                                                        XL=min(point(1),floor(XR)-minWidth);
                                                                                                                                                                                    case 'top'
                                                                                                                                                                                        YU=max(point(2),ceil(YL));
                                                                                                                                                                                    case 'right'
                                                                                                                                                                                        XR=max(point(1),ceil(XL));
                                                                                                                                                                                    case 'bottom'
                                                                                                                                                                                        YL=min(point(2),floor(YU)-minHeight);
                                                                                                                                                                                    otherwise
                                                                                                                                                                                        return;
                                                                                                                                                                                    end


                                                                                                                                                                                    objPos(1)=XL;
                                                                                                                                                                                    objPos(2)=YL;
                                                                                                                                                                                    objPos(3)=XR-XL;
                                                                                                                                                                                    objPos(4)=YU-YL;
                                                                                                                                                                                end


                                                                                                                                                                                if~isempty(insets)
                                                                                                                                                                                    objPos=[objPos(1:2)-insets(1:2),objPos(3:4)+insets(3:4)];
                                                                                                                                                                                end


                                                                                                                                                                                objPos(3)=max(objPos(3),minWidth);
                                                                                                                                                                                objPos(4)=max(objPos(4),minHeight);

                                                                                                                                                                                objPos=hgconvertunits(hFig,objPos,'Pixels',get(obj,'Units'),hAncestor);
                                                                                                                                                                                detachFromLayoutManagement(obj,hAncestor);
                                                                                                                                                                                set(obj,'position',objPos);





                                                                                                                                                                                function ret=localIsPolarOrLockedPlotBox(obj)
                                                                                                                                                                                    ret=false;
                                                                                                                                                                                    if isa(obj,'matlab.graphics.axis.AbstractAxes')
                                                                                                                                                                                        if isa(obj,'matlab.graphics.axis.PolarAxes')...
                                                                                                                                                                                            ||(isprop(obj,'PlotBoxAspectRatioMode')...
                                                                                                                                                                                            &&strcmpi(obj.PlotBoxAspectRatioMode,'manual'))
                                                                                                                                                                                            ret=true;
                                                                                                                                                                                        end
                                                                                                                                                                                    end



                                                                                                                                                                                    function localFixSelectedObjs(hMode)


                                                                                                                                                                                        hMode.ModeStateData.SelectedObjects(~ishghandle(hMode.ModeStateData.SelectedObjects))=[];


                                                                                                                                                                                        function localUpdateNonScribeContextMenu(hObj,hMenuItems)

                                                                                                                                                                                            className=class(handle(hObj));

                                                                                                                                                                                            switch className
                                                                                                                                                                                            case{'axes','matlab.graphics.axis.Axes'}

                                                                                                                                                                                                legendmenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.ShowLegend']);
                                                                                                                                                                                                if~isempty(legendmenu)
                                                                                                                                                                                                    legh=get(double(hObj),'Legend');
                                                                                                                                                                                                    if isempty(legh)||strcmpi(get(legh,'Visible'),'off')
                                                                                                                                                                                                        set(legendmenu,'Label',getString(message('MATLAB:uistring:scribemenu:ShowLegend')));
                                                                                                                                                                                                    else
                                                                                                                                                                                                        set(legendmenu,'Label',getString(message('MATLAB:uistring:scribemenu:HideLegend')));
                                                                                                                                                                                                    end
                                                                                                                                                                                                end

                                                                                                                                                                                                gridMenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.Grid']);
                                                                                                                                                                                                if strcmpi(get(hObj,'XGrid'),'on')&&strcmpi(get(hObj,'YGrid'),'on')...
                                                                                                                                                                                                    &&strcmpi(get(hObj,'ZGrid'),'on')
                                                                                                                                                                                                    set(gridMenu,'Checked','on');
                                                                                                                                                                                                else
                                                                                                                                                                                                    set(gridMenu,'Checked','off');
                                                                                                                                                                                                end
                                                                                                                                                                                            case{'specgraph.contourgroup','matlab.graphics.chart.primitive.Contour','matlab.graphics.function.FunctionContour'}

                                                                                                                                                                                                fillMenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.Fill']);
                                                                                                                                                                                                if strcmpi(get(hObj,'Fill'),'on')
                                                                                                                                                                                                    set(fillMenu,'Checked','on');
                                                                                                                                                                                                else
                                                                                                                                                                                                    set(fillMenu,'Checked','off');
                                                                                                                                                                                                end
                                                                                                                                                                                            case{'matlab.graphics.chart.primitive.Histogram2'}

                                                                                                                                                                                                sebMenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.ShowEmptyBins']);
                                                                                                                                                                                                if strcmpi(get(hObj,'ShowEmptyBins'),'on')
                                                                                                                                                                                                    set(sebMenu,'Checked','on');
                                                                                                                                                                                                else
                                                                                                                                                                                                    set(sebMenu,'Checked','off');
                                                                                                                                                                                                end
                                                                                                                                                                                            end


                                                                                                                                                                                            function localPostEnableUpdateContextMenu(hObj,hMode,hMenuItems)


                                                                                                                                                                                                if isa(hObj,'matlab.graphics.chart.primitive.Histogram')||...
                                                                                                                                                                                                    isa(hObj,'matlab.graphics.chart.primitive.categorical.Histogram')
                                                                                                                                                                                                    className=class(handle(hObj));
                                                                                                                                                                                                    displayordermenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.DisplayOrder']);
                                                                                                                                                                                                    if~isempty(displayordermenu)
                                                                                                                                                                                                        ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
                                                                                                                                                                                                        if(~isempty(ax)&&isscalar(ax.Children))||...
                                                                                                                                                                                                            ~isscalar(hMode.ModeStateData.SelectedObjects)
                                                                                                                                                                                                            set(displayordermenu,'Enable','off');
                                                                                                                                                                                                        else
                                                                                                                                                                                                            set(findall(displayordermenu,'Type','uimenu'),'Enable','on');
                                                                                                                                                                                                            if isequal(hObj,ax.Children(1))

                                                                                                                                                                                                                set(findall(displayordermenu,'Tag','DisplayOrder.BringToFront'),...
                                                                                                                                                                                                                'Enable','off');
                                                                                                                                                                                                                set(findall(displayordermenu,'Tag','DisplayOrder.BringForward'),...
                                                                                                                                                                                                                'Enable','off');
                                                                                                                                                                                                            elseif isequal(hObj,ax.Children(end))

                                                                                                                                                                                                                set(findall(displayordermenu,'Tag','DisplayOrder.SendToBack'),...
                                                                                                                                                                                                                'Enable','off');
                                                                                                                                                                                                                set(findall(displayordermenu,'Tag','DisplayOrder.SendBackward'),...
                                                                                                                                                                                                                'Enable','off');
                                                                                                                                                                                                            end
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end

                                                                                                                                                                                                    alignbinsmenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.AlignBins']);
                                                                                                                                                                                                    if~isempty(alignbinsmenu)
                                                                                                                                                                                                        if isscalar(hMode.ModeStateData.SelectedObjects)||...
                                                                                                                                                                                                            any(strcmp(get(hMode.ModeStateData.SelectedObjects,'BinCountsMode'),'manual'))
                                                                                                                                                                                                            set(alignbinsmenu,'Enable','off');
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end

                                                                                                                                                                                                    morebinsmenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.morebins']);
                                                                                                                                                                                                    if~isempty(morebinsmenu)
                                                                                                                                                                                                        if strcmp(hObj.BinCountsMode,'manual')
                                                                                                                                                                                                            set(morebinsmenu,'Enable','off');
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end
                                                                                                                                                                                                    fewerbinsmenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.fewerbins']);
                                                                                                                                                                                                    if~isempty(fewerbinsmenu)
                                                                                                                                                                                                        if strcmp(hObj.BinCountsMode,'manual')
                                                                                                                                                                                                            set(fewerbinsmenu,'Enable','off');
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end
                                                                                                                                                                                                end

                                                                                                                                                                                                if isa(hObj,'matlab.graphics.chart.primitive.Histogram2')
                                                                                                                                                                                                    className=class(handle(hObj));
                                                                                                                                                                                                    morebinsmenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.morebins2D']);
                                                                                                                                                                                                    if~isempty(morebinsmenu)
                                                                                                                                                                                                        if strcmp(hObj.BinCountsMode,'manual')
                                                                                                                                                                                                            set(morebinsmenu,'Enable','off');
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end
                                                                                                                                                                                                    fewerbinsmenu=findall(hMenuItems,'Tag',[sprintf('scribe.%s.uicontextmenu',className),'.fewerbins2D']);
                                                                                                                                                                                                    if~isempty(fewerbinsmenu)
                                                                                                                                                                                                        if strcmp(hObj.BinCountsMode,'manual')
                                                                                                                                                                                                            set(fewerbinsmenu,'Enable','off');
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end
                                                                                                                                                                                                end


                                                                                                                                                                                                function hMenuItems=localGetNonScribeScribeContextMenu(hMode,hObj)


                                                                                                                                                                                                    hObj=handle(hObj);
                                                                                                                                                                                                    objClass=class(hObj);

                                                                                                                                                                                                    allMenuItems=findall(hMode.UIContextMenu,'Type','uimenu');
                                                                                                                                                                                                    allTags=get(allMenuItems,'Tag');
                                                                                                                                                                                                    hMenuItems=[];
                                                                                                                                                                                                    for i=1:length(allTags)
                                                                                                                                                                                                        if strfind(allTags{i},sprintf('scribe.%s.uicontextmenu',objClass))
                                                                                                                                                                                                            hMenuItems(end+1)=allMenuItems(i);%#ok<AGROW>
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end


                                                                                                                                                                                                    if~isempty(hMenuItems)
                                                                                                                                                                                                        hMenuItems=hMenuItems(end:-1:1);
                                                                                                                                                                                                        return;
                                                                                                                                                                                                    end


                                                                                                                                                                                                    menuSpecificTags=[];
                                                                                                                                                                                                    switch objClass
                                                                                                                                                                                                    case{'axes','matlab.graphics.axis.Axes'}
                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LegendToggle',getString(message('MATLAB:uistring:scribemenu:ShowLegend')),'','');

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));
                                                                                                                                                                                                        set(hMenuItems(end),'Separator','on');

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Font',getString(message('MATLAB:uistring:scribemenu:FontDotDotDot')),'',getString(message('MATLAB:uistring:scribemenu:Font')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Toggle',getString(message('MATLAB:uistring:scribemenu:Grid')),{'XGrid','YGrid','ZGrid'},getString(message('MATLAB:uistring:scribemenu:Grid')));
                                                                                                                                                                                                        set(hMenuItems(end),'Separator','on');
                                                                                                                                                                                                        menuSpecificTags={'ShowLegend','Color','Font','Grid'};
                                                                                                                                                                                                    case{'graph2d.lineseries','line','matlab.graphics.chart.primitive.Line','matlab.graphics.primitive.Line',...
                                                                                                                                                                                                        'matlab.graphics.function.FunctionLine','matlab.graphics.function.ParameterizedFunctionLine'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')),'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')),'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')));
                                                                                                                                                                                                        menuSpecificTags={'Color','LineStyle','LineWidth','Marker','MarkerSize'};
                                                                                                                                                                                                    case{'patch','surface','graph3d.surfaceplot','matlab.graphics.chart.primitive.Surface','matlab.graphics.primitive.Surface','matlab.graphics.primitive.Patch',...
                                                                                                                                                                                                        'matlab.graphics.function.FunctionSurface','matlab.graphics.function.ParameterizedFunctionSurface'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));


                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')),'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')),'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')));
                                                                                                                                                                                                        menuSpecificTags={'FaceColor','EdgeColor','LineStyle','LineWidth','Marker','MarkerSize'};
                                                                                                                                                                                                    case{'rectangle','matlab.graphics.primitive.Rectangle'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));


                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));
                                                                                                                                                                                                        menuSpecificTags={'FaceColor','EdgeColor','LineStyle','LineWidth'};
                                                                                                                                                                                                    case{'text','matlab.graphics.primitive.Text'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'EditText',getString(message('MATLAB:uistring:scribemenu:Edit')),'','');

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:TextColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:TextColor')));
                                                                                                                                                                                                        set(hMenuItems,'Separator','on');

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:BackgroundColorDotDotDot')),'BackgroundColor',getString(message('MATLAB:uistring:scribemenu:BackgroundColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Font',getString(message('MATLAB:uistring:scribemenu:FontDotDotDot')),'',getString(message('MATLAB:uistring:scribemenu:Font')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'TextInterpreter',getString(message('MATLAB:uistring:scribemenu:Interpreter')),'Interpreter',getString(message('MATLAB:uistring:scribemenu:Interpreter')));


                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));
                                                                                                                                                                                                        menuSpecificTags={'Edit','TextColor','BackgroundColor','EdgeColor','Font','Interpreter','LineStyle','LineWidth'};
                                                                                                                                                                                                    case{'figure','matlab.ui.Figure'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'CloseFigure',getString(message('MATLAB:uistring:scribemenu:CloseFigure')),'','');
                                                                                                                                                                                                        menuSpecificTags={'Color','CloseFigure'};
                                                                                                                                                                                                    case{'specgraph.areaseries','matlab.graphics.chart.primitive.Area'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));


                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));
                                                                                                                                                                                                        menuSpecificTags={'FaceColor','EdgeColor','LineStyle','LineWidth'};
                                                                                                                                                                                                    case{'specgraph.barseries','matlab.graphics.chart.primitive.Bar'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'BarWidth',getString(message('MATLAB:uistring:scribemenu:BarWidth')),'BarWidth',getString(message('MATLAB:uistring:scribemenu:BarWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'BarLayout',getString(message('MATLAB:uistring:scribemenu:BarLayout')),'BarLayout',getString(message('MATLAB:uistring:scribemenu:BarLayout')));
                                                                                                                                                                                                        menuSpecificTags={'FaceColor','EdgeColor','BarWidth','BarLayout'};
                                                                                                                                                                                                    case{'specgraph.contourgroup','matlab.graphics.chart.primitive.Contour','matlab.graphics.function.FunctionContour'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:LineColorDotDotDot')),'LineColor',getString(message('MATLAB:uistring:scribemenu:LineColor')));


                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Toggle',getString(message('MATLAB:uistring:scribemenu:Fill')),'Fill',getString(message('MATLAB:uistring:scribemenu:Fill')));
                                                                                                                                                                                                        menuSpecificTags={'LineColor','LineStyle','LineWidth','Fill'};
                                                                                                                                                                                                    case{'specgraph.quivergroup','matlab.graphics.chart.primitive.Quiver'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));


                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));


                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')),'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')),'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'AutoScaleFactor',getString(message('MATLAB:uistring:scribemenu:ScaleFactor')),'AutoScaleFactor',getString(message('MATLAB:uistring:scribemenu:ScaleFactor')));
                                                                                                                                                                                                        menuSpecificTags={'Color','LineStyle','LineWidth','Marker','MarkerSize','AutoScaleFactor'};
                                                                                                                                                                                                    case{'specgraph.scattergroup','matlab.graphics.chart.primitive.Scatter'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:MarkerFaceColorDotDotDot')),'MarkerFaceColor',getString(message('MATLAB:uistring:scribemenu:MarkerFaceColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:MarkerEdgeColorDotDotDot')),'MarkerEdgeColor',getString(message('MATLAB:uistring:scribemenu:MarkerEdgeColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')),'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')));
                                                                                                                                                                                                        menuSpecificTags={'MarkerFaceColor','MarkerEdgeColor','Marker'};
                                                                                                                                                                                                    case{'specgraph.stairseries','specgraph.stemseries',...
                                                                                                                                                                                                        'matlab.graphics.chart.primitive.Stair','matlab.graphics.chart.primitive.Stem'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')),'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')),'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')));
                                                                                                                                                                                                        menuSpecificTags={'Color','LineStyle','LineWidth','Marker','MarkerSize'};
                                                                                                                                                                                                    case{'specgraph.errorbarseries','matlab.graphics.chart.primitive.ErrorBar'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'CapSize',getString(message('MATLAB:uistring:scribemenu:CapSize')),'CapSize',getString(message('MATLAB:uistring:scribemenu:CapSize')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')),'Marker',getString(message('MATLAB:uistring:scribemenu:Marker')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')),'MarkerSize',getString(message('MATLAB:uistring:scribemenu:MarkerSize')));
                                                                                                                                                                                                        menuSpecificTags={'CapSize','Color','LineStyle','LineWidth','Marker','MarkerSize'};
                                                                                                                                                                                                    case{'matlab.graphics.chart.primitive.Histogram'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'morebins',getString(message('MATLAB:uistring:scribemenu:morebins')),'morebins',getString(message('MATLAB:uistring:scribemenu:morebins')));
                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'fewerbins',getString(message('MATLAB:uistring:scribemenu:fewerbins')),'fewerbins',getString(message('MATLAB:uistring:scribemenu:fewerbins')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'AlignBins',getString(message('MATLAB:uistring:scribemenu:AlignBins')),'',getString(message('MATLAB:uistring:scribemenu:AlignBins')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'DisplayStyle',getString(message('MATLAB:uistring:scribemenu:DisplayStyle')),'DisplayStyle',getString(message('MATLAB:uistring:scribemenu:DisplayStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'DisplayOrder',getString(message('MATLAB:uistring:scribemenu:DisplayOrder')),'DisplayOrder','');
                                                                                                                                                                                                        menuSpecificTags={'morebins','fewerbins','AlignBins','FaceColor','EdgeColor','LineStyle','LineWidth','DisplayStyle','DisplayOrder'};
                                                                                                                                                                                                    case{'matlab.graphics.chart.primitive.Histogram2'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'morebins2D',getString(message('MATLAB:uistring:scribemenu:morebins')),'morebins','');
                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'fewerbins2D',getString(message('MATLAB:uistring:scribemenu:fewerbins')),'fewerbins','');

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'DisplayStyle2D',getString(message('MATLAB:uistring:scribemenu:DisplayStyle')),'DisplayStyle',getString(message('MATLAB:uistring:scribemenu:DisplayStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Toggle',getString(message('MATLAB:uistring:scribemenu:ShowEmptyBins')),'ShowEmptyBins',getString(message('MATLAB:uistring:scribemenu:ShowEmptyBins')));

                                                                                                                                                                                                        menuSpecificTags={'morebins2D','fewerbins2D','FaceColor','EdgeColor','LineStyle','LineWidth','DisplayStyle','ShowEmptyBins'};
                                                                                                                                                                                                    case{'matlab.graphics.chart.primitive.categorical.Histogram'}

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'BarWidth',getString(message('MATLAB:uistring:scribemenu:BarWidth')),'BarWidth',getString(message('MATLAB:uistring:scribemenu:BarWidth')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'DisplayStyle',getString(message('MATLAB:uistring:scribemenu:DisplayStyle')),'DisplayStyle',getString(message('MATLAB:uistring:scribemenu:DisplayStyle')));

                                                                                                                                                                                                        hMenuItems(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hMode.UIContextMenu,hMode.UIContextMenu,'DisplayOrder',getString(message('MATLAB:uistring:scribemenu:DisplayOrder')),'DisplayOrder','');
                                                                                                                                                                                                        menuSpecificTags={'FaceColor','EdgeColor','LineStyle','BarWidth','LineWidth','DisplayStyle','DisplayOrder'};
                                                                                                                                                                                                    end


                                                                                                                                                                                                    assert(length(hMenuItems)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
                                                                                                                                                                                                    for i=1:numel(hMenuItems)
                                                                                                                                                                                                        set(hMenuItems(i),'Tag',[sprintf('scribe.%s.uicontextmenu',objClass),'.',menuSpecificTags{i}]);
                                                                                                                                                                                                    end


                                                                                                                                                                                                    function pointerType=localConvertMoveType(moveType)



                                                                                                                                                                                                        switch(moveType)
                                                                                                                                                                                                        case 'mouseover'
                                                                                                                                                                                                            pointerType='fleur';
                                                                                                                                                                                                        case 'topleft'
                                                                                                                                                                                                            pointerType='topl';
                                                                                                                                                                                                        case 'topright'
                                                                                                                                                                                                            pointerType='topr';
                                                                                                                                                                                                        case 'bottomright'
                                                                                                                                                                                                            pointerType='botr';
                                                                                                                                                                                                        case 'bottomleft'
                                                                                                                                                                                                            pointerType='botl';
                                                                                                                                                                                                        case 'left'
                                                                                                                                                                                                            pointerType='left';
                                                                                                                                                                                                        case 'top'
                                                                                                                                                                                                            pointerType='top';
                                                                                                                                                                                                        case 'right'
                                                                                                                                                                                                            pointerType='right';
                                                                                                                                                                                                        case 'bottom'
                                                                                                                                                                                                            pointerType='bottom';
                                                                                                                                                                                                        case 'none'
                                                                                                                                                                                                            pointerType='arrow';
                                                                                                                                                                                                        end


                                                                                                                                                                                                        function localNoop(varargin)



                                                                                                                                                                                                            function localPlotFunctionDone(~,~,hMode)


                                                                                                                                                                                                                if(~strcmp('Standard.EditPlot',hMode.Name)&&~strcmp('Standard.PlotSelect',hMode.Name)||...
                                                                                                                                                                                                                    ~isactiveuimode(hMode.FigureHandle,'Standard.EditPlot'))
                                                                                                                                                                                                                    return
                                                                                                                                                                                                                end


                                                                                                                                                                                                                hMode.ModeStateData.SelectedObjects(~ishandle(hMode.ModeStateData.SelectedObjects))=[];


                                                                                                                                                                                                                if isempty(hMode.ModeStateData.SelectedObjects)
                                                                                                                                                                                                                    selectobject(hMode.FigureHandle)
                                                                                                                                                                                                                end

                                                                                                                                                                                                                function selectionHandlePixelPositions=localSelectionHandlePixelPositions(ax)



                                                                                                                                                                                                                    selectionHandlePixelPositions=[];


                                                                                                                                                                                                                    if isempty(ax.DataSpace)||~isvalid(ax.DataSpace)||isempty(ax.SelectionHandle)||...
                                                                                                                                                                                                                        ~isvalid(ax.SelectionHandle)||isempty(ax.SelectionHandle.MarkerHandle)
                                                                                                                                                                                                                        return
                                                                                                                                                                                                                    end




                                                                                                                                                                                                                    try

                                                                                                                                                                                                                        if isempty(ax.SelectionHandle.MarkerHandle.VertexData)
                                                                                                                                                                                                                            drawnow update
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                        selectionHandlePixelPositions=double(matlab.graphics.chart.internal.convertVertexCoordsToViewerCoords...
                                                                                                                                                                                                                        (ax.DataSpace,ax.SelectionHandle.MarkerHandle.VertexData));
                                                                                                                                                                                                                    catch me
                                                                                                                                                                                                                        if strcmp(me.identifier,'MATLAB:handle_graphics:exceptions:TransformFailed')
                                                                                                                                                                                                                            return
                                                                                                                                                                                                                        else
                                                                                                                                                                                                                            rethrow(me);
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                    end
                                                                                                                                                                                                                    if isempty(selectionHandlePixelPositions)
                                                                                                                                                                                                                        return
                                                                                                                                                                                                                    end



                                                                                                                                                                                                                    hPanel=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
                                                                                                                                                                                                                    hFig=ancestor(ax,'figure');
                                                                                                                                                                                                                    if~isempty(hPanel)&&hPanel~=hFig
                                                                                                                                                                                                                        hViewer=hPanel.getCanvas;
                                                                                                                                                                                                                        OffSet=getpixelposition(hPanel,true);
                                                                                                                                                                                                                        deviceVP=double(hViewer.Viewport);

                                                                                                                                                                                                                        ViewerLoc=hgconvertunits(hFig,deviceVP,'devicepixels','pixels',hPanel);

                                                                                                                                                                                                                        selectionHandlePixelPositions=selectionHandlePixelPositions+...
                                                                                                                                                                                                                        (OffSet(1:2)-double(ViewerLoc(1:2)))'*ones(1,size(selectionHandlePixelPositions,2));
                                                                                                                                                                                                                    end






                                                                                                                                                                                                                    function localAddSelectionListeners(parent,hMode)








                                                                                                                                                                                                                        containersExist=~isempty(findall(allchild(parent),'flat','type','uicontainer',...
                                                                                                                                                                                                                        '-or','type','uipanel','-or','type','uicontrol',...
                                                                                                                                                                                                                        '-or','type','uitable','-or','type','uitabgroup','-or','type','uibuttongroup'));
                                                                                                                                                                                                                        if containersExist
                                                                                                                                                                                                                            hUIObjects=findall(parent,'type','uicontainer','-or','type','uipanel','-or','type','uicontrol',...
                                                                                                                                                                                                                            '-or','type','uitable','-or','type','uitabgroup','-or','type','uibuttongroup');

                                                                                                                                                                                                                            for k=1:length(hUIObjects)


                                                                                                                                                                                                                                selectedProp=findprop(hUIObjects(k),'Selected');
                                                                                                                                                                                                                                if isempty(selectedProp)
                                                                                                                                                                                                                                    continue;
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                if~isprop(hUIObjects(k),'UIObjectSelectionListener')
                                                                                                                                                                                                                                    p=addprop(hUIObjects(k),'UIObjectSelectionListener');
                                                                                                                                                                                                                                    p.Transient=true;
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                hUIObjects(k).UIObjectSelectionListener=event.proplistener(hUIObjects(k),selectedProp,...
                                                                                                                                                                                                                                'PostSet',@localUIObjectSelect);

                                                                                                                                                                                                                                evd.AffectedObject=hUIObjects(k);
                                                                                                                                                                                                                                localUIObjectSelect([],evd);
                                                                                                                                                                                                                            end
                                                                                                                                                                                                                        end


                                                                                                                                                                                                                        if ishghandle(parent,'figure')
                                                                                                                                                                                                                            if~isprop(parent,'UIObjectChildAddedListener')
                                                                                                                                                                                                                                p=addprop(parent,'UIObjectChildAddedListener');
                                                                                                                                                                                                                                p.Transient=true;
                                                                                                                                                                                                                                p.Hidden=true;
                                                                                                                                                                                                                            end
                                                                                                                                                                                                                            parent.UIObjectChildAddedListener=event.listener(parent,'ObjectChildAdded',...
                                                                                                                                                                                                                            @(e,d)localAddSelectionListeners(parent,hMode));
                                                                                                                                                                                                                        end

                                                                                                                                                                                                                        if containersExist
                                                                                                                                                                                                                            hUIContainerObjects=findall(parent,'type','uicontainer','-or','type','uipanel');
                                                                                                                                                                                                                            for k=1:length(hUIContainerObjects)
                                                                                                                                                                                                                                if~isprop(hUIContainerObjects(k),'UIObjectChildAddedListener')
                                                                                                                                                                                                                                    p=addprop(hUIContainerObjects(k),'UIObjectChildAddedListener');
                                                                                                                                                                                                                                    p.Transient=true;
                                                                                                                                                                                                                                    p.Hidden=true;
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                hUIContainerObjects(k).UIObjectChildAddedListener=event.listener(hUIContainerObjects(k),'ObjectChildAdded',...
                                                                                                                                                                                                                                @(e,d)localAddSelectionListeners(hUIContainerObjects(k),hMode));
                                                                                                                                                                                                                            end
                                                                                                                                                                                                                        end

                                                                                                                                                                                                                        function localRemoveSelectionListeners(parent)




                                                                                                                                                                                                                            if ishghandle(parent,'figure')&&isprop(parent,'UIObjectChildAddedListener')
                                                                                                                                                                                                                                delete(parent.UIObjectChildAddedListener);
                                                                                                                                                                                                                                delete(parent.findprop('UIObjectChildAddedListener'));
                                                                                                                                                                                                                            end





                                                                                                                                                                                                                            containersExist=~isempty(findall(allchild(parent),'flat','type','uicontainer',...
                                                                                                                                                                                                                            '-or','type','uipanel','-or','type','uicontrol','-or','type','uitable',...
                                                                                                                                                                                                                            '-or','type','uitabgroup','-or','type','uibuttongroup'));
                                                                                                                                                                                                                            if containersExist
                                                                                                                                                                                                                                hUIObjects=findall(parent,'type','uicontainer','-or','type','uipanel','-or','type','uicontrol',...
                                                                                                                                                                                                                                '-or','type','uitable','-or','type','uitabgroup','-or','type','uibuttongroup');
                                                                                                                                                                                                                                for k=1:length(hUIObjects)
                                                                                                                                                                                                                                    if isprop(hUIObjects(k),'UIObjectSelectionListener')
                                                                                                                                                                                                                                        delete(hUIObjects(k).UIObjectSelectionListener);
                                                                                                                                                                                                                                        delete(hUIObjects(k).findprop('UIObjectSelectionListener'));
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                hUIContainerObjects=findall(parent,'type','uicontainer','-or','type','uipanel');
                                                                                                                                                                                                                                for k=1:length(hUIContainerObjects)
                                                                                                                                                                                                                                    if isprop(hUIContainerObjects(k),'UIObjectChildAddedListener')
                                                                                                                                                                                                                                        delete(hUIContainerObjects(k).UIObjectChildAddedListener);
                                                                                                                                                                                                                                        delete(hUIContainerObjects(k).findprop('UIObjectChildAddedListener'));
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                            end


                                                                                                                                                                                                                            function v=findMethod(obj,name)
                                                                                                                                                                                                                                MD=metaclass(obj);
                                                                                                                                                                                                                                v=~isempty(findobj(MD.MethodList,'Name',name));

                                                                                                                                                                                                                                function detachFromLayoutManagement(obj,hAncestor)



                                                                                                                                                                                                                                    if~isempty(ancestor(obj,'matlab.graphics.layout.Layout'))

                                                                                                                                                                                                                                        if isa(obj,'matlab.graphics.illustration.ColorBar')||isa(obj,'matlab.graphics.illustration.Legend')
                                                                                                                                                                                                                                            obj.Axes.Parent=hAncestor;
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        obj.Parent=hAncestor;
                                                                                                                                                                                                                                    end
