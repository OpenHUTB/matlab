function varList=getExportableVariableList(modelName,causality,mode)

































    varList={};
    varListSource=[];
    valid=true;
    if strcmp(causality,'parameter')
        varListSource=FMU2ExpCSDialog.getParamListSource(modelName);
    elseif strcmp(causality,'internal')
        varListSource=FMU2ExpCSDialog.getInternalVarListSource(modelName);
    else

        valid=false;
        coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:FMU2ExpCSInvalidQueryType',causality),'Warning',modelName);
    end
    if valid
        switch mode
        case 'struct'

            if~isempty(varListSource.valueStructure)
                for i=1:length(varListSource.valueStructure)
                    if varListSource.valueStructure(i).IsRoot
                        varList=[varList,varListSource.valueStructure(i).Name];
                    end
                end
            end
        case 'flat'

            if~isempty(varListSource.valueScalarTable)
                varList={varListSource.valueScalarTable.name};
            end
        otherwise

            coder.internal.fmuexport.reportMsg(message('FMUExport:FMU:FMU2ExpCSInvalidQueryMode'),'Warning',modelName);
        end
    end
end