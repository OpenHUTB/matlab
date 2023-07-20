classdef(ConstructOnLoad,Sealed)TexturedQuad...
    <matlab.graphics.primitive.world.Group...
    &matlab.graphics.mixin.AxesParentable


    properties(AffectsObject)
        XLimits=[0,1]
        YLimits=[0,1]
    end

    properties(Dependent,AffectsObject)

CData
    end

    properties(Hidden,AffectsObject)

        ForceGrayScaleRendering=false;
    end

    properties(Transient,Access=private,Hidden,NonCopyable)

        TriangleStrip matlab.graphics.primitive.world.TriangleStrip
    end

    properties(Transient,Access=public,Hidden,NonCopyable)

RGBCDataCache
    end

    methods
        function obj=TexturedQuad(interpolation)
            if nargin==0

                interpolation='nearest';
            end

            ts=matlab.graphics.primitive.world.TriangleStrip;
            tx=matlab.graphics.primitive.world.Texture;
            tx.ColorType='truecoloralpha';
            if ispc&&isSoftwareOpenGL()
                tx.SamplingFilter='nearest';
            else
                tx.SamplingFilter=interpolation;
            end
            ts.Layer='back';
            ts.StripData=uint32([1,5]);
            ts.VertexData=single([0,0,1,1;0,1,0,1;0,0,0,0]);
            ts.ColorData=single([0,0,1,1;0,1,0,1]);
            ts.ColorType='texturemapped';
            ts.ColorBinding='none';
            ts.ColorBinding='interpolated';
            ts.PickableParts='none';
            ts.Texture=tx;
            ts.Visible='off';
            addNode(obj,ts);
            obj.TriangleStrip=ts;
            obj.Visible='off';

            obj.Internal=true;
        end

        function setCDataFrom(obj,rawData,cdataMapping,alpha,alphaMapping,colorspace)



            if isempty(rawData)
                obj.CData=uint8.empty;
                return
            end

            if iscategorical(rawData)
                if numel(categories(rawData))<255
                    rawData=uint8(rawData);
                else
                    rawData=double(rawData);
                end
            end

            if isa(rawData,'uint8')&&size(rawData,3)==3&&isempty(alpha)

                rgba=ones([4,size(rawData,2),size(rawData,1)],'uint8')*255;
                rgba(1:3,:,:)=permute(rawData,[3,2,1]);
                obj.CData=rgba;
                return
            end

            if~isempty(alpha)&&~isscalar(alpha)

                alpha=imresize(alpha,[size(rawData,1),size(rawData,2)],'nearest');
            end

            ci=matlab.graphics.axis.colorspace.IndexColorsIterator;

            ci.Colors=rawData;
            if~isempty(alpha)
                ci.AlphaData=alpha(:);
            end
            ci.AlphaDataMapping=alphaMapping;
            ci.CDataMapping=cdataMapping;

            if size(rawData,3)==3
                cdata=TransformTrueColorToTrueColor(colorspace,ci);
            else
                cdata=TransformColormappedToTrueColor(colorspace,ci);
            end
            rgba=reshape(cdata.Data,[4,size(rawData,1),size(rawData,2)]);
            rgba=permute(rgba,[1,3,2]);

            obj.CData=rgba;
        end


        function set.CData(obj,RGB)


            obj.TriangleStrip.Texture.CData=RGB;
        end
    end

    methods(Hidden)
        function doUpdate(obj,~)
            obj.TriangleStrip.Visible=obj.Visible;
            if obj.Visible

                obj.TriangleStrip.VertexData=single([...
                obj.XLimits([1,1,2,2]);
                obj.YLimits([1,2,1,2]);
                [0,0,0,0]]);

                if obj.ForceGrayScaleRendering
                    if isempty(obj.RGBCDataCache)
                        obj.RGBCDataCache=obj.TriangleStrip.Texture.CData;
                    end
                    obj.TriangleStrip.Texture.CData=convertToGray(obj.TriangleStrip.Texture.CData);
                else

                    if~isempty(obj.RGBCDataCache)
                        obj.TriangleStrip.Texture.CData=obj.RGBCDataCache;
                    end
                end
            end
        end
    end
end

function tf=isSoftwareOpenGL()
    info=opengl('data');
    tf=(info.Software==1);
end

function im=convertToGray(im)
    grayComp=0.2989*im(1,:,:)+0.5870*im(2,:,:)+0.1140*im(3,:,:);
    im(1,:,:)=grayComp;
    im(2,:,:)=grayComp;
    im(3,:,:)=grayComp;
end
