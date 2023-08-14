classdef(ConstructOnLoad,Sealed)ParameterizedFunctionSurface<...
    matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&...
    matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.function.mixin.Legendable&...
    matlab.graphics.chart.interaction.DataAnnotatable






    properties(AffectsDataLimits)
        MeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=35;
    end

    properties(AffectsObject)
        FaceAlpha matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=1.0;
        ShowContours='off';
    end

    properties(NeverAmbiguous)
        URangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        VRangeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Dependent,AffectsDataLimits)
        XFunction;
        YFunction;
        ZFunction;
    end

    properties(Dependent,AffectsDataLimits)
        URange;
        VRange;
    end

    properties(Dependent,AffectsObject)
        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBInterpNoneColor='interp';
        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBInterpNoneColor=[0,0,0];
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end

    properties(Dependent)
        AmbientStrength matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=0.3;
        DiffuseStrength matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=0.6;
        SpecularStrength matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=0.9;
        SpecularExponent matlab.internal.datatype.matlab.graphics.datatype.Positive=10;
        SpecularColorReflectance matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=1;
    end

    properties(Dependent,Hidden)
Triangulation
    end

    properties(Hidden,AffectsDataLimits)
        AdaptiveMeshDensity matlab.internal.datatype.matlab.graphics.datatype.PositiveWithZero=4;
    end

    properties(Hidden)
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

    properties(Hidden,Access=private,AffectsDataLimits)
        XFunction_I;
        YFunction_I;
        ZFunction_I;
        URange_I=[-5,5];
        VRange_I=[-5,5];
        DataTipIndices;
    end

    properties(Transient,Access=private)
        XFunction_fh_I;
        YFunction_fh_I;
        ZFunction_fh_I;
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
        Edge matlab.graphics.primitive.world.LineStrip;
        Faces matlab.graphics.primitive.world.TriangleStrip;
        Contourlines matlab.graphics.primitive.world.LineStrip;
        XYZCache;
    end

    properties(Transient,Access=public,Hidden)
        UData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
        VData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    methods
        function hObj=ParameterizedFunctionSurface(fn,varargin)
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
            hObj.Edge.LineWidth_I=hObj.LineWidth;
            hObj.Edge.Internal=true;
            hObj.addNode(hObj.Edge);

            hObj.Contourlines=matlab.graphics.primitive.world.LineStrip;
            hgfilter('RGBAColorToGeometryPrimitive',hObj.Contourlines,hObj.EdgeColor);
            hObj.Contourlines.LineWidth_I=hObj.LineWidth;
            hObj.Contourlines.Internal=true;
            hObj.Contourlines.Visible='off';
            hObj.addNode(hObj.Contourlines);

            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker;
            hObj.MarkerHandle.LineWidth_I=hObj.LineWidth;
            hObj.MarkerHandle.Description_I='FunctionSurface MarkerHandle';
            hObj.MarkerHandle.Internal=true;
            hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker);

            hObj.DataTipIndices=struct('x',{},'y',{},'z',{});

            hObj.Type='parameterizedfunctionsurface';

            hObj.addDependencyConsumed({'xyzdatalimits','dataspace','figurecolormap','colorspace'});








            setInteractionHint(hObj,'DataBrushing',false);

            if nargin<1
                return;
            end

            hObj.DisplayNameMode='auto';
            validateattributes(fn,{'cell'},{'numel',3});
            hObj.XFunction=fn{1};
            hObj.YFunction=fn{2};
            hObj.ZFunction=fn{3};

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

        function set.XFunction(hObj,fn)
            checkVectorization(fn);
            hObj.XFunction_I=fn;
        end

        function set.XFunction_I(hObj,fn)
            if isa(fn,'sym')
                fn=saveobj(fn);
            end
            hObj.XFunction_I=fn;
            hObj.XFunction_fh_I=[];
            hObj.updateDisplayName;
            hObj.updateFunctionHandles;
            hObj.clearXYZCache;
        end

        function v=get.XFunction(hObj)
            v=hObj.XFunction_I;
        end

        function set.YFunction(hObj,fn)
            checkVectorization(fn);
            hObj.YFunction_I=fn;
        end

        function set.YFunction_I(hObj,fn)
            if isa(fn,'sym')
                fn=saveobj(fn);
            end
            hObj.YFunction_I=fn;
            hObj.YFunction_fh_I=[];
            hObj.updateDisplayName;
            hObj.updateFunctionHandles;
            hObj.clearXYZCache;
        end

        function v=get.YFunction(hObj)
            v=hObj.YFunction_I;
        end

        function set.ZFunction(hObj,fn)
            checkVectorization(fn);
            hObj.ZFunction_I=fn;
        end

        function set.ZFunction_I(hObj,fn)
            if isa(fn,'sym')
                fn=saveobj(fn);
            end
            hObj.ZFunction_I=fn;
            hObj.ZFunction_fh_I=[];
            hObj.updateDisplayName;
            hObj.updateFunctionHandles;
            hObj.clearXYZCache;
        end

        function v=get.ZFunction(hObj)
            v=hObj.ZFunction_I;
        end

        function set.MeshDensity(hObj,val)
            hObj.MeshDensity=val;
            hObj.clearXYZCache;
        end

        function set.AdaptiveMeshDensity(hObj,val)
            hObj.AdaptiveMeshDensity=val;
            hObj.clearXYZCache;
        end

        function set.ShowContours(hObj,val)

            hObj.ShowContours=val;
        end

        function val=get.MarkerEdgeColor(hObj)
            val=hObj.MarkerEdgeColor_I;
        end

        function set.MarkerEdgeColor(hObj,val)
            hObj.MarkerEdgeColorMode='manual';
            hObj.MarkerEdgeColor_I=val;
        end

        function val=get.MarkerFaceColor(hObj)
            val=hObj.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor(hObj,val)
            hObj.MarkerFaceColorMode='manual';
            hObj.MarkerFaceColor_I=val;
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
        end

        function ulim=get.URange(hObj)
            ulim=hObj.URange_I;
        end

        function set.URange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.URangeMode='manual';
            hObj.URange_I=lim;
            hObj.clearXYZCache;
        end

        function vlim=get.VRange(hObj)
            vlim=hObj.VRange_I;
        end

        function set.VRange(hObj,lim)
            matlab.graphics.function.internal.checkRangeVector(lim);
            hObj.VRangeMode='manual';
            hObj.VRange_I=lim;
            hObj.clearXYZCache;
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
            hObj.Edge.LineWidth_I=width;
            for fanChild=[hObj.MarkerHandle,hObj.Contourlines]
                if~isempty(fanChild)&&isvalid(fanChild)
                    if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                        set(fanChild,'LineWidth_I',width);
                    end
                end
            end
            hObj.markLegendEntryDirty;
        end

        function val=get.FaceColor(hObj)
            val=hObj.FaceColor_I;
        end

        function set.FaceColor(hObj,color)
            hObj.FaceColor_I=color;
            if isequal(hObj.FaceColor,'interp')
                hObj.clearXYZCache;
            end
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
            hObj.markLegendEntryDirty;
        end

        function set.FaceAlpha(hObj,alpha)
            hObj.FaceAlpha=alpha;
        end

        function val=get.EdgeColor(hObj)
            val=hObj.EdgeColor_I;
        end

        function set.EdgeColor(hObj,color)
            hObj.EdgeColor_I=color;
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
        end

        function vbox=getXYZDataExtents(hObj,transformation,~)
            data=hObj.getXYZData(hObj.getDataSpace,transformation);
            vbox=data.vbox;
        end

        function xd=get.XData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace);
            xd=double(data.xdata);
        end

        function yd=get.YData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace);
            yd=double(data.ydata);
        end

        function zd=get.ZData(hObj)
            data=hObj.getXYZData(hObj.getDataSpace);
            zd=double(data.zdata);
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

            hObj.UData=data.udata;
            hObj.VData=data.vdata;

            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

            piter.XData=data.FaceVertices(1,:);
            piter.YData=data.FaceVertices(2,:);
            piter.ZData=data.FaceVertices(3,:);

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);

            faces=hObj.Faces;
            faces.VertexData=vd;
            faces.VertexIndices=data.FaceVertexIndices;
            faces.StripData=uint32(1:3:numel(faces.VertexIndices)+1);
            faces.NormalBinding='interpolated';
            faces.NormalData=data.NormalData;
            faces.Visible='on';

            if isequal(hObj.FaceColor,'interp')
                ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
                ci.Colors=data.FaceVertices(3,:).';
                ci.CDataMapping='scaled';
                cd=TransformColormappedToColormapped(us.ColorSpace,ci);
                if~isempty(cd)&&~isempty(cd.Texture)&&~isempty(cd.Texture.CData)
                    set(faces,...
                    'ColorData_I',cd.Data,...
                    'ColorBinding_I','interpolated',...
                    'ColorType_I',cd.Type,...
                    'Texture',cd.Texture);
                    if strcmp(cd.Texture.ColorType,'truecolor')&&~isequal(hObj.FaceAlpha,1.0)
                        faces.Texture.ColorType='truecoloralpha';
                        faces.Texture.CData(4,:)=255*hObj.FaceAlpha;
                    end
                else
                    set(faces,'ColorData_I',[],'ColorBinding_I','none');
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
                        faces.ColorData(4,:)=255*hObj.FaceAlpha;
                    end
                end
            end


            if isequal(hObj.ShowContours,'on')||isequal(hObj.ShowContours,'auto')
                hObj.Contourlines.Visible='on';



                xmesh=reshape(data.xdata_coarse,hObj.MeshDensity,[]);
                ymesh=reshape(data.ydata_coarse,hObj.MeshDensity,[]);
                zmesh=reshape(data.zdata_coarse,hObj.MeshDensity,[]);
                zmin=min(zmesh(:));
                zmax=max(zmesh(:));
                vertexData=single([]);
                stripData=uint32(1);
                for level=linspace(double(zmin),double(zmax),10)
                    s=matlab.graphics.chart.generatecontourlevel(xmesh,ymesh,zmesh,level);
                    if~isempty(s)
                        levelVertexData=s.LineVertices;
                        levelStripData=s.LineStripData;
                        [levelVertexData,levelStripData]...
                        =matlab.graphics.chart.internal.contour.linkLineStrips(levelVertexData,levelStripData);
                        stripData=[stripData,size(vertexData,2)+levelStripData(2:end)];%#ok<AGROW>
                        levelVertexData(3,:)=level;
                        vertexData=[vertexData,levelVertexData];%#ok<AGROW>
                    end
                end

                if isempty(vertexData)
                    cd=[];
                else
                    ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
                    ci.Colors=vertexData(3,:).';
                    ci.CDataMapping='scaled';
                    cd=TransformColormappedToColormapped(us.ColorSpace,ci);
                    vertexData(3,:)=us.DataSpace.ZLim(1);
                end
                if isempty(cd)||isempty(cd.Texture)||isempty(cd.Texture.CData)
                    set(hObj.Contourlines,'ColorData_I',[],'ColorBinding_I','none');
                else
                    set(hObj.Contourlines,...
                    'ColorData',cd.Data,...
                    'ColorBinding','interpolated',...
                    'ColorType',cd.Type,...
                    'Texture',cd.Texture);
                end

                hObj.Contourlines.VertexData=single(vertexData);
                hObj.Contourlines.StripData=uint32(stripData);
            else
                hObj.Contourlines.Visible='off';
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
            edge.Visible='on';

            if isequal(hObj.EdgeColor,'interp')
                ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
                ci.Colors=data.LineVertices(3,:).';
                ci.CDataMapping='scaled';
                cd=TransformColormappedToColormapped(us.ColorSpace,ci);
                if~isempty(cd)&&~isempty(cd.Texture)&&~isempty(cd.Texture.CData)
                    set(edge,...
                    'ColorData_I',cd.Data,...
                    'ColorBinding_I','interpolated',...
                    'ColorType_I',cd.Type,...
                    'Texture',cd.Texture);
                else
                    set(edge,'ColorData_I',[],'ColorBinding_I','none');
                end
            else
                hgfilter('RGBAColorToGeometryPrimitive',edge,hObj.EdgeColor);
                if isequal(hObj.EdgeColor,'none')
                    edge.ColorBinding_I='none';
                else
                    edge.ColorBinding_I='object';
                    edge.ColorType_I='truecolor';
                end
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
            dataTipTextRow('U','UData');...
            dataTipTextRow('V','VData');...
            dataTipTextRow('X','XData');...
            dataTipTextRow('Y','YData');...
            dataTipTextRow('Z','ZData')];
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            if numel(hObj.DataTipIndices)>=dataIndex
                location=hObj.cacheLookup(dataIndex);
            else
                location=struct('x','','y','','z','','u','','v','');
            end
            switch(valueSource)
            case 'XData'
                coordinateData=CoordinateData('XData',location.x);
            case 'YData'
                coordinateData=CoordinateData('YData',location.y);
            case 'ZData'
                coordinateData=CoordinateData('ZData',location.z);
            case 'UData'
                coordinateData=CoordinateData('UData',location.u);
            case 'VData'
                coordinateData=CoordinateData('VData',location.v);
            end
        end


        function valueSources=getAllValidValueSources(~)
            valueSources=["UData","VData","XData","YData","ZData"];
        end

        mcodeConstructor(hObj,code)
    end

    methods(Access=protected)
        function clearXYZCache(hObj)
            hObj.XYZCache=[];
        end

        function group=getPropertyGroups(hObj)
            show={'XFunction','YFunction','ZFunction'};
            if strcmp(hObj.URangeMode,'manual')
                show=[show,{'URange'}];
            end
            if strcmp(hObj.VRangeMode,'manual')
                show=[show,{'VRange'}];
            end
            group=matlab.mixin.util.PropertyGroup([show...
            ,{'EdgeColor','LineStyle','FaceColor'}]);
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            point=hObj.cacheLookup(index);
            descriptors=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('U',point.u),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('V',point.v),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('X',point.x),...
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
            data=hObj.getXYZData(hObj.getDataSpace);
            vertices=[data.FaceVertices];
            pointIndex=pickUtils.nearestPoint(hObj,position,true,vertices.');
            point=vertices(:,pointIndex);
            u=data.udata(pointIndex);
            v=data.vdata(pointIndex);
            index=hObj.getCacheFor(point(1),point(2),point(3),u,v);
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYZData(hObj.getDataSpace);
            vertices=[data.FaceVertices];
            pointIndex=pickUtils.nearestPoint(hObj,position,false,vertices.');
            point=vertices(:,pointIndex);
            u=data.udata(pointIndex);
            v=data.vdata(pointIndex);
            index=hObj.getCacheFor(point(1),point(2),point(3),u,v);
            interpolationFactor=0;
        end


        function indices=doGetEnclosedPoints(hObj,polygon)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            data=hObj.getXYZData(hObj.getDataSpace);
            vertices=[data.FaceVertices];
            localIndices=pickUtils.enclosedPoints(hObj,polygon,vertices.');
            points=vertices(:,localIndices);
            u=data.udata(localIndices);
            v=data.vdata(localIndices);
            indices=arrayfun(@(i)hObj.getCacheFor(points(1,i),points(2,i),points(i,3),uVerts(i),vVerts(i)),1:size(points,2));
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

    methods(Access=?tfsurf)

        function pos=preparePointNear(hObj,pos)
            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            pointIndex=pickUtils.nearestPoint(hObj,pos,false,hObj.Faces.VertexData.');
            point=hObj.Faces.VertexData(:,pointIndex);
            u=hObj.UData(pointIndex);
            v=hObj.VData(pointIndex);
            index=hObj.getCacheFor(point(1),point(2),point(3),u,v);
            pos=hObj.cacheLookup(index);
            pos=[pos.x,pos.y,pos.z];
        end
    end

    methods(Access=private)
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
                ds={ds.XLim,ds.XLimMode,ds.XScale,...
                ds.YLim,ds.YLimMode,ds.YScale,...
                ds.ZLim,ds.ZLimMode,ds.ZScale,...
                transformation};
            end
            if isempty(hObj.XYZCache)||~isequal(hObj.XYZCache{1},{ds})
                hObj.XYZCache={{ds},hObj.calcXYZData(us,transformation)};
            end
            data=hObj.XYZCache{2};
        end

        function ds=getDataSpace(hObj)
            ds=ancestor(hObj,'matlab.graphics.axis.dataspace.DataSpace','node');
        end

        function createSelectionHandle(hObj)

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
            hObj.addNode(hObj.SelectionHandle);


            hObj.SelectionHandle.Description='ParameterizedFunctionSurface SelectionHandle';


        end

        function index=getCacheFor(hObj,x,y,z,u,v)
            index=find([hObj.DataTipIndices.x]==x&[hObj.DataTipIndices.y]==y&[hObj.DataTipIndices.z]==z);
            if isempty(index)
                index=numel(hObj.DataTipIndices)+1;
                hObj.DataTipIndices(index).x=x;
                hObj.DataTipIndices(index).y=y;
                hObj.DataTipIndices(index).z=z;
                hObj.DataTipIndices(index).u=u;
                hObj.DataTipIndices(index).v=v;
            end
        end

        function pos=cacheLookup(hObj,index)

            if numel(hObj.DataTipIndices)<index
                pos.u=NaN;
                pos.v=NaN;
                pos.x=NaN;
                pos.y=NaN;
                pos.z=NaN;
                return;
            end
            pos=hObj.DataTipIndices(index);
            uVerts=hObj.UData;
            vVerts=hObj.VData;
            if pos.u>=min(uVerts)&&pos.u<=max(uVerts)&&...
                pos.v>=min(vVerts)&&pos.v<=max(vVerts)

                if isempty(hObj.XFunction_fh_I)||isempty(hObj.YFunction_fh_I)||isempty(hObj.ZFunction_fh_I)
                    hObj.updateFunctionHandles;
                end
                pos.x=hObj.XFunction_fh_I(pos.u,pos.v);
                pos.y=hObj.YFunction_fh_I(pos.u,pos.v);
                pos.z=hObj.ZFunction_fh_I(pos.u,pos.v);
                return
            else
                pos.u=NaN;
                pos.v=NaN;
                pos.x=NaN;
                pos.y=NaN;
                pos.z=NaN;
            end
        end

        function updateFunctionHandles(hObj)



            fn_vars={getVars(hObj.XFunction),...
            getVars(hObj.YFunction),...
            getVars(hObj.ZFunction)};
            vars=unique([fn_vars{:}]);
            switch numel(vars)
            case 0
                vars={'~','~'};
            case 1
                vars{end+1}='~';
            case 2

                order_fixed=false;
                funs={hObj.XFunction,hObj.YFunction,hObj.ZFunction};
                for k=1:3
                    fun=funs{k};
                    if isa(fun,'symfun')
                        xvars=fn_vars{k};
                        if numel(xvars)==2&&~isequal(xvars,vars)
                            if order_fixed
                                error(message('MATLAB:fsurf:InconsistentVariables'));
                            end
                            vars=xvars;
                        end
                        order_fixed=true;
                    end
                end
            otherwise
                error(message('MATLAB:fsurf:TooManyVariables'));
            end
            hObj.XFunction_fh_I=getFunction(hObj.XFunction,vars,hObj.URange,hObj.VRange);
            hObj.YFunction_fh_I=getFunction(hObj.YFunction,vars,hObj.URange,hObj.VRange);
            hObj.ZFunction_fh_I=getFunction(hObj.ZFunction,vars,hObj.URange,hObj.VRange);
        end

        function updateDisplayName(hObj)
            if strcmp(hObj.DisplayNameMode,'auto')
                xStruct=hObj.displayNames(hObj.XFunction);
                yStruct=hObj.displayNames(hObj.YFunction);
                zStruct=hObj.displayNames(hObj.ZFunction);

                xyzStruct=xStruct;
                for field=string(fieldnames(xyzStruct)).'
                    xyzStruct.(field)=join([string(xStruct.(field)),yStruct.(field),zStruct.(field)],",");
                end

                hObj.DisplayName_I_ByInterpreter=xyzStruct;
                hObj.DisplayName=xyzStruct.tex;
                hObj.DisplayNameMode='auto';
            else
                hObj.DisplayName_I_ByInterpreter=struct;
            end

            if strcmp(hObj.DisplayNameMode,'auto')
                hObj.DisplayName=[fn2str(hObj.XFunction),',',fn2str(hObj.YFunction),',',fn2str(hObj.ZFunction)];
                hObj.DisplayNameMode='auto';
            end
        end
    end
end

function vars=getVars(fn)
    vars={};
    if isa(fn,'symfun')
        vars=cellfun(@char,num2cell(argnames(fn)),'UniformOutput',false);
    elseif isa(fn,'sym')
        vars=cellfun(@char,num2cell(symvar(fn)),'UniformOutput',false);
    end
    vars=reshape(vars,1,[]);
end

function nv=struct2nvpairs(x)

    n=fieldnames(x);
    v=struct2cell(x);
    nv=[n,v]';
end

function c=fn2str(fn)

    if isa(fn,'function_handle')
        fn=regexprep(char(fn),'^@(\(.*?\))?\s*','');
    end
    c=texlabel(fn);
end

function checkVectorization(fn)
    if isa(fn,'function_handle')
        try
            [X,Y]=meshgrid(1:3,1:2);
            fnX=fn(X,Y);
            good=isequaln(fnX,[fn(1,1),fn(2,1),fn(3,1);fn(1,2),fn(2,2),fn(3,2)]);
        catch
            good=false;
        end
        if~good
            warning(message('MATLAB:fplot:NotVectorized'));
        end
    end
end

function fn=getFunction(fnIn,vars,urange,vrange)
    if isempty(fnIn)
        fn=@(u,v)zeros(size(u));
    elseif isa(fnIn,'sym')
        fn=matlab.graphics.function.internal.sym2fn(fnIn,vars);
    elseif isnumeric(fnIn)&&isscalar(fnIn)
        fn=@(u,~)fnIn.*ones(size(u));
    else
        if nargin(fnIn)<0
            fn=fnIn;
        else
            switch nargin(fnIn)
            case 1
                fn=@(u,v)double(feval(fnIn,u));
            case 2
                fn=@(u,v)double(feval(fnIn,u,v));
            otherwise
                error(message('MATLAB:fsurf:TooManyVariables'));
            end
        end
    end

    try
        U=linspace(urange(1),urange(end),3);
        V=linspace(vrange(1),vrange(end),3);
        fnX=fn(U,V);
        good=isequaln(fnX,arrayfun(fn,U,V));
    catch
        good=false;
    end
    if~good
        fn=@(u,v)arrayfun(fn,u,v);
    end
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropSetClsMismatch','%s',message('MATLAB:type:PropSetClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
