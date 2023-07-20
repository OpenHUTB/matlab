function dataType=getDataType(values,minimumDeltaValue)









    fractionLength=-log2(double(minimumDeltaValue));
    if floor(fractionLength)~=fractionLength
        fractionLength=ceil(fractionLength);
    end


    dataTypeSelector=fixed.DataTypeSelector;
    dataTypeSelector.WordLength='Auto';
    dataTypeSelector.Scaling='Lock';
    dataType=dataTypeSelector.propose([values(1),values(end)],numerictype(1,16,fractionLength));




    fiObject=fi(values,dataType);
    differenceVector=fiObject(2:end)-fiObject(1:end-1);
    if any(differenceVector==0)


        dataType.WordLength=dataType.WordLength+1;
    end
end
