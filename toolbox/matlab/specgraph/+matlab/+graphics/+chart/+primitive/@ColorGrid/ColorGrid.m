classdef(Abstract,ConstructOnLoad,UseClassDefaultsOnLoad)...
    ColorGrid<...
    matlab.graphics.primitive.Data&...
    matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.mixin.Pickable&...
    matlab.graphics.chart.interaction.DataAnnotatable



    properties(AffectsDataLimits)
        Position(1,2)double=[1,1];
        CellSize(1,2)double{mustBePositive}=[1,1];
        ColorData matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=[]
    end

    properties(Transient,NonCopyable,Hidden)
        Behavior struct=struct()
    end

    properties(Transient,NonCopyable,SetAccess=?ChartUnitTestFriend)
        ScaledColorData double=[]
    end

    properties(Dependent,SetAccess=private)
ActualFontSize
    end

    properties(Transient,NonCopyable,Access={?matlab.graphics.chart.primitive.ColorGrid,?ChartUnitTestFriend})
        ScaledColorDataDirty logical=true
        CellLabelsDirty logical=true
    end

    properties(AbortSet)
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName=get(groot,'FactoryTextFontName')
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=get(groot,'FactoryTextFontSize')
        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle=get(groot,'FactoryTextFontAngle')
        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight=get(groot,'FactoryTextFontWeight')
        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='none'
        MinimumFontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6
        CellMargin matlab.internal.datatype.matlab.graphics.datatype.Positive=3

        GridVisible matlab.internal.datatype.matlab.graphics.datatype.on_off='on'
        GridLineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'

        LineColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0.15,0.15,0.15]
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5
    end

    properties(AffectsObject,AbortSet)
        CellLabelFormat matlab.internal.datatype.matlab.graphics.datatype.PrintfFormat='%0.4g'
        CellLabelColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'

        MissingDataLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString='NaN'
        MissingDataColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor=[0.94,0.94,0.94]
    end

    properties(Transient,AffectsObject,AbortSet,NonCopyable,Hidden,Access=?ChartUnitTestFriend)
        Face matlab.graphics.primitive.world.Quadrilateral
        Grid matlab.graphics.primitive.world.LineStrip
        Edge matlab.graphics.primitive.world.LineLoop
        Labels matlab.graphics.chart.primitive.internal.LabelGrid
    end

    methods
        function hObj=ColorGrid(varargin)
            hObj.Description='Color Grid';


            hFace=matlab.graphics.primitive.world.Quadrilateral;
            hFace.Internal=true;
            hFace.Description_I='Color Grid Face';
            hFace.Clipping_I='on';
            hObj.Face=hFace;


            hGrid=matlab.graphics.primitive.world.LineStrip;
            hGrid.Internal=true;
            hGrid.Description_I='Color Grid Grid';
            hGrid.Clipping_I='on';
            hGrid.AlignVertexCenters='on';
            hObj.Grid=hGrid;


            hEdge=matlab.graphics.primitive.world.LineLoop;
            hEdge.Internal=true;
            hEdge.Description_I='Color Grid Edge';
            hEdge.Clipping_I='on';
            hEdge.AlignVertexCenters='on';
            hObj.Edge=hEdge;


            hLabels=matlab.graphics.chart.primitive.internal.LabelGrid;
            hLabels.Internal=true;
            hLabels.Description_I='Color Grid Labels';
            hObj.Labels=hLabels;


            hObj.setDefaultPropertiesOnPrimitives();


            hObj.addDependencyConsumed({'figurecolormap','colorspace','xyzdatalimits'});


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Hidden)
        function doUpdate(hObj,updateState)

            colorData=hObj.ScaledColorData;
            [ny,nx]=size(colorData);


            hPointsIter=matlab.graphics.axis.dataspace.IndexPointsIterator;


            nx=max(1,nx);
            ny=max(1,ny);


            cx=hObj.Position(1);
            cy=hObj.Position(2);
            sx=hObj.CellSize(1);
            sy=hObj.CellSize(2);






            [x,y]=meshgrid(cx+sx*(-0.5:nx-0.5),cy+sy*(-0.5:ny-0.5));
            z=zeros(size(x));
            vertexData=[x(:),y(:),z(:)];











            nny=ny+1;
            onesquare=[0;1;nny+1;nny];
            onecolumn=onesquare+(1:ny);
            vertexIndices=onecolumn(:)+(0:nny:(nny*(nx-1)));
            hPointsIter.Vertices=vertexData;
            hFace=hObj.Face;
            hFace.VertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hPointsIter);
            hFace.VertexIndices=uint32(vertexIndices(:)');


            cd=hObj.getRGBAColorData(updateState,colorData);


            if isempty(cd)||isempty(cd.Data)

                hFace.ColorBinding='object';
                hFace.ColorData=uint8([240;240;240;255]);
                hFace.ColorType='truecolor';
                trueColorData=zeros(4,0,0,'uint8');
            else


                trueColorData=cd.Data;
                hFace.ColorData=trueColorData;
                hFace.ColorBinding='discrete';
                hFace.ColorType='truecolor';
            end





            vertX=cx+sx*((1:nx-1)-[0.5;0.5]);
            vertY=cy+sy*(([0;ny]-0.5).*ones(1,nx-1));





            horzX=cx+sx*(([0;nx]-0.5).*ones(1,ny-1));
            horzY=cy+sy*((1:ny-1)-[0.5;0.5]);


            vertexData=[...
            [vertX(:),vertY(:),zeros(2*(nx-1),1)];...
            [horzX(:),horzY(:),zeros(2*(ny-1),1)]];


            hPointsIter.Vertices=vertexData;
            hGrid=hObj.Grid;
            hGrid.VertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hPointsIter);
            if strcmp(hObj.GridVisible,'off')||isempty(colorData)||isempty(vertexData)
                hGrid.Visible='off';
            else
                hGrid.Visible='on';
            end





            oexl=min(cx+(nx-0.5)*sx,max(cx-0.5*sx,updateState.DataSpace.XLim));
            oeyl=min(cy+(ny-0.5)*sy,max(cy-0.5*sy,updateState.DataSpace.YLim));




            hPointsIter.Vertices=[oexl([1,2,2,1]);oeyl([1,1,2,2]);0,0,0,0]';
            hEdge=hObj.Edge;
            hEdge.VertexData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,hPointsIter);
            hEdge.StripData=uint32([1,5]);
            hEdge.LineJoin='miter';

            labelColor=hObj.CellLabelColor;
            if~ischar(labelColor)||~strcmp(labelColor,'none')

                colorData=hObj.ColorData;
                [ny,nx]=size(colorData);
                [x,y]=meshgrid(0:nx-1,0:ny-1);
                numLabels=numel(colorData);
                labelVertexData=[single([cx+sx*x(:)';cy+sy*y(:)']);zeros(1,numLabels,'single')];


                if ischar(labelColor)&&strcmp(labelColor,'auto')

                    rgbValues=double(trueColorData(1:3,:)')/255;
                    grayValues=rgbValues*[0.2989;0.5870;0.1140];
                    darkColors=grayValues<=0.5;

                    blackColor=uint8([0;0;0;255]);
                    whiteColor=uint8([255;255;255;255]);
                else

                    darkColors=false(numLabels,1);
                    blackColor=uint8([labelColor(:).*255;255]);
                    whiteColor=blackColor;
                end


                colors=[blackColor,whiteColor];
                colorInd=ones(numLabels,1);
                colorInd(darkColors)=2;


                labelColorData=colors(:,colorInd);


                hLabels=hObj.Labels;
                hLabels.Visible='on';
                hLabels.ColorData=labelColorData;
                hLabels.VertexData=labelVertexData;


                if hObj.CellLabelsDirty
                    strings=getLabelStrings(hObj,colorData);
                    hLabels.Strings=strings;
                    hObj.CellLabelsDirty=false;
                end
            else
                hObj.Labels.Visible='off';
            end
        end

        function extents=getXYZDataExtents(hObj,~,~)




            [ny,nx]=size(hObj.ColorData);
            cx=hObj.Position(1);
            cy=hObj.Position(2);
            sx=hObj.CellSize(1);
            sy=hObj.CellSize(2);

            x=matlab.graphics.chart.primitive.utilities.arraytolimits(cx+([0,max(1,nx)]-0.5)*sx);
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(cy+([0,max(1,ny)]-0.5)*sy);
            extents=[x;y;NaN,NaN,NaN,NaN];
        end

        function extents=getColorDataExtents(hObj)



            colorData=hObj.ScaledColorData(:);


            finiteData=colorData(isfinite(colorData));

            if isempty(finiteData)

                extents=[NaN,NaN];
            else


                mn=min(finiteData);
                mx=max(finiteData);
                extents=[mn,mx];
            end
        end

        function extents=getColorAlphaDataExtents(hObj)



            extents=[getColorDataExtents(hObj);NaN,NaN];
        end

        function hObj=saveobj(hObj)%#ok<MANU>

            error(message('MATLAB:Chart:SavingDisabled',...
            'matlab.graphics.chart.primitive.ColorGrid'));
        end
    end

    methods(Access=protected)
        function newObj=setNamedChild(hObj,oldObj,newObj)

            if isscalar(newObj)&&isvalid(newObj)
                if isscalar(oldObj)&&isvalid(oldObj)


                    hObj.replaceChild(oldObj,newObj);
                else

                    hObj.addNode(newObj);
                end
            elseif isscalar(oldObj)&&isvalid(oldObj)



                oldObj.Parent=matlab.graphics.primitive.world.Group.empty;
            end
        end

        function setDefaultPropertiesOnPrimitives(hObj)



            font=matlab.graphics.general.Font;
            font.Name=hObj.FontName;
            font.Size=hObj.FontSize;
            font.Angle=hObj.FontAngle;
            font.Weight=hObj.FontWeight;
            hObj.Labels.Interpreter=hObj.Interpreter;
            hObj.Labels.Font=font;
            hObj.Labels.MinimumFontSize=hObj.MinimumFontSize;
            hObj.Labels.CellMargin=hObj.CellMargin;


            hObj.Grid.Visible=hObj.GridVisible;
            hgfilter('LineStyleToPrimLineStyle',hObj.Grid,hObj.GridLineStyle);
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Grid,hObj.LineColor);
            hObj.Grid.LineWidth=hObj.LineWidth;


            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,hObj.LineColor);
            hObj.Edge.LineWidth=hObj.LineWidth;
        end

        function colorData=calculateScaledColorData(hObj)

            colorData=double(hObj.ColorData);
        end

        function rgba=getRGBAColorData(hObj,updateState,colorData)

            hColorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
            hColorIter.Colors=colorData(:);
            hColorIter.CDataMapping='scaled';
            rgba=updateState.ColorSpace.TransformColormappedToTrueColor(hColorIter);


            nanColors=isnan(colorData);
            if any(nanColors(:))&&~isempty(rgba)&&~isempty(rgba.Data)
                missingColor=hObj.MissingDataColor;
                missingColor=uint8([missingColor(:).*255;255]);
                rgba.Data(:,nanColors)=repmat(missingColor,1,sum(nanColors(:)));
            end
        end

        function strings=getLabelStrings(hObj,colorData)



            if isempty(colorData)
                strings=cell(0,1);
            else
                fmt=hObj.CellLabelFormat;
                strings=compose(fmt,colorData(:));
            end


            nanColors=isnan(colorData);
            if any(nanColors(:))
                strings(nanColors)={char(hObj.MissingDataLabel)};
            end
        end
    end

    methods
        function set.MissingDataLabel(hObj,lbl)
            hObj.MissingDataLabel=lbl;
            hObj.CellLabelsDirty=true;%#ok<MCSUP>
        end

        function set.CellLabelFormat(hObj,format)
            import matlab.graphics.chart.internal.validateFormatString



            [errID,errMsg]=validateFormatString(format,10);
            if~isempty(errID)
                throwAsCaller(MException(errID,'%s',errMsg));
            end



            format=strrep(format,'\n','');
            format=strrep(format,newline,'');

            hObj.CellLabelFormat=format;
            hObj.CellLabelsDirty=true;%#ok<MCSUP>
        end

        function set.ColorData(hObj,colorData)
            oldColorData=hObj.ColorData;
            hObj.ColorData=colorData;



            if~isequaln(oldColorData,colorData)
                hObj.ScaledColorDataDirty=true;%#ok<MCSUP>
                hObj.CellLabelsDirty=true;%#ok<MCSUP>
            end
        end

        function colorData=get.ScaledColorData(hObj)


            if~hObj.ScaledColorDataDirty
                colorData=hObj.ScaledColorData;
                return
            end


            colorData=calculateScaledColorData(hObj);


            hObj.ScaledColorData=colorData;
            hObj.ScaledColorDataDirty=false;
        end

        function set.Face(hObj,newObj)
            hObj.Face=hObj.setNamedChild(hObj.Face,newObj);
        end

        function set.Grid(hObj,newObj)
            hObj.Grid=hObj.setNamedChild(hObj.Grid,newObj);
        end

        function set.Edge(hObj,newObj)
            hObj.Edge=hObj.setNamedChild(hObj.Edge,newObj);
        end

        function set.Labels(hObj,newObj)
            hObj.Labels=hObj.setNamedChild(hObj.Labels,newObj);
        end

        function set.FontName(hObj,fontName)

            hLabels=hObj.Labels;%#ok<MCSUP>
            if isscalar(hLabels)&&isvalid(hLabels)
                hLabels.Font.Name=fontName;
            end
            hObj.FontName=fontName;
        end

        function set.FontSize(hObj,fontSize)

            hLabels=hObj.Labels;%#ok<MCSUP>
            if isscalar(hLabels)&&isvalid(hLabels)
                hLabels.Font.Size=fontSize;
            end
            hObj.FontSize=fontSize;
        end

        function set.FontAngle(hObj,fontAngle)

            hLabels=hObj.Labels;%#ok<MCSUP>
            if isscalar(hLabels)&&isvalid(hLabels)
                hLabels.Font.Angle=fontAngle;
            end
            hObj.FontAngle=fontAngle;
        end

        function set.FontWeight(hObj,fontWeight)

            hLabels=hObj.Labels;%#ok<MCSUP>
            if isscalar(hLabels)&&isvalid(hLabels)
                hLabels.Font.Weight=fontWeight;
            end
            hObj.FontWeight=fontWeight;
        end

        function set.Interpreter(hObj,interpreter)

            hLabels=hObj.Labels;%#ok<MCSUP>
            if isscalar(hLabels)&&isvalid(hLabels)
                hLabels.Interpreter=interpreter;
            end
            hObj.Interpreter=interpreter;
        end

        function set.MinimumFontSize(hObj,fontSize)

            hLabels=hObj.Labels;%#ok<MCSUP>
            if isscalar(hLabels)&&isvalid(hLabels)
                hLabels.MinimumFontSize=fontSize;
            end
            hObj.MinimumFontSize=fontSize;
        end

        function set.CellMargin(hObj,margin)

            hLabels=hObj.Labels;%#ok<MCSUP>
            if isscalar(hLabels)&&isvalid(hLabels)
                hLabels.CellMargin=margin;
            end
            hObj.CellMargin=margin;
        end

        function set.CellSize(hObj,sz)

            hLabels=hObj.Labels;%#ok<MCSUP>
            if isscalar(hLabels)&&isvalid(hLabels)
                hLabels.CellSize=sz;
            end
            hObj.CellSize=sz;
        end

        function set.GridVisible(hObj,visible)

            hGrid=hObj.Grid;%#ok<MCSUP>
            if isscalar(hGrid)&&isvalid(hGrid)
                hGrid.Visible=visible;
            end
            hObj.GridVisible=visible;
        end

        function set.GridLineStyle(hObj,style)

            hGrid=hObj.Grid;%#ok<MCSUP>
            if isscalar(hGrid)&&isvalid(hGrid)
                hgfilter('LineStyleToPrimLineStyle',hGrid,style);
            end
            hObj.GridLineStyle=style;
        end

        function set.LineColor(hObj,color)


            hEdge=hObj.Edge;%#ok<MCSUP>
            hGrid=hObj.Grid;%#ok<MCSUP>

            if isscalar(hEdge)&&isvalid(hEdge)
                hgfilter('RGBAColorToGeometryPrimitive',hEdge,color);
            end

            if isscalar(hGrid)&&isvalid(hGrid)
                hgfilter('RGBAColorToGeometryPrimitive',hGrid,color);
            end

            hObj.LineColor=color;
        end

        function set.LineWidth(hObj,width)


            hEdge=hObj.Edge;%#ok<MCSUP>
            hGrid=hObj.Grid;%#ok<MCSUP>

            if isscalar(hEdge)&&isvalid(hEdge)
                hEdge.LineWidth=width;
            end

            if isscalar(hGrid)&&isvalid(hGrid)
                hGrid.LineWidth=width;
            end

            hObj.LineWidth=width;
        end

        function fontSize=get.ActualFontSize(hObj)
            fontSize=hObj.Labels.ActualFontSize;
        end
    end


    methods(Hidden,Access=protected)
        index=doGetNearestPoint(hObj,position)
        [index,interp]=doGetInterpolatedPoint(hObj,position)
        [index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)
        index=doGetNearestIndex(hObj,index)
        [index,interp]=doIncrementIndex(hObj,index,direction,~)
        point=doGetReportedPosition(hObj,index,~)
        point=doGetDisplayAnchorPoint(hObj,index,~)
        descriptors=doGetDataDescriptors(hObj,index,~)

        function indices=doGetEnclosedPoints(~,~)

            indices=[];
        end
    end
end
