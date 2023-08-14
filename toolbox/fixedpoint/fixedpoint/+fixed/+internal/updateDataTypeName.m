function modernDataTypeNameStr=updateDataTypeName(legacyDataTypeNameStr)















    if iscell(legacyDataTypeNameStr)
        modernDataTypeNameStr=cell(size(legacyDataTypeNameStr));
        for i=1:numel(legacyDataTypeNameStr)
            modernDataTypeNameStr{i}=updateOne(legacyDataTypeNameStr{i});
        end
    else
        modernDataTypeNameStr=updateOne(legacyDataTypeNameStr);
    end


end

function modernDataTypeNameStr=updateOne(legacyDataTypeNameStr)
    nt=numerictype(legacyDataTypeNameStr);
    modernDataTypeNameStr=nt.tostringInternalSlName;
end
