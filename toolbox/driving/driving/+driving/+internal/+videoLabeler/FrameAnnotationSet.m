






classdef FrameAnnotationSet<handle
    methods(Static,Hidden)
        function this=loadobj(that)

            this=vision.internal.labeler.FrameAnnotationSet(that.LabelSet);


            this.BackupAnnotationStruct=that.AnnotationStruct;
        end
    end

    methods(Access=private)
        function this=FrameAnnotationSet(varargin)
        end
    end
end
