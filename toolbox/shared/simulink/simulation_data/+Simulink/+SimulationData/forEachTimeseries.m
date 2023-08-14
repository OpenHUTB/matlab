















function ret=forEachTimeseries(functionHandle,data)
    try

        parser=inputParser;
        parser.addRequired('functionHandle',@(x)validateattributes(x,{'function_handle'},{'scalar'}));
        parser.addRequired('data');
        parser.parse(functionHandle,data);
        cfg.functionHandle=functionHandle;


        ret=locProcessValue(data,cfg);
    catch me
        throwAsCaller(me);
    end
end

function varargout=locProcessValue(val,cfg)


    value_processed=false;
    oldDataType=[];
    oldFieldNames={};

    if~(isa(val,'timeseries')||...
        (isstruct(val)&&~isempty(val)&&~isempty(fieldnames(val))))
        Simulink.SimulationData.utError('InputInvalidDataTypes');
    end


    for idx_arr=numel(val):-1:1

        if isstruct(val)


            fnames=fieldnames(val(idx_arr));
            for idx_struct=1:length(fnames)
                value_processed=true;
                ret(idx_arr).(fnames{idx_struct})=...
                locProcessValue(val(idx_arr).(fnames{idx_struct}),cfg);
            end

        else


            value_processed=true;
            ret_tmp=cfg.functionHandle(val(idx_arr));
            [oldDataType,oldFieldNames]=...
            locCheckUniformity(ret_tmp,oldDataType,oldFieldNames);
            ret(idx_arr)=ret_tmp;

        end

    end

    if~value_processed

        varargout{1}=[];
    else

        varargout{1}=reshape(ret,size(val));
    end

end

function[newDataType,oldFieldNames]=locCheckUniformity(val,oldDataType,oldFieldNames)


    if numel(val)~=1
        Simulink.SimulationData.utError('OutputNonUniformSize');
    end


    newDataType=class(val);
    if~isempty(oldDataType)
        if~isequal(newDataType,oldDataType)
            Simulink.SimulationData.utError('OutputNonUniformDataType');
        end
    end


    if isequal(newDataType,'struct')
        newFieldNames=fieldnames(val);
        if isequal(size(oldFieldNames),[0,0])
            oldFieldNames=newFieldNames;
        else
            if~isequal(newFieldNames,oldFieldNames)
                Simulink.SimulationData.utError('OutputNonUniformStructFieldNames')
            end
        end
    end


    if ismember(newDataType,{'containers.Map','table','function_handle'})
        Simulink.SimulationData.utError('OutputUnsupportedType',newDataType);
    end
end

