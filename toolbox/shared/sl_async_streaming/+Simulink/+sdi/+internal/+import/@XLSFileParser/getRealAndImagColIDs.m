function[realColIDs,imagColIDs]=getRealAndImagColIDs(this,leafName,...
    actualLeafStr,signalNames,signalIndices)
    sigNameRx=[leafName,this.DimsRx];
    realColIDs=[];
    imagColIDs=[];
    for sigIdx=1:length(signalNames)
        if regexp(signalNames{sigIdx},sigNameRx)==1
            if strcmpi([actualLeafStr,' ',this.REAL_PART_STR],signalNames{sigIdx})
                realColIDs(end+1)=signalIndices(sigIdx);%#ok
            elseif strcmpi([actualLeafStr,' ',this.IMAG_PART_STR],signalNames{sigIdx})
                imagColIDs(end+1)=signalIndices(sigIdx);%#ok
            end
        end
    end
end