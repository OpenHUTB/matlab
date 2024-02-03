classdef(Sealed)Volume<images.ui.graphics3d.GraphicsContainer&...
    images.ui.graphics3d.internal.Compatibility

    events(ListenAccess=public,NotifyAccess=?images.ui.graphics3d.Viewer3D)

SlicePlanesChanging
SlicePlanesChanged

    end


    properties(Dependent)

        GradientOpacityValue(1,1)single{mustBeNonnegative,mustBeLessThanOrEqual(GradientOpacityValue,1)}
        SlicePlaneValues(:,4){mustBeFinite,mustBeNonNan,mustBeReal,mustBeNonsparse}
        IsosurfaceValue(1,1)single{mustBeInRange(IsosurfaceValue,0,1),mustBeNonNan,mustBeReal,mustBeNonsparse}

OverlayData
        OverlayRenderingStyle string{mustBeMember(OverlayRenderingStyle,["VolumeOverlay","GradientOverlay","LabelOverlay"])}
        OverlayColormap(:,3)single{mustBeInRange(OverlayColormap,0,1),mustBeNonNan,mustBeReal,mustBeNonsparse}
        OverlayAlphamap(:,1)single{mustBeInRange(OverlayAlphamap,0,1),mustBeNonNan,mustBeReal,mustBeNonsparse}
        OverlayThreshold(1,1)single{mustBeInRange(OverlayThreshold,0,1),mustBeNonNan,mustBeReal,mustBeNonsparse}

        Alphamap(:,1)single{mustBeInRange(Alphamap,0,1),mustBeNonNan,mustBeReal,mustBeNonsparse}
AlphaData
Colormap

        RenderingStyle string{mustBeMember(RenderingStyle,["VolumeRendering","MaximumIntensityProjection","MinimumIntensityProjection","Isosurface","SlicePlanes","GradientOpacity"])}

    end


    properties(Hidden,Dependent)
        DepthValue(1,1)single{mustBeInRange(DepthValue,0,1),mustBeNonNan,mustBeReal,mustBeNonsparse}

        Interpolation string{mustBeMember(Interpolation,["bilinear","nearest"])}
        SmoothIsosurface(1,1)matlab.lang.OnOffSwitchState

    end

    properties(Dependent,Hidden,SetAccess=private,GetAccess=public)

NumChannels

    end


    properties(Hidden)

        RescaleData(1,1)logical=true;
        RescaleOverlayData(1,1)logical=true;
    end


    properties(Hidden,SetAccess=private)
        Size(1,3)single=[0,0,0];
        OverlaySize(1,3)single=[0,0,0];
        OriginalSize(1,3)single=[0,0,0];
    end


    properties(Access=?images.ui.graphics3d.Viewer3D)

        SlicePlanes_I(4,:)single=[];

    end


    properties(Access=private)
        GradientOpacityValue_I(1,1)single=0.3;
        DepthValue_I(1,1)single=0.05;
        Isovalue_I(1,1)single=0.15;

        OverlayData_I(:,:,:)=[];
        OverlayRenderingStyle_I(1,1)string="LabelOverlay";
        OverlayAlpha_I(:,1)single=0.2;
        OverlayColor_I(:,3)single=turbo(256);
        OverlayAlphamap_I(256,1)uint8=im2uint8(repmat(0.2,[256,1]));
        OverlayColormap_I(3,256)uint8=im2uint8(turbo(256)');
        OverlayThreshold_I(1,1)single=0.001;
        OriginalOverlayData(:,:,:)=[];

        Alpha_I(:,1)single=linspace(0,1,256)';
        Color_I(:,3)single=repmat(linspace(0,1,256)',[1,3]);
        Alphamap_I(256,1)uint8=im2uint8(linspace(0,1,256)');
        Colormap_I(3,256)uint8=im2uint8(repmat(linspace(0,1,256),[3,1]));
        AlphaData_I(:,:,:)=[];
        OriginalAlphaData(:,:,:)=[];
        UseAlphaData(1,1)logical=false;

        RenderingStyle_I(1,1)string="VolumeRendering";

        Interpolation_I(1,1)string="bilinear";
        NumChannels_I(1,1)double=1;
        SmoothIsosurface_I(1,1)logical=true;

    end


    methods

        function self=Volume(h,varargin)
            self@images.ui.graphics3d.GraphicsContainer(h,"volume",varargin{:});
        end

    end


    methods(Access=protected)

        function validateData(self,vol,type)

            if isempty(vol)

                setEmptyData(self,type);
                return;
            end

            sz=size(vol);

            if any(sz>self.Max3DTextureSize)
                error(message('images:volume:max3DTexture',self.Max3DTextureSize));
            end
            supportedDataTypes={'numeric','logical'};
            supportedAttributes={'real','nonsparse','finite','nonnan'};

            switch type
            case "Data"
                if~(ndims(vol)==3&&all(sz>1))
                    if~(ndims(vol)==4&&all(sz>1))
                        error(message('images:volume:requireVolumeData'));
                    end
                    if sz(4)~=3
                        error(message('images:volume:invalid4DVolume'));
                    end
                end

            case "OverlayData"
                if~(ndims(vol)==3&&all(sz>1))
                    error(message('images:volume:require3DData'));
                end
                supportedDataTypes={'numeric','logical','categorical'};
                if iscategorical(vol)
                    supportedAttributes={'real','nonsparse'};
                end

            case "AlphaData"
                if~(ndims(vol)==3&&all(sz>1))
                    error(message('images:volume:require3DData'));
                end
                if~isequal([sz(2),sz(1),sz(3)],self.OriginalSize)
                    error(message('images:volume:alphaDataSize',string(num2str([self.OriginalSize(2),self.OriginalSize(1),self.OriginalSize(3)]))));
                end
            end

            validateattributes(vol,supportedDataTypes,supportedAttributes);

            notify(self,'DataBeingUpdated');

            sizeChanged=false;

            sz=[sz(2),sz(1),sz(3)];

            if self.KeepOriginalDataCopy
                switch type
                case "Data"
                    self.OriginalData=vol;
                case "OverlayData"
                    self.OriginalOverlayData=vol;
                case "AlphaData"
                    self.OriginalAlphaData=vol;
                end
            end

            vol=sanitizeData(self,vol,type);

            switch type
            case "Data"
                if any(self.OverlaySize>0)

                    if~isequal(self.OverlaySize,sz)
                        setEmptyData(self,"OverlayData");
                        sizeChanged=true;
                    end
                else
                    if any(self.Size>0)
                        sizeChanged=~isequal(sz,self.Size);
                    else
                        sizeChanged=true;
                    end
                end

                self.Size=sz;
                self.OriginalSize=sz;
                self.DataModified=true;

            case "OverlayData"
                if any(self.Size>0)

                    if~isequal(self.Size,sz)
                        setEmptyData(self,"Data");
                        sizeChanged=true;
                    end
                else
                    if any(self.OverlaySize>0)
                        sizeChanged=~isequal(sz,self.OverlaySize);
                    else
                        sizeChanged=true;
                    end
                end

                self.OverlaySize=sz;
                self.OriginalSize=sz;
                self.OverlayDataModified=true;

            case "AlphaData"
                self.UseAlphaData=true;
                self.AlphaDataModified=true;

            end

            if sizeChanged
                self.SlicePlanes_I=[-1,0,0,floor(self.OriginalSize(1)/2);
                0,-1,0,floor(self.OriginalSize(2)/2);
                0,0,-1,floor(self.OriginalSize(3)/2)]';

                updateBoundingBox(self,0.5,self.OriginalSize(1)+0.5,0.5,self.OriginalSize(2)+0.5,0.5,self.OriginalSize(3)+0.5);
                setEmptyData(self,"AlphaData");
            end

            downsampleData(self,vol,type);

            updateAlphamap(self);

            self.IsContainerEmpty=false;
            propertiesUpdated(self);

        end


        function setEmptyData(self,type)

            switch type
            case "Data"
                if isempty(self.Data_I)
                    return;
                end
                if~any(self.OverlaySize>0)
                    emptyContainer(self);
                end
                self.Size=[0,0,0];
                self.Data_I=[];
                self.OriginalData=[];
                self.DataModified=true;
                updateAlphamap(self);

            case "OverlayData"
                if isempty(self.OverlayData_I)
                    return;
                end
                if~any(self.Size>0)
                    emptyContainer(self);
                end
                self.OverlaySize=[0,0,0];
                self.OverlayData_I=[];
                self.OriginalOverlayData=[];
                self.OverlayDataModified=true;
                updateAlphamap(self);

            case "AlphaData"
                if isempty(self.AlphaData_I)
                    return;
                end
                self.AlphaData_I=[];
                self.OriginalAlphaData=[];
                self.UseAlphaData=false;
                self.AlphaDataModified=true;

            end

            propertiesUpdated(self);

        end


        function emptyContainer(self)
            updateBoundingBox(self,-Inf,Inf,-Inf,Inf,-Inf,Inf);
            self.SlicePlanes_I=[];
            self.IsContainerEmpty=true;
            self.OriginalSize=[0,0,0];
            setEmptyData(self,"AlphaData");
        end


        function cmap=createColormap(~,color)
            cmap=im2uint8(imresize(color,[256,3],'nearest'))';
        end


        function amap=createAlphamap(~,alpha,sz)
            if all(sz>0)
                amap=im2uint8(imresize(alpha,[256,1],'bicubic'));
            else

                amap=zeros([256,1],'uint8');
            end
        end


        function vol=sanitizeData(self,vol,type)


            datatype=class(vol);
            permuteIndices=[2,1,3,4];

            switch type

            case "Data"
                self.NumChannels_I=size(vol,4);

                if self.NumChannels_I==3
                    switch datatype
                    case{'double','single'}
                        limits=[0,1];
                    case 'logical'

                        limits=[0,1];
                    otherwise
                        limits=[intmin(datatype),intmax(datatype)];
                    end


                    if self.RescaleData
                        vol=images.ui.graphics3d.internal.rescaleVolume(vol,limits,limits,limits);
                    else
                        vol=im2uint8(vol);
                    end
                    permuteIndices=[4,2,1,3];
                else
                    if self.RescaleData
                        vol=images.ui.graphics3d.internal.rescaleVolume(vol,[],[],[]);
                    else
                        vol=im2uint8(vol);
                    end
                end

            case "OverlayData"
                if iscategorical(vol)
                    numCats=numel(categories(vol));
                    limits=single([0,numCats]);

                    if limits(2)==limits(1)
                        vol=zeros(size(vol),'uint8');
                    else
                        vol=uint8((single(vol)-single(limits(1)))./(single(limits(2)-limits(1)))*255);
                    end

                else
                    if self.RescaleOverlayData
                        vol=images.ui.graphics3d.internal.rescaleVolume(vol,[],[],[]);
                    else
                        vol=im2uint8(vol);
                    end
                end

            case "AlphaData"
                vol=im2uint8(vol);

            end

            vol=permute(vol,permuteIndices);

        end


        function downsampleData(self,vol,type)

            switch type

            case "Data"
                if self.DownsampleLevel_I>1
                    newSize=self.OriginalSize;
                    newSize(newSize>10)=ceil(newSize(newSize>10)/self.DownsampleLevel_I);
                    if~isequal(newSize,self.OriginalSize)
                        if self.NumChannels_I==3
                            oldVol=vol;
                            vol=zeros([3,newSize],'uint8');
                            for i=1:3
                                vol(i,:,:,:)=imresize3(squeeze(oldVol(i,:,:,:)),newSize,'nearest');
                            end
                            self.Size=newSize;
                        else
                            vol=imresize3(vol,newSize,'nearest');
                            self.Size=size(vol,1:3);
                        end
                    end
                end
                self.Data_I=vol(:);

            case "OverlayData"
                if self.DownsampleLevel_I>1
                    newSize=self.OriginalSize;
                    newSize(newSize>10)=ceil(newSize(newSize>10)/self.DownsampleLevel_I);
                    if~isequal(newSize,self.OriginalSize)
                        vol=imresize3(vol,newSize,'nearest');
                        self.OverlaySize=size(vol,1:3);
                    end
                end
                self.OverlayData_I=vol(:);

            case "AlphaData"
                if self.DownsampleLevel_I>1
                    vol=imresize3(vol,self.Size,'nearest');
                end
                self.AlphaData_I=vol(:);
            end

        end


        function applyDownsample(self)
            sz=self.Size;
            if~isempty(self.Data_I)
                if self.NumChannels_I==3
                    downsampleData(self,reshape(self.Data_I,[3,self.Size]),"Data");
                else
                    downsampleData(self,reshape(self.Data_I,self.Size),"Data");
                end
            end
            if~isempty(self.OverlayData_I)
                downsampleData(self,reshape(self.OverlayData_I,self.OverlaySize),"OverlayData");
            end
            if~isempty(self.AlphaData_I)
                downsampleData(self,reshape(self.AlphaData_I,sz),"AlphaData");
            end
        end


        function s=getPropertyStruct(self)

            s=struct('RenderingStyle',self.RenderingStyle_I,...
            'NumChannels',self.NumChannels_I,...
            'Colormap',self.Colormap_I,...
            'Alphamap',self.Alphamap_I,...
            'UseAlphaData',self.UseAlphaData,...
            'Transform',getTransformMatrix(self),...
            'Isovalue',self.Isovalue_I,...
            'GradientOpacityLimits',[0,self.GradientOpacityValue_I],...
            'SlicePlanes',self.SlicePlanes_I(:),...
            'ClippingPlanes',self.ClippingPlanes_I(:),...
            'Visible',self.Visible_I,...
            'Interpolation',self.Interpolation_I,...
            'IsNewObject',~self.IsContainerConstructed,...
            'IsEmpty',self.IsContainerEmpty,...
            'Type',self.Type,...
            'DownsampleLevel',self.DownsampleLevel_I,...
            'DepthSensitivity',self.DepthValue_I,...
            'OverlayColormap',self.OverlayColormap_I,...
            'OverlayAlphamap',self.OverlayAlphamap_I,...
            'OverlayRenderingStyle',self.OverlayRenderingStyle_I,...
            'OverlayThreshold',self.OverlayThreshold_I,...
            'SmoothIsosurface',self.SmoothIsosurface_I);

        end


        function setData(self,vol)
            validateData(self,vol,"Data");
        end


        function data=getData(self)

            data=[];
            if self.DataModified
                data=self.Data_I;
            end
            if self.OverlayDataModified
                data=[data;self.OverlayData_I];
            end
            if self.AlphaDataModified
                data=[data;self.AlphaData_I];
            end

            if~self.KeepModifiedDataCopy
                self.OverlayData_I=[];
                self.AlphaData_I=[];
            end

        end


        function s=getInstructionSet(self)
            binaryChannelNeeded=((self.DataModified&&~isempty(self.Data_I))||...
            (self.OverlayDataModified&&~isempty(self.OverlayData_I))||...
            (self.AlphaDataModified&&~isempty(self.AlphaData_I)));
            s=struct('DataModified',self.DataModified,...
            'OverlayDataModified',self.OverlayDataModified,...
            'AlphaDataModified',self.AlphaDataModified,...
            'Size',self.Size,...
            'OverlaySize',self.OverlaySize,...
            'UseAlphaData',self.UseAlphaData,...
            'NumChannels',self.NumChannels,...
            'UseBinaryChannel',binaryChannelNeeded);
        end


        function isVolumeOpaque(self)
            switch self.RenderingStyle_I
            case{"Isosurface","SlicePlanes"}
                self.Opaque=true;
            case "GradientOpacity"
                self.Opaque=false;
            otherwise
                if self.UseAlphaData
                    if~isempty(self.AlphaData_I)
                        self.Opaque=all(self.AlphaData_I>uint8(243));
                    else
                        self.Opaque=false;
                    end
                else
                    self.Opaque=all(self.Alphamap_I>uint8(243));
                end
            end
        end


        function updateAlphamap(self)
            self.Alphamap_I=createAlphamap(self,self.Alpha_I,self.Size);
            self.OverlayAlphamap_I=createAlphamap(self,self.OverlayAlpha_I,self.OverlaySize);
        end

    end


    methods(Sealed,Access=protected)

        function group=getPropertyGroups(obj)

            if obj.NumChannels_I==3
                propList={'RenderingStyle','Data','Alphamap','AlphaData','Parent','Visible'};
                otherList={'ClippingPlanes','SlicePlaneValues','Transformation'};
            else
                propList={'RenderingStyle','Data','Colormap','Alphamap','AlphaData','Parent','Visible'};
                otherList={'ClippingPlanes','SlicePlaneValues','IsosurfaceValue','GradientOpacityValue','Transformation'};
            end
            overlayList={'OverlayRenderingStyle','OverlayData','OverlayColormap','OverlayAlphamap','OverlayThreshold'};

            group=[matlab.mixin.util.PropertyGroup(propList),...
            matlab.mixin.util.PropertyGroup(overlayList),...
            matlab.mixin.util.PropertyGroup(otherList)];

        end

    end


    methods

        function set.RenderingStyle(self,val)
            self.RenderingStyle_I=val;
            isVolumeOpaque(self);
            propertiesUpdated(self);
        end


        function val=get.RenderingStyle(self)
            val=self.RenderingStyle_I;
        end


        function set.Interpolation(self,val)
            self.Interpolation_I=val;
            propertiesUpdated(self);
        end


        function val=get.Interpolation(self)
            val=self.Interpolation_I;
        end


        function set.Colormap(self,cmap)
            if ischar(cmap)||isstring(cmap)||numel(cmap)==3
                self.Color_I=convertColorSpec(images.internal.ColorSpecToRGBConverter,cmap);
            else
                validateattributes(cmap,{'numeric'},{'size',[NaN,3],'nonsparse','real','finite','nonnan','nonempty','>=',0,'<=',1});
                self.Color_I=cmap;
            end
            self.Colormap_I=createColormap(self,self.Color_I);
            propertiesUpdated(self);
        end

        function cmap=get.Colormap(self)
            cmap=self.Color_I;
        end




        function set.Alphamap(self,amap)
            self.Alpha_I=amap;
            self.Alphamap_I=createAlphamap(self,self.Alpha_I,self.Size);
            isVolumeOpaque(self);
            propertiesUpdated(self);
        end

        function amap=get.Alphamap(self)
            amap=self.Alpha_I;
        end




        function set.AlphaData(self,data)
            validateData(self,data,"AlphaData");
        end

        function data=get.AlphaData(self)
            data=self.OriginalAlphaData;
        end




        function set.IsosurfaceValue(self,val)
            self.Isovalue_I=val;
            propertiesUpdated(self);
        end

        function val=get.IsosurfaceValue(self)
            val=self.Isovalue_I;
        end




        function set.DepthValue(self,val)
            self.DepthValue_I=val;
            propertiesUpdated(self);
        end

        function val=get.DepthValue(self)
            val=self.DepthValue_I;
        end




        function set.SmoothIsosurface(self,val)
            self.SmoothIsosurface_I=val;
            propertiesUpdated(self);
        end

        function val=get.SmoothIsosurface(self)
            val=logical(self.SmoothIsosurface_I);
        end




        function set.GradientOpacityValue(self,val)
            self.GradientOpacityValue_I=val;
            propertiesUpdated(self);
        end

        function val=get.GradientOpacityValue(self)
            val=self.GradientOpacityValue_I;
        end




        function set.SlicePlaneValues(self,planes)
            if size(planes,1)>6
                error(message('images:volume:slicePlaneMax'));
            end
            planes=images.ui.graphics3d.internal.validatePlanes(planes,[0.5,0.5,0.5;self.OriginalSize+0.5],true);
            self.SlicePlanes_I=planes';
            propertiesUpdated(self);
        end

        function planes=get.SlicePlaneValues(self)
            planes=self.SlicePlanes_I';
        end




        function set.OverlayColormap(self,cmap)
            if ischar(cmap)||isstring(cmap)||numel(cmap)==3
                self.OverlayColor_I=convertColorSpec(images.internal.ColorSpecToRGBConverter,cmap);
            else
                self.OverlayColor_I=cmap;
            end
            self.OverlayColormap_I=createColormap(self,self.OverlayColor_I);
            propertiesUpdated(self);
        end

        function cmap=get.OverlayColormap(self)
            cmap=self.OverlayColor_I;
        end




        function set.OverlayAlphamap(self,amap)
            self.OverlayAlpha_I=amap;
            self.OverlayAlphamap_I=createAlphamap(self,self.OverlayAlpha_I,self.OverlaySize);
            propertiesUpdated(self);
        end

        function amap=get.OverlayAlphamap(self)
            amap=self.OverlayAlpha_I;
        end




        function set.OverlayThreshold(self,val)
            self.OverlayThreshold_I=val;
            propertiesUpdated(self);
        end

        function val=get.OverlayThreshold(self)
            val=self.OverlayThreshold_I;
        end




        function set.OverlayRenderingStyle(self,val)
            self.OverlayRenderingStyle_I=val;
            propertiesUpdated(self);
        end

        function val=get.OverlayRenderingStyle(self)
            val=self.OverlayRenderingStyle_I;
        end




        function set.OverlayData(self,data)
            validateData(self,data,"OverlayData");
        end

        function data=get.OverlayData(self)
            data=self.OriginalOverlayData;
        end




        function val=get.NumChannels(self)
            if~any(self.Size>0)
                val=[];
            else
                val=self.NumChannels_I;
            end
        end

    end

end