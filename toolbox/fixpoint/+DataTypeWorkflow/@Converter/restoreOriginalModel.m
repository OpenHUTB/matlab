function status=restoreOriginalModel(model)





    status=false;
    hasValidPoint=DataTypeWorkflow.Converter.hasValidRestorePoint(model);
    if hasValidPoint
        restoreOutput=restorepoint.internal.restore(model);
        status=restoreOutput.Status;
        filesThatCannotBeRestored=restoreOutput.FilesThatCannotBeRestored;
        if(~status)
            fileList='';
            for idx=1:numel(filesThatCannotBeRestored)
                if isempty(fileList)
                    fileList=filesThatCannotBeRestored{idx};
                else
                    fileList=[fileList,', ',filesThatCannotBeRestored{idx}];%#ok
                end
            end
            error(message('SimulinkFixedPoint:restorepoint:FilesNotRestored',fileList));
        end
    else
        warning(message('SimulinkFixedPoint:restorepoint:NoValidRestorePoint',model));
    end
end


