classdef JSAnnotationsService<handle

    methods

        function annotationsSave(this,runID,annotations)
            filePath=fullfile(this.getResultsDir(),runID,'annotations.mat');
            save(filePath,'annotations');
        end

        function annotations=annotationsLoad(this,runID)
            annotations=[];
            filePath=fullfile(this.getResultsDir(),runID,'annotations.mat');
            if isfile(filePath)
                annotations=load(filePath);
            end
        end

    end

end
