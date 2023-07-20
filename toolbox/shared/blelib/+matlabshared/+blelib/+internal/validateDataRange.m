function output=validateDataRange(data,precision)







    if isstring(data)
        data=char(data);
    end
    if ischar(data)
        data=uint8(data);
    end


    try
        validateattributes(data,{'double','uint8','uint16','uint32','uint64'},{'2d','integer','real','finite','nonnan'});
    catch
        matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:invalidDataType');
    end


    if~(all(data>=intmin(precision))&&all(data<=intmax(precision)))
        matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:invalidDataRanged',num2str(intmin(precision)),num2str(intmax(precision)));
    end

    output=typecast(cast(data,precision),'uint8');
end

