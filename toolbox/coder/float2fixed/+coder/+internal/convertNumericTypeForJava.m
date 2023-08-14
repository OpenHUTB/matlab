function ntStruct=convertNumericTypeForJava(nt)
    if isempty(nt)
        ntStruct=[];
        return;
    end

    ntStruct.Signedness=nt.Signedness;
    ntStruct.WordLength=nt.WordLength;
    ntStruct.FractionLength=nt.FractionLength;
    ntStruct.DataType=nt.DataType;
end
