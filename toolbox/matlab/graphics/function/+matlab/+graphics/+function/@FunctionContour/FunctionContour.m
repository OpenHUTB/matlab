classdef(ConstructOnLoad,Sealed)FunctionContour<...
    matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&...
    matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.function.mixin.Legendable&...
    matlab.graphics.chart.interaction.DataAnnotatable






    properties(AffectsObject)
        MeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=71;
    end

    properties(NeverAmbiguous)
        LevelListMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        LevelStepMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';






    end

    properties(AffectsObject)
        Fill matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    properties(NeverAmbiguous)
        XRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        YRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent,AffectsDataLimits)
        XRange;
        YRange;
        Function;
    end

    properties(AffectsObject)
        LevelList matlab.internal.datatype.matlab.graphics.datatype.VectorData=[];
        LevelStep(1,1)double{mustBeReal}=0;
        LineColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor;
    end

    properties(Dependent,AffectsObject)
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
    end

    properties(Hidden)
        LineColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='flat';
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
        FaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        ContourZLevel(1,1)double{mustBeReal}=0.0;
    end

    properties(Hidden,Dependent,AffectsObject)
        FaceColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='flat';
    end

    properties(Hidden,Access=private)
        XRange_I=[-5,5];
        YRange_I=[-5,5];
Function_I
        LevelList_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=[];
        LevelStep_I(1,1)double{mustBeReal}=0;
        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='flat';
        DataTipIndices;
        Color_I;
    end

    properties(Hidden,Transient,Access=private,NonCopyable)
Function_fh_I
XYCache
    end

    properties(Transient,SetAccess=private)
        ContourMatrix;
        XData matlab.internal.datatype.matlab.graphics.datatype.SurfaceXYData;
        YData matlab.internal.datatype.matlab.graphics.datatype.SurfaceXYData;
        ZData matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix;
    end

    properties(Transient,Hidden,DeepCopy,AffectsObject)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(Transient,Access=public,Hidden,NonCopyable)
        Edge matlab.graphics.primitive.world.LineStrip;
        FacePrims matlab.graphics.primitive.world.TriangleStrip{matlab.internal.validation.mustBeVector(FacePrims)}=matlab.graphics.primitive.world.TriangleStrip.empty;
        ContourLines;
    end

    methods
        function hObj=FunctionContour(fn,varargin)
            hObj.Edge=matlab.graphics.primitive.world.LineStrip.empty;

            hObj.DataTipIndices=struct('x',{},'y',{});

            hObj.addDependencyConsumed({'xyzdatalimits','dataspace','figurecolormap','colorspace'});




            setInteractionHint(hObj,'DataBrushing',false);

            if nargin<1
                return;
            end

            hObj.Function=fn;
            hObj.Type='functioncontour';

            inargs=struct(varargin{:});

            if isfield(inargs,'Parent')
                hObj.Parent=inargs.Parent;
                inargs=rmfield(inargs,'Parent');
            end

            incell=struct2nvpairs(inargs);
            if~isempty(incell)
                set(hObj,incell{:});
            end
            hObj.clearXYCache;
        end

        function v=get.Function(hObj)
            v=hObj.Function_I;
        end

        function set.Function(hObj,fn)
            validateattributes(fn,{'function_handle','sym'},{'scalar'});
            if isa(fn,'sym')
                validateattributes(formula(fn),{'sym'},{'scalar'});
                fn=saveobj(fn);
            end
            if nvars(fn)>2
                error(message('MATLAB:handle_graphics:FunctionLine:TooManyVariables'));
            end
            hObj.Function_I=fn;
        end

        function set.Function_I(hObj,fn)
            hObj.Function_I=fn;
            hObj.updateFunction;
            hObj.clearXYCache;
            hObj.sendDataChangedEvent;
        end

        function set.MeshDensity(hObj,val)
            hObj.MeshDensity=val;
            hObj.clearXYCache;
            hObj.sendDataChangedEvent();
        end

        function val=get.XRange(hObj)
            if strcmp(hObj.XRangeMode,'auto')
                try
                    ds=hObj.getAxesAncestor();
                    val=ds.XLim;
                    return
                catch
                end
            end
            if~strcmp(hObj.XRangeMode,'manual')

                try
                    forceFullUpdate(hObj,'all','XRange');
                catch
                end
            end
            val=hObj.XRange_I;
        end

        function set.XRange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.XRangeMode='manual';
            hObj.XRange_I=lim;
            hObj.clearXYCache;
            hObj.sendDataChangedEvent;
        end

        function val=get.YRange(hObj)
            if strcmp(hObj.YRangeMode,'auto')
                try
                    ds=hObj.getAxesAncestor();
                    val=ds.YLim;
                    return
                catch
                end
            end
            if~strcmp(hObj.YRangeMode,'manual')

                try
                    forceFullUpdate(hObj,'all','YRange');
                catch
                end
            end
            val=hObj.YRange_I;
        end

        function set.YRange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.YRangeMode='manual';
            hObj.YRange_I=lim;
            hObj.clearXYCache;
            hObj.sendDataChangedEvent;
        end

        function l=get.LevelList(hObj)
            if strcmp(hObj.LevelListMode,'manual')
                l=hObj.LevelList_I;
            else
                data=hObj.getXYData(hObj.getAxesAncestor());
                l=[data.contourlines.Level];
            end
        end

        function set.LevelList(hObj,val)
            hObj.LevelListMode='manual';
            hObj.LevelList_I=val;
            hObj.clearXYCache;
            hObj.sendDataChangedEvent;
        end

        function val=get.LevelStep(hObj)
            val=hObj.LevelStep_I;
        end

        function set.LevelStep(hObj,val)
            hObj.LevelStepMode='manual';
            hObj.LevelStep_I=val;
            hObj.clearXYCache;
            hObj.sendDataChangedEvent;
        end

        function val=get.FaceColor(hObj)
            val=hObj.FaceColor_I;
        end

        function set.FaceColor(hObj,val)
            hObj.FaceColorMode='manual';
            hObj.FaceColor_I=val;
        end

        function set.Fill(hObj,val)
            hObj.Fill=val;
        end

        function val=get.LineStyle(hObj)
            val=hObj.LineStyle_I;
        end

        function set.LineStyle(hObj,style)
            hObj.LineStyle_I=style;
        end

        function set.LineStyle_I(hObj,style)
            hObj.LineStyle_I=style;
            for i=1:numel(hObj.Edge)%#ok<*MCSUP>
                hgfilter('LineStyleToPrimLineStyle',hObj.Edge(i),style);
            end
            hObj.markLegendEntryDirty;
        end

        function val=get.LineWidth(hObj)
            val=hObj.LineWidth_I;
        end

        function set.LineWidth(hObj,width)
            hObj.LineWidth_I=width;
        end

        function set.LineWidth_I(hObj,width)
            hObj.LineWidth_I=width;
            for i=1:numel(hObj.Edge)
                hObj.Edge(i).LineWidth=width;
            end
            hObj.markLegendEntryDirty;
        end

        function val=get.LineColor(hObj)
            val=hObj.LineColor_I;
        end

        function set.LineColor(hObj,color)
            hObj.LineColor_I=color;
        end

        function storedValue=get.Color_I(hObj)
            storedValue=hObj.LineColor_I;
        end

        function set.SelectionHandle(hObj,newValue)
            newValue=hgcastvalue('matlab.mixin.Heterogeneous',newValue);
            oldValue=hObj.SelectionHandle;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)
                    hObj.replaceChild(hObj.SelectionHandle,newValue);
                else
                    hObj.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)
                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.SelectionHandle=newValue;
        end

        function vbox=getXYZDataExtents(hObj,transformation,~)
            vbox=[hObj.XRange;hObj.YRange;0,0;1,1];
            vbox=transformation*vbox;
            vbox=sort(bsxfun(@rdivide,vbox(1:3,:),vbox(4,:)),2);
        end

        function xd=get.XData(hObj)
            data=hObj.getXYData(hObj.getAxesAncestor());
            xd=data.xdata;
        end

        function yd=get.YData(hObj)
            data=hObj.getXYData(hObj.getAxesAncestor());
            yd=data.ydata;
        end

        function zd=get.ZData(hObj)
            data=hObj.getXYData(hObj.getAxesAncestor());
            zd=data.zdata;
        end

        function ex=getColorAlphaDataExtents(hObj)
            data=hObj.getXYData(hObj.getAxesAncestor());
            if isempty(data.contourlines)
                ex=[NaN,NaN;NaN,NaN];
            else
                cmin=min([data.contourlines.Level]);
                cmax=max([data.contourlines.Level]);
                if cmin==cmax
                    cmin=cmin-1;
                    cmax=cmax+1;
                end
                ex=[cmin,cmax;NaN,NaN];
            end
        end

        function C=get.ContourMatrix(hObj)
            data=hObj.getXYData(hObj.getAxesAncestor());
            C=deriveContourMatrix(data.contourlines);
        end

        function C=get.ContourLines(hObj)
            data=hObj.getXYData(hObj.getAxesAncestor());
            C=data.contourlines;
        end
    end

    methods(Hidden)
        doUpdate(hObj,us)
        graphic=getLegendGraphic(hObj)


        function dataTipRows=createDefaultDataTipRows(~)
            dataTipRows=[...
            dataTipTextRow('X','XData');...
            dataTipTextRow('Y','YData')];
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            if numel(hObj.DataTipIndices)>=dataIndex
                location=hObj.cacheLookup(dataIndex);
            else
                location=struct('x','','y','');
            end
            switch(valueSource)
            case 'XData'
                coordinateData=CoordinateData('XData',location.x);
            case 'YData'
                coordinateData=CoordinateData('YData',location.y);
            end
        end


        function valueSources=getAllValidValueSources(~)
            valueSources=["XData","YData"];
        end

        mcodeConstructor(hObj,code)
    end

    methods(Access=protected)
        function clearXYCache(hObj)
            hObj.XYCache=[];
        end

        function group=getPropertyGroups(hObj)
            show={'Function'};
            if strcmp(hObj.XRangeMode,'manual')
                show=[show,{'XRange'}];
            end
            if strcmp(hObj.YRangeMode,'manual')
                show=[show,{'YRange'}];
            end
            show=[show,{'LineColor','LineStyle','LineWidth','Fill','LevelList'}];
            group=matlab.mixin.util.PropertyGroup(show);
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            point=hObj.cacheLookup(index);
            descriptors=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',point.x),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',point.y)];
        end

        function index=doGetNearestIndex(~,index)
        end

        function[index,interp]=doIncrementIndex(~,index,~,~)

            interp=0;
        end

        function index=doGetNearestPoint(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYData(hObj.getAxesAncestor);
            vertices=[data.contourlines.VertexData];
            pointIndex=pickUtils.nearestPoint(hObj,position,true,vertices.');
            if isempty(pointIndex)
                point=[NaN,NaN];
            else
                point=vertices(:,pointIndex);
            end
            index=hObj.getCacheFor(point(1),point(2));
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
            interpolationFactor=0;
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYData(hObj.getAxesAncestor);
            vertices=[data.contourlines.VertexData];
            pointIndex=pickUtils.nearestPoint(hObj,position,false,vertices.');
            if isempty(pointIndex)
                point=[NaN,NaN];
            else
                point=vertices(:,pointIndex);
            end
            index=hObj.getCacheFor(point(1),point(2));
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end


        function indices=doGetEnclosedPoints(hObj,polygon)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYData(hObj.getAxesAncestor);
            vertices=[data.contourlines.VertexData];
            localIndices=pickUtils.enclosedPoints(hObj,polygon,vertices.');
            points=vertices(:,localIndices);
            indices=arrayfun(@(i)hObj.getCacheFor(points(1,i),points(2,i)),1:size(points,2));
        end


        function point=doGetDisplayAnchorPoint(hObj,index,~)
            pos=hObj.cacheLookup(index);
            point=matlab.graphics.shape.internal.util.SimplePoint(...
            double([pos.x,pos.y,0]));
        end

        function point=doGetReportedPosition(hObj,index,interpolationFactor)
            point=doGetDisplayAnchorPoint(hObj,index,interpolationFactor);
        end
    end

    methods(Access=?tfcontour)

        function pos=preparePointNear(hObj,pos)
            pos=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,pos.');
            index=hObj.doGetNearestPoint(pos.');
            pos=hObj.cacheLookup(index);
            pos=[pos.x,pos.y,0];
        end
    end

    methods(Access=private)
        data=calcXYData(hObj,us)

        function data=getXYData(hObj,us)

            ds=[];
            if~isempty(us)
                ds=us.DataSpace;
                ds={ds.XLim,ds.XLimMode,ds.XScale,...
                ds.YLim,ds.YLimMode,ds.YScale};
            end

            if isempty(hObj.XYCache)||~isequal(hObj.XYCache{1},ds)
                hObj.XYCache={ds,hObj.calcXYData(us)};
            end
            data=hObj.XYCache{2};
        end

        function index=getCacheFor(hObj,x,y)
            sameX=bsxfun(@isequaln,[hObj.DataTipIndices.x],x);
            sameY=bsxfun(@isequaln,[hObj.DataTipIndices.y],y);
            index=find(sameX&sameY);
            if isempty(index)
                index=numel(hObj.DataTipIndices)+1;
                hObj.DataTipIndices(index).x=x;
                hObj.DataTipIndices(index).y=y;
            end
        end

        function pos=cacheLookup(hObj,index)

            if numel(hObj.DataTipIndices)>=index
                pos=hObj.DataTipIndices(index);
            else
                pos.x=NaN;
                pos.y=NaN;
            end
        end

        function updateFunction(hObj)
            hObj.Function_fh_I=getImplicitFunction(hObj.Function_I,hObj.XRange,hObj.YRange);
            if strcmp(hObj.DisplayNameMode,'auto')
                hObj.DisplayName_I_ByInterpreter=hObj.displayNames(hObj.Function_I);
                hObj.DisplayName=hObj.DisplayName_I_ByInterpreter.tex;
                hObj.DisplayNameMode='auto';
            else
                hObj.DisplayName_I_ByInterpreter=struct;
            end
        end

        function createSelectionHandle(hObj)

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
            hObj.addNode(hObj.SelectionHandle);


            hObj.SelectionHandle.Description='FunctionContour SelectionHandle';


        end
        function ax=getAxesAncestor(hObj)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
        end
    end
end

function nv=struct2nvpairs(x)

    n=fieldnames(x);
    v=struct2cell(x);
    nv=[n,v]';
end

function fn=getImplicitFunction(fnIn,xrange,yrange)
    if isempty(fnIn)
        fn=@(x)0*x+1;
    elseif isa(fnIn,'sym')
        fn=sym2Implicitfn(fnIn);
    elseif isa(fnIn,'function_handle')
        fn=fnIn;
    elseif isnumeric(fnIn)&&isscalar(fnIn)
        fn=@(x,~)fnIn.*ones(size(x));
    else
        fn=@(x,y)double(feval(fnIn,x,y));
    end
    if nargin(fn)==1
        fn1=fn;
        fn=@(x,y)fn1(x);
    end

    testvaluesX=linspace(xrange(1),xrange(end),3);
    testvaluesY=linspace(yrange(1),yrange(end),3);
    vectorError=false;
    scalarError=false;
    try
        fnXY=fn(testvaluesX,testvaluesY);
    catch
        vectorError=true;
    end
    try
        fnXYScalar=arrayfun(fn,testvaluesX,testvaluesY);
    catch
        scalarError=true;
    end

    if vectorError
        good=scalarError;
    else
        good=~scalarError&&isequaln(fnXY,fnXYScalar);
    end

    if~good
        if~isa(fnIn,'sym')
            warning(message('MATLAB:fplot:NotVectorized'));
        end
        fn=@(x,y)arrayfun(fn,x,y);
    end
end

function fn=sym2Implicitfn(sf)
    sf2=feval_internal(symengine,'subs',sf,'hold(_equal)=_subtract','EvalChanges');
    fn=matlab.graphics.function.internal.sym2fn(sf2,symvar(sf,2));
end

function n=nvars(fn)

    if isa(fn,'function_handle')
        n=nargin(fn);
        if n<0
            n=-1-n;
        end
    else
        n=numel(symvar(fn));
    end
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropSetClsMismatch','%s',message('MATLAB:type:PropSetClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
