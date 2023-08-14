classdef(ConstructOnLoad,Sealed)FunctionLine<...
    matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&...
    matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.function.mixin.Legendable&...
    matlab.graphics.chart.interaction.DataAnnotatable&...
    matlab.graphics.mixin.ColorOrderUser






    properties(SetObservable=true,AffectsObject)
        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
        ShowPoles matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
        MeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=23;
    end

    properties(NeverAmbiguous)
        XRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent,AffectsLegend)
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor;
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle;
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor;
    end

    properties(Dependent,AffectsObject)
        Function;
        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle;
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive;
        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor;
    end

    properties(Dependent,AffectsDataLimits)
        XRange;
    end

    properties(Hidden,AffectsLegend,AffectsObject)
        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,1];
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
    end

    properties(Hidden)

        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden,AffectsObject)
        AdaptiveMeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=10;
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
    end

    properties(Transient,SetAccess=private)
        XData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
        YData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
        ZData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    properties(Hidden,Access=private)
        XRange_I=[-5,5];
        Function_I;
        DataTipIndices;
        FunctionPoleCache={};
        FunctionDerivativePoleCache={};
    end

    properties(Transient,Hidden,Access=private)
        ExtentsMarkedCleanListener event.listener;
        ExtentsMarkedCleanListenerUpdating(1,1)logical=false;
        XLimitsUsedForExtents;
    end

    properties(InternalComponent,Transient,Access=public,Hidden,DeepCopy)
        MarkerHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(Transient,Access=public,Hidden,DeepCopy,AffectsObject)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(InternalComponent,Transient,Access=public,Hidden,NonCopyable)
        Edge matlab.graphics.primitive.world.LineStrip
        VerticalAsymptoteEdges matlab.graphics.primitive.world.LineStrip
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
        function hObj=FunctionLine(fn,varargin)
            hObj.Edge=matlab.graphics.primitive.world.LineStrip;
            hObj.Edge.ColorData=uint8(255*[hObj.Color,1]).';
            hObj.Edge.ColorBinding='object';
            hObj.Edge.LineWidth_I=hObj.LineWidth;
            hObj.Edge.Internal=true;

            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker;
            hObj.MarkerHandle.Description_I='FunctionLine MarkerHandle';
            hObj.MarkerHandle.LineWidth_I=hObj.LineWidth;
            hObj.MarkerHandle.Internal=true;
            hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker);

            hObj.VerticalAsymptoteEdges=matlab.graphics.primitive.world.LineStrip;
            hObj.VerticalAsymptoteEdges.Visible='off';
            hObj.VerticalAsymptoteEdges.LineStyle='dashed';
            hObj.VerticalAsymptoteEdges.ColorData=uint8(255*[0.5,0.5,0.5,1]).';
            hObj.VerticalAsymptoteEdges.ColorBinding='object';
            hObj.VerticalAsymptoteEdges.LineWidth_I=hObj.LineWidth;
            hObj.VerticalAsymptoteEdges.Internal=true;
            hObj.VerticalAsymptoteEdges.AlignVertexCenters='on';


            hObj.DataTipIndices=struct('x',{},'y',{});

            hObj.Type='functionline';

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
            if nvars(fn)>1
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
            hObj.FunctionPoleCache={};
            hObj.FunctionDerivativePoleCache={};
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
            passObj=hObj.MarkerHandle;
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
            hObj.MarkerHandle=val;
            hObj.markLegendEntryDirty;
        end


        function val=get.XRange(hObj)
            if strcmp(hObj.XRangeMode,'manual')
                val=hObj.XRange_I;
                return;
            end





            if hObj.XLimInclude=="off"
                val=hObj.getAxesAncestor.XLim_I;
                return
            end


            try
                forceFullUpdate(hObj,'all','XRange');
            catch
            end

            poles=hObj.findPoles;
            poles=1.1*poles;
            val=[min([hObj.XRange_I(1),poles]),max([hObj.XRange_I(2),poles])];
            if isa(hObj.Function,'sym')
                t=symvar(hObj.Function,1);
                if~isempty(t)
                    assumptionLimits=double(feval_internal(symengine,'op@Re@hull@getprop',...
                    t,'"Constant"=TRUE, "Targets"={Dom::Interval}, "StrictTargets"=TRUE'));
                    val=[max([val(1),assumptionLimits(1)]),min([val(2),assumptionLimits(2)])];
                end
            end
        end

        function set.XRange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.XRangeMode='manual';
            hObj.XRange_I=lim;
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
            for fanChild=[hObj.MarkerHandle,hObj.VerticalAsymptoteEdges]
                if~isempty(fanChild)&&isvalid(fanChild)
                    if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                        set(fanChild,'LineWidth_I',width);
                    end
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

        function set.ShowPoles(hObj,val)
            hObj.ShowPoles=val;

            if~isempty(hObj.VerticalAsymptoteEdges.StripData)
                hObj.VerticalAsymptoteEdges.Visible=val;
            end
        end

        function set.SelectionHandle(hObj,newValue)
            hObj.SelectionHandle=newValue;
            hObj.clearXYZCache;
        end

        function vbox=getXYZDataExtents(hObj,transformation,~)
            ax=hObj.getAxesAncestor();
            data=hObj.getXYZData(hObj.getTlim,ax,transformation);
            vbox=data.vbox;
            vbox([hObj.XLimInclude=="off",hObj.YLimInclude=="off",hObj.ZLimInclude=="off"],:)=NaN;




            if hObj.XLimInclude=="off"
                hObj.XLimitsUsedForExtents=ax.DataSpace.XLim_I;

                if isempty(hObj.ExtentsMarkedCleanListener)



                    hObj.ExtentsMarkedCleanListener=event.listener(hObj,'MarkedClean',@(e,d)hObj.maybeUpdateIfLimitsChange);
                end
            else
                delete(hObj.ExtentsMarkedCleanListener)
                hObj.ExtentsMarkedCleanListener=event.listener.empty;
            end
        end

        function xd=get.XData(hObj)
            data=hObj.getXYZData(hObj.getTlim,hObj.getAxesAncestor());
            xd=data.xdata;
        end

        function yd=get.YData(hObj)
            data=hObj.getXYZData(hObj.getTlim,hObj.getAxesAncestor());
            yd=data.ydata;
        end

        function yd=get.ZData(hObj)
            data=hObj.getXYZData(hObj.getTlim,hObj.getAxesAncestor());
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

            hObj.XYZCache=[];
            data=hObj.getXYZData(hObj.getTlim(us.DataSpace),us);

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
                counts=histcounts(xdata,[-inf,separateHere(:).',inf]);
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

            poles=data.poles;

            if~isempty(data.vbox)&&numel(poles)>1
                mindist=(data.vbox(1,2)-data.vbox(1,1))/100;
                removePoles=logical([false,arrayfun(@(i)poles(i)-poles(i-1)<mindist,2:numel(poles))]);
                poles(removePoles)=[];
            end

            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

            piter.XData=reshape([poles;poles],1,[]);
            piter.YData=repmat(us.DataSpace.YLim,1,numel(poles));
            piter.ZData=repmat(1,1,2*numel(poles));

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);


            hObj.VerticalAsymptoteEdges.VertexData=vd;
            hObj.VerticalAsymptoteEdges.VertexIndices=uint32(1:(2*numel(poles)));
            hObj.VerticalAsymptoteEdges.StripData=uint32(1:2:(2*numel(poles)+1));

            if isempty(poles)
                hObj.VerticalAsymptoteEdges.Visible='off';
            else
                hObj.VerticalAsymptoteEdges.Visible=hObj.ShowPoles;
            end

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
                if isempty(hObj.SelectionHandle.NodeParent)
                    hObj.addNode(hObj.SelectionHandle);
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
                [location,isPole]=hObj.cacheLookup(dataIndex);
            else
                location=struct('x','','y','');
            end
            switch(valueSource)
            case 'XData'
                coordinateData=CoordinateData('XData',location.x);
            case 'YData'
                if isPole
                    coordinateData=CoordinateData('YData','');
                else
                    coordinateData=CoordinateData('YData',location.y);
                end
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
            show=[show,{'Color','LineStyle','LineWidth'}];
            group=matlab.mixin.util.PropertyGroup(show);
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            [point,isPole]=hObj.cacheLookup(index);
            if isPole
                descriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',point.x);
            else
                descriptors=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',point.x),...
                matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',point.y)];
            end
        end

        function index=doGetNearestIndex(~,index)
        end

        function[index,interp]=doIncrementIndex(~,index,~,~)

            interp=0;
        end

        function index=doGetNearestPoint(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            pts=hObj.getXYZData(hObj.getTlim,hObj.getAxesAncestor());

            numActualPoints=numel(pts.xdata);
            poles=pts.poles;
            ptsXYZ=[pts.xdata;pts.ydata;pts.zdata].';
            yForPoles=unique(pts.ydata);
            yForPoles=reshape(yForPoles,[],1);
            xForPoles=repmat(poles,1,numel(yForPoles)).';
            yForPoles=repmat(yForPoles,numel(poles),1);
            ptsXYZ=[ptsXYZ;[xForPoles,yForPoles,repmat(1,numel(xForPoles),1)]];
            pointIndex=pickUtils.nearestPoint(hObj,position,true,ptsXYZ);
            index=hObj.getCacheFor(ptsXYZ(pointIndex,1),ptsXYZ(pointIndex,2),poles);
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
            interpolationFactor=0;
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            pts=hObj.getXYZData(hObj.getTlim,hObj.getAxesAncestor());

            numActualPoints=numel(pts.xdata);
            poles=pts.poles;
            ptsXYZ=[pts.xdata;pts.ydata;pts.zdata].';
            yForPoles=unique(pts.ydata);
            yForPoles=reshape(yForPoles,[],1);
            xForPoles=repmat(poles,1,numel(yForPoles)).';
            yForPoles=repmat(yForPoles,numel(poles),1);
            ptsXYZ=[ptsXYZ;[xForPoles,yForPoles,repmat(1,numel(xForPoles),1)]];
            pointIndex=pickUtils.nearestPoint(hObj,position,false,ptsXYZ);
            index=hObj.getCacheFor(ptsXYZ(pointIndex,1),ptsXYZ(pointIndex,2),poles);
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end


        function indices=doGetEnclosedPoints(hObj,polygon)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            pts=hObj.getXYZData(hObj.getTlim,hObj.getAxesAncestor());
            localIndices=pickUtils.enclosedPoints(hObj,polygon,[pts.xdata;pts.ydata;pts.zdata].');
            indices=arrayfun(@(i)hObj.getCacheFor(pts.xdata(i),pts.ydata(2,i),pts.poles),localIndices);
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

    methods(Access=?tfplot)

        function pos=preparePointNear(hObj,pos)
            pos=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,pos.');
            index=hObj.doGetNearestPoint(pos.');
            pos=hObj.cacheLookup(index);
            pos=[pos.x,pos.y,0];
        end
    end

    methods(Access='private')
        data=calcXYZData(hObj,xlims,us,transformation)

        function data=getXYZData(hObj,xlims,us,transformation)
            if nargin<4
                transformation=eye(4);
            end


            ds=[];
            if~isempty(us)
                ds=us.DataSpace;
                if nargin<3&&~isempty(findprop(us,'Transform'))
                    transformation=us.Transform;
                end
                ds={ds.XLim,ds.XLimMode,ds.XScale,...
                ds.YLim,ds.YLimMode,ds.YScale,...
                ds.ZLim,ds.ZLimMode,ds.ZScale,...
                transformation};
            end

            if isempty(hObj.XYZCache)||~isequal(hObj.XYZCache{1},{xlims,ds})
                hObj.XYZCache={{xlims,ds},hObj.calcXYZData(xlims,us,transformation)};
            end
            data=hObj.XYZCache{2};
        end

        function updateFunction(hObj)
            hObj.Function_fh_I=getFunction(hObj.Function_I,hObj.XRange);
            if strcmp(hObj.DisplayNameMode,'auto')
                hObj.DisplayName_I_ByInterpreter=hObj.displayNames(hObj.Function_I);
                hObj.DisplayName=hObj.DisplayName_I_ByInterpreter.tex;
                hObj.DisplayNameMode='auto';
            else
                hObj.DisplayName_I_ByInterpreter=struct;
            end
        end

        function poles=findPoles(hObj)
            fn=hObj.Function;
            if isa(fn,'sym')
                x=symvar(fn,1);
                if isempty(x)
                    poles=[];
                    return;
                end
                eng=symengine;
                sympoles=feval_internal(eng,'poles',fn,x);
                tp=feval_internal(eng,'domtype',sympoles);
                poles=[];
                if strcmp(char(tp),'DOM_SET')
                    sympoles=feval_internal(eng,'_intersect',sympoles,'R_');
                    [Xstr,err]=feval_internal(eng,'symobj::double',sympoles);
                    if err==0
                        poles=eval(Xstr);
                    end
                end
            else
                poles=[];
            end
        end

        function xlim=getTlim(hObj,ds,transformation)
            if nargin<2
                ds=hObj.getAxesAncestor();
            end
            if nargin<3
                transformation=eye(4);
                p=hObj.Parent;
                while~isempty(p)&&~isequal(p.Type,'axes')
                    if isequal(p.Type,'hgtransform')
                        transformation=p.Matrix*transformation;
                    end
                    p=p.Parent;
                end
            end
            xlim=[-inf,inf];
            try
                if~(isa(ds,'matlab.graphics.axis.AbstractAxes')&&strcmp(ds.XLimMode,'auto'))

                    xlim=ds.XLim_I;
                    ylim=ds.YLim_I;
                    zlim=ds.ZLim_I;
                    transformedLimits=transformation\[xlim;ylim;zlim;1,1];
                    xlim=sort(transformedLimits(1,:));
                end
            catch
                xlim=[-inf,inf];
            end
            if strcmp(hObj.XRangeMode,'manual')||isequal(xlim,[-inf,inf])
                xlim(1)=max([xlim(1),hObj.XRange(1)]);
                xlim(2)=min([xlim(2),hObj.XRange(2)]);
            end

            if strcmp(hObj.XRangeMode,'auto')
                hObj.XRange_I=xlim;
            end
        end

        function index=getCacheFor(hObj,x,y,poles)
            index=find([hObj.DataTipIndices.x]==x&([hObj.DataTipIndices.y]==y|ismember(x,poles)));
            if isempty(index)
                index=numel(hObj.DataTipIndices)+1;
                hObj.DataTipIndices(index).x=x;
                hObj.DataTipIndices(index).y=y;
            end
        end

        function[pos,isPole]=cacheLookup(hObj,index)

            if numel(hObj.DataTipIndices)<index
                isPole=false;
                pos.x=NaN;
                pos.y=NaN;
                return;
            end
            pos=hObj.DataTipIndices(index);
            ax=hObj.getAxesAncestor();
            pts=hObj.getXYZData(hObj.getTlim,ax);
            xVerts=pts.xdata;



            if~isempty(xVerts)&&pos.x>=min(xVerts)&&pos.x<=max(xVerts)

                if isempty(hObj.Function_fh_I)
                    hObj.updateFunction;
                end

                xrange=ax.DataSpace.XLim;
                if ax.DataSpace.XScale=="log"
                    xdelta=log(xrange(2)/xrange(1))/100;
                    mindist=min(abs(real(log(pos.x./pts.poles))));
                else
                    xdelta=(xrange(2)-xrange(1))/100;
                    mindist=min(abs(pos.x-pts.poles));
                end
                if mindist<xdelta
                    isPole=true;
                    yrange=ax.DataSpace.YLim;
                    if ax.DataSpace.YScale=="log"
                        pos.y=sign(yrange(1))*exp(sum(log(yrange))/2);
                    else
                        pos.y=(yrange(1)+yrange(2))/2;
                    end
                else
                    isPole=false;
                    pos.y=hObj.Function_fh_I(pos.x);
                end
            else
                isPole=false;
                pos.x=NaN;
                pos.y=NaN;
            end
        end

        function createSelectionHandle(hObj)

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);


            hObj.SelectionHandle.Description='FunctionLine SelectionHandle';


        end

        function ax=getAxesAncestor(hObj)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
        end

        function maybeUpdateIfLimitsChange(hObj)



            ax=hObj.getAxesAncestor;
            xLimsUsedForExtents=hObj.XLimitsUsedForExtents;
            xLim=ax.DataSpace.XLim;





            if~hObj.ExtentsMarkedCleanListenerUpdating&&...
                ~isempty(xLimsUsedForExtents)&&...
                all(abs(xLimsUsedForExtents-xLim)>max(diff(xLim)*.05,eps(single(xLimsUsedForExtents))))



                hObj.ExtentsMarkedCleanListenerUpdating=true;


                hObj.MarkDirty('all');
            elseif hObj.ExtentsMarkedCleanListenerUpdating



                hObj.ExtentsMarkedCleanListenerUpdating=false;
            end
        end
    end
end

function fn=getFunction(fnIn,range)
    fn=fnIn;
    if isempty(fnIn)
        fn=@(x)x;
    elseif isa(fnIn,'sym')
        fn=matlab.graphics.function.internal.sym2fn(fnIn);
    elseif isnumeric(fnIn)&&isscalar(fnIn)
        fn=@(x)fnIn.*ones(size(x));
    end
    fn=matlab.graphics.chart.internal.ezfcnchk(fn);


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

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropSetClsMismatch','%s',message('MATLAB:type:PropSetClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
