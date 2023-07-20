










function qSpecObj=getQuantizationSpec(quantSpecMatfile)





    qSpecObj=[];

    qSpec=load(quantSpecMatfile);
    fieldNames=fieldnames(qSpec);

    for i=1:numel(qSpec)
        fieldValue=qSpec.(fieldNames{i});
        if isa(fieldValue,'coder.internal.QuantizationSpec')
            qSpecObj=fieldValue;
            break;
        end
    end

    if strcmpi(qSpecObj.DataType,'int8')
        if isempty(qSpecObj.CalibrationDataStore)

            error(message('dlcoder_spkg:TensorRTReducedPrecision:imageDatastoreIsEmpty'));
        end
    end
end
