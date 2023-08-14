classdef(Sealed)Points<images.ui.graphics3d.GraphicsContainer




    properties(Dependent)

        Alpha(1,1)single{mustBeInRange(Alpha,0,1),mustBeNonNan,mustBeReal,mustBeNonsparse}
Color
        PointSize(1,1)single{mustBeGreaterThanOrEqual(PointSize,1)}

    end

    properties(GetAccess=public,SetAccess=private)

        NumPoints(1,1)double=0;

    end

    properties(Access=private)

        Alpha_I(1,1)single=1.0;
        Color_I(:,3)single
        VertexColors_I(:,3)single
        PointSize_I(1,1)single=1.0;

        ColorByVertex(1,1)logical=false;
PointCloud

    end

    methods




        function self=Points(h,varargin)
            self@images.ui.graphics3d.GraphicsContainer(h,"points",varargin{:});
        end

    end

    methods(Access=protected)


        function setData(self,data)

            if isempty(data)

                setEmptyData(self);
                return;
            end

            validateattributes(data,{'numeric','pointCloud'},{'real','nonsparse'});

            if isa(data,'pointCloud')
                if isempty(data.Location)
                    setEmptyData(self);
                    return;
                end
                usePointCloud=true;
            else
                if~ismatrix(data)||size(data,2)~=3
                    error(message('images:volume:invalidPoints'));
                end
                usePointCloud=false;
            end




            notify(self,'DataBeingUpdated');

            if self.KeepOriginalDataCopy
                self.OriginalData=data;
            end
            if usePointCloud
                if ismatrix(data.Location)
                    setPointCloud(self,data.Location);
                else
                    X=reshape(data.Location(:,:,1),[],1);
                    Y=reshape(data.Location(:,:,2),[],1);
                    Z=reshape(data.Location(:,:,3),[],1);
                    data=[X(:),Y(:),Z(:)];
                    setPointCloud(self,data);
                end
            else
                setPointCloud(self,data);
            end

            self.IsContainerEmpty=false;
            self.DataModified=true;

            propertiesUpdated(self);
        end


        function setEmptyData(self)

            if~isempty(self.Data_I)
                updateBoundingBox(self,-Inf,Inf,-Inf,Inf,-Inf,Inf);

                self.Data_I=[];
                self.OriginalData=[];
                self.DataModified=true;
                self.IsContainerEmpty=true;

                propertiesUpdated(self);
            end

            self.NumPoints=0;
            self.PointCloud=[];
            clearVertexColors(self);

        end


        function applyDownsample(self)


            if~isempty(self.Data_I)
                data=self.PointCloud(1:self.DownsampleLevel_I:end,:);
                setPointCloud(self,data);
            end
        end


        function setPointCloud(self,data)
            self.PointCloud=single(data);

            if self.NumPoints~=size(self.PointCloud,1)
                clearVertexColors(self);
                self.NumPoints=size(self.PointCloud,1);
            end

            minVal=min(self.PointCloud,[],1);
            maxVal=max(self.PointCloud,[],1);

            updateBoundingBox(self,minVal(1),maxVal(1),minVal(2),maxVal(2),minVal(3),maxVal(3));

            xyzPoints=self.PointCloud';
            self.Data_I=xyzPoints(:);
        end


        function clearVertexColors(self)
            self.ColorByVertex=false;
            self.VertexColors_I=[];
        end


        function s=getPropertyStruct(self)

            s=struct('Color',self.Color_I,...
            'Alpha',self.Alpha_I,...
            'PointSize',self.PointSize_I,...
            'Transform',getTransformMatrix(self),...
            'ClippingPlanes',self.ClippingPlanes_I(:),...
            'ColorByVertex',self.ColorByVertex,...
            'Visible',self.Visible_I,...
            'IsNewObject',~self.IsContainerConstructed,...
            'IsEmpty',self.IsContainerEmpty,...
            'Type',self.Type);
        end


        function data=getData(self)



            if self.ColorByVertex
                xyzColors=self.VertexColors_I';
                data=[self.Data_I;xyzColors(:)];
            else
                data=self.Data_I;
            end
        end


        function s=getInstructionSet(self)

            s=struct('ColorByVertex',self.ColorByVertex,...
            'UseBinaryChannel',~isempty(self.Data_I));
        end

    end

    methods(Sealed,Access=protected)

        function group=getPropertyGroups(~)

            propList={'Data','Color','Alpha','PointSize','Parent','Visible'};
            otherList={'ClippingPlanes','Transformation'};

            group=[matlab.mixin.util.PropertyGroup(propList),...
            matlab.mixin.util.PropertyGroup(otherList)];

        end

    end

    methods




        function set.Color(self,color)
            if ischar(color)||isstring(color)||numel(color)==3
                self.Color_I=convertColorSpec(images.internal.ColorSpecToRGBConverter,color);
                if self.ColorByVertex
                    self.DataModified=true;
                end
                clearVertexColors(self);
            else
                validateattributes(color,{'numeric'},{'size',[self.NumPoints,3],'nonsparse','finite','nonnan','nonempty','>=',0,'<=',1});
                self.ColorByVertex=true;
                self.DataModified=true;
                self.VertexColors_I=color;
            end
            propertiesUpdated(self);
        end

        function cmap=get.Color(self)
            if self.ColorByVertex
                cmap=self.VertexColors_I;
            else
                cmap=self.Color_I;
            end
        end




        function set.Alpha(self,val)
            self.Alpha_I=val;
            self.Opaque=val>0.95;
            propertiesUpdated(self);
        end

        function val=get.Alpha(self)
            val=self.Alpha_I;
        end




        function set.PointSize(self,val)
            self.PointSize_I=val;
            propertiesUpdated(self);
        end

        function val=get.PointSize(self)
            val=self.PointSize_I;
        end

    end

end