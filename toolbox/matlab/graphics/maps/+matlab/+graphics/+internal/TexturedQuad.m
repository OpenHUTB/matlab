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

    properties(Dependent,AffectsObject)

AlphaData
    end

    properties(AffectsObject)
        GrayscaleRendering=matlab.lang.OnOffSwitchState.off
    end

    properties(Access=private)
        CData_I=uint8.empty
    end

    properties(Access=private)
        AlphaData_I=uint8(255)
    end

    properties(Transient,Access=public,Hidden,NonCopyable)

        TriangleStrip matlab.graphics.primitive.world.TriangleStrip
    end


    methods(Access=protected,Hidden)
        function groups=getPropertyGroups(~)

            props={
            'XLimits','YLimits','CData','AlphaData'...
            ,'GrayscaleRendering','Visible'
            };
            groups=matlab.mixin.util.PropertyGroup(props);
        end
    end


    methods
        function obj=TexturedQuad


            ts=matlab.graphics.primitive.world.TriangleStrip;
            tx=matlab.graphics.primitive.world.Texture;
            tx.ColorType='truecolor';
            if ispc&&isSoftwareOpenGL()
                tx.SamplingFilter='nearest';
            else
                tx.SamplingFilter='linear';
            end
            ts.Layer='back';
            ts.StripData=uint32([1,5]);
            ts.VertexData=single([0,0,1,1;0,1,0,1;0,0,0,0]);
            ts.ColorData=single([0,0,1,1;0,1,0,1]);
            ts.ColorType='texturemapped';
            ts.ColorBinding='none';
            ts.PickableParts='none';
            ts.Texture=tx;
            ts.Visible='on';
            addNode(obj,ts);
            obj.TriangleStrip=ts;
            obj.Visible='on';
        end


        function set.CData(obj,RGB)
            obj.CData_I=rgb2cdata(RGB,obj.AlphaData_I);
        end


        function RGB=get.CData(obj)
            RGB=cdata2rgb(obj.CData_I);
        end


        function alphaData=get.AlphaData(obj)
            alphaData=obj.AlphaData_I;
        end
    end


    methods(Hidden)
        function doUpdate(obj,~)





            ts=obj.TriangleStrip;
            ts.Visible=obj.Visible;
            if obj.Visible
                ts.VertexData=single([...
                obj.XLimits([1,1,2,2]);
                obj.YLimits([1,2,1,2]);
                [0,0,0,0]]);

                if obj.GrayscaleRendering
                    cdata=convertToGrayscale(obj.CData_I);
                else
                    cdata=obj.CData_I;
                end

                if isempty(cdata)
                    ts.ColorBinding='none';
                else
                    ts.ColorBinding='interpolated';
                end

                ts.Texture.CData=cdata;
            end
        end
    end
end


function grayscale=convertToGrayscale(cdata)

    if isempty(cdata)
        grayscale=cdata;
    else
        cdata16=uint16(cdata);
        gray=30*cdata16(1,:,:)+59*cdata16(2,:,:)+11*cdata16(3,:,:);
        maxgray=100*255;
        gray(gray>maxgray)=maxgray;
        gray=uint8(gray/100);
        cdata(1,:,:)=gray;
        cdata(2,:,:)=gray;
        cdata(3,:,:)=gray;
        grayscale=cdata;
    end
end


function cdata=rgb2cdata(RGB,alpha)

    if isempty(RGB)
        cdata=uint8.empty;
    else
        cdata=zeros([4,size(RGB,2),size(RGB,1)],'uint8');
        cdata(1:3,:,:)=permute(RGB,[3,2,1]);
        cdata(4,:,:)=alpha;
    end
end


function RGB=cdata2rgb(cdata)

    if isempty(cdata)
        RGB=uint8.empty;
    else
        RGB=cdata(1:3,:,:);
        RGB=permute(RGB,[3,2,1]);
    end
end


function tf=isSoftwareOpenGL()
    info=opengl('data');
    tf=(info.Software==1);
end
