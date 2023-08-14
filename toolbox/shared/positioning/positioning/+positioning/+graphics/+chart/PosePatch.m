classdef(ConstructOnLoad,Sealed)PosePatch<...
    matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.Legendable...
    &matlab.graphics.mixin.ColorOrderUser...
    &fusion.internal.PositioningHandleBase














    properties(Hidden,Constant)
        Type matlab.internal.datatype.matlab.graphics.datatype.TypeName='PosePatch';
    end

    properties(Dependent)
        Orientation=quaternion.ones;
        Position(1,3)double=[0,0,0];
        PatchFaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=defaultPatchFaceAlpha;
        PatchFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBColor=get(groot,'FactoryPatchFaceColor');
        ScaleFactor matlab.internal.datatype.matlab.graphics.datatype.Positive=defaultScaleFactor;
    end

    properties(Hidden,NeverAmbiguous)
        PatchFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Access=private,AffectsObject)
        Orientation_I=quaternion.ones;
        ScaleFactor_I matlab.internal.datatype.matlab.graphics.datatype.Positive=defaultScaleFactor;
        pMeshVertices_I=defaultMeshVertices;

        pMeshFaces_I=defaultMeshFaces;
    end

    properties(Access=private,AffectsObject,AffectsLegend)
        PatchFaceAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=defaultPatchFaceAlpha;
        PatchFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBColor=get(groot,'FactoryPatchFaceColor');
    end

    properties(Access=private,AffectsDataLimits)
        Position_I(1,3)double=[0,0,0];
        LineData_I=defaultLineData;
    end

    properties(Access=private,Transient,NonCopyable)

        pMesh matlab.graphics.primitive.Patch;

        OriginBox matlab.graphics.primitive.Patch;
        OriginPoint matlab.graphics.primitive.Line;

        XLine matlab.graphics.primitive.Line;
        YLine matlab.graphics.primitive.Line;
        ZLine matlab.graphics.primitive.Line;

        XLetter matlab.graphics.primitive.Text;
        YLetter matlab.graphics.primitive.Text;
        ZLetter matlab.graphics.primitive.Text;
    end

    properties(Access=private)
        OriginBoxScale=0.6;
    end

    properties(SetAccess=private)
        MeshFileName='';
    end

    properties(Access=private)
        IsMeshSpecified=false;
    end

    methods(Hidden)
        function obj=PosePatch(varargin)


            vertices=defaultMeshVertices;
            faces=defaultMeshFaces;
            obj.pMesh=matlab.graphics.primitive.Patch(...
            'Vertices',vertices,'Faces',faces,...
            'FaceColor','flat',...
            'HandleVisibility','off','PickableParts','none',...
            'XLimInclude','off',...
            'YLimInclude','off',...
            'ZLimInclude','off');
            obj.addNode(obj.pMesh);
            obj.pMesh.Internal=true;


            obj.OriginPoint=matlab.graphics.primitive.Line(...
            'XData',0,'YData',0,'ZData',0,...
            'HandleVisibility','off',...
            'Marker','.','MarkerFaceColor','none',...
            'MarkerEdgeColor','none','Color',[0,0,0,0],...
            'PickableParts','all',...
            'XLimInclude','off',...
            'YLimInclude','off',...
            'ZLimInclude','off');
            obj.addNode(obj.OriginPoint);
            obj.OriginPoint.Internal=true;


            cdata=[blue;blue;red;red;green;green];
            originBoxScale=obj.OriginBoxScale;
            obj.OriginBox=matlab.graphics.primitive.Patch(...
            'Vertices',originBoxScale*vertices,...
            'Faces',faces,...
            'FaceVertexCData',cdata,'FaceColor','flat',...
            'HandleVisibility','off',...
            'PickableParts','none',...
            'XLimInclude','off',...
            'YLimInclude','off',...
            'ZLimInclude','off');
            obj.addNode(obj.OriginBox);
            obj.OriginBox.Internal=true;


            lineData=obj.LineData_I;
            zeroData=[0,0];
            xLenData=[0,lineData(1,1)];
            yLenData=[0,lineData(2,2)];
            zLenData=[0,lineData(3,3)];
            obj.XLine=createLine(xLenData,zeroData,zeroData,red);
            obj.addNode(obj.XLine);
            obj.XLine.Internal=true;
            obj.YLine=createLine(zeroData,yLenData,zeroData,green);
            obj.addNode(obj.YLine);
            obj.YLine.Internal=true;
            obj.ZLine=createLine(zeroData,zeroData,zLenData,blue);
            obj.addNode(obj.ZLine);
            obj.ZLine.Internal=true;


            obj.XLetter=createText(lineData(1,:),'X');
            obj.addNode(obj.XLetter);
            obj.XLetter.Internal=true;
            obj.YLetter=createText(lineData(2,:),'Y');
            obj.addNode(obj.YLetter);
            obj.YLetter.Internal=true;
            obj.ZLetter=createText(lineData(3,:),'Z');
            obj.addNode(obj.ZLetter);
            obj.ZLetter.Internal=true;


            obj.PatchFaceAlpha_I=defaultPatchFaceAlpha;
            obj.PatchFaceColor_I=get(groot,'FactoryPatchFaceColor');


            addDependencyConsumed(obj,{'dataspace','colororder_linestyleorder'});


            try
                if~isempty(varargin)
                    set(obj,varargin{:});
                end
            catch e

                obj.Parent=[];
                rethrow(e);
            end
        end

        function doUpdate(obj,us)

            updatedColor=obj.getColor(us);
            if obj.PatchFaceColorMode=="auto"&&~isempty(updatedColor)
                obj.pMesh.FaceColor=updatedColor;
            end


            xScale=us.DataSpace.XScale;
            yScale=us.DataSpace.YScale;
            zScale=us.DataSpace.ZScale;
            if any(strcmp('log',{xScale,yScale,zScale}))
                setPrimitives(obj,'Visible','off');
            else
                setPrimitives(obj,'Visible','on');
            end

            R=obj.Orientation_I;
            if isa(R,'quaternion')
                R=rotmat(R,'frame');
            end
            origin=obj.Position_I;
            sf=obj.ScaleFactor_I;
            initMeshVertices=sf*obj.pMeshVertices_I;
            obj.pMesh.Vertices=initMeshVertices*R+origin;

            set(obj.OriginPoint,...
            'XData',origin(1),'YData',origin(2),...
            'ZData',origin(3));

            if~obj.IsMeshSpecified
                obj.OriginBox.Vertices=(obj.OriginBoxScale*initMeshVertices)*R+origin;
            else
                obj.OriginBox.Visible='off';
            end

            ld=sf*obj.LineData_I*R+origin;
            set(obj.XLine,'XData',[origin(1),ld(1,1)],...
            'YData',[origin(2),ld(1,2)],...
            'ZData',[origin(3),ld(1,3)]);
            set(obj.YLine,'XData',[origin(1),ld(2,1)],...
            'YData',[origin(2),ld(2,2)],...
            'ZData',[origin(3),ld(2,3)]);
            set(obj.ZLine,'XData',[origin(1),ld(3,1)],...
            'YData',[origin(2),ld(3,2)],...
            'ZData',[origin(3),ld(3,3)]);

            obj.XLetter.Position=ld(1,:);
            obj.YLetter.Position=ld(2,:);
            obj.ZLetter.Position=ld(3,:);
        end

        function graphic=getLegendGraphic(obj)
            graphic=getLegendGraphic(obj.pMesh);
        end

        function extents=getXYZDataExtents(obj)















            origin=obj.Position_I;
            val=max(obj.LineData_I(:));
            sf=obj.ScaleFactor_I;
            lims=sf*[-val,val];

            xlim=matlab.graphics.chart.primitive.utilities.arraytolimits(lims+origin(1));
            ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(lims+origin(2));
            zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(lims+origin(3));

            extents=[xlim;ylim;zlim];
        end
    end

    methods
        function set.Orientation(obj,val)
            obj.Orientation_I=positioning.graphics.chart.PosePatch.validateOrientation(val);
        end
        function val=get.Orientation(obj)
            val=obj.Orientation_I;
        end

        function set.Position(obj,val)
            obj.Position_I=positioning.graphics.chart.PosePatch.validatePosition(val);
        end
        function val=get.Position(obj)
            val=obj.Position_I;
        end

        function set.PatchFaceColor(obj,val)
            obj.PatchFaceColor_I=val;
            obj.PatchFaceColorMode='manual';
        end
        function val=get.PatchFaceColor(obj)
            val=obj.PatchFaceColor_I;
        end

        function set.PatchFaceAlpha(obj,val)
            obj.PatchFaceAlpha_I=val;
        end
        function val=get.PatchFaceAlpha(obj)
            val=obj.PatchFaceAlpha_I;
        end

        function set.PatchFaceColor_I(obj,val)
            obj.pMesh.FaceColor=val;%#ok<MCSUP>
        end
        function val=get.PatchFaceColor_I(obj)
            val=obj.pMesh.FaceColor;
        end

        function set.PatchFaceAlpha_I(obj,val)
            obj.pMesh.FaceAlpha=val;%#ok<MCSUP>
        end
        function val=get.PatchFaceAlpha_I(obj)
            val=obj.pMesh.FaceAlpha;
        end

        function set.ScaleFactor(obj,val)
            obj.ScaleFactor_I=val;
        end
        function val=get.ScaleFactor(obj)
            val=obj.ScaleFactor_I;
        end

        function set.pMeshVertices_I(obj,val)
            obj.pMeshVertices_I=val;




            maxVertex=max(abs(val(:)));
            obj.LineData_I=defaultLineData.*maxVertex;%#ok<MCSUP>
        end

        function val=get.pMeshFaces_I(obj)
            val=obj.pMesh.Faces;
        end
        function set.pMeshFaces_I(obj,val)
            obj.pMesh.Faces=val;%#ok<MCSUP>
        end

        function set.MeshFileName(obj,val)
            obj.MeshFileName=val;
            obj.IsMeshSpecified=true;%#ok<MCSUP>
        end
    end

    methods(Hidden)
        function mcodeConstructor(obj,code)


            setConstructorName(code,'poseplot');

            plotutils('makemcode',obj,code);

            ignoreProperty(code,'Orientation');
            ignoreProperty(code,'Position');
            ignoreProperty(code,'MeshFileName');

            orientArg=codegen.codeargument('Name','q',...
            'Value',obj.Orientation,...
            'IsParameter',true,'Comment','poseplot q');
            addConstructorArgin(code,orientArg);

            posArg=codegen.codeargument('Name','pos',...
            'Value',obj.Position,...
            'IsParameter',true,'Comment','poseplot pos');
            addConstructorArgin(code,posArg);

            if(obj.Parent.ZDir=="normal")
                navFrameArg=codegen.codeargument('Name','navframe',...
                'Value',"ENU",...
                'IsParameter',false,'Comment','nav frame');
                addConstructorArgin(code,navFrameArg);
            end

            if obj.IsMeshSpecified
                fileNameArg=codegen.codeargument(...
                'Value',"MeshFileName",...
                'IsParameter',false,...
                'ArgumentType',codegen.ArgumentType.PropertyName);
                addConstructorArgin(code,fileNameArg);
                meshArg=codegen.codeargument('Name','meshfile',...
                'Value',obj.MeshFileName,...
                'IsParameter',false,...
                'ArgumentType',codegen.ArgumentType.PropertyValue,...
                'Comment','poseplot meshfile');
                addConstructorArgin(code,meshArg);
            end

            generateDefaultPropValueSyntax(code);
        end
    end

    methods(Access=protected)
        function setPrimitives(obj,prop,val)
            obj.pMesh.(prop)=val;
            obj.OriginBox.(prop)=val;
            obj.OriginPoint.(prop)=val;
            obj.XLine.(prop)=val;
            obj.YLine.(prop)=val;
            obj.ZLine.(prop)=val;
            obj.XLetter.(prop)=val;
            obj.YLetter.(prop)=val;
            obj.ZLetter.(prop)=val;
        end

        function groups=getPropertyGroups(obj)
            props={'Orientation','Position'};
            if obj.IsMeshSpecified
                props{end+1}='MeshFileName';
            end
            groups(1)=matlab.mixin.util.PropertyGroup(props);
        end
    end

    methods(Hidden)
        function h=getGraphicsPrimitive(obj,prop)
            h=obj.(prop);
        end
    end

    methods(Hidden,Static)
        function orient=validateOrientation(val)

            if isa(val,'quaternion')
                validateattributes(val,{'quaternion'},{'scalar'});
            else
                validateattributes(val,{'double','single'},...
                {'real','2d','nrows',3,'ncols',3});
            end

            orient=val;
        end

        function pos=validatePosition(val)

            validateattributes(val,{'double','single'},...
            {'real','vector','numel',3});

            pos=val(:).';
        end
    end
end



function lineObj=createLine(xData,yData,zData,color)
    lineWidth=2;

    lineObj=matlab.graphics.primitive.Line(...
    'XData',xData,'YData',yData,'ZData',zData,...
    'LineWidth',lineWidth,'Marker','none',...
    'Color',color,'HandleVisibility','off',...
    'PickableParts','none',...
    'XLimInclude','off',...
    'YLimInclude','off',...
    'ZLimInclude','off');
end

function textObj=createText(pos,str)
    textObj=matlab.graphics.primitive.Text(...
    'HorizontalAlignment','center','VerticalAlignment','middle',...
    'Position',pos,'String',str,'HandleVisibility','off',...
    'PickableParts','none',...
    'XLimInclude','off',...
    'YLimInclude','off',...
    'ZLimInclude','off');
end

function vertices=defaultMeshVertices
    b=1;
    a=1/(0.5*(1+sqrt(5)));
    xVertices=[-a;a;a;-a;-a;a;a;-a];
    yVertices=[0;0;b;b;0;0;b;b];
    zVertices=[0;0;0;0;b;b;b;b];
    xVertices=(xVertices);
    yVertices=(yVertices-b/2);
    zVertices=(zVertices-b/2);
    vertices=[xVertices,yVertices,zVertices];
end

function faces=defaultMeshFaces
    faces=[1,2,3,4;...
    5,6,7,8;...
    1,4,8,5;...
    2,3,7,6;...
    1,5,6,2;...
    4,8,7,3];
end

function data=defaultLineData
    defaultLineLen=2;
    data=defaultLineLen*eye(3);
end

function val=defaultPatchFaceAlpha
    val=0.1;
end

function val=defaultScaleFactor
    val=1;
end

function val=red
    val=[0.6350,0.0780,0.1840];
end

function val=green
    val=[0.4660,0.6740,0.1880];
end

function val=blue
    val=[0,0.4470,0.7410];
end
