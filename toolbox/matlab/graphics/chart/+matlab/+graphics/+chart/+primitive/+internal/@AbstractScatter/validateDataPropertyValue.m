function data=validateDataPropertyValue(channelName,data)
    switch channelName
    case 'Color'
        msg=message('MATLAB:scatter:InvalidCData');
        if isvector(data)
            try
                hgcastvalue('matlab.graphics.datatype.NumericMatrix',data);
            catch
                error(msg);
            end
        elseif ismatrix(data)&&size(data,2)==3
            assert(isnumeric(data),msg);
        elseif~isempty(data)
            error(msg)
        end
    case 'Alpha'
        try
            hgcastvalue('matlab.graphics.datatype.NumericMatrix',data);
        catch
            error(message('MATLAB:hg:shaped_arrays:NumericMatrixType'));
        end
        data=validateDataPropertyValue@matlab.graphics.mixin.DataProperties(channelName,data);
    otherwise
        data=validateDataPropertyValue@matlab.graphics.mixin.DataProperties(channelName,data);
    end
end