





classdef FrameLabelSet<handle

    methods(Static,Hidden)
        function this=loadobj(that)
            this=vision.internal.labeler.FrameLabelSet;

            defStruct=that.DefinitionStruct;
            numLabels=that.NumLabels;

            for n=1:numLabels
                name=defStruct(n).Name;
                desc=defStruct(n).Description;

                if isfield(defStruct(n),'Group')
                    group=defStruct(n).Group;
                else
                    group='None';
                end

                frameLabel=vision.internal.labeler.FrameLabel(name,desc,group);

                addLabel(this,frameLabel);
            end
        end
    end

    methods(Access=private)
        function this=FrameLabelSet(varargin)
        end
    end
end