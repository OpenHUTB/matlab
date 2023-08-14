function res=isDatasetStreamingFromMemory(ds)





    assert(isa(ds,"Simulink.SimulationData.Dataset"));

    for idx=1:numel(ds)
        if locObjContainSimulationDatastore(ds(idx))
            res=false;
            return
        end
    end

    res=true;
end


function ret=locObjContainSimulationDatastore(obj)
    ret=false;
    numEle=locGetObjNumElements(obj);
    isStruct=isstruct(obj);

    fields={};
    if isStruct
        fields=fieldnames(obj);
    end

    for elIdx=1:numEle
        ele=locGetElement(obj,elIdx,fields);

        if isa(ele,"matlab.io.datastore.SimulationDatastore")

            ret=true;
            return
        elseif isa(ele,"Simulink.SimulationData.Dataset")||isstruct(ele)

            for idx=1:numel(ele)
                ret=locObjContainSimulationDatastore(ele(idx));
                if ret
                    return
                end
            end
        elseif isobject(ele)&&all(isprop(ele,'Values'),'all')

            for idx=1:numel(ele)
                if isstruct(ele(idx).Values)
                    ret=locObjContainSimulationDatastore(ele(idx).Values);
                else
                    ret=isa(ele(idx).Values,"matlab.io.datastore.SimulationDatastore");
                end
                if ret
                    return
                end
            end
        end

    end
end


function ret=locGetObjNumElements(obj)
    ret=0;
    if isstruct(obj)
        ret=numel(fieldnames(obj));
    elseif isa(obj,"Simulink.SimulationData.Dataset")
        ret=obj.numElements();
    else
        assert(isempty(obj));
    end
end


function ret=locGetElement(obj,idx,fields)
    if isempty(fields)
        ret=get(obj,idx);
    else
        ret=obj.(fields{idx});
    end
end
