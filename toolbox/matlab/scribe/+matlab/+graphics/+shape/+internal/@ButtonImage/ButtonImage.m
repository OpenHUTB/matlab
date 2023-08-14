classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Hidden,Sealed)ButtonImage<...
    matlab.graphics.primitive.world.Group






    properties(AffectsObject,AbortSet)






        ImageDPIRatios(1,:)double{mustBeFinite}=[];


        Alpha(1,1)double{mustBeFinite,mustBeGreaterThanOrEqual(Alpha,0),mustBeLessThanOrEqual(Alpha,1)}=1;

        ImageSource;
    end

    properties(Dependent)




        ImageFile(1,:)string=string.empty(1,0);
    end

    properties(Dependent)
        Layer matlab.internal.datatype.matlab.graphics.datatype.OrderLayer;
    end

    properties(AbortSet,Access=private)
        Layer_I matlab.internal.datatype.matlab.graphics.datatype.OrderLayer='front';
    end

    properties(Access=private,Transient,NonCopyable)

        ImageDataCache={};
    end

    properties(Hidden,Transient,NonCopyable)

Face
    end

    methods
        function obj=ButtonImage(varargin)





            obj@matlab.graphics.primitive.world.Group(varargin{:});

            obj.Face=matlab.graphics.primitive.world.Quadrilateral(...
            'Clipping','off',...
            'PickableParts','visible',...
            'Layer',obj.Layer_I,...
            'Internal',true);
            obj.addNode(obj.Face);

            obj.addDependencyConsumed('xyzdatalimits');
            obj.addDependencyConsumed('dataspace');
            obj.addDependencyConsumed('colorspace');
        end

        function set.ImageSource(obj,value)
            imageSourceChanged=~isequal(obj.ImageSource,value);
            if imageSourceChanged
                obj.ImageSource=value;
                addlistener(obj.ImageSource,'SourceChanged',@(e,d)obj.updateCache(e));
            end


            obj.ImageDataCache=cell(size(value));
        end

        function set.ImageFile(obj,value)




            imageSources=matlab.graphics.shape.internal.image.FileImageSource.empty;
            for k=1:length(value)
                imageSources(k)=matlab.graphics.shape.internal.image.FileImageSource(value(k));



                addlistener(imageSources(k),'SourceChanged',@(e,d)obj.updateCache(e));
            end
            obj.ImageSource=imageSources;
        end

        function value=get.ImageFile(obj)
            value=repmat("",1,length(obj.ImageSource));
            for k=1:length(value)
                value(k)=obj.ImageSource(k).FileName;
            end
        end

        function set.Layer(obj,newval)
            obj.Layer_I=newval;
            if~isempty(obj.Face)
                obj.Face.Layer=newval;
            end
        end

        function val=get.Layer(obj)
            val=obj.Layer_I;
        end

        function updateCache(obj,src)

            ind=obj.ImageSource==src;
            if any(ind)
                obj.ImageDataCache{ind}=[];
                obj.MarkDirty('all');
            end
        end
    end

    methods(Hidden)
        doUpdate(obj,updateState)
    end

    methods(Access=private)
        function imageRatios=getImageRatios(obj)
            numImages=numel(obj.ImageSource);
            if numel(obj.ImageDPIRatios)~=numImages

                imageRatios=1:numImages;
            else
                imageRatios=obj.ImageDPIRatios;
            end
        end

        function im=applyAlpha(obj,im)
            if obj.Alpha<1

                if size(im,3)==4
                    im(:,:,4)=im(:,:,4)*obj.Alpha;
                else
                    alpha=uint8(obj.Alpha*255);
                    im(:,:,4)=alpha;
                end
            end
        end

        function im=getImageData(obj,scale)






            imageRatios=getImageRatios(obj);


            nearestScore=(imageRatios-scale);

            if all(nearestScore<0)


                [~,fileIndex]=max(imageRatios);
            else

                nearestScore(nearestScore<0)=inf;

                [~,fileIndex]=min(nearestScore);
            end

            if fileIndex>0



                obj.ImageSource(fileIndex).setDPIScale(scale)

                if isempty(obj.ImageDataCache{fileIndex})


                    obj.ImageDataCache{fileIndex}=obj.ImageSource(fileIndex).loadImage;
                end

                im=obj.ImageDataCache{fileIndex};


                im=applyAlpha(obj,im);
            else
                im=[];
            end
        end
    end
end
