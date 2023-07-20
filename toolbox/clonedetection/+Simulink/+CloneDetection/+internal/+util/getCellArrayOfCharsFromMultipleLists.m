





function[outputCellArray,invalidInputs]=getCellArrayOfCharsFromMultipleLists(varargin)
    outputCellArray={};
    invalidInputs={};
    for cellIndex=1:length(varargin)
        cellElement=varargin{cellIndex};
        outputCellArray_local={};
        invalidInputs_local={};
        if isempty(cellElement)||...
            (isstring(cellElement)&&length(cellElement)==1&&strlength(cellElement)==0)
            return;
        elseif(ischar(cellElement)||isstring(cellElement))
            outputCellArray_local=cellstr(cellElement);
        elseif(iscell(cellElement))
            for internalCellIndex=1:length(cellElement)
                internalCellElement=cellElement{internalCellIndex};
                [outputCellArray_local2,invalidInputs_local2]=...
                Simulink.CloneDetection.internal.util.getCellArrayOfCharsFromMultipleLists(internalCellElement);
                outputCellArray_local=[outputCellArray_local;outputCellArray_local2];
                invalidInputs_local=[invalidInputs_local;invalidInputs_local2];
            end
        else

            invalidInputs_local=[invalidInputs_local;cellElement];
        end
        invalidInputs=[invalidInputs;invalidInputs_local];
        outputCellArray=[outputCellArray;outputCellArray_local];
    end
end

