function value=getValue(val,type,sid)



    try


        if strcmp(type,'boolean')
            type='logical';
        end

        if slci.internal.isStateflowBasedBlock(sid)
            value=slResolve(val,sid,...
            'expression','startUnderMask');
        else
            value=slResolve(val,sid);
        end
        if isstruct(value)

            type='struct';
        end

        value=slci.internal.flattenVariable(value);

        value=castToDestinationType(value,type);

        value=castToContainerType(value);
    catch Exception %#ok
        value=[];
    end
end


function out=castToDestinationType(value,type)
    if strcmp(type,'struct')...
        ||strcmp(type,'enum')
        out=value;
        return;
    end
    for i=1:numel(value)
        if(iscell(value))
            value{i}=cast(value{i},type);
        else
            value(i)=cast(value(i),type);
        end
    end
    out=value;
end


function out=castToContainerType(value)
    if iscell(value)
        value=cellfun(@double,value);
    else
        value=double(value);
    end

    out=reshape(value,1,[]);
end
