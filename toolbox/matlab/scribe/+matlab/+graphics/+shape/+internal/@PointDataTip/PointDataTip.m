classdef(ConstructOnLoad,Sealed)PointDataTip<matlab.graphics.primitive.world.Group...
    &matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.internal.Legacy...
    &matlab.graphics.mixin.Selectable...
    &matlab.graphics.mixin.PolarAxesParentable...
    &matlab.graphics.mixin.GeographicAxesParentable






    properties(Hidden=true,DeepCopy)

        TipHandle{mustBe_matlab_graphics_shape_internal_TipInfo};


        LocatorHandle{mustBe_matlab_graphics_shape_internal_TipLocator};
    end

    properties(Hidden=true)
        Listeners;
    end

    properties(Hidden=true,Transient,NonCopyable)
        LocatorListener;
        TipListener;
        MarkedCleanListener;
    end

    properties(Hidden=true,SetObservable=true)
        ParentLayer='overlay';
    end

    properties(SetAccess=private,GetAccess=public,NonCopyable)


        Cursor matlab.graphics.shape.internal.PointDataCursor;
    end

    properties(Access=private)
        AddedMiddleLayer=false;
        AddedOverlayLayer=true;
    end

    properties(SetAccess=private,GetAccess=public)
        IsAddedViaDataTipAPI=false;
    end

    properties(SetAccess=private,GetAccess=private,Transient,NonCopyable)

        TipHitListener=event.listener.empty;
    end

    properties(SetAccess=private,GetAccess=private,Transient,NonCopyable)



        CursorListeners=event.listener.empty;


        LocatorHitListener=event.listener.empty;




        DataSourceListener=event.listener.empty;



        ControllerData={};



        TrueParent=matlab.graphics.primitive.world.Group.empty;


        StringUpdateStrategy=[];



        WebInteractionsInitListener=event.listener.empty;
    end

    properties(SetObservable=true,SetAccess=public,GetAccess=public)






        UpdateFcn matlab.internal.datatype.matlab.graphics.datatype.Callback='';
    end

    properties(SetAccess=public,GetAccess=public)



        Draggable matlab.internal.datatype.matlab.graphics.datatype.on_off='on';





        Controller{mustBe_matlab_graphics_shape_internal_DataTipController};
    end

    properties(AffectsObject,SetAccess=public,GetAccess=public)



        DataTipStyle matlab.graphics.shape.internal.util.PointDataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerAndTip;


        PinnableStyle matlab.graphics.shape.internal.util.PinnableStyle=matlab.graphics.shape.internal.util.PinnableStyle.Pinnable;


        PinnedView matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
        CurrentTip matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    properties(AffectsObject,SetObservable=true,GetAccess=public,SetAccess=public,Dependent=true)


        BackgroundAlpha;


        BackgroundColor;


        EdgeColor;


        FontAngle;


        FontName;


        FontSize;


        FontUnits;


        FontWeight;


        Marker;


        MarkerEdgeColor;


        MarkerFaceColor;


        MarkerSize;



        Orientation;


        TextColor;

        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter


        String;
    end

    properties(AffectsObject,SetObservable=true,GetAccess=public,SetAccess=public,Dependent=true,NeverAmbiguous)


        OrientationMode;
    end

    properties(SetObservable=true,GetAccess=public,SetAccess=public,Dependent=true)



        DataSource;




        Position;


        Interpolate;


        Host;
    end

    events(NotifyAccess=private)


LocatorHit



TipHit
    end


    properties(SetAccess=private,GetAccess=public,Transient,NonCopyable)

        AreWebInteractionsEnabled=false;
    end

    events
ValueChanged
    end

    methods
        function set.TipHandle(hObj,newValue)
            oldValue=hObj.TipHandle;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)
                    hObj.replaceChild(hObj.TipHandle,newValue);
                else
                    hObj.addNode(newValue);
                end
                hObj.TipHitListener=event.listener(newValue,'Hit',@hObj.tipHit);%#ok<MCSUP>
            else
                if~isempty(oldValue)&&isvalid(oldValue)
                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
                hObj.TipHitListener=event.listener.empty;%#ok<MCSUP>
            end
            hObj.TipHandle=newValue;

            hObj.MarkDirty('all');
        end

        function set.LocatorHandle(hObj,newValue)
            oldValue=hObj.LocatorHandle;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)
                    hObj.replaceChild(hObj.LocatorHandle,newValue);
                else
                    hObj.addNode(newValue);
                end
                hObj.LocatorHitListener=event.listener(newValue,'Hit',@hObj.locatorHit);%#ok<MCSUP>
            else
                if~isempty(oldValue)&&isvalid(oldValue)
                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
                hObj.LocatorHitListener=event.listener.empty;%#ok<MCSUP>
            end
            hObj.LocatorHandle=newValue;

            hObj.MarkDirty('all');
        end

        function set.Controller(hObj,newValue)
            newValue=newValue(:);

            oldValue=hObj.Controller;
            oldData=hObj.ControllerData;%#ok<MCSUP>

            if~isempty(oldValue)

                [removed,idx_removed]=setdiff(oldValue,newValue,'legacy');
                if~isempty(removed)
                    for n=1:numel(removed)
                        if isvalid(removed(n))
                            removed(n).uninstall(hObj,oldData{idx_removed(n)});
                        end
                    end
                end
            end


            newData=cell(size(newValue));

            if~isempty(newValue)


                [installed,dataloc]=ismember(newValue,oldValue,'legacy');
                for n=1:numel(newValue)
                    if installed(n)
                        newData{n}=oldData{dataloc(n)};
                    else
                        newData{n}=newValue(n).install(hObj);
                    end
                end
            end

            hObj.Controller=newValue;
            hObj.ControllerData=newData;%#ok<MCSUP>
        end

        function set.PinnedView(hObj,newValue)
            if strcmp(hObj.PinnableStyle,'Pinnable')%#ok<MCSUP>
                if~strcmpi(hObj.PinnedView,newValue)
                    hObj.PinnedView=newValue;


                    hObj.updatePinnedState();
                end
            end
        end

        function set.ParentLayer(hObj,newValue)



            if~strcmpi(hObj.ParentLayer,newValue)
                hObj.ParentLayer=newValue;
                hObj.TipHandle.ParentLayer=newValue;%#ok<MCSUP>
                hObj.LocatorHandle.ParentLayer=newValue;%#ok<MCSUP>
            end
        end

        function val=get.BackgroundAlpha(hObj)

            val=hObj.TipHandle.BackgroundAlpha;
        end

        function set.BackgroundAlpha(hObj,newValue)

            hObj.TipHandle.BackgroundAlpha=newValue;
        end

        function val=get.BackgroundColor(hObj)

            val=hObj.TipHandle.BackgroundColor;
        end

        function set.BackgroundColor(hObj,newValue)

            hObj.TipHandle.BackgroundColor=newValue;
        end

        function val=get.EdgeColor(hObj)

            val=hObj.TipHandle.EdgeColor;
        end

        function set.EdgeColor(hObj,newValue)

            hObj.TipHandle.EdgeColor=newValue;
        end

        function val=get.FontAngle(hObj)

            val=hObj.TipHandle.FontAngle;
        end

        function set.FontAngle(hObj,newValue)

            hObj.TipHandle.FontAngle=newValue;
        end

        function val=get.FontName(hObj)

            val=hObj.TipHandle.FontName;
        end

        function set.FontName(hObj,newValue)

            hObj.TipHandle.FontName=newValue;
        end

        function val=get.FontSize(hObj)

            val=hObj.TipHandle.FontSize;
        end

        function set.FontSize(hObj,newValue)

            hObj.TipHandle.FontSize=newValue;
        end

        function val=get.FontUnits(hObj)

            val=hObj.TipHandle.FontUnits;
        end

        function set.FontUnits(hObj,newValue)

            hObj.TipHandle.FontUnits=newValue;
        end

        function val=get.FontWeight(hObj)

            val=hObj.TipHandle.FontWeight;
        end

        function set.FontWeight(hObj,newValue)

            hObj.TipHandle.FontWeight=newValue;
        end

        function val=get.Marker(hObj)

            val=hObj.LocatorHandle.Marker;
        end

        function set.Marker(hObj,newValue)

            hObj.LocatorHandle.Marker=newValue;
        end

        function val=get.MarkerEdgeColor(hObj)

            val=hObj.LocatorHandle.EdgeColor;
        end

        function set.MarkerEdgeColor(hObj,newValue)

            hObj.LocatorHandle.EdgeColor=newValue;
        end

        function val=get.MarkerFaceColor(hObj)

            val=hObj.LocatorHandle.FaceColor;
        end

        function set.MarkerFaceColor(hObj,newValue)

            hObj.LocatorHandle.FaceColor=newValue;
        end

        function val=get.MarkerSize(hObj)

            val=hObj.LocatorHandle.Size;
        end

        function set.MarkerSize(hObj,newValue)

            hObj.LocatorHandle.Size=newValue;

            hObj.MarkDirty('all');
        end

        function val=get.Orientation(hObj)

            val=hObj.TipHandle.Orientation;
        end

        function set.Orientation(hObj,newValue)

            hObj.TipHandle.Orientation=newValue;
        end

        function val=get.OrientationMode(hObj)

            val=hObj.TipHandle.OrientationMode;
        end

        function set.OrientationMode(hObj,newValue)

            hObj.TipHandle.OrientationMode=newValue;
        end

        function val=get.TextColor(hObj)

            val=hObj.TipHandle.Color;
        end

        function set.TextColor(hObj,newValue)

            hObj.TipHandle.Color=newValue;
        end

        function val=get.DataSource(hObj)

            if~isempty(hObj.Cursor)
                val=hObj.Cursor.DataSource;
            else
                val=[];
            end
        end

        function set.DataSource(hObj,newValue)

            if~isempty(hObj.Cursor)
                hObj.Cursor.DataSource=newValue;
            end
        end

        function val=get.Position(hObj)

            if~isempty(hObj.Cursor)
                val=hObj.Cursor.Position;
            else
                val=[NaN,NaN,NaN];
            end
        end

        function set.Position(hObj,newValue)

            if~isempty(hObj.Cursor)
                hObj.Cursor.Position=newValue;
            end
        end

        function set.UpdateFcn(hObj,newValue)



            newValue=hgcastvalue('matlab.graphics.datatype.Callback',newValue);


            hObj.UpdateFcn=newValue;


            hObj.TipHandle.TextFormatHelper.UpdateFcn=newValue;


            hObj.clearStringStrategy();


            hObj.MarkDirty('all');
        end

        function set.Cursor(hObj,hCursor)



            hObj.Cursor=hCursor;


            if~isempty(hCursor)


                hObj.CursorListeners=[...
                event.listener(hCursor,'CursorDataSourceChanged',@hObj.dataSourceChanged),...
                event.listener(hCursor,'CursorUpdated',@hObj.cursorUpdated),...
                event.listener(hCursor,'ObjectBeingDestroyed',@(obj,evd)delete(hObj))...
                ];%#ok<MCSUP>

            else
                hObj.CursorListeners=event.listener.empty;%#ok<MCSUP>
            end


            hObj.dataSourceChanged();
        end

        function hObj=PointDataTip(varargin)








            if nargin&&~ischar(varargin{1})

                hTarget=varargin{1};
                varargin(1)=[];


                matlab.graphics.shape.internal.PointDataTip.validateTarget(hTarget);
            else


                hTarget=[];
            end

            hObj.TipHandle=matlab.graphics.shape.internal.GraphicsTip();
            hObj.LocatorHandle=matlab.graphics.shape.internal.PointTipLocator();




            if isempty(hTarget)
                hCursor=matlab.graphics.shape.internal.PointDataCursor.empty;
            elseif isa(hTarget,'matlab.graphics.chart.interaction.DataAnnotatable')
                hCursor=matlab.graphics.shape.internal.PointDataCursor(hTarget);
            else
                hCursor=hTarget;
            end



            hObj.Cursor=hCursor;


            hObj.Type='hggroup';


            hObj.Controller=matlab.graphics.shape.internal.PointDataTipController.getInstance;



            hObj.addDependencyConsumed({'xyzdatalimits','view','hgtransform_under_dataspace'});



            if nargin>1
                set(hObj,varargin{:});
            end

            hObj.applyDataTipTemplate();
            if~hObj.IsAddedViaDataTipAPI&&...
                ~isempty(hObj.DataSource)&&...
                matlab.graphics.datatip.DataTip.isValidParent(hObj.DataSource.getAnnotationTarget())
                matlab.graphics.datatip.DataTip(hObj);
            end


            hObj.WebInteractionsInitListener=event.listener(hObj,'MarkedClean',@(s,e)hObj.enableInteractionsOnDatatips());
        end


        function val=get.Host(hObj)
            val=hObj.DataSource;
        end

        function set.Host(hObj,newVal)
            hObj.Cursor.DataSource=newVal;
        end

        function val=get.String(hObj)
            val=char(hObj.TipHandle.String);
        end

        function set.String(hObj,newVal)
            hObj.TipHandle.String=newVal;
        end

        function val=get.Interpreter(hObj)
            val=hObj.TipHandle.Interpreter;
        end

        function set.Interpreter(hObj,newVal)
            hObj.TipHandle.Interpreter=newVal;
            hObj.TipHandle.TextFormatHelper.Interpreter=newVal;
        end

        function set.Interpolate(hObj,newValue)
            hObj.Cursor.Interpolate=newValue;
        end

        function val=get.Interpolate(hObj)
            val=hObj.Cursor.Interpolate;
        end
    end

    methods(Access={?matlab.graphics.internal.CopyContext,?matlab.graphics.mixin.internal.Copyable},Hidden)
        connectCopyToTree(hCopy,hSrc,hCopyParent,hContext)
    end

    methods(Access=public)
        doUpdate(hObj,updateState)

        function firstChild=doGetChildren(~)
            firstChild=matlab.graphics.shape.internal.GraphicsTip.empty;
        end

        function extents=getXYZDataExtents(~)


            extents=[NaN,NaN;NaN,NaN;NaN,NaN];
        end


        function obj=getObjectToInspect(hObj)
            obj=[];
            if~isempty(hObj.DataSource)&&isprop(hObj.DataSource,'DataTipTemplate')
                obj=hObj.DataSource.DataTipTemplate.getInspectorProxy();
            end
        end
    end

    methods(Access=public,Hidden)
        function beginInteraction(hObj)




            evd=matlab.graphics.shape.internal.TipHitEvent(1,[0,0],[]);
            hObj.notify('LocatorHit',evd);
        end

        function markPointDataTipDirty(hObj)

            hObj.MarkDirty('all');
        end


        function setPickability(hObj,val)
            hObj.LocatorHandle.setPickability(val);
            hObj.TipHandle.setPickability(val);
        end
    end

    methods(Access=private)

        function applyDataTipTemplate(hObj)
            hDS=hObj.DataSource;


            if~isempty(hDS)&&isprop(hDS,'DataTipTemplate')&&...
                matlab.graphics.datatip.internal.DataTipTemplateHelper.isCustomizable(hDS)
                if strcmpi(hDS.DataTipTemplate.DataTipRowsMode,'manual')
                    hObj.UpdateFcn=[];
                end

                hObj.TipHandle.TextFormatHelper.isDataTipCustomizable=true;
            else
                hObj.TipHandle.TextFormatHelper.isDataTipCustomizable=false;
            end
        end

        function updatePinnedState(hTip)


            pb=hggetbehavior(hTip,'Print');
            if strcmpi(hTip.PinnedView,'off')

                hTip.MarkerFaceColor=matlab.graphics.shape.internal.PointTipLocator.TRANSIENT_MARKERCOLOR;

                hTip.TipHandle.TextFormatHelper.TexValueFormat=matlab.graphics.shape.internal.TextFormatHelper.TRANSIENT_VALUESTRING;



                hTip.TipHitListener.Enabled=false;
                hTip.setPickability('none');
                if~isempty(hTip.UIContextMenu)
                    hTip.UIContextMenu=[];
                end


                hTip.CurrentTip='off';


                pb.PrePrintCallback=@(hObj,type)hObj.excludePrintCallback(type);
                pb.PostPrintCallback=@(hObj,type)hObj.excludePrintCallback(type);
            else
                hTip.TipHandle.ScribeHost.Tag='GraphicsTip';




                hTip.TipHandle.ScribeHost.setPeerParentSerializable();


                hTip.MarkerFaceColor=matlab.graphics.shape.internal.PointTipLocator.PINNED_MARKERCOLOR;

                hTip.TipHandle.TextFormatHelper.TexValueFormat=matlab.graphics.shape.internal.TextFormatHelper.PINNED_VALUESTRING;


                hTip.TipHitListener.Enabled=true;




                hTip.setPickability('visible');


                pb.PrePrintCallback=[];
                pb.PostPrintCallback=[];




                matlab.graphics.shape.internal.DataTipController.setCurrentCursor(hTip);

            end
        end

        function findPositionInTree(hObj)

            hParent=matlab.graphics.primitive.world.Group.empty;
            hDS=hObj.DataSource;
            if~isempty(hDS)
                hParent=hDS.Parent;
            end

            if isa(hParent,'matlab.graphics.axis.Axes')...
                ||isa(hParent,'matlab.graphics.chart.Chart')




                [~,newParent]=matlab.graphics.internal.plottools.getDataSpaceForChild(hDS.getAnnotationTarget());
                if~isempty(newParent)
                    hParent=newParent;
                end
            end



            if~isempty(hParent)&&all(hObj.TrueParent~=hParent)
                hParent.addNode(hObj);
            end
            hObj.TrueParent=hParent;
        end

        function dataSourceChanged(hObj,~,~)
            if isvalid(hObj)
                hDS=hObj.DataSource;
                if~isempty(hDS)


                    newTarget=hDS.getAnnotationTarget;
                    props=[findprop(newTarget,'Visible'),...
                    findprop(newTarget,'Parent'),...
                    findprop(newTarget,'Clipping')];

                    hObj.DataSourceListener=event.proplistener(newTarget,...
                    props,'PostSet',...
                    @hObj.cursorUpdated);
                else
                    hObj.DataSourceListener=event.listener.empty;
                end
            end


            hObj.cursorUpdated();
        end

        function cursorUpdated(hObj,~,~)
            if isvalid(hObj)
                hObj.findPositionInTree();
                hObj.updateParentLayerIfNeeded();
                hObj.applyDataTipTemplate();

                hObj.MarkDirty('all');
            end
        end

        function locatorHit(hObj,~,evd)



            evd=matlab.graphics.shape.internal.TipHitEvent(...
            evd.Button,...
            evd.IntersectionPoint,...
            evd.Primitive);
            hObj.notify('LocatorHit',evd);
        end

        function tipHit(hObj,~,evd)



            evd=matlab.graphics.shape.internal.TipHitEvent(...
            evd.Button,...
            evd.IntersectionPoint,...
            evd.Primitive);
            hObj.notify('TipHit',evd);
        end

        function clearStringStrategy(hObj)


            hObj.StringUpdateStrategy=[];
        end

        function configureStringStrategy(hObj)






            hDS=hObj.Cursor.DataSource.getAnnotationTarget();
            if isprop(hDS,'DataTipTemplate')&&isvalid(hDS.DataTipTemplate)&&...
                strcmpi(hDS.DataTipTemplate.DataTipRowsMode,'manual')
                hObj.UpdateFcn=[];
            end


            if isempty(hObj.UpdateFcn)
                func=createStandardStringStrategy();
            else
                func=createCustomStringStrategy();
            end
            hObj.StringUpdateStrategy=func;
        end

        function excludePrintCallback(tip,type)

            if strcmp(type,'PrePrintCallback')
                tip.Visible_I='off';
            elseif strcmp(type,'PostPrintCallback')
                tip.Visible_I='on';
            end
        end

        function updateParentLayerIfNeeded(hObj)

            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');






            if~isempty(ax)&&isvalid(ax)
                hFig=ancestor(ax,'figure','node');
                if~isempty(hFig)&&matlab.ui.internal.isUIFigure(hFig)...
                    &&isa(ax,'matlab.graphics.axis.Axes')
                    if~strcmp(hObj.ParentLayer,'middle')
                        hObj.ParentLayer='middle';
                    end
                else
                    if~strcmp(hObj.ParentLayer,'overlay')
                        hObj.ParentLayer='overlay';
                        hObj.setParentToOverlayLayer(hFig);
                    end
                end
            end
        end
    end

    methods(Hidden)

        function setParentToOverlayLayer(hObj,fig)
            if~isempty(fig)&&~matlab.ui.internal.isUIFigure(fig)...
                &&~isempty(hObj)...
                &&isvalid(hObj)...
                &&strcmp(hObj.PinnedView,'on')...
                &&strcmp(hObj.ParentLayer,'overlay')

                delete(hObj.LocatorListener);
                delete(hObj.TipListener);

                if~isa(hObj.TipHandle,'matlab.graphics.shape.internal.PanelTip')
                    sHLocator=hObj.LocatorHandle.ScribeHost;
                    sHTip=hObj.TipHandle.ScribeHost;
                    sPLocator=sHLocator.getScribePeer();
                    sPTip=sHTip.getScribePeer();
                    ap=matlab.graphics.annotation.internal.getDefaultCamera(fig,'overlay','-peek');



                    if sPLocator.Parent~=ap
                        sPLocator.Parent=ap;
                    end

                    if sPTip.Parent~=ap
                        sPTip.Parent=ap;
                    end
                end
                hObj.AddedMiddleLayer=false;
                hObj.AddedOverlayLayer=true;
            end
        end



        function setParentToMiddleLayer(hObj,fig)
            if~isempty(fig)&&matlab.ui.internal.isUIFigure(fig)...
                &&~isempty(hObj)...
                &&isvalid(hObj)...
                &&strcmp(hObj.PinnedView,'on')...
                &&strcmp(hObj.ParentLayer,'middle')
                delete(hObj.LocatorListener);
                delete(hObj.TipListener);

                if~isa(hObj.TipHandle,'matlab.graphics.shape.internal.PanelTip')
                    sHTip=hObj.TipHandle.ScribeHost;
                    sPTip=sHTip.getScribePeer();
                    sHTip.addNode(sPTip);
                    hObj.TipListener=event.listener(sHTip,'MarkedClean',@(s,e)hObj.changeClipping(sHTip));
                end


                sHLocator=hObj.LocatorHandle.ScribeHost;
                sPLocator=sHLocator.getScribePeer();
                sHLocator.addNode(sPLocator);
                hObj.LocatorListener=event.listener(sHLocator,'MarkedClean',@(s,e)hObj.changeClipping(sHLocator));
                hObj.AddedMiddleLayer=true;
                hObj.AddedOverlayLayer=false;
            end
        end




        function enableInteractionsOnDatatips(hObj,canvas)

            if~hObj.PinnedView||hObj.AreWebInteractionsEnabled

                return
            end

            if nargin==1
                canvas=ancestor(hObj,'matlab.graphics.primitive.canvas.HTMLCanvas','node');
                if isempty(canvas)
                    return
                end
            end

            pointTipLocator=findobjinternal(hObj,'-isa','matlab.graphics.shape.internal.PointTipLocator');
            draggbleDtatips=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DraggbleDatatipInteraction(pointTipLocator,canvas);



            addlistener(draggbleDtatips,'ObjectBeingDestroyed',@(e,d)set(hObj,'AreWebInteractionsEnabled',false));

            canvas.InteractionsManager.registerInteraction(pointTipLocator,draggbleDtatips);
            dragOrientationDatatip=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragDatatipOrientationInteraction(hObj.TipHandle);
            addlistener(dragOrientationDatatip,'ObjectBeingDestroyed',@(e,d)set(hObj,'AreWebInteractionsEnabled',false));
            canvas.InteractionsManager.registerInteraction(hObj.TipHandle,dragOrientationDatatip);

            hObj.AreWebInteractionsEnabled=true;
        end

        function changeClipping(~,sh)



            sh.setClippingAndlayer();
        end

        function isAddedViaAPI=checkIsAddedViaDataTipAPI(hObj)
            isAddedViaAPI=hObj.IsAddedViaDataTipAPI;
        end
    end

    methods(Access=?matlab.graphics.shape.internal.DataCursorManager,Static=true)
        function setMenuNotCopyable(hObj)
            hObj.Copyable=false;
        end
    end

    methods(Access=private,Static=true)
        function validateTarget(hTarget)


            if~isscalar(hTarget)||...
                (~isa(hTarget,'matlab.graphics.chart.interaction.DataAnnotatable')&&...
                ~isa(hTarget,'matlab.graphics.shape.internal.PointDataCursor'))||...
                ~isvalid(hTarget)

                E=MException('matlab:graphics:shape:internal:PointDataTip:InvalidTarget',...
                ['The target object must be either an object implementing the ''DataAnnotatable''',...
                ' mixin or a matlab.graphics.shape.internal.PointDataCursor.']);
                E.throwAsCaller();
            end
        end
    end
end

function mustBe_matlab_graphics_shape_internal_DataTipController(input)
    if~isa(input,'matlab.graphics.shape.internal.DataTipController')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.graphics.shape.internal.DataTipController').getString));
    end
end

function mustBe_matlab_graphics_shape_internal_TipInfo(input)
    if~isa(input,'matlab.graphics.shape.internal.TipInfo')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.graphics.shape.internal.TipInfo').getString));
    end
end

function mustBe_matlab_graphics_shape_internal_TipLocator(input)
    if~isa(input,'matlab.graphics.shape.internal.TipLocator')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.graphics.shape.internal.TipLocator').getString));
    end
end
