
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Ellipse<matlab.graphics.shape.internal.TwoDimensional





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Transform matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Transform(hObj)


            valueToCaller=hObj.Transform_I;

        end

        function set.Transform(hObj,newValue)



            hObj.TransformMode='manual';


            hObj.Transform_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        TransformMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TransformMode(hObj)
            storedValue=hObj.TransformMode;
        end

        function set.TransformMode(hObj,newValue)

            oldValue=hObj.TransformMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TransformMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Transform_I;
    end

    methods
        function set.Transform_I(hObj,newValue)
            hObj.Transform_I=newValue;
            try
                hObj.setTransform_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        BoundingRect matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.BoundingRect(hObj)


            valueToCaller=hObj.BoundingRect_I;

        end

        function set.BoundingRect(hObj,newValue)



            hObj.BoundingRectMode='manual';


            hObj.BoundingRect_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BoundingRectMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BoundingRectMode(hObj)
            storedValue=hObj.BoundingRectMode;
        end

        function set.BoundingRectMode(hObj,newValue)

            oldValue=hObj.BoundingRectMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BoundingRectMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        BoundingRect_I;
    end

    methods
        function set.BoundingRect_I(hObj,newValue)
            oldValue=hObj.BoundingRect_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.Transform.replaceChild(hObj.BoundingRect_I,newValue);
                else

                    hObj.Transform.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.BoundingRect_I=newValue;
            try
                hObj.setBoundingRect_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.EdgeColor(hObj)


            valueToCaller=hObj.EdgeColor_I;

        end

        function set.EdgeColor(hObj,newValue)



            hObj.EdgeColorMode='manual';


            hObj.EdgeColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        EdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeColorMode(hObj)
            storedValue=hObj.EdgeColorMode;
        end

        function set.EdgeColorMode(hObj,newValue)

            oldValue=hObj.EdgeColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.EdgeColor_I(hObj)
            storedValue=hObj.EdgeColor_I;
        end

        function set.EdgeColor_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.EdgeColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Face matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Face(hObj)


            valueToCaller=hObj.Face_I;

        end

        function set.Face(hObj,newValue)



            hObj.FaceMode='manual';


            hObj.Face_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        FaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceMode(hObj)
            storedValue=hObj.FaceMode;
        end

        function set.FaceMode(hObj,newValue)

            oldValue=hObj.FaceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Face_I;
    end

    methods
        function set.Face_I(hObj,newValue)
            oldValue=hObj.Face_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.Transform.replaceChild(hObj.Face_I,newValue);
                else

                    hObj.Transform.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Face_I=newValue;
            try
                hObj.setFace_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Edge matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Edge(hObj)


            valueToCaller=hObj.Edge_I;

        end

        function set.Edge(hObj,newValue)



            hObj.EdgeMode='manual';


            hObj.Edge_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        EdgeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeMode(hObj)
            storedValue=hObj.EdgeMode;
        end

        function set.EdgeMode(hObj,newValue)

            oldValue=hObj.EdgeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Edge_I;
    end

    methods
        function set.Edge_I(hObj,newValue)
            oldValue=hObj.Edge_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.Transform.replaceChild(hObj.Edge_I,newValue);
                else

                    hObj.Transform.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Edge_I=newValue;
            try
                hObj.setEdge_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
    end

    methods
        function valueToCaller=get.FaceColor(hObj)


            valueToCaller=hObj.FaceColor_I;

        end

        function set.FaceColor(hObj,newValue)



            hObj.FaceColorMode='manual';


            hObj.FaceColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceColorMode(hObj)
            storedValue=hObj.FaceColorMode;
        end

        function set.FaceColorMode(hObj,newValue)

            oldValue=hObj.FaceColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
    end

    methods
        function storedValue=get.FaceColor_I(hObj)
            storedValue=hObj.FaceColor_I;
        end

        function set.FaceColor_I(hObj,newValue)



            fanChild=hObj.Face;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.FaceColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function valueToCaller=get.LineStyle(hObj)


            valueToCaller=hObj.LineStyle_I;

        end

        function set.LineStyle(hObj,newValue)



            hObj.LineStyleMode='manual';


            hObj.LineStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineStyleMode(hObj)
            storedValue=hObj.LineStyleMode;
        end

        function set.LineStyleMode(hObj,newValue)

            oldValue=hObj.LineStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle=get(0,'DefaultLineLineStyle');
    end

    methods
        function storedValue=get.LineStyle_I(hObj)
            storedValue=hObj.LineStyle_I;
        end

        function set.LineStyle_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function valueToCaller=get.LineWidth(hObj)


            valueToCaller=hObj.LineWidth_I;

        end

        function set.LineWidth(hObj,newValue)



            hObj.LineWidthMode='manual';


            hObj.LineWidth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineWidthMode(hObj)
            storedValue=hObj.LineWidthMode;
        end

        function set.LineWidthMode(hObj,newValue)

            oldValue=hObj.LineWidthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineWidthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=get(0,'DefaultLineLineWidth');
    end

    methods
        function storedValue=get.LineWidth_I(hObj)
            storedValue=hObj.LineWidth_I;
        end

        function set.LineWidth_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Rotation matlab.internal.datatype.matlab.graphics.datatype.RealWithNoInfs=0;
    end

    methods
        function valueToCaller=get.Rotation(hObj)


            valueToCaller=hObj.Rotation_I;

        end

        function set.Rotation(hObj,newValue)



            hObj.RotationMode='manual';


            hObj.Rotation_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        RotationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.RotationMode(hObj)
            storedValue=hObj.RotationMode;
        end

        function set.RotationMode(hObj,newValue)

            oldValue=hObj.RotationMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.RotationMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Rotation_I matlab.internal.datatype.matlab.graphics.datatype.RealWithNoInfs=0;
    end

    methods
        function storedValue=get.Rotation_I(hObj)
            storedValue=hObj.Rotation_I;
        end

        function set.Rotation_I(hObj,newValue)



            hObj.Rotation_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'Transform')
                b=true;
                return;
            end
            if strcmp(name,'Transform_I')
                b=true;
                return;
            end
            if strcmp(name,'BoundingRect')
                b=true;
                return;
            end
            if strcmp(name,'BoundingRect_I')
                b=true;
                return;
            end
            if strcmp(name,'Face')
                b=true;
                return;
            end
            if strcmp(name,'Face_I')
                b=true;
                return;
            end
            if strcmp(name,'Edge')
                b=true;
                return;
            end
            if strcmp(name,'Edge_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.shape.internal.TwoDimensional(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=Ellipse(varargin)






            hObj.Transform_I=matlab.graphics.primitive.Transform;

            set(hObj.Transform,'Description_I','Ellipse Transform');

            set(hObj.Transform,'Internal',true);

            hObj.BoundingRect_I=matlab.graphics.primitive.world.Quadrilateral;

            set(hObj.BoundingRect,'Description_I','Ellipse BoundingRect');

            set(hObj.BoundingRect,'Internal',true);

            hObj.Face_I=matlab.graphics.primitive.world.TriangleStrip;

            set(hObj.Face,'Description_I','Ellipse Face');

            set(hObj.Face,'Internal',true);

            hObj.Edge_I=matlab.graphics.primitive.world.LineLoop;

            set(hObj.Edge,'Description_I','Ellipse Edge');

            set(hObj.Edge,'Internal',true);



            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setTransform_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setBoundingRect_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setFace_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.Face,hObj.FaceColor_I);

        end
    end
    methods(Access=private)
        function setEdge_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,hObj.EdgeColor_I);


            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,hObj.LineStyle_I);


            try
                mode=hObj.Edge.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Edge,'LineWidth_I',hObj.LineWidth_I);
            end

        end
    end


    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='ellipseshape';




            hAf=hObj.Srect;
            hG=matlab.graphics.primitive.world.Group.empty;
            set(hAf,'Parent',hG);
            for k=1:numel(hAf)
                hObj.addNode(hAf(k));
            end


            colorProps=hObj.ColorProps;
            colorProps{end+1}='EdgeColor';
            hObj.ColorProps=colorProps;



            hR=hObj.BoundingRect;
            hR.ColorBinding_I='none';
            hR.PickableParts_I='all';


            hObj.LineWidth_I=get(0,'DefaultLineLineWidth');
            hObj.LineStyle_I=get(0,'DefaultLineLineStyle');


            hObj.Transform.HitTest='off';
        end
    end
    methods(Access='public',Static=true,Hidden=true)

        varargout=doloadobj(hObj)
    end
    methods(Access='public',Hidden=true)
        function varargout=getScribeMenus(hObj)










            hFig=ancestor(hObj,'figure');
            res=matlab.ui.container.Menu.empty;

            if isempty(hFig)||~isvalid(hFig)
                varargout{1}=res;
                return;
            end

            hPlotEdit=plotedit(hFig,'getmode');
            hMode=hPlotEdit.ModeStateData.PlotSelectMode;
            hMenu=hMode.UIContextMenu;

            res=findall(hMenu,'Type','uimenu','-regexp','Tag','matlab.graphics.shape.Ellipse.uicontextmenu*');
            if~isempty(res)
                res=res(end:-1:1);
                varargout{1}=res;
                return;
            end


            res=matlab.ui.container.Menu.empty;
            tempParent=matlab.ui.container.ContextMenu;

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));

            res(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(hFig,tempParent,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')));


            menuSpecificTags={'Color','FaceColor','LineWidth','LineStyle'};
            assert(length(res)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
            for i=1:length(res)
                set(res(i),'Tag',['matlab.graphics.shape.Ellipse.uicontextmenu','.',menuSpecificTags{i}]);
            end


            set(res,'Visible','off','Parent',hMenu);
            delete(tempParent);
            varargout{1}=res;
        end
    end
    methods(Access='public',Hidden=true)
        function doUpdate(hObj,updateState)




            updatePins(hObj,updateState);
            updateMarkers(hObj,updateState);



            hIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            pos=hObj.NormalizedPosition;
            x=[pos(1),pos(1)+pos(3)];
            y=[pos(2),pos(2)+pos(4)];
            hIter.XData=[x(1),x(1),x(2),x(2)];
            hIter.YData=[y(1),y(2),y(1),y(2)];
            hIter.ZData=[0,0,0,0,0];
            vertexData=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,hIter);
            hBox=hObj.BoundingRect;
            set(hBox,'VertexData',vertexData);
            set(hBox,'StripData',uint32([1,5]));




            horizontalRadius=pos(3)/2;
            verticalRadius=pos(4)/2;
            centerX=pos(1)+horizontalRadius;
            centerY=pos(2)+verticalRadius;
            numVertices=75;
            angles=linspace(0,2*pi,numVertices)';
            x=cos(angles);
            y=sin(angles);
            z=zeros(size(x));

            x=x.*horizontalRadius;
            y=y.*verticalRadius;

            x=x+centerX;
            y=y+centerY;

            hIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            hIter.XData=x;
            hIter.YData=y;
            hIter.ZData=z;

            vertexData=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,hIter);
            hEdge=hObj.Edge;
            set(hEdge,'VertexData',vertexData);
            set(hEdge,'StripData',uint32([1,numVertices+1]));


            hFace=hObj.Face;

            half=(numVertices-1)/2;
            indices=[1:half;(numVertices-1):-1:(half+1)];
            indices=indices(:)';
            hFace.VertexData=vertexData(:,indices);
            hFace.VertexIndices=uint32([]);
            hFace.StripData=uint32([1,numVertices]);




            id='MATLAB:hg:DiceyTransformMatrix';
            old_warn_state=warning('query',id);
            warning('off',id);


            tform=getTransformationMatrix(hObj,updateState);
            hObj.Transform.Matrix=tform;


            warning(old_warn_state.state,id);

        end
    end
    methods(Access='public',Hidden=true)
        function varargout=getPlotEditToolbarProp(hObj,toolbarProp)

            if strcmpi(toolbarProp,'facecolor')
                varargout{1}={'FaceColor'};
                varargout{2}=getString(message('MATLAB:uistring:plotedittoolbar:FaceColor'));
            else
                outargs=cell(1,nargout);
                [outargs{1:nargout}]=getPlotEditToolbarProp@matlab.graphics.shape.internal.TwoDimensional(hObj,toolbarProp);
                varargout=outargs;
            end
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Color','FaceColor','LineStyle','LineWidth',...
            'Position','Units'});

        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getDescriptiveLabelForDisplay(hObj)

            varargout{1}=hObj.Tag;
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,code)
    end




end
