classdef(Abstract,AllowedSubclasses={?images.ui.graphics3d.Volume,...
    ?images.ui.graphics3d.internal.Points,...
    ?images.ui.graphics3d.Surface})...
    GraphicsContainer<images.ui.graphics3d.internal.AbstractContainer




    events(ListenAccess=public,NotifyAccess=?images.ui.graphics3d.Viewer3D)

ClippingPlanesChanging
ClippingPlanesChanged

    end

    events(ListenAccess=?images.ui.graphics3d.Viewer3D,NotifyAccess=protected)

ContainerUpdated
DataBeingUpdated
TransformationUpdated

    end

    properties(Dependent)

        Transformation{mustBeA(Transformation,["affinetform3d","rigidtform3d","simtform3d","transltform3d","double"])}
        Visible(1,1)matlab.lang.OnOffSwitchState
        ClippingPlanes(:,4){mustBeFinite,mustBeNonNan,mustBeReal,mustBeNonsparse}
Data

    end

    properties(Dependent,SetAccess=private,GetAccess=public)

        Parent images.ui.graphics3d.Viewer3D

    end

    properties(Dependent,Hidden,SetAccess=private,GetAccess=public)

Empty

    end

    properties(Hidden,GetAccess=public,SetAccess=protected)

        Opaque(1,1)logical=false;
        BoundingBox(2,3)double=[Inf,Inf,Inf;-Inf,-Inf,-Inf];
        Type(1,1)string="";

    end

    properties(Access={?images.ui.graphics3d.Viewer3D...
        ,?images.ui.graphics3d.Volume,...
        ?images.ui.graphics3d.internal.Points,...
        ?images.ui.graphics3d.Surface})

        ClippingPlanes_I(4,:)single=[];

    end

    properties(Access=protected)

        Transformation_I(1,1)=affinetform3d;
        Visible_I(1,1)logical=true;
        Data_I(:,:,:,:)=[];
        OriginalData(:,:,:,:)=[];
        Parent_I images.ui.graphics3d.Viewer3D=images.ui.graphics3d.Viewer3D.empty;

        BoundingBoxCoordinates(8,3)double=zeros([8,3]);

        IsContainerReady(1,1)logical=false;
        IsContainerEmpty(1,1)logical=true;

    end

    methods(Abstract,Access=protected)

        s=getPropertyStruct(self);
        s=getInstructionSet(self);
        data=getData(self);
        setData(self,data);

    end

    methods




        function self=GraphicsContainer(h,type,varargin)


            self.Type=type;


            if~isempty(varargin)
                set(self,varargin{:});
            end



            self.Parent=h;
            self.IsContainerReady=true;

            propertiesUpdated(self);

        end

    end

    methods(Access=?images.ui.graphics3d.Viewer3D)


        function s=getContainerProperties(self)

            s=getPropertyStruct(self);




            if~self.IsContainerConstructed
                self.IsContainerConstructed=true;
            end
        end


        function data=getContainerData(self)

            data=getData(self);


            if~self.KeepModifiedDataCopy
                self.Data_I=[];
            end


            self.DataUpdateRequired=false;
        end


        function s=getContainerInstructions(self)


            s=getInstructionSet(self);
        end

    end

    methods(Access={?images.ui.graphics3d.Viewer3D...
        ,?images.ui.graphics3d.Volume,...
        ?images.ui.graphics3d.internal.Points,...
        ?images.ui.graphics3d.Surface})


        function tform=getTransformMatrix(self)
            tform=single(self.Transformation_I.T);
            if self.DownsampleLevel_I>1&&isa(self,'images.ui.graphics3d.Volume')

                tform=makehgtform('scale',self.DownsampleLevel_I)*tform;
            end
        end

    end

    methods(Access=protected)


        function propertiesUpdated(self)


            if~self.IsContainerReady
                return;
            end

            notify(self,'ContainerUpdated');

        end


        function updateBoundingBox(self,minX,maxX,minY,maxY,minZ,maxZ)

            self.BoundingBoxCoordinates=[minX,minY,minZ;...
            maxX,minY,minZ;...
            minX,maxY,minZ;...
            maxX,maxY,minZ;...
            minX,minY,maxZ;...
            maxX,minY,maxZ;...
            minX,maxY,maxZ;...
            maxX,maxY,maxZ];

            transformBoundingBox(self);

        end


        function transformBoundingBox(self)



            tformedPoints=[self.BoundingBoxCoordinates,ones([size(self.BoundingBoxCoordinates,1),1])]*self.Transformation_I.T;

            self.BoundingBox=[min(tformedPoints(:,1:3),[],1);
            max(tformedPoints(:,1:3),[],1)];

            notify(self,'TransformationUpdated');

        end

    end

    methods




        function set.Transformation(self,T)
            if isa(T,"double")
                T=affinetform3d(T);
            end
            self.Transformation_I=T;
            if~self.IsContainerEmpty
                transformBoundingBox(self);
                propertiesUpdated(self);
            end
        end

        function T=get.Transformation(self)
            T=self.Transformation_I;
        end




        function set.Visible(self,TF)
            self.Visible_I=TF;
            propertiesUpdated(self);
        end

        function TF=get.Visible(self)
            TF=matlab.lang.OnOffSwitchState(self.Visible_I);
        end




        function set.ClippingPlanes(self,planes)
            if size(planes,1)>6
                error(message('images:volume:clippingPlaneMax'));
            end
            planes=images.ui.graphics3d.internal.validatePlanes(planes,[],false);
            self.ClippingPlanes_I=planes';
            propertiesUpdated(self);

        end

        function planes=get.ClippingPlanes(self)
            planes=self.ClippingPlanes_I';
        end




        function set.Parent(self,viewer)

            if~isempty(self.Parent_I)
                error(message('images:volume:noReparent'));
            end

            if~isgraphics(viewer)||~isa(viewer,'images.ui.graphics3d.Viewer3D')
                error(message('images:volume:invalidViewer'));
            end

            self.Parent_I=viewer;
            addChild(viewer,self);

        end

        function viewer=get.Parent(self)
            viewer=self.Parent_I;
        end




        function set.Data(self,data)
            setData(self,data);
        end

        function data=get.Data(self)
            data=self.OriginalData;
        end




        function TF=get.Empty(self)
            TF=self.IsContainerEmpty||~self.Visible_I;
        end

    end

end