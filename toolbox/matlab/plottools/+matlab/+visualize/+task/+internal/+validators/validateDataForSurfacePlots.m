function isValid=validateDataForSurfacePlots(data,channel)
    isValid=false;

    for i=1:numel(channel.KeyType)
        keyTypes=channel.KeyType(i);
        try
            [attrClass,attrType]=matlab.visualize.task.internal.model.DataModel.cleanUpTypeAttributes(keyTypes);

            validateattributes(data,attrClass,attrType);

            isValid=true;
            break;
        catch
        end
    end
    if isValid
        if strcmpi(channel.Name,'Z')
            [zm,zn]=size(data);
            if iscomplex(data)
                isValid=false;
            end

            if isValid&&(zm==1||zn==1)
                isValid=false;
            end
        elseif strcmpi(channel.Name,'C')
            if iscomplex(data)
                isValid=false;
            end
        end
    end
end

function out=iscomplex(x)
    out=isnumeric(x)&&~isreal(x);
end