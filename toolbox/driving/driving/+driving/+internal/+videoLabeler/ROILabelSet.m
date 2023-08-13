classdef ROILabelSet<handle

    methods(Static,Hidden)
        function this=loadobj(that)
            this=vision.internal.labeler.ROILabelSet;

            defStruct=that.DefinitionStruct;
            numLabels=that.NumLabels;

            for n=1:numLabels
                shape=defStruct(n).Type;
                name=defStruct(n).Name;
                desc=defStruct(n).Description;

                if isfield(defStruct(n),'Group')
                    group=defStruct(n).Group;
                else
                    group='None';
                end

                roiLabel=vision.internal.labeler.ROILabel(shape,name,desc,group);

                addLabel(this,roiLabel);
            end
        end
    end

    methods(Access=private)
        function this=ROILabelSet(varargin)
        end
    end
end