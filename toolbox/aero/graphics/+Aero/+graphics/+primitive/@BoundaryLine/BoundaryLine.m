classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)BoundaryLine<...
    Aero.graphics.primitive.Data&...
    matlab.graphics.mixin.Chartable2D&...
    matlab.graphics.internal.GraphicsUIProperties&...
    matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.mixin.Selectable&...
    matlab.graphics.mixin.Legendable




    properties(SetObservable,SetAccess='public',GetAccess='public',Dependent)
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0]
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=.5;
    end
    properties(Hidden,Access='protected',AffectsObject,AffectsLegend)
        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0]
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=.5;
    end

    methods
        function set.Color(hObj,value)
            hObj.Color_I=value;
        end
        function set.LineStyle(hObj,value)
            hObj.LineStyle_I=value;
        end
        function set.LineWidth(hObj,value)
            hObj.LineWidth_I=value;
        end
        function value=get.Color(hObj)
            value=hObj.Color_I;
        end
        function value=get.LineStyle(hObj)
            value=hObj.LineStyle_I;
        end
        function value=get.LineWidth(hObj)
            value=hObj.LineWidth_I;
        end
    end


    properties(SetObservable,SetAccess='public',GetAccess='public',Dependent)
        HatchLength matlab.internal.datatype.matlab.graphics.datatype.Positive=0.03
        HatchSpacing matlab.internal.datatype.matlab.graphics.datatype.Positive=0.1
        HatchAngle(1,1){mustBeReal,mustBeFinite}=225
        HatchTangency matlab.lang.OnOffSwitchState="on"
        FlipBoundary matlab.lang.OnOffSwitchState="off"
    end
    properties(Hidden,Access='protected',AffectsDataLimits)
        HatchLength_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.03
        HatchSpacing_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.1
        HatchAngle_I(1,1){mustBeReal,mustBeFinite}=225
        HatchTangency_I matlab.lang.OnOffSwitchState="on"
        FlipBoundary_I matlab.lang.OnOffSwitchState="off"
    end

    methods
        function set.HatchLength(hObj,value)
            hObj.HatchLength_I=value;
        end
        function set.HatchSpacing(hObj,value)
            hObj.HatchSpacingMode='manual';
            hObj.HatchSpacing_I=value;
        end
        function set.HatchAngle(hObj,value)
            hObj.HatchAngleMode='manual';
            hObj.HatchAngle_I=value;
        end
        function set.HatchTangency(hObj,value)
            hObj.HatchTangency_I=value;
        end
        function set.FlipBoundary(hObj,value)
            hObj.FlipBoundary_I=value;
        end
        function value=get.HatchLength(hObj)
            value=hObj.HatchLength_I;
        end
        function value=get.HatchSpacing(hObj)
            value=hObj.HatchSpacing_I;
        end
        function value=get.HatchAngle(hObj)
            value=hObj.HatchAngle_I;
        end
        function value=get.HatchTangency(hObj)
            value=hObj.HatchTangency_I;
        end
        function value=get.FlipBoundary(hObj)
            value=hObj.FlipBoundary_I;
        end
    end


    properties(SetObservable,SetAccess='public',GetAccess='public',Dependent)
        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end
    properties(Hidden,Access='protected',AffectsObject)
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end

    methods
        function set.Marker(hObj,value)
            hObj.Marker_I=value;
        end
        function set.MarkerEdgeColor(hObj,value)
            hObj.MarkerEdgeColor_I=value;
        end
        function set.MarkerFaceColor(hObj,value)
            hObj.MarkerFaceColor_I=value;
        end
        function set.MarkerSize(hObj,value)
            hObj.MarkerSize_I=value;
        end
        function value=get.Marker(hObj)
            value=hObj.Marker_I;
        end
        function value=get.MarkerEdgeColor(hObj)
            value=hObj.MarkerEdgeColor_I;
        end
        function value=get.MarkerFaceColor(hObj)
            value=hObj.MarkerFaceColor_I;
        end
        function value=get.MarkerSize(hObj)
            value=hObj.MarkerSize_I;
        end
    end


    properties(SetObservable,SetAccess='public',GetAccess='public',Dependent)
        HatchSpacingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        HatchAngleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end
    properties(Hidden,Access='protected',AffectsDataLimits)
        HatchSpacingMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        HatchAngleMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function set.HatchSpacingMode(hObj,value)
            hObj.HatchSpacingMode_I=value;
        end
        function set.HatchAngleMode(hObj,value)
            hObj.HatchAngleMode_I=value;

            if hObj.HatchAngleMode_I=="auto"&&~isempty(hObj.Hatches_I)
                switch hObj.Hatches_I(1)
                case "/"
                    hObj.HatchAngle_I=225;
                case "\"
                    hObj.HatchAngle_I=315;
                case "|"
                    hObj.HatchAngle_I=270;
                end
            end
        end
        function value=get.HatchSpacingMode(hObj)
            value=hObj.HatchSpacingMode_I;
        end
        function value=get.HatchAngleMode(hObj)
            value=hObj.HatchAngleMode_I;
        end
    end


    properties(SetObservable,SetAccess='public',GetAccess='public',Dependent)
        Hatches matlab.internal.datatype.asciiString='/';
    end
    properties(Hidden,Access='protected',AffectsDataLimits)
        Hatches_I matlab.internal.datatype.asciiString='/';
    end

    methods
        function set.Hatches(hObj,value)
            mustBeHatch(value)
            hObj.Hatches_I=value;
            hObj.HatchSpacingMode='auto';
            hObj.HatchAngleMode='auto';
        end
        function value=get.Hatches(hObj)
            value=hObj.Hatches_I;
        end
    end


    properties(Access={?hBoundaryLineTester},Transient,NonCopyable)
        MarkerHandle(:,1)matlab.graphics.primitive.world.Marker;
        LineHandle(:,1)matlab.graphics.primitive.world.LineStrip;
        HatchHandle(:,1)matlab.graphics.primitive.world.LineStrip;
        SelectionHandle(:,1)matlab.graphics.interactor.ListOfPointsHighlight;
    end

    methods
        function set.MarkerHandle(hObj,value)
            hObj.MarkerHandle=value;
            hObj.addNode(value);
        end
        function set.LineHandle(hObj,value)
            hObj.LineHandle=value;
            hObj.addNode(value);
        end
        function set.HatchHandle(hObj,value)
            hObj.HatchHandle=value;
            hObj.addNode(value);
        end
        function set.SelectionHandle(hObj,value)
            hObj.SelectionHandle=value;
            hObj.addNode(value);
        end
    end


    methods
        function hObj=BoundaryLine(varargin)



            if~builtin('license','checkout','Aerospace_Toolbox')
                error(message('MATLAB:license:NoFeature','boundaryline','Aerospace_Toolbox'))
            end


            hObj.Type='boundaryline';

            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker;
            hObj.LineHandle=matlab.graphics.primitive.world.LineStrip;
            hObj.HatchHandle=matlab.graphics.primitive.world.LineStrip;
            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight;


            hObj.MarkerHandle.Description_I="BoundaryLine Marker";
            hObj.MarkerHandle.Internal=true;


            hObj.LineHandle.Description_I="BoundaryLine Line";
            hObj.LineHandle.Internal=true;
            hObj.LineHandle.Layer='front';


            hObj.HatchHandle.Description_I="BoundaryLine Hatch";
            hObj.HatchHandle.Internal=true;
            hObj.HatchHandle.Layer='front';


            hObj.SelectionHandle.Description_I="BoundaryLine Selection";
            hObj.SelectionHandle.Internal=true;
            hObj.SelectionHandle.Layer='front';


            addDependencyConsumed(hObj,{'ref_frame','view','dataspace','xyzdatalimits'});


            setInteractionHint(hObj,'DataBrushing',false);



            [varargin,hatches]=Aero.internal.namevalues.findAndTrimNameValuePair(varargin,"Hatches");
            if~isempty(hatches)
                hObj.Hatches=hatches;
            end


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end


    methods(Hidden)
        doUpdate(hObj,updateState)
        extents=getXYZDataExtents(hObj,T,constraints)
        graphic=getLegendGraphic(hObj)
        hints=getHints(hObj);
    end

    methods(Hidden,Access='protected')
        propgroups=getPropertyGroups(hObj)
        label=getDescriptiveLabelForDisplay(hObj)

        tf=isDataValid(hObj,throwError)
        [x,y,z]=preProcessData(hObj,xscale,yscale,xlim,ylim)
        vertexData=calculateLineVertexData(hObj,x,y,z)
        calculateHatchSpacing(hObj,vertexData)
        [hatchVertexData,cantDrawHatches]=calculateHatchVertexData(hObj,vertexData,hatchspacing,hatchlength,hatchangle)
        [hatchStartingVertexData,bins]=calculateHatchStartingVertexData(hObj,vertexData,numHatches)
        hatchEndingVertexData=calculateHatchEndingVertexData(hObj,hatchStartingVertexData,prevVertexData,nextVertexData,hatchlength,hatchangle)
    end
end

function mustBeHatch(hatch)
    if strlength(hatch)==0
        return
    end
    h=hatch(1);
    if~any(h==["/","\","|"])||~all(hatch.'==h)
        error(message("aero_graphics:BoundaryLine:mustBeHatch"))
    end

end
