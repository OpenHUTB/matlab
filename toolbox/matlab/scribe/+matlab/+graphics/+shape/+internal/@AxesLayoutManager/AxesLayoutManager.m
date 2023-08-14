classdef(Sealed)AxesLayoutManager<...
    matlab.graphics.primitive.world.Group&...
    matlab.graphics.mixin.UIParentable&...
    matlab.graphics.chartcontainer.mixin.internal.OuterPositionChangedEventMixin







    properties


        initialOuterOffset3D=[20,20,20,20];


        colorbarBonusInset=20;
    end

    properties(AffectsObject,Access=?layouthelpers.AxesLayoutManagerTester)

        ChartLayout(1,1)logical=false
    end

    properties(SetAccess=private)
        Axes;
        PlotyyPeer;
        StartingLayoutPositionPixels=[1,1,560,420];



        AxesPositionSetBySubplot=false;
    end

    properties(SetAccess=private,GetAccess={?layouthelpers.AxesLayoutManagerTester,?tmatlab_graphics_shape_internal_AxesLayoutManager_Impl})

        MakeRoom(1,1)logical=true;


        StartingLayoutPositionNorm=[0,0,1,1];
StartingLooseInsetNorm
StartingLooseInsetPixels
        TrackingStartingLayoutPosition(1,1)logical=false;

        SyncLayoutInfo(1,1)logical=true;
        SyncMakeRoomInfo(1,1)logical=true;

StartingOuterPositionPixels
DecorationAdjustments
DecoratedPlotBoxPixels
    end

    properties(SetAccess=private,GetAccess={?layouthelpers.AxesLayoutManagerTester,?tmatlab_graphics_shape_internal_AxesLayoutManager_Impl,?tmatlab_graphics_interaction_internal_toggleAxesLayoutManager,?InteractionLayoutHelper},Transient=true)






        LayoutList=matlab.graphics.primitive.world.Group.empty;




        InnerList matlab.graphics.shape.internal.ListComponent=matlab.graphics.shape.internal.ListComponent.empty;
        OuterList matlab.graphics.shape.internal.ListComponent=matlab.graphics.shape.internal.ListComponent.empty;



        AxesDirtyListener=event.listener.empty;



        AxesPositionListeners=event.proplistener.empty;


        Enabled(1,1)logical=true;
    end

    properties(Access='private',Transient,NonCopyable)





OuterPositionChangedListener
    end

    methods
        function set.MakeRoom(hObj,bool)
            if~bool
                delete(hObj.AxesPositionListeners);%#ok<MCSUP>
            end
            hObj.MakeRoom=bool;
        end

        function set.Axes(hObj,hAx)
            assert(isa(hAx,'matlab.graphics.axis.AbstractAxes'),...
            'matlab:graphics:shape:internal:AxesLayoutManager:invalidAxes',...
            'An AxesLayoutManager object may only be created for an Axes object.');

            hObj.Axes=hAx;
            hObj.addAxesListeners;
        end

        function set.LayoutList(hObj,newValue)


            if isgraphics(hObj.Axes)
                setappdata(hObj.Axes,'LayoutPeers',newValue)
            end
            hObj.LayoutList=newValue;
        end
    end

    methods(Access=protected)
        function unitPos=getUnitPositionObject(hObj)





            hAx=hObj.Axes;
            if isa(hAx,'matlab.graphics.axis.AbstractAxes')&&~isempty(hAx)
                unitPos=hAx.Camera.Viewport;
            else
                unitPos=matlab.graphics.general.UnitPosition;
            end
        end
    end

    methods(Access=public,Static=true)
        function hObj=getManager(hAx)
            assert(isa(hAx,'matlab.graphics.axis.AbstractAxes'),...
            'matlab:graphics:shape:internal:AxesLayoutManager:invalidAxes',...
            'An AxesLayoutManager object may only be created for an Axes object.');

            if isa(hAx.Parent,'matlab.graphics.layout.Layout')
                hObj=hAx.Parent;
                return
            end


            if isappdata(hAx,'graphicsPlotyyPeer')&&isvalid(getappdata(hAx,'graphicsPlotyyPeer'))
                hObj=matlab.graphics.shape.internal.AxesLayoutManager.getManagerPlotyy(hAx);
                return;
            end

            if~isprop(hAx,'LayoutManager')
                addInstancePropToAxes(hAx);
            end
            if isempty(hAx.LayoutManager)||~isvalid(hAx.LayoutManager)
                hObj=matlab.graphics.shape.internal.AxesLayoutManager(hAx);
                setInstancePropOnAxes(hObj,hAx);

                insertAboveAxes(hObj);
            else
                hObj=hAx.LayoutManager;
            end
        end

        function removeManager(hAx)%#ok<INUSD>






        end
    end

    methods(Access=private,Static=true)
        function hObj=getManagerPlotyy(axesFromCaller)




            if strcmp(axesFromCaller.Color,'none')
                hPlotyyPeer=axesFromCaller;
                hAx=getappdata(axesFromCaller,'graphicsPlotyyPeer');
            else
                hAx=axesFromCaller;
                hPlotyyPeer=getappdata(axesFromCaller,'graphicsPlotyyPeer');
            end

            created=false;


            if~isprop(hAx,'LayoutManager')
                addInstancePropToAxes(hAx);
            end
            if isempty(hAx.LayoutManager)||~isvalid(hAx.LayoutManager)
                hObj=matlab.graphics.shape.internal.AxesLayoutManager(hAx);
                setInstancePropOnAxes(hObj,hAx);
                created=true;
            else
                hObj=hAx.LayoutManager;
            end


            if~isprop(hPlotyyPeer,'LayoutManager')
                addInstancePropToAxes(hPlotyyPeer);
            end
            if isempty(hPlotyyPeer.LayoutManager)||~isvalid(hPlotyyPeer.LayoutManager)
                setInstancePropOnAxes(hObj,hPlotyyPeer);
            end


            if~isprop(hObj,'PlotyyPeer')
                hP=addprop(hObj,'PlotyyPeer');
                hP.Hidden=true;
                hP.Transient=true;
                hP.SetAccess='private';
            end
            hObj.PlotyyPeer=hPlotyyPeer;



            if created
                insertAboveAxes(hObj);
            end
        end
    end

    methods(Access=private)
        function hObj=AxesLayoutManager(hAx)
            hObj.Axes=hAx;
            hObj.OuterPositionChangedListener=event.listener(hObj,'OuterPositionChanged',...
            @(src,evt)hObj.handleOuterPositionChangedEvent);
        end

        function handleOuterPositionChangedEvent(hObj,src,evt)
            hObj.Axes.fireOuterPositionChanged();
        end

        function syncLayoutInfoFromAxes(hObj)
            if hObj.SyncLayoutInfo||hObj.SyncMakeRoomInfo



                hAx=hObj.Axes;
                if isappdata(hAx,'LayoutInfo')
                    layoutInfo=getappdata(hAx,'LayoutInfo');
                    if hObj.SyncMakeRoomInfo&&islogical(layoutInfo.MakeRoom)
                        hObj.MakeRoom=layoutInfo.MakeRoom;
                    end
                    if hObj.SyncLayoutInfo
                        if~isempty(layoutInfo.StartingLayoutPositionNorm)
                            hObj.StartingLayoutPositionNorm=layoutInfo.StartingLayoutPositionNorm;
                        end
                        if~isempty(layoutInfo.StartingLayoutPositionPixels)
                            hObj.StartingLayoutPositionPixels=layoutInfo.StartingLayoutPositionPixels;
                        end
                        if isfield(layoutInfo,'StartingLooseInsetNorm')&&...
                            ~isempty(layoutInfo.StartingLooseInsetNorm)
                            hObj.StartingLooseInsetNorm=layoutInfo.StartingLooseInsetNorm;
                        end
                        if isfield(layoutInfo,'StartingLooseInsetPixels')&&...
                            ~isempty(layoutInfo.StartingLooseInsetPixels)
                            hObj.StartingLooseInsetNorm=layoutInfo.StartingLooseInsetPixels;
                        end
                        hObj.TrackingStartingLayoutPosition=true;
                    end
                end
            end
            hObj.SyncLayoutInfo=false;
            hObj.SyncMakeRoomInfo=false;
        end

        function delete(~)

        end

        function insertAboveAxes(hObj)


            hAx=hObj.Axes;
            hAxParent=hAx.Parent;
            trueParent=hAx.NodeParent;
            is_parented=false;


            if~isempty(hAxParent)&&isvalid(hAxParent)
                slm=getappdata(hAxParent,'SubplotListenersManager');
                if~isempty(slm)
                    disable(slm);
                end
            end



            if~isempty(trueParent)&&isvalid(trueParent)



                siblings=flipud(hgGetTrueChildren(trueParent));
                childIndex=find(siblings==hAx);
                is_parented=true;





                set(siblings(childIndex:end),'Parent_I',matlab.graphics.primitive.world.Group.empty);
















                if isa(trueParent,'matlab.graphics.primitive.world.Group')
                    trueParent.addNode(hObj);
                else
                    hObj.Parent_I=hAxParent;
                end
            else


                hObj.addNode(hAx);
            end


            if is_parented
                for ind=(childIndex+1):numel(siblings)
                    try
                        siblings(ind).Parent=hAxParent;
                    catch



                        siblings(ind).Parent=trueParent;
                    end
                end
            end


            if~isempty(hObj.PlotyyPeer)&&isvalid(hObj.PlotyyPeer)
                hObj.addNode(hObj.PlotyyPeer);
            end


            if~isempty(hAxParent)&&isvalid(hAxParent)
                if~isempty(slm)
                    enable(slm);
                end
            end
        end

        function v=findMethod(~,obj,name)
            MD=metaclass(obj);
            v=~isempty(findobj(MD.MethodList,'Name',name));
        end

        function isValid=ValidateObject(hObj,obj)
            isValid=true;
            if~ishghandle(obj)
                isValid=false;
                return;
            end
            if~isprop(obj,'Position_I')||~isprop(obj,'Units')
                isValid=false;
                return;
            end
            if numel(obj.Position_I)~=4
                isValid=false;
                return;
            end

            if~hObj.findMethod(obj,'getPreferredSize')||...
                ~hObj.findMethod(obj,'getPreferredLocation')||...
                ~hObj.findMethod(obj,'isStretchToFill')||...
                ~hObj.findMethod(obj,'setLayoutPosition')
                isValid=false;
                return;
            end
        end

        function addAxesListeners(hObj)


            hAx=hObj.Axes;
            hObj.AxesDirtyListener=event.listener(hAx,'MarkedDirty',@(obj,evd)(hObj.MarkDirty('all')));

            hObj.AxesPositionListeners(1)=addlistener(hAx,'Position','PostSet',@(h,e)localAxesPositionPostSetCB(hObj,h,e));
            hObj.AxesPositionListeners(2)=addlistener(hAx,'InnerPosition','PostSet',@(h,e)localAxesPositionPostSetCB(hObj,h,e));
            hObj.AxesPositionListeners(3)=addlistener(hAx,'OuterPosition','PostSet',@(h,e)localAxesPositionPostSetCB(hObj,h,e));
            hObj.AxesPositionListeners(4)=addlistener(hAx,'ActivePositionProperty','PostSet',@(h,e)localAxesPositionPostSetCB(hObj,h,e));
            hObj.AxesPositionListeners(5)=addlistener(hAx,'PositionConstraint','PostSet',@(h,e)localAxesPositionPostSetCB(hObj,h,e));
            hObj.AxesPositionListeners(6)=addlistener(hAx,'Units','PreSet',@(h,e)localAxesUnitsPreSetCB(hObj,h,e));
            hObj.AxesPositionListeners(7)=addlistener(hAx,'Units','PostSet',@(h,e)localAxesUnitsPostSetCB(hObj,h,e));


            addlistener(hAx,'ObjectBeingDestroyed',@(obj,evd)(localDestroyLayoutManager(hObj)));

            function localDestroyLayoutManager(hLayoutManager)
                delete(hLayoutManager);
            end


            addlistener(hAx,'Reparent',@(h,e)localReparentCB(h,e,hObj));

            function localAxesPositionPostSetCB(hObj,h,~)
                propName=h.Name;
                hObj.SyncLayoutInfo=false;
                if hObj.MakeRoom
                    if hObj.ChartLayout
                        hObj.TrackingStartingLayoutPosition=false;
                    elseif ismember(propName,{'Position','ActivePositionProperty','PositionConstraint'})
                        updateInnerOuterLists(hObj);
                        if~isempty(hObj.OuterList)
                            hObj.MakeRoom=false;
                            hObj.SyncMakeRoomInfo=false;
                        else
                            hObj.TrackingStartingLayoutPosition=false;
                        end
                    elseif ismember(propName,{'OuterPosition','InnerPosition'})
                        hObj.TrackingStartingLayoutPosition=false;
                    end
                end
            end

            function localAxesUnitsPreSetCB(hObj,~,e)

                if hObj.TrackingStartingLayoutPosition
                    setappdata(hAx,'PreUnits',e.AffectedObject.Units);
                end
            end

            function localAxesUnitsPostSetCB(hObj,~,e)

                import matlab.graphics.internal.convertUnits
                if isappdata(hAx,'PreUnits')




                    preUnits=getappdata(hAx,'PreUnits');
                    rmappdata(hAx,'PreUnits');
                    postUnits=e.AffectedObject.Units;
                    if strcmp(preUnits,'normalized')&&~strcmp(postUnits,'normalized')




                        hAx.InnerPosition;
                        if hObj.TrackingStartingLayoutPosition
                            axViewport=hAx.Camera.Viewport;
                            normPos=hObj.StartingLayoutPositionNorm;
                            hObj.StartingLayoutPositionPixels=convertUnits(axViewport,'pixels','normalized',normPos);
                            hObj.StartingLooseInsetNorm=[];
                            hObj.StartingLooseInsetPixels=[];
                            hObj.MarkDirty('all');
                        end
                    elseif~strcmp(preUnits,'normalized')&&strcmp(postUnits,'normalized')




                        hAx.InnerPosition;
                        if hObj.TrackingStartingLayoutPosition
                            axViewport=hAx.Camera.Viewport;
                            pixelPos=hObj.StartingLayoutPositionPixels;
                            hObj.StartingLayoutPositionNorm=convertUnits(axViewport,'normalized','pixels',pixelPos);
                            hObj.StartingLooseInsetNorm=[];
                            hObj.StartingLooseInsetPixels=[];
                            hObj.MarkDirty('all');
                        end
                    end
                end
            end

            function localReparentCB(hAx,e,hLayoutManager)
                if isa(e.NewValue,'matlab.graphics.layout.Layout')||isequal(e.NewValue,hLayoutManager)||~isvalid(hAx)||~isvalid(hLayoutManager)
                    return
                else



                    layoutChildren=hLayoutManager.NodeChildren;
                    set(layoutChildren,'Parent_I',matlab.graphics.primitive.world.Group.empty);


                    hLayoutManager.Parent=hAx.Parent;
                    hLayoutManager.addNode(hAx);



                    for k=numel(layoutChildren):-1:1
                        hLayoutManager.addNode(layoutChildren(k));
                    end
                end
            end
        end

        function updateStartingLayoutPosition(hObj,hAx)




            import matlab.graphics.internal.convertUnits
            notTrackingSLP=~hObj.TrackingStartingLayoutPosition;
            axUpdatedBySubplot=hObj.AxesPositionSetBySubplot;
            if notTrackingSLP||axUpdatedBySubplot

                hObj.AxesPositionSetBySubplot=false;

                actPosProp=hAx.PositionConstraint;
                if strcmp(actPosProp,'innerposition')
                    actPosProp_I='InnerPosition_I';
                else
                    actPosProp_I='OuterPosition_I';
                end
                axViewport=hAx.Camera.Viewport;
                currAxPos=hAx.(actPosProp_I);
                hObj.StartingLayoutPositionPixels=convertUnits(axViewport,'pixels',hAx.Units,currAxPos);
                hObj.StartingLayoutPositionNorm=convertUnits(axViewport,'normalized',hAx.Units,currAxPos);
                [hObj.StartingLooseInsetPixels,...
                hObj.StartingLooseInsetNorm]=calculateLooseInset(hAx);
            elseif isempty(hObj.StartingLooseInsetPixels)||...
                isempty(hObj.StartingLayoutPositionNorm)
                [hObj.StartingLooseInsetPixels,...
                hObj.StartingLooseInsetNorm]=calculateLooseInset(hAx);
            end
        end

        function tf=hasValidParent(hObj,obj)

            tf=true;
            if isempty(obj.Parent)

                tf=false;
            else




                assert(any(obj==hgGetTrueChildren(hObj)),...
                'Invalid parent for layout object detected');
            end

        end

        function retval=getSubplotLayoutManager(hObj)
            retval=[];
            if(~isempty(hObj.Axes)&&~isempty(hObj.Axes.Parent)&&isappdata(hObj.Axes.Parent,'SubplotListenersManager'))
                slm=getappdata(hObj.Axes.Parent,'SubplotListenersManager');
                if slm.isManaged(hObj.Axes)
                    retval=slm;
                end
            end
        end
    end

    methods(Access={?layouthelpers.AxesLayoutManagerTester})
        function updateInnerOuterLists(hObj)

            hObj.InnerList=matlab.graphics.shape.internal.ListComponent.empty;
            hObj.OuterList=matlab.graphics.shape.internal.ListComponent.empty;


            removeInvalidLayoutListItems(hObj);


            layoutList=hObj.LayoutList;
            for i=1:numel(layoutList)
                obj=layoutList(i);
                [list,side]=addToLayout(obj);


                if~isempty(list)&&~isempty(side)

                    try
                        side=hgcastvalue('matlab.graphics.chart.datatype.ScribeLayoutType',side);
                    catch E
                        error(message('MATLAB:graphics:axeslayoutmanager:InvalidLocation'));
                    end

                    md_lis=event.listener(obj,'MarkedDirty',@(~,~)(hObj.MarkDirty('all')));
                    ul_lis=event.listener(obj,'UpdateLayout',@(~,~)(hObj.MarkDirty('all')));
                    des_lis=event.listener(obj,'ObjectBeingDestroyed',@(~,~)(hObj.MarkDirty('all')));
                    if strcmpi(list,'inner')

                        hObj.InnerList(end+1)=matlab.graphics.shape.internal.ListComponent(obj,side,md_lis,ul_lis,des_lis);
                    elseif strcmpi(list,'outer')

                        hObj.OuterList(end+1)=matlab.graphics.shape.internal.ListComponent(obj,side,md_lis,ul_lis,des_lis);
                    else
                        error(message('MATLAB:graphics:axeslayoutmanager:InvalidList'));
                    end
                end
            end
        end

        function removeInvalidLayoutListItems(hObj)

            list=hObj.LayoutList;
            ch=hgGetTrueChildren(hObj);
            list=list(isvalid(list)&ismember(list,ch));
            hObj.LayoutList=list;
        end
    end

    methods(Access=public)
        function doMarkDirty(hObj)

            hObj.MarkDirty('all');
        end

        function addToTree(hObj,obj)

            if~hObj.ValidateObject(obj)
                error(message('MATLAB:graphics:axeslayoutmanager:InvalidObject'));
            end
            if ismember(obj,hObj.Children)
                error(message('MATLAB:graphics:axeslayoutmanager:DuplicateEntry'));
            end



            if~ismember(obj,hObj.Children)
                hObj.addNode(obj);
                addToLayout(hObj,obj);
            end


            hObj.MarkDirty('all');
        end

        function posUpdatedBySubplot(hObj)
            hObj.AxesPositionSetBySubplot=true;
        end

        function addToLayout(hObj,obj)


            list=hObj.LayoutList;
            list(list==obj)=[];
            list(end+1)=obj;
            hObj.LayoutList=list;


            hObj.MarkDirty('all');
        end

        function doUpdate(hObj,updateState)

            import matlab.graphics.internal.convertUnits
            import matlab.graphics.internal.convertDistances

            hAx=hObj.Axes;

            if~isempty(hAx.Parent)&&isa(hAx.Parent,'matlab.graphics.layout.TiledChartLayout')
                enableAxesDirtyListeners(hObj,false);
                return;
            end

            axViewport=hAx.Camera.Viewport;





            hFig=ancestor(hObj,'Figure');
            if~isempty(hFig)&&isvalid(hFig)

                if strcmpi(hFig.BeingDeleted,'on')
                    return;
                end




                viewer=updateState.Canvas;
                if viewer.ScreenPixelsPerInch~=hFig.ScreenPixelsPerInch
                    warning(message('MATLAB:graphics:axeslayoutmanager:InconsistentState'));
                    return;
                end
            end



            updateInnerOuterLists(hObj);






            hObj.syncLayoutInfoFromAxes();



            updateStartingLayoutPosition(hObj,hAx);





            responsiveFactor=hAx.calculateResponsiveFactor();
            decorationOffset=8.*responsiveFactor+4.*(1-responsiveFactor);



            hObj.DecorationAdjustments=[];
            hObj.DecoratedPlotBoxPixels=[];


            if hObj.MakeRoom

                currActPos=hAx.PositionConstraint;
                if strcmp(currActPos,'innerposition')
                    actPosProp_I='InnerPosition_I';
                else
                    actPosProp_I='OuterPosition_I';
                end



                currAxUnits=hAx.Units_I;
                currAxPos=hAx.(actPosProp_I);
                currLooseInset=hAx.LooseInset_I;



                if strcmp(currAxUnits,'normalized')

                    startingLayoutPosUnits=hObj.StartingLayoutPositionNorm;
                    startingLayoutPosPoints=convertUnits(axViewport,'points','normalized',startingLayoutPosUnits);
                    startingLooseInsetUnits=hObj.StartingLooseInsetNorm;
                else

                    startingLayoutPosUnits=convertUnits(axViewport,currAxUnits,'pixels',hObj.StartingLayoutPositionPixels);
                    startingLayoutPosPoints=convertUnits(axViewport,'points','pixels',hObj.StartingLayoutPositionPixels);
                    startingLooseInsetUnits=convertDistances(axViewport,currAxUnits,'pixels',hObj.StartingLooseInsetPixels);
                end



                axDecAdjustments=[0,0,0,0];



                adjustments=[0,0,0,0];



                useAxDecAdj=[0,0,0,0];






                outerList=hObj.OuterList;
                if~isempty(outerList)






                    if hObj.ChartLayout

                        set(hAx,'LooseInset_I',startingLooseInsetUnits)
                    else

                        set(hAx,actPosProp_I,startingLayoutPosUnits);
                    end


                    startingLayoutInfo=hAx.GetLayoutInformation;
                    startingPlotBoxPoints=convertUnits(axViewport,'points','pixels',startingLayoutInfo.PlotBox);
                    startingDecPlotBoxPoints=convertUnits(axViewport,'points','pixels',startingLayoutInfo.DecoratedPlotBox);
                    startingPosPoints=convertUnits(axViewport,'points','pixels',startingLayoutInfo.Position);


                    hObj.StartingOuterPositionPixels=startingLayoutInfo.OuterPosition;



                    responsiveFactor=hAx.calculateResponsiveFactor();
                    decorationOffset=8.*responsiveFactor+4.*(1-responsiveFactor);

                    if hObj.ChartLayout

                        set(hAx,'LooseInset_I',currLooseInset);
                    else

                        set(hAx,actPosProp_I,currAxPos);
                    end














                    if hObj.is2Dim||hObj.ChartLayout
                        axDecAdjustments=[...
                        startingPlotBoxPoints(1)-startingDecPlotBoxPoints(1),...
                        startingPlotBoxPoints(2)-startingDecPlotBoxPoints(2),...
                        (startingDecPlotBoxPoints(1)+startingDecPlotBoxPoints(3))-(startingPlotBoxPoints(1)+startingPlotBoxPoints(3)),...
                        (startingDecPlotBoxPoints(2)+startingDecPlotBoxPoints(4))-(startingPlotBoxPoints(2)+startingPlotBoxPoints(4))];
                    else
                        axDecAdjustments=hObj.initialOuterOffset3D;
                    end


                    for i=1:numel(outerList)
                        if(~hObj.hasValidParent(outerList(i).ObjectHandle))

                            continue;
                        end

                        prefSize=outerList(i).ObjectHandle.getPreferredSize(updateState,startingPosPoints(3:4));





                        if isa(outerList(i).ObjectHandle,'matlab.graphics.illustration.ColorBar')
                            prefSize=prefSize+hObj.colorbarBonusInset;
                        end

                        loc=outerList(i).Location;
                        if any(strcmpi(loc,{'east','west'}))
                            if strcmpi(loc,'west')
                                useAxDecAdj(1)=1;
                                adjustments(1)=adjustments(1)+prefSize(1)+decorationOffset(1);
                            else
                                useAxDecAdj(3)=1;
                                adjustments(3)=adjustments(3)+prefSize(1)+decorationOffset(1);
                            end
                        else
                            if strcmpi(loc,'south')
                                useAxDecAdj(2)=1;
                                adjustments(2)=adjustments(2)+prefSize(2)+decorationOffset(2);
                            else
                                useAxDecAdj(4)=1;
                                adjustments(4)=adjustments(4)+prefSize(2)+decorationOffset(2);
                            end
                        end
                    end


                    hObj.TrackingStartingLayoutPosition=true;
                else


                    hObj.TrackingStartingLayoutPosition=false;
                end

                adjustments=adjustments+useAxDecAdj.*axDecAdjustments;

                tolInPixels=.1;
                if hObj.ChartLayout





                    adjustments=adjustments+useAxDecAdj.*decorationOffset([1,2,1,2]);
                end

                if hObj.ChartLayout&&isempty(outerList)

                    set(hAx,'LooseInset_I',startingLooseInsetUnits);
                    if~isempty(hObj.PlotyyPeer)&&isvalid(hObj.PlotyyPeer)
                        set(hObj.PlotyyPeer,'LooseInset_I',startingLooseInsetUnits);
                    end
                elseif hObj.ChartLayout&&strcmp(currActPos,'outerposition')





                    adjustments=capMinimumSize(startingLayoutPosPoints,adjustments,5);



                    if strcmp(currAxUnits,'normalized')
                        newLooseInset=adjustments./startingLayoutPosPoints([3,4,3,4]);
                    else
                        newLooseInset=convertDistances(axViewport,currAxUnits,...
                        'points',adjustments);
                    end


                    newLooseInset=max(newLooseInset,startingLooseInsetUnits);


                    set(hAx,'LooseInset_I',newLooseInset);
                    if~isempty(hObj.PlotyyPeer)&&isvalid(hObj.PlotyyPeer)
                        set(hObj.PlotyyPeer,'LooseInset_I',newLooseInset);
                    end
                elseif hObj.ChartLayout

                    set(hAx,'LooseInset_I',startingLooseInsetUnits);
                    if~isempty(hObj.PlotyyPeer)&&isvalid(hObj.PlotyyPeer)
                        set(hObj.PlotyyPeer,'LooseInset_I',startingLooseInsetUnits);
                    end



                    newAxPosPoints(1)=startingPlotBoxPoints(1)-adjustments(1);
                    newAxPosPoints(2)=startingPlotBoxPoints(2)-adjustments(2);
                    newAxPosPoints(3)=startingPlotBoxPoints(3)+adjustments(1)+adjustments(3);
                    newAxPosPoints(4)=startingPlotBoxPoints(4)+adjustments(2)+adjustments(4);





                    left=startingLayoutPosPoints(1)-newAxPosPoints(1);
                    bottom=startingLayoutPosPoints(2)-newAxPosPoints(2);
                    right=sum(newAxPosPoints([1,3]))-sum(startingLayoutPosPoints([1,3]));
                    top=sum(newAxPosPoints([2,4]))-sum(startingLayoutPosPoints([2,4]));
                    adjustments=max(0,[left,bottom,right,top]);
                else




                    adjustments=capMinimumSize(startingLayoutPosPoints,adjustments,5);


                    newAxPosPoints(1)=startingLayoutPosPoints(1)+adjustments(1);
                    newAxPosPoints(2)=startingLayoutPosPoints(2)+adjustments(2);
                    newAxPosPoints(3)=startingLayoutPosPoints(3)-adjustments(1)-adjustments(3);
                    newAxPosPoints(4)=startingLayoutPosPoints(4)-adjustments(2)-adjustments(4);

                    currAxPosPoints=convertUnits(axViewport,'points',currAxUnits,currAxPos);
                    if~isNearlyEqual(newAxPosPoints,currAxPosPoints,tolInPixels,axViewport)
                        newPos=convertUnits(axViewport,currAxUnits,'points',newAxPosPoints);
                        set(hAx,actPosProp_I,newPos);






                        if~isempty(hObj.PlotyyPeer)&&isvalid(hObj.PlotyyPeer)
                            set(hObj.PlotyyPeer,actPosProp_I,newPos);
                        end
                    end
                end


                hObj.DecorationAdjustments=convertDistances(...
                axViewport,'pixels','points',adjustments);

            end


















            newLayoutInfo=hAx.GetLayoutInformation;
            if hObj.is2Dim||hObj.ChartLayout
                plotBox=convertUnits(axViewport,'points','pixels',newLayoutInfo.PlotBox);
                decPlotBox=convertUnits(axViewport,'points','pixels',newLayoutInfo.DecoratedPlotBox);




                eastWestOuterBox=decPlotBox;
                northSouthOuterBox=decPlotBox;


                initOuterOffset=[0,0,0,0];
            else

                plotBox=convertUnits(axViewport,'points','pixels',newLayoutInfo.Position);
                eastWestOuterBox=plotBox;
                northSouthOuterBox=plotBox;
                decPlotBox=plotBox;




                initOuterOffset=hObj.initialOuterOffset3D;
            end


            outerList=hObj.OuterList;
            for i=1:numel(outerList)
                hLayoutObj=outerList(i).ObjectHandle;

                if(~hObj.hasValidParent(hLayoutObj))

                    continue;
                end


                prefSize=hLayoutObj.getPreferredSize(updateState,plotBox(3:4));




                outerObjAdjustment=prefSize;
                if isa(outerList(i).ObjectHandle,'matlab.graphics.illustration.ColorBar')
                    outerObjAdjustment=outerObjAdjustment+hObj.colorbarBonusInset;
                end






                fillSpace=max([0,0],plotBox(3:4));

                prefLoc=hLayoutObj.getPreferredLocation;

                if hLayoutObj.isStretchToFill
                    if any(strcmpi(outerList(i).Location,{'east','west'}))
                        prefSize(2)=fillSpace(2);
                    else
                        prefSize(1)=fillSpace(1);
                    end
                end

                try
                    objViewport=hLayoutObj.Camera.Viewport;
                catch
                    objViewport=axViewport;
                end
                switch(outerList(i).Location)
                case 'east'


                    objPosPoints=[0,0,prefSize];
                    objPosPoints(1)=eastWestOuterBox(1)+eastWestOuterBox(3)+decorationOffset(1)+initOuterOffset(3);




                    objPosPoints(2)=min(plotBox(2)+plotBox(4)-prefSize(2),max(plotBox(2),plotBox(2)+prefLoc(2)*plotBox(4)-.5*prefSize(2)));





                    currObjPosPoints=convertUnits(objViewport,'points',hLayoutObj.Units,hLayoutObj.Position_I);
                    if~all(abs(currObjPosPoints-objPosPoints)<max(2,.01*currObjPosPoints))
                        hLayoutObj.setLayoutPosition(convertUnits(objViewport,hLayoutObj.Units,'points',objPosPoints));
                    end





                    eastWestOuterBox(3)=eastWestOuterBox(3)+initOuterOffset(3)+decorationOffset(1)+outerObjAdjustment(1);
                    initOuterOffset(3)=0;
                case 'west'


                    objPosPoints=[0,0,prefSize];
                    objPosPoints(1)=eastWestOuterBox(1)-prefSize(1)-decorationOffset(1)-initOuterOffset(1);




                    objPosPoints(2)=min(plotBox(2)+plotBox(4)-prefSize(2),max(plotBox(2),plotBox(2)+prefLoc(2)*plotBox(4)-.5*prefSize(2)));





                    currObjPosPoints=convertUnits(objViewport,'points',hLayoutObj.Units,hLayoutObj.Position_I);
                    if~all(abs(currObjPosPoints-objPosPoints)<max(2,.01*currObjPosPoints))
                        hLayoutObj.setLayoutPosition(convertUnits(objViewport,hLayoutObj.Units,'points',objPosPoints));
                    end

                    eastWestOuterBox(1)=eastWestOuterBox(1)-initOuterOffset(1)-decorationOffset(1)-outerObjAdjustment(1);
                    eastWestOuterBox(3)=eastWestOuterBox(3)+initOuterOffset(1)+decorationOffset(1)+outerObjAdjustment(1);
                    initOuterOffset(1)=0;
                case 'north'


                    objPosPoints=[0,0,prefSize];
                    objPosPoints(2)=northSouthOuterBox(2)+northSouthOuterBox(4)+decorationOffset(2)+initOuterOffset(4);




                    objPosPoints(1)=min(plotBox(1)+plotBox(3)-prefSize(1),max(plotBox(1),plotBox(1)+prefLoc(1)*plotBox(3)-.5*prefSize(1)));





                    currObjPosPoints=convertUnits(objViewport,'points',hLayoutObj.Units,hLayoutObj.Position_I);
                    if~all(abs(currObjPosPoints-objPosPoints)<max(2,.01*currObjPosPoints))
                        hLayoutObj.setLayoutPosition(convertUnits(objViewport,hLayoutObj.Units,'points',objPosPoints));
                    end

                    northSouthOuterBox(4)=northSouthOuterBox(4)+initOuterOffset(4)+decorationOffset(2)+outerObjAdjustment(2);
                    initOuterOffset(4)=0;
                case 'south'


                    objPosPoints=[0,0,prefSize];
                    objPosPoints(2)=northSouthOuterBox(2)-prefSize(2)-decorationOffset(2)-initOuterOffset(2);




                    objPosPoints(1)=min(plotBox(1)+plotBox(3)-prefSize(1),max(plotBox(1),plotBox(1)+prefLoc(1)*plotBox(3)-.5*prefSize(1)));





                    currObjPosPoints=convertUnits(objViewport,'points',hLayoutObj.Units,hLayoutObj.Position_I);
                    if~all(abs(currObjPosPoints-objPosPoints)<max(2,.01*currObjPosPoints))
                        hLayoutObj.setLayoutPosition(convertUnits(objViewport,hLayoutObj.Units,'points',objPosPoints));
                    end

                    northSouthOuterBox(2)=northSouthOuterBox(2)-initOuterOffset(2)-decorationOffset(2)-outerObjAdjustment(2);
                    northSouthOuterBox(4)=northSouthOuterBox(4)+initOuterOffset(2)+decorationOffset(2)+outerObjAdjustment(2);
                    initOuterOffset(2)=0;
                end
            end


            if~isempty(outerList)



                decoratedPlotBoxPoints=[
                min(eastWestOuterBox(1),decPlotBox(1)),...
                min(northSouthOuterBox(2),decPlotBox(2)),...
                max(eastWestOuterBox(1)+eastWestOuterBox(3),decPlotBox(1)+decPlotBox(3)),...
                max(northSouthOuterBox(2)+northSouthOuterBox(4),decPlotBox(2)+decPlotBox(4))];
                decoratedPlotBoxPoints(3:4)=decoratedPlotBoxPoints(3:4)-decoratedPlotBoxPoints(1:2);
                hObj.DecoratedPlotBoxPixels=convertUnits(axViewport,'pixels','points',decoratedPlotBoxPoints);
            end


            innerList=hObj.InnerList;
            currInnerBox=plotBox;
            for i=1:numel(innerList)
                hLayoutObj=innerList(i).ObjectHandle;

                if(~hObj.hasValidParent(hLayoutObj))

                    continue;
                end

                prefSize=hLayoutObj.getPreferredSize(updateState,plotBox(3:4));







                innerObjAdjustment=prefSize;
                if isa(innerList(i).ObjectHandle,'matlab.graphics.illustration.ColorBar')
                    innerObjAdjustment=innerObjAdjustment+hObj.colorbarBonusInset;
                end

                fillSpace=max([0,0],plotBox(3:4)-2*decorationOffset);
                prefLoc=hLayoutObj.getPreferredLocation;

                if hLayoutObj.isStretchToFill
                    if any(strcmpi(innerList(i).Location,{'east','west'}))
                        prefSize(2)=fillSpace(2);
                    else
                        prefSize(1)=fillSpace(1);
                    end
                end

                try
                    objViewport=hLayoutObj.Camera.Viewport;
                catch
                    objViewport=axViewport;
                end
                switch(innerList(i).Location)
                case 'east'


                    objPos=[0,0,prefSize];
                    objPos(1)=currInnerBox(1)+currInnerBox(3)-prefSize(1)-decorationOffset(1);




                    objPos(2)=min(plotBox(2)+plotBox(4)-prefSize(2)-decorationOffset(2),max(plotBox(2)+decorationOffset(2),plotBox(2)+prefLoc(2)*plotBox(4)-.5*prefSize(2)));
                    newObjPos=convertUnits(objViewport,hLayoutObj.Units,'points',objPos);
                    hLayoutObj.setLayoutPosition(newObjPos);

                    currInnerBox(3)=currInnerBox(3)-innerObjAdjustment(1)-decorationOffset(1);
                case 'west'


                    objPos=[0,0,prefSize];
                    objPos(1)=currInnerBox(1)+decorationOffset(1);




                    objPos(2)=min(plotBox(2)+plotBox(4)-prefSize(2)-decorationOffset(2),max(plotBox(2)+decorationOffset(2),plotBox(2)+prefLoc(2)*plotBox(4)-.5*prefSize(2)));
                    newObjPos=convertUnits(objViewport,hLayoutObj.Units,'points',objPos);
                    hLayoutObj.setLayoutPosition(newObjPos);

                    currInnerBox(1)=currInnerBox(1)+innerObjAdjustment(1)+decorationOffset(1);
                    currInnerBox(3)=currInnerBox(3)-innerObjAdjustment(1)-decorationOffset(1);
                case 'north'


                    objPos=[0,0,prefSize];
                    objPos(2)=currInnerBox(2)+currInnerBox(4)-prefSize(2)-decorationOffset(2);




                    objPos(1)=min(plotBox(1)+plotBox(3)-prefSize(1)-decorationOffset(1),max(plotBox(1)+decorationOffset(1),plotBox(1)+prefLoc(1)*plotBox(3)-.5*prefSize(1)));
                    newObjPos=convertUnits(objViewport,hLayoutObj.Units,'points',objPos);
                    hLayoutObj.setLayoutPosition(newObjPos);

                    currInnerBox(4)=currInnerBox(4)-innerObjAdjustment(2)-decorationOffset(2);
                case 'south'


                    objPos=[0,0,prefSize];
                    objPos(2)=currInnerBox(2)+decorationOffset(2);




                    objPos(1)=min(plotBox(1)+plotBox(3)-prefSize(1)-decorationOffset(1),max(plotBox(1)+decorationOffset(1),plotBox(1)+prefLoc(1)*plotBox(3)-.5*prefSize(1)));
                    newObjPos=convertUnits(objViewport,hLayoutObj.Units,'points',objPos);
                    hLayoutObj.setLayoutPosition(newObjPos);

                    currInnerBox(2)=currInnerBox(2)+innerObjAdjustment(2)+decorationOffset(2);
                    currInnerBox(4)=currInnerBox(4)-innerObjAdjustment(2)-decorationOffset(2);
                end
            end


            s.MakeRoom=hObj.MakeRoom;
            s.ExpectedAxesPositionNorm=[0,0,1,1];
            s.ExpectedAxesPositionPixels=[1,1,560,420];
            s.ExpectedAxesPositionProperty='outerposition';
            s.StartingLayoutPositionNorm=hObj.StartingLayoutPositionNorm;
            s.StartingLayoutPositionPixels=hObj.StartingLayoutPositionPixels;
            s.StartingLooseInsetNorm=hObj.StartingLooseInsetNorm;
            s.StartingLooseInsetPixels=hObj.StartingLooseInsetPixels;
            setappdata(hAx,'LayoutInfo',s);




            if~isprop(hAx,'PlotBox')
                hprop=addprop(hAx,'PlotBox');
                hprop.Hidden=true;
                hprop.Transient=true;
            end
            hAx.PlotBox=newLayoutInfo.PlotBox;
            layoutInfo=hAx.GetLayoutInformation();
            hObj.setState(layoutInfo.OuterPosition,...
            "doUpdate",hAx.PositionConstraint);
        end

        function hParent=getParentImpl(~,hParent)


        end

        function hParent=setParentImpl(hObj,hParent)



            hParent=setParentImpl@matlab.graphics.mixin.UIParentable(hObj,hParent);

            if isscalar(hParent)
                positionableAncestor=ancestor(hParent,...
                'matlab.graphics.chartcontainer.mixin.internal.Positionable','node');
                hObj.ChartLayout=~isempty(positionableAncestor);
            end
        end

        function enableAxesDirtyListeners(hObj,trueFalse)



            hObj.Enabled=trueFalse;
            hObj.AxesDirtyListener.Enabled=trueFalse;
            listComponents=[hObj.InnerList,hObj.OuterList];
            if~isempty(listComponents)
                for i=1:numel(listComponents)


                    listComponents(i).DirtyListener.Enabled=trueFalse;


                    listComponents(i).ObjectHandle.enableAxesDirtyListeners(trueFalse);
                end
            end



            slm=getSubplotLayoutManager(hObj);
            if~isempty(slm)
                if trueFalse
                    slm.enable();
                else
                    slm.disable();
                end
            end
        end

        function tf=is2Dim(hObj)

            tf=false;
            if isvalid(hObj.Axes)
                ax=hObj.Axes;
                tf=isequal(ax.View,[0,90])&&...
                (~hasCameraProperties(ax)||isequal(abs(ax.CameraUpVector_I),[0,1,0]));
            end
        end

        function[op,units]=getOuterPositionForAutoResize(hObj)














            forceFullUpdate(hObj,'all','OuterPosition');


            op=hObj.Axes.OuterPosition;
            units=hObj.Axes.Units;


            startingOp=hObj.StartingOuterPositionPixels;
            if hObj.MakeRoom&&~isempty(startingOp)




                op=startingOp;
                units='pixels';
            end
        end

        function[inset,units]=getTightInset(hObj)







            layout=hObj.Axes.GetLayoutInformation;
            almDecPlotBox=hObj.DecoratedPlotBoxPixels;
            axDecPlotBox=layout.DecoratedPlotBox;
            if isempty(almDecPlotBox)

                almDecPlotBox=axDecPlotBox;
            end



            leftbottom=min(almDecPlotBox(1:2),axDecPlotBox(1:2));
            topright=max(almDecPlotBox(1:2)+almDecPlotBox(3:4),...
            axDecPlotBox(1:2)+axDecPlotBox(3:4));


            pos=layout.Position;
            inset=[0,0,0,0];
            inset(1:2)=pos(1:2)-leftbottom;
            inset(3:4)=topright-(pos(1:2)+pos(3:4));



            adjustments=hObj.DecorationAdjustments;
            if~isempty(adjustments)
                inset=max(inset,adjustments);
            end


            inset(inset<0)=0;
            units='pixels';
        end
    end
end

function addInstancePropToAxes(hAx)
    hP=addprop(hAx,'LayoutManager');
    hP.Hidden=true;
    hP.Transient=true;
    hP.SetAccess='private';
end

function setInstancePropOnAxes(hObj,hAx)
    hP=hAx.findprop('LayoutManager');
    hP.SetAccess='public';
    hAx.LayoutManager=hObj;
    hP.SetAccess='private';
end

function tf=isNearlyEqual(newAxPosPoints,currAxPosPoints,tolInPixels,axViewport)
    import matlab.graphics.internal.convertUnits
    posPixels=[1,1,1,tolInPixels];
    posPoints=convertUnits(axViewport,'points','pixels',posPixels);
    tolInPoints=posPoints(4);
    tf=all(abs(newAxPosPoints-currAxPosPoints)<tolInPoints);
end

function[liPx,liNorm]=calculateLooseInset(ax)

    import matlab.graphics.internal.convertUnits
    import matlab.graphics.internal.convertDistances


    li=ax.LooseInset_I;
    units=ax.Units;
    op=ax.GetLayoutInformation.OuterPosition;


    if strcmp(units,'normalized')
        liNorm=li;
        liPx=liNorm.*op([3,4,3,4]);
    elseif strcmp(units,'pixels')
        liPx=li;
        liNorm=liPx./op([3,4,3,4]);
    else
        liPx=convertDistances(ax.Camera.Viewport,...
        'pixels',units,li);
        liNorm=liPx./op([3,4,3,4]);
    end

end

function adjustments=capMinimumSize(startingPos,adjustments,minSize)






    minWidth=min(minSize,startingPos(3));
    widthAdjustments=adjustments(1)+adjustments(3);
    if(startingPos(3)-widthAdjustments)<minWidth


        maxAdjustment=startingPos(3)-minWidth;
        adjustments([1,3])=adjustments([1,3]).*maxAdjustment./widthAdjustments;
    end

    minHeight=min(minSize,startingPos(4));
    heightAdjustments=adjustments(2)+adjustments(4);
    if(startingPos(4)-heightAdjustments)<minHeight


        maxAdjustment=startingPos(4)-minHeight;
        adjustments([2,4])=adjustments([2,4]).*maxAdjustment./heightAdjustments;
    end

end
