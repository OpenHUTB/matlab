


classdef AnnotationStructFactory<handle

    properties

    end

    methods(Static)
        function s=createAnnotationStruct(annotType,signalName,numImages,labelSet,varargin)

            if(annotType==annotationType.ROI)
                assert(nargin==7);
                sublabelSet=varargin{1};
                attributeSet=varargin{2};
                signalType=varargin{3};
                s=lidar.internal.labeler.annotation.ROIAnnotationStruct(signalName,numImages,labelSet,sublabelSet,attributeSet,signalType);
            elseif(annotType==annotationType.Frame)
                assert(nargin==4);
                s=vision.internal.labeler.annotation.FrameAnnotationStruct(signalName,numImages,labelSet);
            else
                s=[];
            end
        end
    end
end
