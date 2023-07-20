classdef(ConstructOnLoad,Sealed)ImplicitFunctionLine<...
    matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&...
    matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.function.mixin.Legendable&...
    matlab.graphics.chart.interaction.DataAnnotatable&...
    matlab.graphics.mixin.ColorOrderUser




    properties(SetObservable=true,AffectsObject)
        MeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=151;
        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
    end

    properties(NeverAmbiguous)
        XRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        YRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent,AffectsDataLimits)
        Function;
        XRange;
        YRange;
    end

    properties(Dependent,AffectsObject)
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor;
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle;
    end

    properties(Hidden,AffectsLegend,AffectsObject)
        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,1];
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';


        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent,AffectsObject)
        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle;
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive;
        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor;
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor;
    end

    properties(Hidden,AffectsObject)
        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
    end

    properties(Transient,SetAccess=private)
        XData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
        YData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
        ZData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    properties(Hidden,Access=private)
        XRange_I=[-5,5];
        YRange_I=[-5,5];
        Function_I;
        DataTipIndices;
    end

    properties(Transient,Access=public,Hidden,DeepCopy,AffectsObject)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
        MarkerHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(Transient,Access=public,Hidden,NonCopyable)
        Edge matlab.graphics.primitive.world.LineStrip
    end

    properties(Transient,Access=private)
        Function_fh_I;
        XYZCache;
    end

    properties(AffectsObject,AbortSet,SetAccess='public',GetAccess='public',NeverAmbiguous)
        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function hObj=ImplicitFunctionLine(fn,varargin)
            hObj.Edge=matlab.graphics.primitive.world.LineStrip;
            hObj.Edge.ColorData=uint8(255*[hObj.Color,1]).';
            hObj.Edge.ColorBinding='object';
            hObj.Edge.LineWidth=hObj.LineWidth;
            hObj.Edge.Internal=true;
            hObj.addNode(hObj.Edge);

            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker;
            hObj.MarkerHandle.Description_I='ImplicitFunctionLine MarkerHandle';
            hObj.MarkerHandle.LineWidth_I=hObj.LineWidth;
            hObj.MarkerHandle.Internal=true;
            hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker);

            hObj.DataTipIndices=struct('x',{},'y',{});

            hObj.Type='implicitfunctionline';

            hObj.addDependencyConsumed({'xyzdatalimits','dataspace','view',...
            'colororder_linestyleorder'});




            setInteractionHint(hObj,'DataBrushing',false);

            if nargin<1
                return;
            end

            hObj.Function=fn;
            inargs=varargin;

            parent=strcmpi(inargs(1:2:end),'Parent');
            if any(parent)
                parent=find(parent);
                hObj.Parent=inargs{2*parent};
                inargs(2*parent-1:2*parent)=[];
            end

            if~isempty(inargs)
                set(hObj,inargs{:});
            end
        end

        function v=get.Function(hObj)
            v=hObj.Function_I;
        end

        function set.Function(hObj,fn)
            validateattributes(fn,{'function_handle','sym'},{'scalar'});
            if isa(fn,'sym')
                validateattributes(formula(fn),{'sym'},{'scalar'});
            end
            if nvars(fn)>2
                error(message('MATLAB:handle_graphics:FunctionLine:TooManyVariables'));
            end
            hObj.Function_I=fn;
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function set.Function_I(hObj,fn)
            if isa(fn,'sym')
                fn=saveobj(fn);
            end
            hObj.Function_I=fn;
            hObj.updateFunction;
        end

        function set.MeshDensity(hObj,val)
            hObj.MeshDensity=val;
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function val=get.MarkerEdgeColor(hObj)
            val=hObj.MarkerEdgeColor_I;
        end

        function set.MarkerEdgeColor(hObj,val)
            hObj.MarkerEdgeColorMode='manual';
            hObj.MarkerEdgeColor_I=val;
        end

        function set.MarkerEdgeColor_I(hObj,val)
            hObj.MarkerEdgeColor_I=val;
            hObj.clearXYZCache;
        end

        function val=get.MarkerFaceColor(hObj)
            val=hObj.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor(hObj,val)
            hObj.MarkerFaceColorMode='manual';
            hObj.MarkerFaceColor_I=val;
        end

        function set.MarkerFaceColor_I(hObj,val)
            hObj.MarkerFaceColor_I=val;
            hObj.clearXYZCache;
        end

        function val=get.MarkerSize(hObj)
            val=hObj.MarkerSize_I;
        end

        function set.MarkerSize(hObj,val)
            hObj.MarkerSize_I=val;
            hObj.clearXYZCache;
        end

        function set.MarkerSize_I(hObj,val)
            hObj.MarkerSize_I=val;
            passObj=hObj.MarkerHandle;%#ok<*MCSUP>
            if~isempty(passObj)&&isvalid(passObj)
                passObj.Size=val;
            end
            hObj.markLegendEntryDirty;
        end

        function val=get.Marker(hObj)
            val=hObj.Marker_I;
        end

        function set.Marker(hObj,val)
            hObj.Marker_I=val;
            hObj.clearXYZCache;
            hObj.MarkerMode='manual';
        end

        function set.Marker_I(hObj,val)
            hObj.Marker_I=val;
            fanChild=hObj.MarkerHandle;
            if~isempty(fanChild)&&isvalid(fanChild)
                hgfilter('MarkerStyleToPrimMarkerStyle',fanChild,val);
            end
        end

        function set.MarkerHandle(hObj,val)
            val=hgcastvalue('matlab.mixin.Heterogeneous',val);
            oldValue=hObj.MarkerHandle;
            if~isempty(val)&&isvalid(val)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.replaceChild(hObj.MarkerHandle,val);
                else

                    hObj.addNode(val);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.MarkerHandle=val;
            hObj.markLegendEntryDirty;
        end

        function val=get.XRange(hObj)
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
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function val=get.YRange(hObj)
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
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function val=get.LineStyle(hObj)
            val=hObj.LineStyle_I;
        end

        function set.LineStyle(hObj,val)
            hObj.LineStyle_I=val;
            hObj.LineStyleMode='manual';
        end

        function set.LineStyle_I(hObj,style)
            hObj.LineStyle_I=style;
            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,style);
        end

        function set.LineWidth(hObj,width)
            hObj.LineWidth=width;
            hObj.Edge.LineWidth=width;
            fanChild=hObj.MarkerHandle;
            if~isempty(fanChild)&&isvalid(fanChild)
                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',width);
                end
            end
            hObj.markLegendEntryDirty;
        end

        function val=get.Color(hObj)
            val=hObj.Color_I;
        end

        function set.Color(hObj,color)
            hObj.Color_I=color;
            hObj.ColorMode='manual';
        end

        function set.Color_I(hObj,color)
            hObj.Color_I=color;
            hObj.Edge.ColorData=uint8(255*[color,1]).';
            hObj.Edge.ColorBinding='object';

            mec=hObj.MarkerEdgeColor;
            if strcmpi(mec,'auto')
                mec=hObj.Color;
            end
            hgfilter('EdgeColorToMarkerPrimitive',hObj.MarkerHandle,mec);

            mfc=hObj.MarkerFaceColor;
            if strcmpi(mfc,'auto')
                mfc=mec;
            end
            hgfilter('FaceColorToMarkerPrimitive',hObj.MarkerHandle,mfc);

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
            hObj.clearXYZCache;
        end

        function vbox=getXYZDataExtents(hObj,transformation,~)
            data=hObj.getXYZData(hObj.getDataSpace(),transformation);
            if isempty(data.xdata)
                transdata=[NaN(2,4);0,0,0,0;1,1,1,1];
            else
                transdata=[data.xdata;data.ydata;data.zdata;ones(size(data.xdata))];
            end
            if isequal(hObj.XRangeMode,'manual')
                if isequal(hObj.YRangeMode,'manual')

                    transdata=[hObj.XRange,hObj.XRange;hObj.YRange,fliplr(hObj.YRange);0,0,0,0;1,1,1,1];
                else
                    ymin=min(data.ydata);
                    ymax=max(data.ydata);
                    transdata=[hObj.XRange,hObj.XRange;ymin,ymax,ymax,ymin;0,0,0,0;1,1,1,1];
                end
            elseif isequal(hObj.YRangeMode,'manual')
                xmin=min(data.xdata);
                xmax=max(data.xdata);
                transdata=[xmin,xmax,xmax,xmin;hObj.YRange,hObj.YRange;0,0,0,0;1,1,1,1];
            end

            transdata=transformation*transdata;
            transdata=bsxfun(@rdivide,transdata(1:3,:),transdata(4,:));

            xrange=matlab.graphics.function.internal.estimateViewingBox(transdata(1,:),-inf,inf);
            yrange=matlab.graphics.function.internal.estimateViewingBox(transdata(2,:),-inf,inf);
            zrange=matlab.graphics.function.internal.estimateViewingBox(transdata(3,:),-inf,inf);
            vbox=[xrange;yrange;zrange];
        end

        function xd=get.XData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace());
            xd=data.xdata;
            for pos=fliplr(data.LineStripData(2:end-1))
                xd=[xd(1:pos-1),NaN,xd(pos:end)];
            end
        end

        function yd=get.YData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace());
            yd=data.ydata;
            for pos=fliplr(data.LineStripData(2:end-1))
                yd=[yd(1:pos-1),NaN,yd(pos:end)];
            end
        end

        function zd=get.ZData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace());
            zd=data.zdata;
            for pos=fliplr(data.LineStripData(2:end-1))
                zd=[zd(1:pos-1),NaN,zd(pos:end)];
            end
        end
    end

    methods(Hidden)
        function doUpdate(hObj,us)
            if hObj.Visible=="off"
                return
            end

            updatedColor=hObj.getColor(us);
            if strcmp(hObj.ColorMode,'auto')&&~isempty(updatedColor)
                hObj.Color_I=updatedColor;
            end

            updatedLineStyle=hObj.getLineStyle(us);
            if strcmp(hObj.LineStyleMode,'auto')&&~isempty(updatedLineStyle)
                hObj.LineStyle_I=updatedLineStyle;
            end

            updatedMarker=hObj.getMarker(us);
            if strcmp(hObj.MarkerMode,'auto')&&~isempty(updatedMarker)
                hObj.Marker_I=updatedMarker;
            end

            hObj.XYZCache=[];
            data=hObj.getXYZData(us);

            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

            piter.XData=data.xdata;
            piter.YData=data.ydata;
            piter.ZData=data.zdata;

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);

            edge=hObj.Edge;
            edge.VertexData=single(vd);
            edge.StripData=uint32(data.LineStripData);

            hObj.MarkerHandle.VertexData=single(data.marker_pos);

            mec=hObj.MarkerEdgeColor;
            if strcmpi(mec,'auto')
                mec=hObj.Color;
            end
            hgfilter('EdgeColorToMarkerPrimitive',hObj.MarkerHandle,mec);

            mfc=hObj.MarkerFaceColor;
            if strcmpi(mfc,'auto')
                mfc=mec;
            end
            hgfilter('FaceColorToMarkerPrimitive',hObj.MarkerHandle,mfc);


            if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
                if isempty(hObj.SelectionHandle)
                    createSelectionHandle(hObj);
                end
                hObj.SelectionHandle.VertexData=edge.VertexData;
                hObj.SelectionHandle.Visible='on';
            else
                if~isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle.VertexData=[];
                    hObj.SelectionHandle.Visible='off';
                end
            end
        end

        function graphic=getLegendGraphic(hObj)
            graphic=matlab.graphics.chart.primitive.utilities.getIconForLinePlots(hObj);
        end


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
        function clearXYZCache(hObj)
            hObj.XYZCache=[];
        end

        function group=getPropertyGroups(hObj)
            show={'Function'};
            if strcmp(hObj.XRangeMode,'manual')
                show=[show,{'XRange'}];
            end
            if strcmp(hObj.YRangeMode,'manual')
                show=[show,{'YRange'}];
            end
            show=[show,{'Color','LineStyle','LineWidth'}];
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
            data=hObj.getXYZData(hObj.getDataSpace());
            points=[data.xdata;data.ydata;data.zdata];
            pointIndex=pickUtils.nearestPoint(hObj,position,true,points.');
            point=points(:,pointIndex);
            index=hObj.getCacheFor(point(1),point(2));
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYZData(hObj.getDataSpace());
            points=[data.xdata;data.ydata;data.zdata];
            pointIndex=pickUtils.nearestPoint(hObj,position,false,points.');
            point=points(:,pointIndex);
            index=hObj.getCacheFor(point(1),point(2));
            interpolationFactor=0;
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end


        function indices=doGetEnclosedPoints(hObj,polygon)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYZData(hObj.getDataSpace());
            points=[data.xdata;data.ydata;data.zdata];
            localIndices=pickUtils.enclosedPoints(hObj,polygon,points.');
            indices=arrayfun(@(i)hObj.getCacheFor(points(1,i),points(2,i)),localIndices);
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

    methods(Access=?tfimplicit)

        function pos=preparePointNear(hObj,pos)
            pos=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,pos.');
            index=hObj.doGetNearestPoint(pos.');
            pos=hObj.cacheLookup(index);
            pos=[pos.x,pos.y,0];
        end
    end

    methods(Access='private')
        data=calcXYZData(hObj,us,transformation)

        function data=getXYZData(hObj,us,transformation)
            if nargin<3
                transformation=eye(4);
            end

            ds=[];
            if~isempty(us)
                ds=hObj.getDataSpace;
                if nargin<3&&~isempty(findprop(us,'Transform'))
                    transformation=us.Transform;
                end
                ds={ds.XLim,ds.XLimMode,ds.YLim,ds.YLimMode,ds.ZLim,ds.ZLimMode,transformation};
            end

            if isempty(hObj.XYZCache)||~isequal(hObj.XYZCache{1},{ds})
                hObj.XYZCache={{ds},hObj.calcXYZData(us,transformation)};
            end
            data=hObj.XYZCache{2};
        end

        function ds=getDataSpace(hObj)
            ds=ancestor(hObj,'matlab.graphics.axis.dataspace.DataSpace','node');
        end

        function updateFunction(hObj)
            hObj.Function_fh_I=getFunction(hObj.Function_I,hObj.XRange,hObj.YRange);
            if strcmp(hObj.DisplayNameMode,'auto')
                hObj.DisplayName_I_ByInterpreter=hObj.displayNames(hObj.Function_I);
                hObj.DisplayName=hObj.DisplayName_I_ByInterpreter.tex;
                hObj.DisplayNameMode='auto';
            else
                hObj.DisplayName_I_ByInterpreter=struct;
            end
        end

        function index=getCacheFor(hObj,x,y)
            index=find([hObj.DataTipIndices.x]==x&[hObj.DataTipIndices.y]==y);
            if isempty(index)
                index=numel(hObj.DataTipIndices)+1;
                hObj.DataTipIndices(index).x=x;
                hObj.DataTipIndices(index).y=y;
            end
        end

        function pos=cacheLookup(hObj,index)

            if numel(hObj.DataTipIndices)<index
                pos.x=NaN;
                pos.y=NaN;
                return;
            end
            pos=hObj.DataTipIndices(index);
            data=hObj.getXYZData(hObj.getDataSpace());
            xVerts=data.xdata;
            yVerts=data.ydata;
            if pos.x<min(xVerts)||pos.x>max(xVerts)||...
                pos.y<min(yVerts)||pos.y>max(yVerts)
                pos.x=NaN;
                pos.y=NaN;
            end
        end

        function createSelectionHandle(hObj)

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
            hObj.addNode(hObj.SelectionHandle);


            hObj.SelectionHandle.Description='ImplicitFunctionLine SelectionHandle';


        end
    end
end

function fn=getFunction(fnIn,xrange,yrange)
    if isa(fnIn,'sym')
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
    sf2=feval_internal(symengine,'symobj::map',sf,'symobj::equationToExpression');
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
