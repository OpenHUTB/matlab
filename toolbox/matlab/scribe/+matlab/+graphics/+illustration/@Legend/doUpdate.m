function doUpdate(hObj,updateState)





    if strcmp(hObj.version,'on')
        doMethod(hObj,'doUpdateCompatible',updateState);
        return;
    end

    if strcmp(hObj.standalone,'on')
        doMethod(hObj,'doUpdateStandalone',updateState);
        return;
    end

    initializePositionCache(hObj);

    if isempty(hObj.Axes)
        return
    else
        peerAxes=hObj.Axes;
    end





    if ismember(hObj.Location,{'best','bestoutside','none'});
        matlab.graphics.illustration.internal.updateFontProperties(hObj,peerAxes);
        updateTitleProperties(hObj);
    end

    if strcmp(hObj.LineWidthMode,'auto')
        hObj.LineWidth_I=peerAxes.LineWidth;
    end

    if strcmp(hObj.Location,'none')
        hObj.CausesLayoutUpdate=false;
    else
        hObj.CausesLayoutUpdate=true;
    end



    if~isempty(hObj.PlotChildren_I)&&any(isvalid(hObj.PlotChildren_I))

        if isempty(hObj.EntryContainer.Children)
            doMethod(hObj,'createEntries',updateState);
        else


            doMethod(hObj,'syncEntries')
        end


        doMethod(hObj,'pushLegendPropsToLabels');
    end

    if isvalid(hObj.SelectionHandle)
        if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
            hObj.SelectionHandle.Visible='on';
        else
            hObj.SelectionHandle.Visible='off';
        end
    end





























    fig=ancestor(hObj,'Figure');
    parent=hObj.Parent;
    peerAxes=hObj.Axes;
    pc=hObj.PositionCache;
    posToCacheNorm=convertUnits(updateState,hObj.Position_I,hObj.Units,'normalized');
    posToCachePoints=convertUnits(updateState,hObj.Position_I,hObj.Units,'points');
    orientationChanged=~strcmp(pc.OrientationCache,hObj.Orientation_I);
    updateCache=false;

    switch hObj.Location
    case 'best'
        currPosPoints=convertUnits(updateState,hObj.Position_I,hObj.Units,'points');
        currSizePoints=currPosPoints(3:4);





        minSizePoints=doMethod(hObj,'getsize',updateState);




        sizeDiffPoints=abs(currSizePoints-minSizePoints);
        recalculateBest=false;
        currPeerPosPoints=convertUnits(updateState,peerAxes.InnerPosition_I,peerAxes.Units,'points');

        if any(sizeDiffPoints>1)
            recalculateBest=true;
        elseif any(sizeDiffPoints>0)

            currSizePoints=minSizePoints;
            newPosPoints=[currPosPoints(1:2),currSizePoints];
            [posToCacheNorm,posToCachePoints]=setPositionInLegendUnits(hObj,updateState,newPosPoints,'points',hObj.Units);
        end

        userSetLocation=strcmp(hObj.LocationMode,'manual');


        cachedPeerPosPoints=pc.PeerPositionCachePoints;
        peerPosPointsChanged=~isequal(currPeerPosPoints,cachedPeerPosPoints);
        cachedPeerPosNorm=pc.PeerPositionCacheNorm;
        currPeerPosNorm=convertUnits(updateState,peerAxes.InnerPosition_I,peerAxes.Units,'normalized');
        peerPosNormChanged=~isequal(currPeerPosNorm,cachedPeerPosNorm);

        inLayout=~isempty(hObj.Parent)&&isa(hObj.Parent,'matlab.graphics.layout.Layout');

        if userSetLocation||recalculateBest||inLayout

            newPosPoints=doMethod(hObj,'get_best_location',minSizePoints);
            [posToCacheNorm,posToCachePoints]=setPositionInLegendUnits(hObj,updateState,newPosPoints,'points',hObj.Units);
            hObj.LocationMode='auto';



            currPosPoints=newPosPoints;
            currCenterPoints=[currPosPoints(1)+currPosPoints(3)/2,currPosPoints(2)+currPosPoints(4)/2];
            currPeerOrigPoints=currPeerPosPoints(1:2);
            newPinNorm=(currCenterPoints-currPeerOrigPoints)./currPeerPosPoints(3:4);
            pc.PinToPeerCacheNorm=newPinNorm;
        elseif peerPosPointsChanged||peerPosNormChanged






            currPeerOrigPoints=currPeerPosPoints(1:2);
            currPeerSizePoints=currPeerPosPoints(3:4);
            newOffsetFromPeerPoints=currPeerSizePoints.*pc.PinToPeerCacheNorm;
            newCenterPoints=currPeerOrigPoints+newOffsetFromPeerPoints;
            newPosPoints=[newCenterPoints-currSizePoints./2,currSizePoints];
            [posToCacheNorm,posToCachePoints]=setPositionInLegendUnits(hObj,updateState,newPosPoints,'points',hObj.Units);
        end

        updateCache=true;

    case 'none'

        if~isempty(hObj.Parent)&&isa(hObj.Parent,'matlab.graphics.layout.Layout')



            if~isempty(hObj.SPosition)
                setLayoutPosition(hObj,hObj.SPosition);
                hObj.SPosition=[];
            end
        else

            if isempty(hObj.ParentSizeChangedListener)
                parent=ancestor(parent,'matlab.ui.internal.mixin.CanvasHostMixin','node');


                if isa(hObj.Parent,'matlab.ui.container.GridLayout')
                    parent=ancestor(hObj,'figure');
                end
                hObj.ParentSizeChangedListener=event.listener(parent,'SizeChanged',@(h,e)setappdata(hObj,'ParentResize',true));
            end






            if~isempty(hObj.SPosition)
                setLayoutPosition(hObj,hObj.SPosition);
                hObj.SPosition=[];
            end



            parentResize=isappdata(hObj,'ParentResize');
            if parentResize
                rmappdata(hObj,'ParentResize')
            end

            hasNormUnits=strcmp(hObj.Units,'normalized');
            posNormUnchanged=isequal(hObj.Position_I,pc.PositionCacheNormalized);
            currPosPoints=convertUnits(updateState,hObj.Position_I,hObj.Units,'points');
            if parentResize&&hasNormUnits&&posNormUnchanged
                if~isfield(hObj.PrintSettingsCache,'LockPositionForPrinting')

                    currSizePoints=currPosPoints(3:4);
                    cachedPosPoints=pc.PositionCachePoints;
                    cachedSizePoints=cachedPosPoints(3:4);
                    if~isequal(currSizePoints,cachedSizePoints)

                        Left=hObj.getNewLocation(currPosPoints(1),currPosPoints(3),cachedSizePoints(1));
                        Bottom=hObj.getNewLocation(currPosPoints(2),currPosPoints(4),cachedSizePoints(2));
                        newPosPoints=[Left,Bottom,cachedSizePoints];
                        [posToCacheNorm,posToCachePoints]=setViewportInLegendUnits(hObj,updateState,newPosPoints,hObj.Units);

                        currPosPoints=newPosPoints;
                    end

                else
                    [posToCacheNorm,posToCachePoints]=setViewportInLegendUnits(hObj,updateState,currPosPoints,hObj.Units);
                end
            end




            minSizePoints=doMethod(hObj,'getsize',updateState);
            [widthchanged,heightchanged,newPosPoints]=hObj.recalculateLegendPosition(currPosPoints,minSizePoints,orientationChanged,hObj.WidthMode,hObj.HeightMode);
            if widthchanged
                [posToCacheNorm,posToCachePoints]=setPositionInLegendUnits(hObj,updateState,newPosPoints,'points',hObj.Units);
                hObj.WidthMode='auto';
            end
            if heightchanged
                [posToCacheNorm,posToCachePoints]=setPositionInLegendUnits(hObj,updateState,newPosPoints,'points',hObj.Units);
                hObj.HeightMode='auto';
            end
            updateCache=true;


        end
    otherwise




        hObj.SPosition=[];
    end


    doMethod(hObj,'layoutEntries',updateState);


    if updateCache
        pc.PositionCacheNormalized=posToCacheNorm;
        pc.PositionCachePoints=posToCachePoints;
        pc.PeerPositionCachePoints=convertUnits(updateState,peerAxes.InnerPosition_I,peerAxes.Units,'points');
        pc.PeerPositionCacheNorm=convertUnits(updateState,peerAxes.InnerPosition_I,peerAxes.Units,'normalized');
        pc.OrientationCache=hObj.Orientation_I;
        hObj.PositionCache=pc;
    end



    setappdata(hObj,'inUpdate',true);



    if~isempty(hObj.UIContextMenu)&&~isempty(fig)&&...
        ~isequal(hObj.UIContextMenu.Parent,fig)&&...
        ~matlab.internal.editor.figure.FigureUtils.isEditorEmbeddedFigure(fig)&&...
        ~matlab.internal.editor.figure.FigureUtils.isEditorSnapshotFigure(fig)








        try
            hObj.UIContextMenu.Parent=fig;
        catch err
            if strcmp(err.identifier,'MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality')
                delete(hObj.UIContextMenu);
                doMethod(hObj,'createDefaultContextMenu',fig);
            else
                rethrow(err);
            end
        end

    end

    rmappdata(hObj,'inUpdate')



    if strcmp(hObj.Visible,'on')
        hObj.BoxFace.PickableParts='all';
    else
        hObj.BoxFace.PickableParts='visible';
    end

    canvas=ancestor(hObj,'matlab.graphics.primitive.canvas.Canvas','node');
    if~isempty(canvas)&&(isempty(hObj.CanvasCache)||canvas~=hObj.CanvasCache)
        if matlab.ui.internal.isUIFigure(fig)&&~matlab.internal.editor.figure.FigureUtils.isEditorEmbeddedFigure(fig)
            draginteraction=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragObjectInteraction(hObj);
            canvas.InteractionsManager.registerInteraction(hObj,draginteraction);
        end
        hObj.CanvasCache=canvas;
    end

    matlab.graphics.illustration.internal.updateLegendMenuToolbar([],[],hObj);
end

function[posToCacheNorm,posToCachePoints]=setPositionInLegendUnits(hObj,us,frompos,fromunits,tounits)
    newPosLegendUnits=us.convertUnits('canvas',tounits,fromunits,frompos);
    hObj.setLayoutPosition(newPosLegendUnits);

    posToCacheNorm=us.convertUnits('canvas','normalized',fromunits,frompos);
    posToCachePoints=us.convertUnits('canvas','points',fromunits,frompos);
end

function[posToCacheNorm,posToCachePoints]=setViewportInLegendUnits(hObj,us,newPosPoints,tounits)
    newPosLegendUnits=us.convertUnits('canvas',tounits,'points',newPosPoints);
    setViewportPosition(hObj,newPosLegendUnits);

    posToCacheNorm=us.convertUnits('canvas','normalized','points',newPosPoints);
    posToCachePoints=newPosPoints;
end

function topos=convertUnits(us,frompos,fromunits,tounits)


    topos=us.convertUnits('canvas',tounits,fromunits,frompos);
end
