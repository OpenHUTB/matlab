


function out=getDataStoreMemoryDimensions(obj)

    out=-1;

    hdl=obj.Handle;
    try
        dims=eval(get_param(hdl,'Dimensions'));
    catch
        return;
    end

    if isequal(dims,-1)

        dims=getDimsFromInitValue(get_param(hdl,'InitialValue'));
        if isequal(dims,-1)


            if strcmpi(get_param(hdl,'StateMustResolveToSignalObject'),'on')
                try
                    sigObj=slResolve(get_param(hdl,'DataStoreName'),hdl);
                catch
                    return;
                end

                dims=sigObj.Dimensions;
                if isequal(dims,-1)
                    dims=getDimsFromInitValue(sigObj.InitialValue);
                end
            end
        end
    end

    if~isequal(dims,-1)


        vectorAs1D=strcmp(get_param(hdl,'VectorParams1D'),'on');
        if vectorAs1D&&(numel(dims)==2)
            if any(dims==1)
                [flag,dims]=slci.internal.resolveDim(hdl,dims);
                if~flag
                    return;
                end
                dims=prod(dims);
            end
        end
    end

    out=dims;
end


function dims=getDimsFromInitValue(initValueStr)
    dims=-1;
    [success,initial_value]=resolveInitValue(initValueStr);
    if~success
        return;
    end
    if~isempty(initial_value)
        dims=size(initial_value);
    end
end


function[success,initial_value]=resolveInitValue(initValStr)
    try
        initial_value=eval(initValStr);
        success=true;
    catch
        initial_value=[];
        success=false;
    end
end
