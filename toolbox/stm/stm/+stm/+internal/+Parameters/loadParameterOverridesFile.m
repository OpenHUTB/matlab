function paramList=loadParameterOverridesFile(fileName,sheet,simIndex,scenarioIndx,runOnTarget)


    [~,~,ext]=fileparts(fileName);

    if(~runOnTarget&&strcmpi(ext,'.m'))
        paramList=stm.internal.Parameters.loadParameterOverridesMFile(fileName);
    elseif(~runOnTarget&&strcmpi(ext,'.mat'))
        if scenarioIndx>0

            paramList=stm.internal.Parameters.loadParameterOverridesSldvFile(fileName,scenarioIndx);
        else

            paramList=stm.internal.Parameters.loadParameterOverridesMatFile(fileName);
        end
    elseif any(strcmpi(ext,xls.internal.WriteTable.SpreadsheetExts))
        paramList=stm.internal.Parameters.loadExcelFile(fileName,sheet,simIndex);
    else
        if(runOnTarget)
            MException(message('stm:Parameters:UnsupportedFormatForRTParameters')).throw;
        else

            MException(message('stm:Parameters:UnsupportedFormat')).throw;
        end
    end
end
