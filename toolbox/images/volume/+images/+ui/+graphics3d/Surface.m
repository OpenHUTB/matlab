classdef(Sealed)Surface<images.ui.graphics3d.GraphicsContainer




    properties(Dependent)

        Alpha(1,1)single{mustBeInRange(Alpha,0,1),mustBeNonNan,mustBeReal,mustBeNonsparse}
Color
        Wireframe(1,1)matlab.lang.OnOffSwitchState

    end

    properties(GetAccess=public,SetAccess=private)

        NumVertices(1,1)double=0;

    end

    properties(Access=private)

        Alpha_I(1,1)single=0.15;
        Color_I(:,3)single
        Wireframe_I(1,1)logical=false;
        VertexColors_I(:,3)single

        ColorByVertex(1,1)logical=false;
Triangulation

    end

    properties(Constant,Access=private)


        Isovalue=0.05;

    end

    methods




        function self=Surface(h,varargin)
            self@images.ui.graphics3d.GraphicsContainer(h,"surface",varargin{:});
        end

    end

    methods(Access=protected)


        function setData(self,data)

            if isempty(data)

                setEmptyData(self);
                return;
            end

            validateattributes(data,{'triangulation','logical'},{'real','nonsparse'});

            if isa(data,'triangulation')
                if size(data.Points,2)~=3
                    error(message('images:volume:invalidTriangulation'))
                end
                reuseTriangulation=true;
            else
                if~islogical(data)
                    error(message('images:volume:invalidInput'))
                end
                sz=size(data);
                if~(ndims(data)==3&&all(sz>1))
                    error(message('images:volume:invalidMask'));
                end
                reuseTriangulation=false;
                if~any(data,'all')
                    setEmptyData(self);
                    return;
                end
            end




            notify(self,'DataBeingUpdated');

            if self.KeepOriginalDataCopy
                self.OriginalData=data;
            end

            if reuseTriangulation
                tri=data;
            else


                [f,v]=images.internal.marchingcubes(data,self.Isovalue);
                tri=triangulation(double(f),double(v));
            end

            setTriangulation(self,tri);

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

            self.NumVertices=0;
            self.Triangulation=[];
            clearVertexColors(self);

        end


        function applyDownsample(self)


            if~isempty(self.Data_I)
                [nf,nv]=reducepatch(self.Triangulation.ConnectivityList,self.Triangulation.Points,1/self.DownsampleLevel_I);
                setTriangulation(self,triangulation(nf,nv));
            end
        end


        function setTriangulation(self,tri)


            self.Triangulation=tri;

            indices=self.Triangulation.ConnectivityList';
            indices=indices(:);
            xyzPoints=self.Triangulation.Points(indices,:);

            if self.NumVertices~=size(self.Triangulation.Points,1)
                clearVertexColors(self);
                self.NumVertices=size(self.Triangulation.Points,1);
            end

            minVal=min(xyzPoints,[],1);
            maxVal=max(xyzPoints,[],1);

            updateBoundingBox(self,minVal(1),maxVal(1),minVal(2),maxVal(2),minVal(3),maxVal(3));

            xyzPoints=xyzPoints';
            self.Data_I=single(xyzPoints(:));
        end


        function clearVertexColors(self)
            self.ColorByVertex=false;
            self.VertexColors_I=[];
        end


        function s=getPropertyStruct(self)

            s=struct('Color',self.Color_I,...
            'Alpha',self.Alpha_I,...
            'Wireframe',self.Wireframe_I,...
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
                indices=self.Triangulation.ConnectivityList';
                xyzColors=self.VertexColors_I(indices(:),:)';
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

            propList={'Data','Color','Alpha','Wireframe','Parent','Visible'};
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
                validateattributes(color,{'numeric'},{'size',[self.NumVertices,3],'nonsparse','finite','nonnan','nonempty','>=',0,'<=',1});
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




        function set.Wireframe(self,val)
            self.Wireframe_I=val;
            propertiesUpdated(self);
        end

        function val=get.Wireframe(self)
            val=matlab.lang.OnOffSwitchState(self.Wireframe_I);
        end

    end

end