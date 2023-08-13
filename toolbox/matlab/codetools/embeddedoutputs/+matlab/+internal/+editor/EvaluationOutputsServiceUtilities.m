classdef EvaluationOutputsServiceUtilities


    methods(Static,Hidden)
        function shouldUseTempFile=shouldUseTempFile(isSavedFile,filePath)


            import matlab.internal.editor.EvaluationOutputsServiceUtilities;


            if~isSavedFile||~usejava('jvm')
                shouldUseTempFile=true;
                return;
            end
            [~,pathValue]=mdbfileonpath(filePath);
            shouldUseTempFile=~(pathValue==com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_WILL_RUN);
        end

        function processCustomExecutionData(customExecutionDataJSON)

            customExecutionData=mls.internal.fromJSON(customExecutionDataJSON);
            if isempty(customExecutionData)
                return;
            end

            for i=1:length(customExecutionData)
                handler=customExecutionData(i).handler;
                data=customExecutionData(i).data;

                eval([handler,'(data);']);
            end
        end
    end

end
