function out=mapParameters(in,map)

    out.NewBlockPath='';
    out.NewInstanceData=in.InstanceData;

    values={in.InstanceData.Value};

    for entry=map'
        entry=entry{1};
        [old,new]=entry{:};
        [inParamName,inParamValues]=old{:};
        [outParamName,outParamValues]=new{:};
        idx=strcmp({in.InstanceData.Name},inParamName);
        if any(idx)

            newValue=values{idx};
            if iscell(inParamValues)

                assert(iscell(outParamValues));
                assert(length(inParamValues)==length(outParamValues));
                jdx=strcmp(newValue,inParamValues);
                assert(~isempty(jdx));
                newValue=outParamValues(jdx);
            end
            out.NewInstanceData(idx)=struct('Name',outParamName,'Value',newValue);
        else

            newValue=outParamValues;
            if iscell(newValue)
                newValue=newValue{1};
            end
            out.NewInstanceData(end+1)=struct('Name',outParamName,'Value',newValue);
        end
    end
end
