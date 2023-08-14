function future=configurationSet(key,value,optionalStruct)
    msg=struct('type','connector/configuration/ConfigurationSet',...
    'key',key);
    if nargin>2&&isfield(optionalStruct,'source')
        msg.source=optionalStruct.source;
    end

    if nargin>2&&isfield(optionalStruct,'stringDataType')
        msg.value=constructValue(value,optionalStruct.stringDataType);
    else
        msg.value=constructValue(value,'string');
    end

    future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,{'connector/json/deserialize',...
    'connector/configuration'});
    future=future.then(@(f)f.get().value);
end

function option=constructValue(value,stringDataType)
    if numel(value)==1
        if isa(value,'int8')||isa(value,'int16')||isa(value,'int32')||isa(value,'int64')
            option=struct('type','int','value',value);
        elseif isa(value,'uint8')||isa(value,'uint16')||isa(value,'uint32')||isa(value,'uint64')
            option=struct('type','uint','value',value);
        elseif isnumeric(value)
            option=struct('type','double','value',value);
        elseif ischar(value)||isstring(value)
            if strcmp(stringDataType,'ustring')
                option=struct('type','ustring','value',value);
            else
                option=struct('type','string','value',value);
            end
        elseif islogical(value)
            option=struct('type','bool','value',value);
        elseif iscell(value)
            option=constructValue(value{1});
        elseif isstring(value)
            option=struct('type','string','value',char(value));
        else
            warning('Unsupported data type for options');
        end
    else
        if isa(value,'int8')||isa(value,'int16')||isa(value,'int32')||isa(value,'int64')
            option=struct('type','intArray','value',value);
        elseif isa(value,'uint8')||isa(value,'uint16')||isa(value,'uint32')||isa(value,'uint64')
            option=struct('type','uintArray','value',value);
        elseif isnumeric(value)
            option=struct('type','doubleArray','value',value);
        elseif ischar(value)
            if strcmp(stringDataType,'ustring')
                option=struct('type','ustring','value',value);
            else
                option=struct('type','string','value',value);
            end
        elseif iscellstr(value)||isstring(value)
            option=struct('type','stringArray','value',value);
        elseif islogical(value)
            option=struct('type','boolArray','value',value);
        else
            warning('Unsupported data type for options');
        end
    end
end