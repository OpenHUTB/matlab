classdef(ConstructOnLoad,Sealed)ImplicitFunctionSurface<...
    matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&...
    matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.function.mixin.Legendable&...
    matlab.graphics.chart.interaction.DataAnnotatable




    properties
        MeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=35;
        FaceAlpha matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=1.0;
    end

    properties(NeverAmbiguous)
        XRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        YRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        ZRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent)
        XRange;
        YRange;
        ZRange;
        Function;
        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBInterpNoneColor;
        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBInterpNoneColor;
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
        AmbientStrength matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=0.3;
        DiffuseStrength matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=0.6;
        SpecularStrength matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=0.9;
        SpecularExponent matlab.internal.datatype.matlab.graphics.datatype.Positive=10;
        SpecularColorReflectance matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=1;
    end

    properties(Hidden,Dependent)
        Triangulation;
    end

    properties(Hidden)
        AdaptiveMeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=4;
        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBInterpNoneColor='interp';
        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBInterpNoneColor=[0,0,0];
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Hidden,Access=private)
        Function_I;
        XRange_I=[-5,5];
        YRange_I=[-5,5];
        ZRange_I=[-5,5];
        DataTipIndices;
    end

    properties(Transient,Access=private)
        Function_fh_I;
    end

    properties(Transient,Hidden,DeepCopy)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
        MarkerHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(Transient,Access=public,Hidden,NonCopyable)
        Edge matlab.graphics.primitive.world.LineStrip;
        Faces matlab.graphics.primitive.world.TriangleStrip;
        XYZCache;
    end

    methods
        function hObj=ImplicitFunctionSurface(fn,varargin)
            hObj.Faces=matlab.graphics.primitive.world.TriangleStrip;
            if~isequal(hObj.FaceColor,'interp')
                hgfilter('RGBAColorToGeometryPrimitive',hObj.Faces,hObj.FaceColor);
            end
            hObj.Faces.TwoSidedLighting='on';
            hObj.Faces.AmbientStrength=hObj.AmbientStrength;
            hObj.Faces.DiffuseStrength=hObj.DiffuseStrength;
            hObj.Faces.SpecularStrength=hObj.SpecularStrength;
            hObj.Faces.SpecularExponent=hObj.SpecularExponent;
            hObj.Faces.SpecularColorReflectance=hObj.SpecularColorReflectance;
            hObj.Faces.Internal=true;
            hObj.addNode(hObj.Faces);

            hObj.Edge=matlab.graphics.primitive.world.LineStrip;
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,hObj.EdgeColor);
            hObj.Edge.LineWidth=hObj.LineWidth;
            hObj.Edge.Internal=true;
            hObj.addNode(hObj.Edge);

            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker;
            hObj.MarkerHandle.Description_I='ImplicitFunctionSurface MarkerHandle';
            hObj.MarkerHandle.LineWidth_I=hObj.LineWidth;
            hObj.MarkerHandle.Internal=true;
            hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker);

            hObj.DataTipIndices=struct('x',{},'y',{},'z',{});

            hObj.Type='implicitfunctionsurface';

            hObj.addDependencyConsumed({'xyzdatalimits','dataspace','figurecolormap','colorspace'});








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

        function set.Function(hObj,fn)
            if isa(fn,'sym')
                fn=saveobj(fn);
            end
            hObj.Function_I=fn;
        end

        function set.Function_I(hObj,fn)
            hObj.Function_I=fn;
            hObj.updateFunction;
            hObj.MarkDirty('limits');
        end

        function v=get.Function(hObj)
            v=hObj.Function_I;
        end

        function set.MeshDensity(hObj,val)
            hObj.MeshDensity=val;
            hObj.MarkDirty('limits');
        end

        function set.AdaptiveMeshDensity(hObj,val)
            hObj.AdaptiveMeshDensity=val;
            hObj.MarkDirty('limits');
        end

        function val=get.MarkerEdgeColor(hObj)
            val=hObj.MarkerEdgeColor_I;
        end

        function set.MarkerEdgeColor(hObj,val)
            hObj.MarkerEdgeColorMode='manual';
            hObj.MarkerEdgeColor_I=val;
            hObj.MarkDirty('all');
        end

        function val=get.MarkerFaceColor(hObj)
            val=hObj.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor(hObj,val)
            hObj.MarkerFaceColorMode='manual';
            hObj.MarkerFaceColor_I=val;
            hObj.MarkDirty('all');
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
        end

        function set.Marker_I(hObj,val)
            hObj.Marker_I=val;
            fanChild=hObj.MarkerHandle;
            if~isempty(fanChild)&&isvalid(fanChild)
                hgfilter('MarkerStyleToPrimMarkerStyle',fanChild,val);
            end

            hObj.markLegendEntryDirty;
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
            hObj.MarkDirty('all');
        end

        function xlim=get.XRange(hObj)
            if~strcmp(hObj.XRangeMode,'manual')

                try
                    forceFullUpdate(hObj,'all','XRange');
                catch
                end
            end
            xlim=hObj.XRange_I;
        end

        function set.XRange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.XRangeMode='manual';
            hObj.XRange_I=lim;
            hObj.MarkDirty('limits');
        end

        function ylim=get.YRange(hObj)
            if~strcmp(hObj.YRangeMode,'manual')

                try
                    forceFullUpdate(hObj,'all','YRange');
                catch
                end
            end
            ylim=hObj.YRange_I;
        end

        function set.YRange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.YRangeMode='manual';
            hObj.YRange_I=lim;
            hObj.MarkDirty('limits');
        end

        function zlim=get.ZRange(hObj)
            if~strcmp(hObj.ZRangeMode,'manual')

                try
                    forceFullUpdate(hObj,'all','ZRange');
                catch
                end
            end
            zlim=hObj.ZRange_I;
        end

        function set.ZRange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.ZRangeMode='manual';
            hObj.ZRange_I=lim;
            hObj.MarkDirty('limits');
        end

        function val=get.LineStyle(hObj)
            val=hObj.LineStyle_I;
        end

        function set.LineStyle(hObj,style)
            hObj.LineStyle_I=style;
        end

        function set.LineStyle_I(hObj,style)
            hObj.LineStyle_I=style;
            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,style);
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
            hObj.Edge.LineWidth=width;
            fanChild=hObj.MarkerHandle;
            if~isempty(fanChild)&&isvalid(fanChild)
                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',width);
                end
            end
            hObj.markLegendEntryDirty;
        end

        function val=get.FaceColor(hObj)
            val=hObj.FaceColor_I;
        end

        function set.FaceColor(hObj,color)
            hObj.FaceColor_I=color;
            if isequal(color,'interp')
                hObj.MarkDirty('all');
            end
            hObj.markLegendEntryDirty;
        end

        function set.FaceColor_I(hObj,color)
            hObj.FaceColor_I=color;
            fanChild=hObj.Faces;
            if~isempty(fanChild)&&isvalid(fanChild)
                if~isequal(hObj.FaceColor,'interp')
                    if ischar(hObj.FaceColor)
                        hgfilter('RGBAColorToGeometryPrimitive',hObj.Faces,hObj.FaceColor);
                    else
                        hgfilter('RGBAColorToGeometryPrimitive',hObj.Faces,[hObj.FaceColor,hObj.FaceAlpha]);
                    end
                end
            end
        end

        function set.FaceAlpha(hObj,alpha)
            hObj.FaceAlpha=alpha;
            hObj.MarkDirty('all');
        end

        function val=get.EdgeColor(hObj)
            val=hObj.EdgeColor_I;
        end

        function set.EdgeColor(hObj,color)
            hObj.EdgeColor_I=color;

            hObj.MarkDirty('all');
        end

        function val=get.AmbientStrength(hObj)
            val=hObj.Faces.AmbientStrength;
        end

        function set.AmbientStrength(hObj,val)
            hObj.Faces.AmbientStrength=val;
        end

        function val=get.DiffuseStrength(hObj)
            val=hObj.Faces.DiffuseStrength;
        end

        function set.DiffuseStrength(hObj,val)
            hObj.Faces.DiffuseStrength=val;
        end

        function val=get.SpecularStrength(hObj)
            val=hObj.Faces.SpecularStrength;
        end

        function set.SpecularStrength(hObj,val)
            hObj.Faces.SpecularStrength=val;
        end

        function val=get.SpecularExponent(hObj)
            val=hObj.Faces.SpecularExponent;
        end

        function set.SpecularExponent(hObj,val)
            hObj.Faces.SpecularExponent=val;
        end

        function val=get.SpecularColorReflectance(hObj)
            val=hObj.Faces.SpecularColorReflectance;
        end

        function set.SpecularColorReflectance(hObj,val)
            hObj.Faces.SpecularColorReflectance=val;
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
            hObj.MarkDirty('all');
        end

        function vbox=getXYZDataExtents(hObj,transformation,~)
            data=hObj.getXYZData(hObj.getDataSpace);
            if isempty(data.vbox)
                vbox=data.vbox;
            else
                vbox=[data.vbox;ones(1,size(data.vbox,2))];
                vbox=transformation*vbox;
                vbox=sort(bsxfun(@rdivide,vbox(1:3,:),vbox(4,:)),2);
            end
        end

        function tr=get.Triangulation(hObj)
            data=hObj.getXYZData(hObj.getDataSpace);
            tr=triangulation(reshape(double(data.FaceVertexIndices),3,[]).',double(data.FaceVertices).');
        end

        function ex=getColorAlphaDataExtents(hObj)
            vbox=hObj.getXYZDataExtents(eye(4));
            if isempty(vbox)
                ex=[NaN,NaN;NaN,NaN];
            else
                ex=[vbox(3,1),vbox(3,end);NaN,NaN];
            end
        end
    end

    methods(Hidden)
        function doUpdate(hObj,us)
            if hObj.Visible=="off"
                return
            end

            data=hObj.getXYZData(us);

            faces=hObj.Faces;
            if numel(data.FaceVertices)<9
                data.FaceVertices=zeros(3,0,'single');
            end

            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

            piter.XData=data.FaceVertices(1,:);
            piter.YData=data.FaceVertices(2,:);
            piter.ZData=data.FaceVertices(3,:);

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);

            faces.VertexData=vd;
            faces.Visible='on';
            faces.VertexIndices=data.FaceVertexIndices;
            faces.StripData=uint32(1:3:numel(faces.VertexIndices)+1);
            faces.NormalBinding='interpolated';
            faces.NormalData=data.NormalData;

            if isequal(hObj.FaceColor,'interp')
                ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
                ci.Colors=faces.VertexData(3,:).';
                ci.CDataMapping='scaled';
                cd=TransformColormappedToColormapped(us.ColorSpace,ci);
                if~isempty(cd)
                    set(faces,...
                    'ColorData_I',cd.Data,...
                    'ColorBinding_I','interpolated',...
                    'ColorType_I',cd.Type,...
                    'Texture',cd.Texture);
                    if~isempty(cd.Texture)&&strcmp(cd.Texture.ColorType,'truecolor')&&~isequal(hObj.FaceAlpha,1.0)
                        faces.Texture.ColorType='truecoloralpha';
                        faces.Texture.CData(4,:)=255*hObj.FaceAlpha;
                    end
                end
            else
                set(faces,'Texture',[]);
                hgfilter('RGBAColorToGeometryPrimitive',faces,hObj.FaceColor);
                if isequal(hObj.FaceColor,'none')
                    faces.ColorBinding_I='none';

                    faces.PickableParts_I='all';
                else
                    faces.ColorBinding_I='object';
                    if isequal(hObj.FaceAlpha,1.0)
                        faces.ColorType_I='truecolor';
                    else
                        faces.ColorType_I='truecoloralpha';
                        hgfilter('RGBAColorToGeometryPrimitive',faces,[hObj.FaceColor,hObj.FaceAlpha]);
                    end
                end
            end

            piter.XData=data.LineVertices(1,:);
            piter.YData=data.LineVertices(2,:);
            piter.ZData=data.LineVertices(3,:);

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);

            edge=hObj.Edge;
            edge.VertexData=vd;
            edge.StripData=data.LineStripData;

            if isequal(hObj.EdgeColor,'interp')
                ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
                ci.Colors=edge.VertexData(3,:).';
                ci.CDataMapping='scaled';
                cd=TransformColormappedToColormapped(us.ColorSpace,ci);
                set(edge,...
                'ColorData_I',cd.Data,...
                'ColorBinding_I','interpolated',...
                'ColorType_I',cd.Type,...
                'Texture',cd.Texture);
            else
                hgfilter('RGBAColorToGeometryPrimitive',edge,hObj.EdgeColor);
                if isequal(hObj.EdgeColor,'none')
                    edge.ColorBinding_I='none';
                else
                    edge.ColorBinding_I='object';
                    edge.ColorType_I='truecolor';
                end
            end

            hObj.MarkerHandle.VertexData=data.MarkerPoints;

            mec=hObj.MarkerEdgeColor;
            if strcmpi(mec,'auto')
                mec=hObj.EdgeColor;
                if isequal(mec,'interp')
                    mec='flat';
                end
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
            graphic=matlab.graphics.function.internal.getIconForSurfacePlots(hObj);
        end


        function dataTipRows=createDefaultDataTipRows(~)
            dataTipRows=[...
            dataTipTextRow('X','XData');...
            dataTipTextRow('Y','YData');...
            dataTipTextRow('Z','ZData')];
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            if numel(hObj.DataTipIndices)>=dataIndex
                location=hObj.cacheLookup(dataIndex);
            else
                location=struct('x','','y','','z','');
            end
            switch(valueSource)
            case 'XData'
                coordinateData=CoordinateData('XData',location.x);
            case 'YData'
                coordinateData=CoordinateData('YData',location.y);
            case 'ZData'
                coordinateData=CoordinateData('ZData',location.z);
            end
        end


        function valueSources=getAllValidValueSources(~)
            valueSources=["XData","YData","ZData"];
        end

        mcodeConstructor(hObj,code)
    end

    methods(Access=protected)
        function MarkDirty(hObj,varargin)
            hObj.XYZCache=[];
            MarkDirty@matlab.graphics.primitive.Data(hObj,varargin{:});
        end

        function group=getPropertyGroups(hObj)
            show={'Function'};
            if strcmp(hObj.XRangeMode,'manual')
                show=[show,{'XRange'}];
            end
            if strcmp(hObj.YRangeMode,'manual')
                show=[show,{'YRange'}];
            end
            if strcmp(hObj.ZRangeMode,'manual')
                show=[show,{'ZRange'}];
            end
            group=matlab.mixin.util.PropertyGroup([show...
            ,{'EdgeColor','LineStyle','FaceColor'}]);
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            point=hObj.cacheLookup(index);
            descriptors=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',point.x),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Y',point.y),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Z',point.z)];
        end

        function index=doGetNearestIndex(~,index)
        end

        function[index,interp]=doIncrementIndex(~,index,~,~)

            interp=0;
        end

        function index=doGetNearestPoint(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYZData(hObj.getDataSpace());
            points=data.FaceVertices;
            pointIndex=pickUtils.nearestPoint(hObj,position,true,points.');
            point=points(:,pointIndex);
            index=hObj.getCacheFor(point(1),point(2),point(3));
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYZData(hObj.getDataSpace());
            points=data.FaceVertices;
            pointIndex=pickUtils.nearestPoint(hObj,position,false,points.');
            point=points(:,pointIndex);
            index=hObj.getCacheFor(point(1),point(2),point(3));
            interpolationFactor=0;
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end


        function indices=doGetEnclosedPoints(hObj,polygon)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYZData(hObj.getDataSpace());
            points=data.FaceVertices;
            localIndices=pickUtils.enclosedPoints(hObj,polygon,points.');
            indices=arrayfun(@(i)hObj.getCacheFor(points(1,i),points(2,i),points(3,i)),localIndices);
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

    methods(Access=?tfimplicit3)

        function pos=preparePointNear(hObj,pos)
            pos=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,pos.');
            index=hObj.doGetNearestPoint(pos.');
            pos=hObj.cacheLookup(index);
            pos=[pos.x,pos.y,pos.z];
        end
    end

    methods(Access=private)
        data=calcXYZData(hObj,us)

        function data=getXYZData(hObj,us)

            ds=[];
            if~isempty(us)
                ds=hObj.getDataSpace;
                if isempty(findprop(us,'Transform'))
                    ds={ds.XLim,ds.XLimMode,ds.YLim,ds.YLimMode,ds.ZLim,ds.ZLimMode};
                else
                    ds={ds.XLim,ds.XLimMode,ds.YLim,ds.YLimMode,ds.ZLim,ds.ZLimMode,us.Transform};
                end
            end
            if isempty(hObj.XYZCache)||~isequal(hObj.XYZCache{1},{ds})
                hObj.XYZCache={{ds},hObj.calcXYZData(us)};
            end
            data=hObj.XYZCache{2};
        end

        function ds=getDataSpace(hObj)
            ds=ancestor(hObj,'matlab.graphics.axis.dataspace.DataSpace','node');
        end

        function createSelectionHandle(hObj)

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
            hObj.addNode(hObj.SelectionHandle);


            hObj.SelectionHandle.Description='ImplicitFunctionSurface SelectionHandle';


        end

        function updateFunction(hObj)
            hObj.Function_fh_I=getFunction(hObj.Function_I,hObj.XRange,hObj.YRange,hObj.ZRange);
            if strcmp(hObj.DisplayNameMode,'auto')
                hObj.DisplayName_I_ByInterpreter=hObj.displayNames(hObj.Function_I);
                hObj.DisplayName=hObj.DisplayName_I_ByInterpreter.tex;
                hObj.DisplayNameMode='auto';
            else
                hObj.DisplayName_I_ByInterpreter=struct;
            end
        end

        function index=getCacheFor(hObj,x,y,z)
            index=find([hObj.DataTipIndices.x]==x&[hObj.DataTipIndices.y]==y&[hObj.DataTipIndices.z]==z);
            if isempty(index)
                index=numel(hObj.DataTipIndices)+1;
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
            data=hObj.getXYZData(hObj.getDataSpace());
            xVerts=data.FaceVertices(1,:);
            yVerts=data.FaceVertices(2,:);
            zVerts=data.FaceVertices(3,:);
            if pos.x>=min(xVerts)&&pos.x<=max(xVerts)&&...
                pos.y>=min(yVerts)&&pos.y<=max(yVerts)&&...
                pos.z>=min(zVerts)&&pos.z<=max(zVerts)
                return
            else
                pos.x=NaN;
                pos.y=NaN;
                pos.z=NaN;
            end
        end
    end
end

function fn=getFunction(fnIn,xrange,yrange,zrange)
    if isempty(fnIn)
        fn=@(x,~,~)x;
    elseif isa(fnIn,'sym')
        if numel(symvar(fnIn))>3
            error(message('MATLAB:fimplicit3:TooManyVariables'));
        end
        fn=sym2Implicitfn(fnIn);
    else
        if nargin(fnIn)<0
            fn=fnIn;
        else
            switch nargin(fnIn)
            case 1
                fn=@(x,~,~)double(feval(fnIn,x));
            case 2
                fn=@(x,y,~)double(feval(fnIn,x,y));
            case 3
                fn=@(x,y,z)double(feval(fnIn,x,y,z));
            otherwise
                error(message('MATLAB:fimplicit3:TooManyVariables'));
            end
        end
    end

    testvaluesX=linspace(xrange(1),xrange(end),3);
    testvaluesY=linspace(yrange(1),yrange(end),3);
    testvaluesZ=linspace(zrange(1),zrange(end),3);
    vectorError=false;
    scalarError=false;
    try
        fnXYZ=fn(testvaluesX,testvaluesY,testvaluesZ);
    catch
        vectorError=true;
    end
    try
        fnXYZScalar=arrayfun(fn,testvaluesX,testvaluesY,testvaluesZ);
    catch
        scalarError=true;
    end

    if vectorError
        good=scalarError;
    else
        good=~scalarError&&isequaln(fnXYZ,fnXYZScalar);
    end

    if~good
        if~isa(fnIn,'sym')
            warning(message('MATLAB:fplot:NotVectorized'));
        end
        fn=@(x,y,z)arrayfun(fn,x,y,z);
    end
end

function fn=sym2Implicitfn(sf)
    sf2=feval_internal(symengine,'symobj::map',sf,'symobj::equationToExpression');
    vars=symvar(sf,3);
    vars=num2cell(vars);
    vars=[vars,{'~','~','~'}];
    vars=vars(1:3);
    fn=matlab.graphics.function.internal.sym2fn(sf2,vars);
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropSetClsMismatch','%s',message('MATLAB:type:PropSetClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
