






classdef ROIAnnotationSet<handle

    methods(Static,Hidden)
        function this=loadobj(that)



            sublabelSet=vision.internal.labeler.ROISublabelSet;
            attributeSet=vision.internal.labeler.ROIAttributeSet;


            this=vision.internal.labeler.ROIAnnotationSet(that.LabelSet,sublabelSet,attributeSet);


            this.BackupAnnotationStruct=that.AnnotationStruct;
        end
    end

    methods(Access=private)
        function this=ROIAnnotationSet(varargin)
        end
    end
end
