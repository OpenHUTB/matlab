function stringRepresentation=compactButAccurateMat2Str(doubleValue)
















    doubleValue=double(doubleValue);
    for precisionDigits=15:19
        stringRepresentation=mat2str(doubleValue,precisionDigits);
        if all(str2num(stringRepresentation)==doubleValue,'all')%#ok<ST2NM>
            break;
        end
    end
end
