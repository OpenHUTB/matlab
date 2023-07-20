classdef(ConstructOnLoad,Sealed)ParameterizedFunctionLine<...
    matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&...
    matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.function.mixin.Legendable&...
    matlab.graphics.chart.interaction.DataAnnotatable&...
    matlab.graphics.mixin.ColorOrderUser






    properties(SetObservable=true)
        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    properties(SetObservable=true,AffectsObject)
        MeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=15;
    end

    properties(SetObservable=true,AffectsDataLimits,NeverAmbiguous)
        TRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent)
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle;
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive;
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor;
        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle;
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive;
    end

    properties(Dependent,AffectsDataLimits)
        TRange;
        XFunction;
        YFunction;
        ZFunction;
    end

    properties(Dependent,AffectsObject)
        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor;
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor;
    end

    properties(Hidden,AffectsLegend,AffectsObject)
        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,1];
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden,AffectsObject)
        AdaptiveMeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=6;
    end

    properties(Hidden,Dependent,Access=private)
ImplicitFunction
    end

    properties(Hidden,Access=private)
        TRange_I=[-5,5];
XFunction_I
YFunction_I
ZFunction_I
DataTipIndices
TData
    end

    properties(Transient,SetAccess=private)
        XData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
        YData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
        ZData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    properties(Transient,Hidden,DeepCopy,AffectsObject)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
        MarkerHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(Transient,Access=public,Hidden,NonCopyable)
        Edge matlab.graphics.primitive.world.LineStrip
    end

    properties(Transient,Access=private)
XFunction_fh_I
YFunction_fh_I
ZFunction_fh_I
        XYZCache;
    end

    properties(AffectsObject,AbortSet,SetAccess='public',GetAccess='public',NeverAmbiguous)
        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function hObj=ParameterizedFunctionLine(fnx,fny,fnz,varargin)
            hObj.Edge=matlab.graphics.primitive.world.LineStrip;
            hObj.Edge.ColorData=uint8(255*[hObj.Color,1]).';
            hObj.Edge.ColorBinding='object';
            hObj.Edge.LineWidth=hObj.LineWidth;
            hObj.Edge.Internal=true;
            hObj.addNode(hObj.Edge);

            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker;
            hObj.MarkerHandle.Description_I='ParameterizedFunctionLine MarkerHandle';
            hObj.MarkerHandle.LineWidth_I=hObj.LineWidth;
            hObj.MarkerHandle.Internal=true;
            hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker);

            hObj.DataTipIndices=struct('t',{},'x',{},'y',{},'z',{});

            hObj.Type='parameterizedfunctionline';

            hObj.addDependencyConsumed({'xyzdatalimits','dataspace','view',...
            'colororder_linestyleorder'});



            setInteractionHint(hObj,'DataBrushing',false);

            if nargin<1
                return;
            end

            hObj.DisplayNameMode='manual';
            hObj.XFunction=fnx;
            hObj.YFunction=fny;
            hObj.ZFunction=fnz;

            hObj.DisplayNameMode='auto';
            hObj.updateDisplayName;

            inargs=struct(varargin{:});

            if isfield(inargs,'Parent')
                hObj.Parent=inargs.Parent;
                inargs=rmfield(inargs,'Parent');
            end

            incell=struct2nvpairs(inargs);
            if~isempty(incell)
                set(hObj,incell{:});
            end
        end

        function v=get.XFunction(hObj)
            v=hObj.XFunction_I;
        end

        function set.XFunction(hObj,fn)
            if nvars(fn)>1
                error(message('MATLAB:handle_graphics:FunctionLine:TooManyVariables'));
            end
            if isImplicit(fn)
                error(message('MATLAB:handle_graphics:FunctionLine:Implicit','XFunction'));
            end
            hObj.XFunction_I=fn;
        end

        function set.XFunction_I(hObj,fn)
            if isa(fn,'sym')
                fn=saveobj(fn);
            end
            hObj.XFunction_I=fn;
            hObj.XFunction_fh_I=getFunction(fn,hObj.TRange);
            hObj.updateDisplayName;
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function v=get.YFunction(hObj)
            v=hObj.YFunction_I;
        end

        function set.YFunction(hObj,fn)
            if nvars(fn)>1
                error(message('MATLAB:handle_graphics:FunctionLine:TooManyVariables'));
            end
            if isImplicit(fn)
                error(message('MATLAB:handle_graphics:FunctionLine:Implicit','YFunction'));
            end
            hObj.YFunction_I=fn;
        end

        function set.YFunction_I(hObj,fn)
            if isa(fn,'sym')
                fn=saveobj(fn);
            end
            hObj.YFunction_I=fn;
            hObj.YFunction_fh_I=getFunction(fn,hObj.TRange);
            hObj.updateDisplayName;
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function v=get.ZFunction(hObj)
            v=hObj.ZFunction_I;
        end

        function set.ZFunction(hObj,fn)
            if nvars(fn)>1
                error(message('MATLAB:handle_graphics:FunctionLine:TooManyVariables'));
            end
            if isImplicit(fn)
                error(message('MATLAB:handle_graphics:FunctionLine:Implicit','ZFunction'));
            end
            hObj.ZFunction_I=fn;
        end

        function set.ZFunction_I(hObj,fn)
            hObj.ZFunction_I=fn;
            if isempty(fn)
                hObj.ZFunction_fh_I=@(x)0;
            else
                hObj.ZFunction_fh_I=getFunction(fn,hObj.TRange);
            end
            hObj.updateDisplayName;
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function set.MeshDensity(hObj,val)
            hObj.MeshDensity=val;
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function set.AdaptiveMeshDensity(hObj,val)
            hObj.AdaptiveMeshDensity=val;
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function val=get.MarkerEdgeColor(hObj)
            val=hObj.MarkerEdgeColor_I;
        end

        function set.MarkerEdgeColor(hObj,val)
            hObj.MarkerEdgeColorMode='manual';
            hObj.MarkerEdgeColor_I=val;
            hObj.clearXYZCache;
        end

        function val=get.MarkerFaceColor(hObj)
            val=hObj.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor(hObj,val)
            hObj.MarkerFaceColorMode='manual';
            hObj.MarkerFaceColor_I=val;
            hObj.clearXYZCache;
        end

        function val=get.MarkerSize(hObj)
            val=hObj.MarkerSize_I;
        end

        function set.MarkerSize(hObj,val)
            hObj.MarkerSize_I=val;
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
            hObj.clearXYZCache;
        end

        function val=get.TRange(hObj)
            val=hObj.TRange_I;
        end

        function set.TRange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.TRangeMode='manual';
            hObj.TRange_I=lim;
            hObj.clearXYZCache;
            hObj.sendDataChangedEvent();
        end

        function val=get.LineStyle(hObj)
            val=hObj.LineStyle_I;
        end

        function set.LineStyle(hObj,style)
            hObj.LineStyle_I=style;
            hObj.LineStyleMode='manual';
        end

        function set.LineStyle_I(hObj,style)
            hObj.LineStyle_I=style;
            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,style);
        end

        function val=get.LineWidth(hObj)
            val=hObj.LineWidth_I;
        end

        function set.LineWidth(hObj,width)
            hObj.LineWidth_I=width;
        end

        function set.LineWidth_I(hObj,width)
            hObj.LineWidth_I=width;
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

        function storedValue=get.Color_I(hObj)
            storedValue=hObj.Color_I;
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

        function vbox=getXYZDataExtents(hObj,transformation,infoStruct)
            data=hObj.getXYZData(hObj.getDataSpace(),infoStruct);
            xyzdata=[data.xdata;data.ydata;data.zdata;ones(size(data.xdata))];
            xyzdata=transformation*xyzdata;
            xyzdata=xyzdata(1:3,:)./xyzdata(4,:);
            xrange=matlab.graphics.function.internal.estimateViewingBox(xyzdata(1,:),-inf,inf,false);
            yrange=matlab.graphics.function.internal.estimateViewingBox(xyzdata(2,:),-inf,inf,false);
            zrange=matlab.graphics.function.internal.estimateViewingBox(xyzdata(3,:),-inf,inf,false);
            vbox=[xrange;yrange;zrange];
        end

        function xd=get.XData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace());
            xd=data.xdata;
        end

        function yd=get.YData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace());
            yd=data.ydata;
        end

        function yd=get.ZData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace());
            yd=data.zdata;
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

            hObj.clearXYZCache;
            data=hObj.getXYZData(us);

            hObj.TData=data.tdata;

            if isempty(data.LineVertices)
                xdata=data.xdata;
                ydata=data.ydata;
                zdata=data.zdata;

                if sum(isfinite(xdata))<2
                    xdata=zeros(0,1,'single');
                    ydata=zeros(0,1,'single');
                    zdata=zeros(0,1,'single');
                end

                piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

                piter.XData=xdata;
                piter.YData=ydata;
                piter.ZData=zdata;

                vd=TransformPoints(us.DataSpace,...
                us.TransformUnderDataSpace,...
                piter);

                edge=hObj.Edge;
                edge.VertexData=vd;

                separateHere=union(data.poles,data.invalidInScale);
                counts=histcounts(data.tdata,[-inf,separateHere(:).',inf]);
                sd=uint32([1,1+cumsum(counts(counts>0))]);
                edge.StripData=sd;
            else
                edge=hObj.Edge;
                edge.VertexData=data.LineVertices;
                edge.StripData=data.LineStripData;
            end


            piter_coarse=matlab.graphics.axis.dataspace.XYZPointsIterator;

            piter_coarse.XData=data.xdata_coarse;
            piter_coarse.YData=data.ydata_coarse;
            piter_coarse.ZData=data.zdata_coarse;

            vd_coarse=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter_coarse);

            hObj.MarkerHandle.VertexData=single(vd_coarse);

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


        function dataTipRows=createDefaultDataTipRows(hObj)
            dataTipRows=[...
            dataTipTextRow('T','TData');...
            dataTipTextRow('X','XData');...
            dataTipTextRow('Y','YData')];
            if~isempty(hObj.ZFunction)
                dataTipRows=[dataTipRows;...
                dataTipTextRow('Z','ZData')];
            end
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            if numel(hObj.DataTipIndices)>=dataIndex
                location=hObj.cacheLookup(dataIndex);
            else
                location=struct('x','','y','','z','','t','');
            end
            switch(valueSource)
            case 'XData'
                coordinateData=CoordinateData('XData',location.x);
            case 'YData'
                coordinateData=CoordinateData('YData',location.y);
            case 'ZData'
                coordinateData=CoordinateData('ZData',location.z);
            case 'TData'
                coordinateData=CoordinateData('TData',location.t);
            end
        end


        function valueSources=getAllValidValueSources(~)
            valueSources=["TData","XData","YData","ZData"];
        end

        mcodeConstructor(hObj,code)
    end

    methods(Access=protected)
        function clearXYZCache(hObj)
            hObj.XYZCache=[];
        end

        function updateDisplayName(hObj)
            if strcmp(hObj.DisplayNameMode,'auto')
                xStruct=hObj.displayNames(hObj.XFunction);
                yStruct=hObj.displayNames(hObj.YFunction);
                if isempty(hObj.ZFunction)
                    xyzStruct=xStruct;
                    for field=string(fieldnames(xyzStruct)).'
                        xyzStruct.(field)="["+join([string(xStruct.(field)),yStruct.(field)],",")+"]";
                    end
                else
                    zStruct=hObj.displayNames(hObj.ZFunction);

                    xyzStruct=xStruct;
                    for field=string(fieldnames(xyzStruct)).'
                        xyzStruct.(field)="["+...
                        join([string(xStruct.(field)),yStruct.(field),zStruct.(field)],",")+"]";
                    end
                end

                hObj.DisplayName_I_ByInterpreter=xyzStruct;
                hObj.DisplayName=xyzStruct.tex;
                hObj.DisplayNameMode='auto';
            else
                hObj.DisplayName_I_ByInterpreter=struct;
            end
        end

        function group=getPropertyGroups(hObj)
            show={'XFunction','YFunction'};
            if~isempty(hObj.ZFunction)
                show=[show,{'ZFunction'}];
            end
            if strcmp(hObj.TRangeMode,'manual')
                show=[show,{'TRange'}];
            end
            show=[show,{'Color','LineStyle','LineWidth'}];
            group=matlab.mixin.util.PropertyGroup(show);
        end

        function index=getCacheFor(hObj,t,x,y,z)
            index=find([hObj.DataTipIndices.t]==t&[hObj.DataTipIndices.x]==x...
            &[hObj.DataTipIndices.y]==y&[hObj.DataTipIndices.z]==z);
            if isempty(index)
                index=numel(hObj.DataTipIndices)+1;
                hObj.DataTipIndices(index).t=t;
                hObj.DataTipIndices(index).x=x;
                hObj.DataTipIndices(index).y=y;
                hObj.DataTipIndices(index).z=z;
            end
        end

        function pos=cacheLookup(hObj,index)

            if numel(hObj.DataTipIndices)<index
                pos.x=NaN;
                pos.y=NaN;
                pos.z=NaN;
                return;
            end
            pos=hObj.DataTipIndices(index);
            tVerts=hObj.TData;
            if pos.t>=min(tVerts)&&pos.t<=max(tVerts)

                if isempty(hObj.XFunction_fh_I)||isempty(hObj.YFunction_fh_I)||isempty(hObj.ZFunction_fh_I)
                    hObj.updateFunctionHandles;
                end
                pos.x=hObj.XFunction_fh_I(pos.t);
                pos.y=hObj.YFunction_fh_I(pos.t);
                pos.z=hObj.ZFunction_fh_I(pos.t);
            else
                pos.x=NaN;
                pos.y=NaN;
                pos.z=NaN;
            end
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            point=hObj.cacheLookup(index);

            if isempty(hObj.ZFunction)
                descriptors=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('T',point.t),...
                matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',point.x),...
                matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',point.y)];
            else
                descriptors=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('T',point.t),...
                matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',point.x),...
                matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',point.y),...
                matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Z',point.z)];
            end
        end

        function index=doGetNearestIndex(~,index)
        end

        function[index,interp]=doIncrementIndex(~,index,~,~)

            interp=0;
        end

        function index=doGetNearestPoint(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            pts=hObj.getXYZData(hObj.getDataSpace());
            pointIndex=pickUtils.nearestPoint(hObj,position,true,[pts.xdata;pts.ydata;pts.zdata].');
            index=hObj.getCacheFor(pts.tdata(pointIndex),pts.xdata(pointIndex),pts.ydata(pointIndex),pts.zdata(pointIndex));
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            pts=hObj.getXYZData(hObj.getDataSpace());
            pointIndex=pickUtils.nearestPoint(hObj,position,false,[pts.xdata;pts.ydata;pts.zdata].');
            index=hObj.getCacheFor(pts.tdata(pointIndex),pts.xdata(pointIndex),pts.ydata(pointIndex),pts.zdata(pointIndex));
            interpolationFactor=0;
        end

        function points=doGetEnclosedPoints(~,~)
            points=[];
        end

        function point=doGetDisplayAnchorPoint(hObj,index,~)
            pos=hObj.cacheLookup(index);
            point=matlab.graphics.shape.internal.util.SimplePoint(...
            double([pos.x,pos.y,pos.z]));
        end

        function point=doGetReportedPosition(hObj,index,interpolationFactor)
            point=doGetDisplayAnchorPoint(hObj,index,interpolationFactor);
        end
    end

    methods(Access={?tfplot3,?tfplot})

        function pos=preparePointNear(hObj,pos)
            pos=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,pos.');
            index=hObj.doGetNearestPoint(pos.');
            pos=hObj.cacheLookup(index);
            pos=[pos.x,pos.y,pos.z];
        end
    end

    methods(Access='private')
        data=calcXYZData(hObj,us,infoStruct)

        function data=getXYZData(hObj,us,infoStruct)
            if nargin<3


                ds=us;
                if isa(us,'matlab.graphics.eventdata.UpdateState')
                    ds=us.DataSpace;
                end
                infoStruct=struct('XConstraints',ds.XLim,...
                'YConstraints',ds.YLim,...
                'ZConstraints',ds.ZLim);
            end

            if isempty(hObj.XYZCache)||~isequal(hObj.XYZCache{1},us)
                hObj.XYZCache={us,hObj.calcXYZData(us,infoStruct)};
            end
            data=hObj.XYZCache{2};
        end

        function createSelectionHandle(hObj)

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
            hObj.addNode(hObj.SelectionHandle);


            hObj.SelectionHandle.Description='ParameterizedLine SelectionHandle';


        end
        function ds=getDataSpace(hObj)
            ds=ancestor(hObj,'matlab.graphics.axis.dataspace.DataSpace','node');
        end

        function updateFunctionHandles(hObj)
            hObj.XFunction_fh_I=getFunction(hObj.XFunction,hObj.TRange);
            hObj.YFunction_fh_I=getFunction(hObj.YFunction,hObj.TRange);
            if isempty(hObj.ZFunction)
                hObj.ZFunction_fh_I=@(x)0*x;
            else
                hObj.ZFunction_fh_I=getFunction(hObj.ZFunction,hObj.TRange);
            end
        end
    end
end

function nv=struct2nvpairs(x)

    n=fieldnames(x);
    v=struct2cell(x);
    nv=[n,v]';
end

function fn=getFunction(fnIn,range)
    if isempty(fnIn)
        fn=@(x)x;
    elseif isa(fnIn,'sym')
        fn=matlab.graphics.function.internal.sym2fn(fnIn);
    elseif isnumeric(fnIn)&&isscalar(fnIn)
        fn=@(x)fnIn.*ones(size(x));
    elseif isa(fnIn,'char')
        fn=matlab.graphics.chart.internal.ezfcnchk(fnIn);
        fn=@(x)double(feval(fn,x));
    else
        fn=@(x)double(feval(fnIn,x));
    end


    testvalues=linspace(range(1),range(end),3);
    vectorError=false;
    scalarError=false;
    try
        fnX=fn(testvalues);
    catch
        vectorError=true;
    end
    try
        fnXScalar=arrayfun(fn,testvalues);
    catch
        scalarError=true;
    end

    if vectorError
        good=scalarError;
    else
        good=~scalarError&&isequaln(fnX,fnXScalar);
    end

    if~good
        if~isa(fnIn,'sym')
            warning(message('MATLAB:fplot:NotVectorized'));
        end
        fn=@(x)arrayfun(fn,x);
    end
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

function b=isImplicit(fn)
    if isa(fn,'function_handle')
        b=any(char(fn)=='=');
    elseif isa(fn,'sym')
        b=sym.isCondition(fn);
    else
        b=false;
    end
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropSetClsMismatch','%s',message('MATLAB:type:PropSetClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
