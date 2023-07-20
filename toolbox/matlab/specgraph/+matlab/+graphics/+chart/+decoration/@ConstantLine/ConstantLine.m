

classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true)ConstantLine<matlab.graphics.primitive.Data&...
    matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Legendable&...
    matlab.graphics.internal.GraphicsBaseFunctions&matlab.graphics.internal.GraphicsUIProperties&matlab.graphics.mixin.Selectable


    properties(AffectsDataLimits)
        Value{mustBeFiniteNumericDateTimeOrCategorical(Value)}=0;
        InterceptAxis matlab.internal.datatype.matlab.graphics.chart.datatype.InterceptAxisType='y';
    end

    properties(Transient,AbortSet,NonCopyable,Hidden,Access=?tConstantLine)
        Edge matlab.graphics.primitive.world.LineStrip;
        LabelPrimitive matlab.graphics.primitive.world.Text;
        Anchor matlab.graphics.primitive.world.CompositeMarker;
    end

    properties(AffectsObject)
        Label matlab.internal.datatype.matlab.graphics.datatype.NumericOrString="";
        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=get(groot,'FactoryTextFontSize');
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName=get(groot,'FactoryTextFontName');
        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
        LabelOrientation matlab.internal.datatype.matlab.graphics.chart.datatype.LabelOrientationType='aligned';
        LabelHorizontalAlignment matlab.internal.datatype.matlab.graphics.chart.datatype.LabelHorizontalAlignmentType='right';
        LabelVerticalAlignment matlab.internal.datatype.matlab.graphics.chart.datatype.LabelVerticalAlignmentType='top';
    end

    properties(SetAccess='public',GetAccess='public',Hidden,Transient,SetObservable)

        SelectionHandle{mustBe_matlab_mixin_Heterogeneous}
    end

    properties(AbortSet,AffectsObject,AffectsLegend)
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0.15,0.15,0.15];
        Alpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=0.7;
    end

    methods(Hidden)
        function hcl=ConstantLine(varargin)
            args=varargin;

            hLine=matlab.graphics.primitive.world.LineStrip;
            hLine.Internal=true;
            hcl.addNode(hLine);
            hcl.Edge=hLine;
            hLine.AlignVertexCenters='on';
            hLine.Layer='front';


            hAnchor=matlab.graphics.primitive.world.CompositeMarker;
            hAnchor.Internal=true;
            hcl.addNode(hAnchor);
            hcl.Anchor=hAnchor;


            hLabel=matlab.graphics.primitive.world.Text;
            hLabel.Internal=true;
            hcl.Anchor.addNode(hLabel);
            hcl.LabelPrimitive=hLabel;
            hLabel.Layer='front';

            hcl.addDependencyConsumed({'xyzdatalimits','view'});


            hcl.Type='constantline';
            matlab.graphics.chart.internal.ctorHelper(hcl,args);

        end

        function doUpdate(obj,us)


            XLim=us.DataSpace.XLim;
            YLim=us.DataSpace.YLim;
            ZLim=us.DataSpace.ZLim;
            val=obj.Value;
            ax=obj.InterceptAxis;
            primLabel=obj.LabelPrimitive;
            vertAlignment=obj.LabelVerticalAlignment;
            horzAlignment=obj.LabelHorizontalAlignment;
            labelOrien=obj.LabelOrientation;
            anchor=obj.Anchor;
            xdir=us.DataSpace.XDir;
            ydir=us.DataSpace.YDir;
            thrownException=MException.empty();

            obj.Edge.Visible=obj.Visible;


            switch ax
            case 'x'
                [val,~]=matlab.graphics.internal.makeNumeric(obj.Parent,val,YLim(1));
            case 'y'
                [~,val]=matlab.graphics.internal.makeNumeric(obj.Parent,XLim(1),val);
            end


            edgeVertData=matlab.graphics.chart.decoration.constantline.calculateEdgeVertexData(val,XLim,YLim,ZLim,ax);
            iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
            iter.Vertices=edgeVertData;
            iter.Indices=[1,2];


            switch ax
            case 'x'
                scale=us.DataSpace.XScale;
                lim=XLim;
            case 'y'
                scale=us.DataSpace.YScale;
                lim=YLim;
            end

            if matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(scale,lim,val)
                anchor.Visible='off';
                obj.Edge.Visible='off';
                obj.LabelPrimitive.Visible='off';
                return
            else
                obj.Edge.Visible='on';
                obj.LabelPrimitive.Visible='on';
            end


            edgeVertWorld=TransformPoints(us.DataSpace,us.TransformUnderDataSpace,iter);
            obj.Edge.VertexData=edgeVertWorld;


            hgfilter('LineStyleToPrimLineStyle',obj.Edge,obj.LineStyle);
            obj.Edge.LineWidth=obj.LineWidth;

            color=obj.Color;
            if strcmp(color,'none')
                obj.Edge.Visible='off';
            else
                obj.Edge.Visible='on';
                color=[obj.Color,obj.Alpha];
                hgfilter('RGBAColorToGeometryPrimitive',obj.Edge,color);
            end


            if isempty(obj.Label)||strcmp(color,'none')||val<lim(1)||val>lim(2)||strcmp(obj.LineStyle,'none')
                anchor.Visible='off';
                primLabel.Visible='off';
            else
                anchor.Visible='on';
                primLabel.Visible='on';


                primLabel.String=obj.Label;
                [primHorzAlign,primVertAlign]=matlab.graphics.chart.decoration.constantline.calcHorzVertAlignment(ax,horzAlignment,vertAlignment,labelOrien);
                primLabel.HorizontalAlignment=primHorzAlign;
                primLabel.VerticalAlignment=primVertAlign;
                primLabel.Font.Size=obj.FontSize;
                primLabel.Font.Angle=obj.FontAngle;
                primLabel.Font.Weight=obj.FontWeight;
                primLabel.Font.Name=obj.FontName;
                primLabel.Interpreter=obj.Interpreter;
                primLabel.ColorData=obj.Edge.ColorData;


                primLabel.VertexData=matlab.graphics.chart.decoration.constantline.calcLabelVertexData(ax,obj.LineWidth,vertAlignment,horzAlignment);



                edgeVertViewer=matlab.graphics.internal.transformWorldToViewer(...
                us.Camera,us.TransformAboveDataSpace,us.DataSpace,us.TransformUnderDataSpace,edgeVertWorld,true);


                switch ax
                case 'y'
                    theta=atan2(edgeVertViewer(2,2)-edgeVertViewer(2,1),edgeVertViewer(1,2)-edgeVertViewer(1,1));
                case 'x'
                    theta=atan2(edgeVertViewer(1,2)-edgeVertViewer(1,1),edgeVertViewer(2,2)-edgeVertViewer(2,1));
                end

                primLabel.Rotation=matlab.graphics.chart.decoration.constantline.rotationOfLabel(ax,labelOrien,rad2deg(theta),xdir,ydir);


                anchorVertViewer=matlab.graphics.chart.decoration.constantline.calculateAnchorVertexDataViewer(ax,horzAlignment,vertAlignment,edgeVertViewer,xdir,ydir,labelOrien);




                w=warning('off','MATLAB:nearlySingularMatrix');
                c1=onCleanup(@()warning(w));


                [lastmsg,lastid]=lastwarn;
                c2=onCleanup(@()lastwarn(lastmsg,lastid));


                anchorVertWorld=matlab.graphics.internal.transformViewerToWorld(us.Camera,us.TransformAboveDataSpace,us.DataSpace,us.TransformUnderDataSpace,anchorVertViewer);
                anchor.VertexData=anchorVertWorld;

                try
                    labelDim=us.getStringBounds(primLabel.String,primLabel.Font,primLabel.Interpreter,'on');
                catch err
                    thrownException=err;
                    labelDim=us.getStringBounds(primLabel.String,primLabel.Font,'none','on');
                    primLabel.Interpreter='none';

                end


                if(strcmp(ax,'y')&&strcmp(vertAlignment,'middle'))||(strcmp(ax,'x')&&strcmp(horzAlignment,'center'))
                    pxPpt=us.PixelsPerPoint;
                    labelDim=labelDim*pxPpt;
                    pxBuff=8;
                    if(strcmp(ax,'x')&&strcmp(labelOrien,'horizontal'))
                        pxBuff=4;
                    end

                    labelDim(1)=labelDim(1)+pxBuff;
                    labelDim(2)=labelDim(2)+pxBuff;

                    updatedEdgeVerts=matlab.graphics.chart.decoration.constantline.calculateEdgeVerticesForIntersectingLabel(edgeVertViewer,...
                    labelDim,horzAlignment,vertAlignment,labelOrien,xdir,ydir,ax,theta);
                    updatedEdgeVerts=matlab.graphics.internal.transformViewerToWorld(us.Camera,us.TransformAboveDataSpace,us.DataSpace,us.TransformUnderDataSpace,updatedEdgeVerts);
                    obj.Edge.VertexData=single(updatedEdgeVerts);

                end

            end


            if strcmp(obj.Visible,'on')&&strcmp(obj.Selected,'on')&&strcmp(obj.SelectionHighlight,'on')
                if isempty(obj.SelectionHandle)
                    obj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight;
                    obj.addNode(obj.SelectionHandle);
                    obj.SelectionHandle.Description='ConstantLine SelectionHandle';
                end

                obj.SelectionHandle.Visible=obj.Selected;
                obj.SelectionHandle.VertexData=obj.Edge.VertexData;
            else
                if~isempty(obj.SelectionHandle)
                    obj.SelectionHandle.VertexData=[];
                    obj.SelectionHandle.Visible='off';
                end
            end



            if(~isempty(thrownException))
                throw(thrownException);
            end

        end

        function extents=getXYZDataExtents(hObj,~,~)
            switch hObj.InterceptAxis
            case 'x'
                [xnumeric,~]=matlab.graphics.internal.makeNumeric(hObj.Parent,hObj.Value,NaN);
                [x,y,z]=matlab.graphics.chart.primitive.utilities.arraytolimits(xnumeric,NaN,NaN);
            case 'y'
                [~,ynumeric]=matlab.graphics.internal.makeNumeric(hObj.Parent,NaN,hObj.Value);
                [x,y,z]=matlab.graphics.chart.primitive.utilities.arraytolimits(NaN,ynumeric,NaN);
            end
            extents=[x;y;z];
        end


        mcodeConstructor(hObj,hCode)

    end


    methods(Access='public',Hidden=true)
        function graphic=getLegendGraphic(hObj)
            graphic=matlab.graphics.primitive.world.Group;
            line=copyobj(hObj.Edge,graphic);
            if~isempty(line.ColorData)
                line.ColorData=line.ColorData(:,1);
                line.ColorBinding='object';
            end
            line.VertexData=single([0,1;.5,.5;0,0]);
            line.StripData=[];
        end
    end

    methods(Access='protected',Hidden=true)
        function varargout=getDescriptiveLabelForDisplay(hobj)
            varargout{1}=hobj.Label;
        end

    end

    methods(Access='protected')
        function groups=getPropertyGroups(~)
            groups=matlab.mixin.util.PropertyGroup({'InterceptAxis',...
            'Value','Color','LineStyle','LineWidth','Label','DisplayName'});
        end
    end

end

function mustBeFiniteNumericDateTimeOrCategorical(data)
    if~isscalar(data)
        throwAsCaller(MException(message('MATLAB:graphics:constantline:EmptyNonScalarInput')));
    elseif~(isnumeric(data)||isdatetime(data)||iscategorical(data)||isduration(data))
        throwAsCaller(MException(message('MATLAB:graphics:constantline:InvalidData')));
    elseif isnumeric(data)&&(~isreal(data))
        throwAsCaller(MException(message('MATLAB:graphics:constantline:ComplexValue')));
    end
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
