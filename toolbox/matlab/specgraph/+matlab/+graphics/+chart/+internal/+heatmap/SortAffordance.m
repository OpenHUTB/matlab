classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)SortAffordance<...
    matlab.graphics.primitive.world.Group&...
    matlab.graphics.mixin.Pickable




    events(NotifyAccess=private)
Click
    end

    properties
        BackgroundColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
        BackgroundAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0.15,0.15,0.15];
        EdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1

        HighlightBackgroundColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0.85,0.85,0.85];
        HighlightBackgroundAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
        HighlightEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
        HighlightEdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=1
        AlignVertexCenters matlab.lang.OnOffSwitchState=false

        TooltipString(1,1)string
    end

    properties(AffectsObject)
        Position(1,2)double=[0,0]
        Size(1,1)double=6
        HitArea(1,2)double=[0,0]
        Axis{mustBeMember(Axis,{'x','y'})}='y'
        State{mustBeMember(State,{'unsorted','ascending','descending'})}='unsorted'
        Style{mustBeMember(Style,{'caret','lines'})}='lines'
    end

    properties(Transient,NonCopyable,Hidden,Access=?ChartUnitTestFriend)
        Background matlab.graphics.primitive.world.TriangleStrip
        Container matlab.graphics.primitive.Marker
        Edge matlab.graphics.primitive.world.LineStrip
        ToolTip matlab.graphics.primitive.Text
        HitListener event.listener
        ClickListener event.listener
        Linger matlab.graphics.interaction.actions.Linger
        LingerEnter event.listener
        LingerExit event.listener
        LingerLinger event.listener
    end

    methods
        function hObj=SortAffordance(varargin)
            hObj.Description='Sort Icon';
            hObj.HitTest='on';


            background=matlab.graphics.primitive.world.TriangleStrip;
            background.Description='Sort Icon Background';
            background.Internal=true;
            background.HitTest='off';
            background.Clipping='off';
            hObj.Background=background;
            hObj.addNode(background);


            container=matlab.graphics.primitive.Marker;
            container.Description='Sort Icon Container';
            container.Internal=true;
            container.XLimInclude='off';
            container.YLimInclude='off';
            container.ZLimInclude='off';
            hObj.Container=container;
            hObj.addNode(container);


            edge=matlab.graphics.primitive.world.LineStrip;
            edge.Description='Sort Icon Edge';
            edge.Internal=true;
            edge.PickableParts='none';
            edge.HitTest='off';
            edge.Clipping='off';
            edge.LineJoin='miter';
            hObj.Edge=edge;
            container.addNode(edge);


            hObj.setDefaultPropertiesOnPrimitives();


            hObj.addDependencyConsumed({'ref_frame','view',...
            'dataspace','hgtransform_under_dataspace',...
            'xyzdatalimits','resolution'});


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);


            hObj.Linger=matlab.graphics.interaction.actions.Linger(hObj);
            hObj.attachCallbacks();
        end

        function set.Position(hObj,position)
            hObj.Position=position;
            hObj.Container.Anchor=[position,0];%#ok<MCSUP>
        end

        function set.BackgroundColor(hObj,color)
            hObj.BackgroundColor=color;
            if~ischar(color)
                color=[color,hObj.BackgroundAlpha];%#ok<MCSUP>
            end
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Background,color);%#ok<MCSUP>
        end

        function set.BackgroundAlpha(hObj,alpha)
            hObj.BackgroundAlpha=alpha;
            color=hObj.BackgroundColor;%#ok<MCSUP>
            if~ischar(color)
                color=[color,alpha];
            end
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Background,color);%#ok<MCSUP>
        end

        function set.EdgeColor(hObj,color)
            hObj.EdgeColor=color;
            if~ischar(color)
                color=[color,hObj.EdgeAlpha];%#ok<MCSUP>
            end
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,color);%#ok<MCSUP>
        end

        function set.EdgeAlpha(hObj,alpha)
            hObj.EdgeAlpha=alpha;
            color=hObj.EdgeColor;%#ok<MCSUP>
            if~ischar(color)
                color=[color,alpha];
            end
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,color);%#ok<MCSUP>
        end

        function set.LineWidth(hObj,width)
            hObj.LineWidth=width;
            hObj.Edge.LineWidth=width;%#ok<MCSUP>
        end

        function set.AlignVertexCenters(hObj,avc)
            hObj.AlignVertexCenters=avc;
            hObj.Edge.AlignVertexCenters=avc;%#ok<MCSUP>
        end
    end

    methods(Hidden)
        function doUpdate(hObj,updateState)

            hEdge=hObj.Edge;
            hBackground=hObj.Background;


            if any(~isfinite(hObj.Position))||~hObj.Visible
                hObj.Container.Visible='off';
                hEdge.Visible='off';
                hBackground.Visible='off';
                hBackground.PickableParts='none';
                return
            end


            hPointsIter=matlab.graphics.axis.dataspace.IndexPointsIterator;


            [vertexData,stripData]=getIconVertexData(hObj);


            hPointsIter.Vertices=vertexData';
            hEdge.VertexData=updateState.DataSpace.TransformPoints(...
            updateState.TransformUnderDataSpace,hPointsIter);
            hEdge.StripData=uint32(stripData);


            position=hObj.Position;
            hitArea=hObj.HitArea;
            l=position(1)-hitArea(1)/2;
            r=position(1)+hitArea(1)/2;
            b=position(2)-hitArea(2)/2;
            t=position(2)+hitArea(2)/2;
            vertexData=[l,l,r,r;b,t,b,t];


            hPointsIter.Vertices=vertexData';
            hBackground.VertexData=updateState.DataSpace.TransformPoints(...
            updateState.TransformUnderDataSpace,hPointsIter);
            hBackground.StripData=uint32([1,5]);


            visible=hObj.Visible;
            hObj.Container.Visible=visible;
            hEdge.Visible=visible;
            hBackground.Visible=visible;
            hBackground.PickableParts='all';
        end

        function hObj=saveobj(hObj)%#ok<MANU>

            error(message('MATLAB:Chart:SavingDisabled',...
            'matlab.graphics.chart.internal.heatmap.SortAffordance'));
        end
    end

    methods(Access=?ChartUnitTestFriend)
        function setDefaultPropertiesOnPrimitives(hObj)



            hgfilter('RGBAColorToGeometryPrimitive',hObj.Background,hObj.BackgroundColor);


            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,[hObj.EdgeColor,hObj.EdgeAlpha]);
            hObj.Edge.LineWidth=hObj.LineWidth;


            hObj.Container.Anchor=[hObj.Position,0];
        end

        function[vertexData,stripData]=getIconVertexData(hObj)


            switch hObj.Style
            case 'caret'
                [vertexData,stripData]=getCaretIconVertexData(hObj);
            case 'lines'
                [vertexData,stripData]=getLinesIconVertexData(hObj);
            end


            if strcmp(hObj.Axis,'x')
                vertexData=vertexData([2,1],:);
                vertexData(2,:)=-vertexData(2,:);
            end
        end

        function[vertexData,stripData]=getCaretIconVertexData(hObj)



            sz=hObj.Size;
            w=sz/2;

            switch hObj.State
            case 'unsorted'

                vertexData=[-w/2,w/2,-w/2;w,0,-w];
                stripData=[1,4];
            case 'ascending'

                vertexData=[w/2,-w/2,w/2;w,0,-w];
                stripData=[1,4];
            case 'descending'

                vertexData=[-w,w,-w,w;w,-w,-w,w];
                stripData=[1,3,5];
            end
        end

        function[vertexData,stripData]=getLinesIconVertexData(hObj)


            sz=hObj.Size;
            w=sz/2;
            h=linspace(0,w,3);
            p=[-w,0,w]*5/6;

            switch hObj.State
            case 'unsorted'
                h=h([2,1,3]);
            case 'ascending'
                h=h([1,2,3]);
            case 'descending'
                h=h([3,2,1]);
            end

            vertexData=[p([1,1,2,2,3,3]);-w,h(1),-w,h(2),-w,h(3);0,0,0,0,0,0];
            stripData=[1,3,5,7];
        end

        function attachCallbacks(hObj)

            hObj.HitListener=event.listener(hObj,'Hit',@(~,e)hObj.hitEvent(e));


            linger=hObj.Linger;
            linger.LingerTime=1;
            hObj.LingerEnter=event.listener(linger,'EnterObject',@(~,~)hObj.enter);
            hObj.LingerExit=event.listener(linger,'ExitObject',@(~,~)hObj.exit);
            hObj.LingerLinger=event.listener(linger,'LingerOverObject',@(~,~)hObj.linger);
            linger.enable();
        end

        function hitEvent(hObj,eventData)
            if eventData.Button==1

                position=hObj.Position;


                hFigure=ancestor(hObj,'figure');
                hObj.ClickListener=event.listener(hFigure,'WindowMouseRelease',@(~,e)hObj.buttonUp(e,position));
            end
        end

        function buttonUp(hObj,eventData,position)

            hObj.ClickListener=event.listener.empty;



            if eventData.HitObject==hObj&&isequal(hObj.Position,position)
                hObj.click();
            end
        end

        function click(hObj)



            hObj.hideToolTip();


            oldState=hObj.State;
            switch oldState
            case 'unsorted'
                newState='ascending';
            case 'ascending'
                newState='descending';
            case 'descending'
                newState='unsorted';
            end


            e=matlab.graphics.chart.internal.heatmap.SortEventData();
            e.Axis=hObj.Axis;
            e.OldState=oldState;
            e.NewState=newState;
            notify(hObj,'Click',e);
        end

        function enter(hObj)

            hObj.highlight(true);
        end

        function exit(hObj)

            hObj.hideToolTip();
            hObj.highlight(false);
        end

        function linger(hObj)

            hObj.showToolTip();
        end

        function highlight(hObj,on)



            backgroundColor=hObj.HighlightBackgroundColor;
            if on&&~ischar(backgroundColor)

                backgroundAlpha=hObj.HighlightBackgroundAlpha;
            else
                backgroundColor=hObj.BackgroundColor;
                backgroundAlpha=hObj.BackgroundAlpha;
            end


            edgeColor=hObj.HighlightEdgeColor;
            if on&&~ischar(edgeColor)

                edgeAlpha=hObj.HighlightEdgeAlpha;
            else
                edgeColor=hObj.EdgeColor;
                edgeAlpha=hObj.EdgeAlpha;
            end


            if~ischar(backgroundColor)
                backgroundColor=[backgroundColor,backgroundAlpha];
            end
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Background,backgroundColor);


            if~ischar(edgeColor)
                edgeColor=[edgeColor,edgeAlpha];
            end
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,edgeColor);
        end

        function showToolTip(hObj)

            str=hObj.TooltipString;
            if str==""
                switch hObj.Axis
                case 'x'
                    rowOrColumn='Column';
                case 'y'
                    rowOrColumn='Row';
                end
                switch hObj.State
                case 'unsorted'
                    direction='Ascending';
                case 'ascending'
                    direction='Descending';
                case 'descending'
                    direction='Undo';
                end
                msgID=sprintf('MATLAB:Chart:TooltipSort%s%s',rowOrColumn,direction);
                str=getString(message(msgID));
            end


            position=hObj.Position;
            hitArea=hObj.HitArea;

            pos=[position(1)+hitArea(1)/2,position(2)-hitArea(2)/2];


            toolTip=matlab.graphics.primitive.Text;
            toolTip.String=str;
            toolTip.Position=[pos,0];
            toolTip.Color='black';
            toolTip.EdgeColor='black';
            toolTip.BackgroundColor=[255,255,225]/255;
            toolTip.LineWidth=0.5;
            toolTip.VerticalAlignment='bottom';
            toolTip.HorizontalAlignment='left';
            toolTip.Internal=true;
            toolTip.PickableParts='none';
            toolTip.HitTest='off';
            toolTip.Clipping='off';
            toolTip.Margin=2;
            toolTip.FontSmoothing='on';
            toolTip.FontName=get(groot,'FactoryTextFontName');
            toolTip.FontSize=get(groot,'FactoryTextFontSize');
            toolTip.Layer='front';
            hObj.addNode(toolTip);
            hObj.ToolTip=toolTip;
        end

        function hideToolTip(hObj)

            toolTip=hObj.ToolTip;
            if isscalar(toolTip)&&isvalid(toolTip)
                delete(hObj.ToolTip)
            end
            hObj.ToolTip=matlab.graphics.primitive.Text.empty();
        end
    end
end
