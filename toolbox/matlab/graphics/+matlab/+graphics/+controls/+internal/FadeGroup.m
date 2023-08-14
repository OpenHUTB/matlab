classdef(Sealed,ConstructOnLoad,Hidden)FadeGroup<...
    matlab.graphics.axis.colorspace.ColorSpace&...
    matlab.graphics.controls.internal.Control









    properties(AffectsObject,AbortSet)

        Alpha(1,1)double...
        {mustBeGreaterThanOrEqual(Alpha,0),...
        mustBeLessThanOrEqual(Alpha,1)}=1;
    end

    properties(Access=private,WeakReference,Transient,NonCopyable)
        ParentColorSpace=[];
    end


    methods
        function obj=FadeGroup(varargin)
            obj@matlab.graphics.axis.colorspace.ColorSpace(varargin{:});



            obj.addDependencyConsumed('colorspace');
        end
    end

    methods(Access=private)
        function cs=getParentColorSpace(obj)
            persistent default_value

            if~isempty(obj.ParentColorSpace)
                cs=obj.ParentColorSpace;
            else
                if isempty(default_value)

                    default_value=matlab.graphics.axis.colorspace.ColorSpace;
                end
                cs=default_value;
            end
        end
    end

    methods(Hidden)
        function doUpdate(obj,updateState)
            obj.ParentColorSpace=updateState.ColorSpace;
        end

        function ret=doSupportsColormapping(obj)
            cs=getParentColorSpace(obj);
            ret=strcmp(cs.SupportsColormapping(),'on');
        end

        function colordata=doTransformTrueColorToTrueColor(obj,iter)
            cs=getParentColorSpace(obj);
            colordata=cs.TransformTrueColorToTrueColor(iter);
            colordata=blendTrueColorData(colordata,obj.Alpha);
        end

        function colordata=doTransformColormappedToTrueColor(obj,iter)
            cs=getParentColorSpace(obj);
            colordata=cs.TransformColormappedToTrueColor(iter);
            colordata=blendTrueColorData(colordata,obj.Alpha);
        end

        function colordata=doTransformColormappedToColormapped(obj,iter)
            cs=getParentColorSpace(obj);
            colordata=cs.TransformColormappedToColormapped(iter);


            colordata.Texture=blendTextureData(colordata.Texture,obj.Alpha);
        end
    end
end


function texdata=blendTextureData(texdata,alpha)

    if alpha<1
        texdata.CData(4,:)=texdata.CData(4,:).*alpha;
        texdata.ColorType='truecoloralpha';
    end
end


function colordata=blendTrueColorData(colordata,alpha)

    if alpha<1
        colordata.Data(4,:)=colordata.Data(4,:).*alpha;
        colordata.Type='truecoloralpha';
    end
end
