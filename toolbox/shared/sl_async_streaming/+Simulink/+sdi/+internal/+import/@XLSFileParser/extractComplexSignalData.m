function[signalData,realColIDs,imagColIDs,baseLeafName]=...
    extractComplexSignalData(this,signalData,signalNames,signalIndices,leafName)


    signalData.isComplex=true;
    signalData.DataVals=1+1i;
    baseLeafName=this.extractSignalNameFromComplex(leafName);
    signalNames=locRemoveBusPaths(signalData,signalNames);

    if this.isMultiDimensionalSignal(leafName)
        dims=this.extractSignalNameFromDims(leafName);
        [realColIDs,imagColIDs]=this.getRealAndImagColIDs(...
        dims,...
        baseLeafName,...
        signalNames,...
        signalIndices);
    else
        realPartName=[baseLeafName,' ',this.REAL_PART_STR];
        imagPartName=[baseLeafName,' ',this.IMAG_PART_STR];


        realPartNameWithoutSpace=[baseLeafName,this.REAL_PART_STR];
        imagPartNameWithoutSpace=[baseLeafName,this.IMAG_PART_STR];

        realColIDs=signalIndices(logical(strcmp(signalNames,realPartName)+...
        strcmp(signalNames,realPartNameWithoutSpace)));
        imagColIDs=signalIndices(logical(strcmp(signalNames,imagPartName)+...
        strcmp(signalNames,imagPartNameWithoutSpace)));
    end

    signalData.LeafName=baseLeafName;
    signalData(end).DimsColIDs=[realColIDs,imagColIDs];
end


function signalNames=locRemoveBusPaths(signalData,signalNames)


    if~isempty(signalData.BusHier)

        numChars=0;
        for idx=1:numel(signalData.BusHier)
            numChars=numChars+numel(signalData.BusHier{idx})+1;
        end


        for idx=1:numel(signalNames)
            signalNames{idx}=signalNames{idx}(numChars+1:end);
        end
    end
end
