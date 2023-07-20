classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)Highlight<...
    matlab.graphics.shape.internal.TipLocator





    properties(AffectsObject)

        Position=[0,0,0]


        Size=1


        Marker='none'


        FaceColor=[0.98,0.98,0.98]


        EdgeColor='black'
    end


    properties(AffectsObject)

        Style(1,:)char{mustBeMember(Style,{'cell','partial','full'})}='partial'


        OutlineLabels(1,:)char{mustBeMember(OutlineLabels,{'off','fade','on'})}='on'


        OverlayLabels(1,1)logical=true


        XLabel(1,1)string=""


        YLabel(1,1)string=""


        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=1.5


        IconSize(1,1)double=10


        EdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1


        DisplaySortIcons(1,1)logical=true
    end

    properties

        FontColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0.15,0.15,0.15]


        FaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=0.9


        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
    end

    properties(Transient,NonCopyable,Hidden,SetAccess=?ChartUnitTestFriend)

        XSortIcon matlab.graphics.chart.internal.heatmap.SortAffordance


        YSortIcon matlab.graphics.chart.internal.heatmap.SortAffordance
    end

    properties(Transient,NonCopyable,Hidden,SetAccess=?ChartUnitTestFriend)
        DragHandles matlab.graphics.primitive.world.Group
    end

    properties(Transient,NonCopyable,Hidden,Access=?ChartUnitTestFriend)
        Face matlab.graphics.primitive.world.TriangleStrip
        Edge matlab.graphics.primitive.world.LineLoop
        XLabelHandle matlab.graphics.primitive.Text
        YLabelHandle matlab.graphics.primitive.Text
    end

    properties(Transient,NonCopyable,Access=?ChartUnitTestFriend)
        XRulerStringsCache=struct.empty;
        YRulerStringsCache=struct.empty;
    end

    methods
        function hObj=Highlight(varargin)
            hObj.Description='Heatmap Highlight';


            hFace=matlab.graphics.primitive.world.TriangleStrip;
            hFace.Description='Highlight Face';
            hFace.Internal=true;
            hFace.PickableParts='all';
            hFace.HitTest='off';
            hFace.Clipping='off';
            hObj.Face=hFace;
            hObj.addNode(hFace);



            hDragHandles=matlab.graphics.primitive.world.Group('Internal',true);
            hObj.DragHandles=hDragHandles;
            hObj.addNode(hDragHandles);


            hIcon=matlab.graphics.chart.internal.heatmap.SortAffordance('Internal',true);
            hIcon.Description='Heatmap x Sort Icon';
            hIcon.Axis='x';
            hObj.XSortIcon=hIcon;
            hObj.addNode(hIcon);


            hIcon=matlab.graphics.chart.internal.heatmap.SortAffordance('Internal',true);
            hIcon.Description='Heatmap y Sort Icon';
            hIcon.Axis='y';
            hObj.YSortIcon=hIcon;
            hObj.addNode(hIcon);


            hEdge=matlab.graphics.primitive.world.LineLoop;
            hEdge.Description='Highlight Edge';
            hEdge.Internal=true;
            hEdge.PickableParts='none';
            hEdge.HitTest='off';
            hEdge.Clipping='off';
            hEdge.AlignVertexCenters='on';
            hEdge.LineJoin='miter';
            hObj.Edge=hEdge;
            hObj.addNode(hEdge);


            hLabel=matlab.graphics.primitive.Text;
            hLabel.Description='Heatmap x-Tick Label';
            hLabel.Internal=true;
            hLabel.PickableParts='none';
            hLabel.HitTest='off';
            hLabel.Clipping='off';
            hLabel.Margin=0.1;
            hObj.XLabelHandle=hLabel;
            hObj.addNode(hLabel);


            hLabel=matlab.graphics.primitive.Text;
            hLabel.Description='Heatmap y-Tick Label';
            hLabel.Internal=true;
            hLabel.PickableParts='none';
            hLabel.HitTest='off';
            hLabel.Clipping='off';
            hLabel.Margin=0.1;
            hObj.YLabelHandle=hLabel;
            hObj.addNode(hLabel);


            hObj.setDefaultPropertiesOnPrimitives();


            hObj.addDependencyConsumed({'ref_frame','view',...
            'dataspace','xyzdatalimits','resolution'});


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Hidden)
        function doUpdate(hObj,updateState)
            visible=strcmp(hObj.Visible,'on');

            if visible

                [x,y,xstyle,ystyle,xr,yr]=getPositionAndStyle(hObj);
                visible=~strcmp(xstyle,'none')||~strcmp(ystyle,'none');
            end


            hXLabel=hObj.XLabelHandle;
            hYLabel=hObj.YLabelHandle;
            hEdge=hObj.Edge;
            hFace=hObj.Face;
            hXIcon=hObj.XSortIcon;
            hYIcon=hObj.YSortIcon;

            if~visible

                hXLabel.Visible='off';
                hYLabel.Visible='off';
                hEdge.Visible='off';
                hFace.Visible='off';
                hFace.PickableParts='none';
                hXIcon.Visible='off';
                hYIcon.Visible='off';
                hXIcon.HitTest='off';
                hYIcon.HitTest='off';
                return
            end


            sz=hObj.Size;
            xl=xr.NumericLimits;
            yl=yr.NumericLimits;
            if hObj.OverlayLabels

                pos=hObj.Position;
                hObj.updateLabelPosition(updateState,hXLabel,xr,'x',pos(1));
                hObj.updateLabelPosition(updateState,hYLabel,yr,'y',pos(2));
            else
                hXLabel.Visible='off';
                hYLabel.Visible='off';
            end


            tickstyles={'fullup','fulldown','up','down'};
            hasTicks=ismember(xstyle,tickstyles)||ismember(ystyle,tickstyles);
            outlineLabels=hObj.OutlineLabels;
            solidOutline=strcmp(outlineLabels,'on');
            if hasTicks&&ismember(outlineLabels,{'on','fade'})


                lineWidth=hObj.LineWidth;



                iconSize=hObj.IconSize;
                spaceForIcon=iconSize*solidOutline;




                [xl,xedges,xicon,xhitarea,yheight,hObj.YRulerStringsCache]=...
                hObj.addRulerToLimits(updateState,yr,...
                hObj.YRulerStringsCache,xl,1,lineWidth,spaceForIcon);
                [yl,yedges,yicon,yhitarea,xwidth,hObj.XRulerStringsCache]=...
                hObj.addRulerToLimits(updateState,xr,...
                hObj.XRulerStringsCache,yl,2,lineWidth,spaceForIcon);



                if xwidth<iconSize
                    xstyle='none';
                end
                if yheight<iconSize
                    ystyle='none';
                end
            end

            if hasTicks&&solidOutline

                if hObj.DisplaySortIcons

                    hXIcon.Position=[x,yicon];
                    hXIcon.HitArea=[sz,yhitarea];


                    hYIcon.Position=[xicon,y];
                    hYIcon.HitArea=[xhitarea,sz];


                    hXIcon.Visible='on';
                    hXIcon.HitTest='on';
                    hYIcon.Visible='on';
                    hYIcon.HitTest='on';
                else

                    hXIcon.Visible='off';
                    hXIcon.HitTest='off';
                    hYIcon.Visible='off';
                    hYIcon.HitTest='off';
                end


                [faceVertexData,faceStripData]=hObj.getFaceVertexData(x,y,xedges,yedges,sz);


                iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                iter.Vertices=faceVertexData';
                faceVertexData=TransformPoints(updateState.DataSpace,...
                updateState.TransformUnderDataSpace,iter);


                hFace.VertexData=single(faceVertexData);
                hFace.StripData=uint32(faceStripData);
                hFace.Visible='on';
                hFace.PickableParts='all';
            else
                hFace.Visible='off';
                hFace.PickableParts='none';
                hXIcon.Visible='off';
                hYIcon.Visible='off';
                hXIcon.HitTest='off';
                hYIcon.HitTest='off';
            end


            [edgeVertexData,edgeStripData,labelCorners]=hObj.getEdgeVertexData(x,y,xl,yl,xstyle,ystyle,sz);


            iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
            iter.Vertices=edgeVertexData';
            edgeVertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,iter);


            hEdge.VertexData=single(edgeVertexData);
            hEdge.StripData=uint32(edgeStripData);
            hEdge.Visible='on';


            edgeColor=hObj.EdgeColor;
            if ischar(edgeColor)
                hEdge.ColorData=zeros(4,0,'uint8');
                hEdge.ColorBinding='none';
            else
                edgeAlpha=hObj.EdgeAlpha;
                colorData=uint8([edgeColor';edgeAlpha]*255);
                if any(labelCorners)&&strcmp(hObj.OutlineLabels,'fade')
                    colorData=colorData(:,ones(size(labelCorners)));
                    colorData(4,labelCorners)=0;
                    hEdge.ColorData=colorData;
                    hEdge.ColorType='truecoloralpha';
                    hEdge.ColorBinding='interpolated';
                elseif edgeAlpha==1
                    hEdge.ColorData=colorData;
                    hEdge.ColorType='truecolor';
                    hEdge.ColorBinding='object';
                else
                    hEdge.ColorData=colorData;
                    hEdge.ColorType='truecoloralpha';
                    hEdge.ColorBinding='object';
                end
            end
        end
    end

    methods(Access=?ChartUnitTestFriend)
        function setDefaultPropertiesOnPrimitives(hObj)



            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,[hObj.EdgeColor,hObj.EdgeAlpha]);
            hObj.Edge.LineWidth=hObj.LineWidth;


            hgfilter('RGBAColorToGeometryPrimitive',hObj.Face,[hObj.FaceColor,hObj.FaceAlpha]);


            hObj.XLabelHandle.String=hObj.XLabel;
            hObj.XLabelHandle.Color=hObj.FontColor;
            hObj.XLabelHandle.FontWeight=hObj.FontWeight;
            hObj.XLabelHandle.BackgroundColor=hObj.FaceColor;


            hObj.YLabelHandle.String=hObj.YLabel;
            hObj.YLabelHandle.Color=hObj.FontColor;
            hObj.YLabelHandle.FontWeight=hObj.FontWeight;
            hObj.YLabelHandle.BackgroundColor=hObj.FaceColor;
        end

        function[x,y,xstyle,ystyle,xr,yr]=getPositionAndStyle(hObj)

            style=hObj.Style;


            [xr,yr]=matlab.graphics.internal.getRulersForChild(hObj);


            position=hObj.Position;
            x=position(1);
            y=position(2);


            xl=xr.NumericLimits;
            yl=yr.NumericLimits;
            if x>xl(2)||x<xl(1)
                x=NaN;
            end
            if y>yl(2)||y<yl(1)
                y=NaN;
            end


            xstyle=hObj.getStyleOneRuler(style,x,y,xr.FirstCrossoverValue);


            ystyle=hObj.getStyleOneRuler(style,y,x,yr.FirstCrossoverValue);
        end
    end

    methods(Static,Access=?ChartUnitTestFriend)
        function xstyle=getStyleOneRuler(style,x,y,firstCrossoverValue)

            if isnan(x)

                xstyle='none';
            elseif strcmp(style,'cell')

                if isnan(y)
                    xstyle='none';
                else
                    xstyle='cell';
                end
            else

                if strcmp(style,'full')||isnan(y)
                    xstyle='full';
                else
                    xstyle='';
                end



                if firstCrossoverValue<=0
                    xstyle=[xstyle,'down'];
                else
                    xstyle=[xstyle,'up'];
                end
            end
        end

        function updateLabelPosition(updateState,hLabel,ruler,axis,center)
            import matlab.graphics.chart.internal.heatmap.Highlight


            [pos,tickChild]=Highlight.getTickPosition(updateState,ruler,axis,center);


            hLabel.Position=pos;

            if~isempty(tickChild)
                hLabel.FontName=tickChild.Font.Name;
                hLabel.FontSize=tickChild.Font.Size;
                hLabel.HorizontalAlignment=tickChild.HorizontalAlignment;
                hLabel.VerticalAlignment=tickChild.VerticalAlignment;
                hLabel.Rotation=tickChild.Rotation;
                hLabel.Interpreter=tickChild.Interpreter;
                hLabel.Visible='on';
            end
        end

        function[limits,edges,icon,hitArea,width,cache]=addRulerToLimits(updateState,ruler,cache,limits,ind,lineWidth,iconSize)





            import matlab.graphics.chart.internal.heatmap.Highlight


            [corners,sz,side,margin,cache]=Highlight.getRulerBoundingBox(updateState,ruler,cache);


            width=sz(mod(ind,2)+1)/diff(ruler.NumericLimits);


            fadeSize=ruler.FontSize_I;
            [extent,fade,icon,hitArea]=Highlight.addPaddingToRulerBounds(updateState,corners,lineWidth,iconSize,margin,side,fadeSize);


            edges=[extent(ind),extent(ind+2)];
            icon=icon(ind);
            fade=fade(ind);
            hitArea=hitArea(ind+2)-hitArea(ind);


            if edges(1)<limits(1)
                edges(2)=limits(1);
                limits=[edges(1),fade,limits];
            elseif edges(2)>limits(2)
                edges(1)=limits(2);
                limits=[limits,fade,edges(2)];
            end
        end

        function[corners,sz,side,margin,cache]=getRulerBoundingBox(updateState,ruler,cache)



            import matlab.graphics.chart.internal.heatmap.Highlight


            tickChild=ruler.TickLabelChild;
            axleChild=ruler.Axle;


            vertexData=[axleChild.VertexData(:,[1,2]),tickChild.VertexData];
            margin=tickChild.Margin;


            aboveMatrix=updateState.TransformAboveDataSpace;
            belowMatrix=updateState.TransformUnderDataSpace;
            vertexDataPixels=matlab.graphics.internal.transformWorldToViewer(...
            updateState.Camera,aboveMatrix,updateState.DataSpace,...
            belowMatrix,vertexData);


            vertexDataPoints=vertexDataPixels./updateState.PixelsPerPoint;


            rotationMatrix=makehgtform('zrotate',deg2rad(tickChild.Rotation));
            numLabels=numel(tickChild.String);
            if Highlight.checkCacheClean(cache,tickChild,vertexDataPoints,rotationMatrix)
                corners=cache.Corners;
            else
                corners=zeros(2,4*numLabels);
                for s=1:numLabels
                    corners(:,4*(s-1)+(1:4))=Highlight.getStringExtent(...
                    updateState,tickChild,tickChild.String{s},...
                    vertexDataPoints(:,s+2),rotationMatrix);
                end
                cache=Highlight.updateCache(corners,tickChild,vertexDataPoints,rotationMatrix);
            end


            if numLabels==0||vertexDataPoints(1,3)<vertexDataPoints(1,1)||...
                vertexDataPoints(2,3)<vertexDataPoints(2,1)
                side=-1;
            else
                side=1;
            end


            corners=[corners,vertexDataPoints(:,[1,2])];


            left=min(corners(1,:));
            right=max(corners(1,:));
            bottom=min(corners(2,:));
            top=max(corners(2,:));
            corners=[left,left,right,right;bottom,top,bottom,top];
            sz=[right-left,top-bottom];
        end

        function tf=checkCacheClean(cache,tickChild,vertexDataPoints,rotationMatrix)

            if isempty(cache)
                tf=false;
            else
                tf=isequal(tickChild.Font,cache.Font)&&...
                isequal(tickChild.Interpreter,cache.Interpreter)&&...
                isequal(tickChild.VerticalAlignment,cache.VerticalAlignment)&&...
                isequal(tickChild.HorizontalAlignment,cache.HorizontalAlignment)&&...
                isequal(tickChild.Margin,cache.Margin)&&...
                isequal(vertexDataPoints,cache.VertexData)&&...
                isequal(rotationMatrix,cache.RotationMatrix);
            end
        end

        function cache=updateCache(corners,tickChild,vertexDataPoints,rotationMatrix)
            cache.Font=tickChild.Font;
            cache.Interpreter=tickChild.Interpreter;
            cache.VerticalAlignment=tickChild.VerticalAlignment;
            cache.HorizontalAlignment=tickChild.HorizontalAlignment;
            cache.Margin=tickChild.Margin;
            cache.VertexData=vertexDataPoints;
            cache.RotationMatrix=rotationMatrix;
            cache.Corners=corners;
        end

        function corners=getStringExtent(updateState,hText,str,pos,rotationMatrix)



            try

                extent=updateState.getStringBounds(...
                str,hText.Font,hText.Interpreter,'on');
            catch err


                if strcmp(err.identifier,'MATLAB:hg:textutils:StringSyntaxError')
                    extent=updateState.getStringBounds(...
                    str,hText.Font,'none','on');
                end
            end



            switch hText.VerticalAlignment
            case{'baseline','bottom'}
                top=extent(2);
                bottom=0;
            case{'top','cap'}
                top=0;
                bottom=-extent(2);
            case 'middle'
                top=extent(2)/2;
                bottom=-top;
            end

            switch hText.HorizontalAlignment
            case 'left'
                right=extent(1);
                left=0;
            case 'right'
                right=0;
                left=-extent(1);
            case 'center'
                right=extent(1)/2;
                left=-right;
            end
            corners=[left,left,right,right;bottom,top,bottom,top;0,0,0,0;0,0,0,0];


            margin=hText.Margin;
            corners=corners+margin*[-1,-1,1,1;-1,1,-1,1;0,0,0,0;0,0,0,0];


            corners=rotationMatrix*corners;


            corners=corners([1,2],:)+pos;
        end

        function[extent,fade,iconCenter,hitArea]=addPaddingToRulerBounds(updateState,corners,lineWidth,iconSize,margin,side,fadeSize)






            padding=lineWidth+iconSize-margin;
            iconCenter=lineWidth/2+iconSize/2;
            if side<0

                fade=corners(:,4)-fadeSize;


                padding=padding.*[-1,-1,0,0;-1,0,-1,0];
                corners=corners+padding;






                minLeftBottom=min(corners(:,4)-lineWidth-2*iconSize,1);
                corners=max(corners,minLeftBottom);


                iconCenter=corners(:,1)+iconCenter;
                hitArea=iconCenter+[-1,1]*(iconSize/2)-[1,0]*lineWidth/2;
            else

                fade=corners(:,1)+fadeSize;


                padding=padding.*[0,0,1,1;0,1,0,1];
                corners=corners+padding;






                vp=updateState.ViewerPosition(3:4)./updateState.PixelsPerPoint;
                maxRightTop=max(corners(:,1)+lineWidth+2*iconSize,vp(:));
                corners=min(corners,maxRightTop);


                iconCenter=corners(:,4)-iconCenter;
                hitArea=iconCenter+[-1,1]*(iconSize/2)+[0,1]*lineWidth/2;
            end
            corners=[corners,iconCenter,hitArea,fade];


            cornersPixels=corners.*updateState.PixelsPerPoint;


            aboveMatrix=updateState.TransformAboveDataSpace;
            belowMatrix=updateState.TransformUnderDataSpace;
            cornersWorld=matlab.graphics.internal.transformViewerToWorld(...
            updateState.Camera,aboveMatrix,updateState.DataSpace,...
            belowMatrix,cornersPixels);


            cornersData=matlab.graphics.internal.transformWorldToData(...
            updateState.DataSpace,belowMatrix,cornersWorld);


            left=min(cornersData(1,1:4));
            right=max(cornersData(1,1:4));
            bottom=min(cornersData(2,1:4));
            top=max(cornersData(2,1:4));


            extent=[left,bottom,right,top];


            iconCenter=cornersData(:,5);


            left=min(cornersData(1,6:7));
            right=max(cornersData(1,6:7));
            bottom=min(cornersData(2,6:7));
            top=max(cornersData(2,6:7));
            hitArea=[left,bottom,right,top];


            fade=cornersData(:,8);
        end

        function[pos,tickChild]=getTickPosition(updateState,ruler,axis,center)

            tickChild=ruler.TickLabelChild;


            if isempty(tickChild)||isempty(tickChild.VertexData)
                pos=[NaN,NaN,0];
                return
            end

            tickVertexData=tickChild.VertexData(:,1);
            axleVertexData=ruler.Axle.VertexData(:,1);


            iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
            iter.Vertices=[tickVertexData,axleVertexData]';
            belowMatrix=updateState.TransformUnderDataSpace;
            vertexData=updateState.DataSpace.UntransformPoints(belowMatrix,iter);


            lim=ruler.NumericLimits;
            if isnan(center)||center<lim(1)||center>lim(2)
                pos=[NaN,NaN,0];
            elseif strcmpi(axis,'x')

                tickPos=vertexData(2,1);
                pos=[center,tickPos,0];
            else

                tickPos=vertexData(1,1);
                pos=[tickPos,center,0];
            end
        end

        function[vertexData,stripData,labelCorners]=getEdgeVertexData(x,y,xl,yl,xstyle,ystyle,sz)



            w=sz/2;
            h=sz/2;


            if numel(yl)==4

















                xLabelCorners=[true(1,2),false(1,4),true(1,2)];
                switch xstyle
                case 'none'
                    xVertexData=zeros(3,0);
                    xLabelCorners=false(1,0);
                case 'cell'
                    xVertexData=[...
                    x+[-w,-w,w,w];
                    y+[-h,h,h,-h];
                    0,0,0,0];
                    xLabelCorners=false(1,4);
                case 'fulldown'
                    xVertexData=[...
                    x+[-w,-w,-w,-w,w,w,w,w];
                    yl([1,2,3,4,4,3,2,1]);
                    0,0,0,0,0,0,0,0];
                case 'fullup'
                    xVertexData=[...
                    x+[w,w,w,w,-w,-w,-w,-w];
                    yl([4,3,2,1,1,2,3,4]);
                    0,0,0,0,0,0,0,0];
                case 'down'
                    xVertexData=[...
                    x+[-w,-w,-w,-w,w,w,w,w];
                    yl(1),yl(2),yl(3),y+h,y+h,yl(3),yl(2),yl(1);
                    0,0,0,0,0,0,0,0];
                case 'up'
                    xVertexData=[...
                    x+[w,w,w,w,-w,-w,-w,-w];
                    yl(4),yl(3),yl(2),y-h,y-h,yl(2),yl(3),yl(4);
                    0,0,0,0,0,0,0,0];
                end
            else













                xLabelCorners=false(1,4);
                switch xstyle
                case 'none'
                    xVertexData=zeros(3,0);
                    xLabelCorners=false(1,0);
                case 'cell'
                    xVertexData=[...
                    x+[-w,-w,w,w];
                    y+[-h,h,h,-h];
                    0,0,0,0];
                case{'fulldown','fullup'}
                    xVertexData=[...
                    x+[-w,-w,w,w];
                    yl([1,2,2,1]);
                    0,0,0,0];
                case 'down'
                    xVertexData=[...
                    x+[-w,-w,w,w];
                    yl(1),y+h,y+h,yl(1);
                    0,0,0,0];
                case 'up'
                    xVertexData=[...
                    x+[-w,-w,w,w];
                    y-h,yl(2),yl(2),y-h;
                    0,0,0,0];
                end
            end


            if numel(xl)==4












                yLabelCorners=[true(1,2),false(1,4),true(1,2)];
                switch ystyle
                case{'none','cell'}

                    yVertexData=zeros(3,0);
                    yLabelCorners=false(1,0);
                case 'fulldown'
                    yVertexData=[...
                    xl([1,2,3,4,4,3,2,1]);
                    y+[-h,-h,-h,-h,h,h,h,h];
                    0,0,0,0,0,0,0,0];
                case 'fullup'
                    yVertexData=[...
                    xl([4,3,2,1,1,2,3,4]);
                    y+[h,h,h,h,-h,-h,-h,-h];
                    0,0,0,0,0,0,0,0];
                case 'down'
                    yVertexData=[...
                    xl(1),xl(2),xl(3),x+w,x+w,xl(3),xl(2),xl(1);
                    y+[-h,-h,-h,-h,h,h,h,h];
                    0,0,0,0,0,0,0,0];
                case 'up'
                    yVertexData=[...
                    xl(4),xl(3),xl(2),x-w,x-w,xl(2),xl(3),xl(4);
                    y+[h,h,h,h,-h,-h,-h,-h];
                    0,0,0,0,0,0,0,0];
                end
            else




                yLabelCorners=false(1,4);
                switch ystyle
                case{'none','cell'}

                    yVertexData=zeros(3,0);
                    yLabelCorners=false(1,0);
                case{'fulldown','fullup'}
                    yVertexData=[...
                    xl([1,1,2,2]);
                    y+[-h,h,h,-h];
                    0,0,0,0];
                case 'down'
                    yVertexData=[...
                    xl(1),xl(1),x+w,x+w;
                    y+[-h,h,h,-h];
                    0,0,0,0];
                case 'up'
                    yVertexData=[...
                    x-w,x-w,xl(2),xl(2);
                    y+[-h,h,h,-h];
                    0,0,0,0];
                end
            end


            vertexData=[xVertexData,yVertexData];
            labelCorners=[xLabelCorners,yLabelCorners];
            nx=size(xVertexData,2);
            ny=size(yVertexData,2);
            if nx==0&&ny==0
                stripData=1;
            elseif nx==0
                stripData=[1,ny+1];
            elseif ny==0
                stripData=[1,nx+1];
            else
                stripData=[1,nx+1,nx+ny+1];
            end
        end

        function[vertexData,stripData]=getFaceVertexData(x,y,xedges,yedges,sz)



            w=sz/2;
            h=sz/2;







            if~any(isnan(yedges))
                xVertexData=[...
                x+[-w,-w,w,w];
                yedges([1,2,1,2]);
                0,0,0,0];
            else
                xVertexData=zeros(3,0);
            end








            if~any(isnan(xedges))
                yVertexData=[...
                xedges([1,1,2,2]);
                y+[-h,h,-h,h];
                0,0,0,0];
            else
                yVertexData=zeros(3,0);
            end


            vertexData=[xVertexData,yVertexData];
            stripData=1:4:size(vertexData,2)+1;
        end
    end

    methods
        function set.LineWidth(hObj,width)
            hObj.LineWidth=width;
            hObj.Edge.LineWidth=width;%#ok<MCSUP>
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

        function set.FaceColor(hObj,color)
            hObj.FaceColor=color;
            hObj.XLabelHandle.BackgroundColor=color;%#ok<MCSUP>
            hObj.YLabelHandle.BackgroundColor=color;%#ok<MCSUP>
            if~ischar(color)
                color=[color,hObj.FaceAlpha];%#ok<MCSUP>
            end
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Face,color);%#ok<MCSUP>
        end

        function set.FaceAlpha(hObj,alpha)
            hObj.FaceAlpha=alpha;
            color=hObj.FaceColor;%#ok<MCSUP>
            if~ischar(color)
                color=[color,alpha];
            end
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Face,color);%#ok<MCSUP>
        end

        function set.XLabel(hObj,label)
            hObj.XLabel=label;
            hObj.XLabelHandle.String=label;%#ok<MCSUP>
        end

        function set.YLabel(hObj,label)
            hObj.YLabel=label;
            hObj.YLabelHandle.String=label;%#ok<MCSUP>
        end

        function set.FontColor(hObj,color)
            hObj.FontColor=color;
            hObj.XLabelHandle.Color=color;%#ok<MCSUP>
            hObj.YLabelHandle.Color=color;%#ok<MCSUP>
        end

        function set.FontWeight(hObj,weight)
            hObj.FontWeight=weight;
            hObj.XLabelHandle.FontWeight=weight;%#ok<MCSUP>
            hObj.YLabelHandle.FontWeight=weight;%#ok<MCSUP>
        end
    end

    methods(Hidden)
        function hObj=saveobj(hObj)%#ok<MANU>

            error(message('MATLAB:Chart:SavingDisabled',...
            'matlab.graphics.chart.internal.heatmap.Highlight'));
        end
    end
end
