
function optsStruct=genOptionsStruct(filePath,rslts,type,ext)
    if any(strcmpi(ext,xls.internal.WriteTable.SpreadsheetExts))

        exlStrct=genExlSpecs(filePath,rslts);


        if(type==stm.internal.SourceSelectionTypes.Baseline)
            optsStruct=exlStrct;
            optsStruct.RefreshIfExists=rslts.RefreshIfExists;
            optsStruct.SeparateSources=rslts.SeparateBaselines;
        else
            optsStruct.exlArgs=exlStrct;
        end

        if(type==stm.internal.SourceSelectionTypes.Input)
            optsStruct.SimulationIndex=rslts.SimulationIndex;
            optsStruct.exlArgs.CreateIterations=rslts.CreateIterations;
            optsStruct.SeparateSources=rslts.SeparateInputs;
        end

        optsStruct.Type=type;
    else
        if(type==stm.internal.SourceSelectionTypes.Baseline)
            optsStruct=rslts.RefreshIfExists;
        else
            optsStruct.SimulationIndex=rslts.SimulationIndex;
            optsStruct.SeparateSources=rslts.SeparateInputs;
            optsStruct.exlArgs=rslts.CreateIterations;
        end
    end
end

function exlStruct=genExlSpecs(filePath,rslts)
    exlStruct=struct('Sheets',string.empty,'Ranges',string.empty);
    if~isempty(rslts.Sheets)

        exlStruct.Sheets=string(rslts.Sheets);
    else


        sheets=sheetnames(filePath);
        exlStruct.Sheets=string(sheets);
    end

    if~isempty(rslts.Ranges)
        exlStruct.Ranges=string(rslts.Ranges);
    else

        exlStruct.Ranges=strings([1,length(exlStruct.Sheets)]);
    end
end