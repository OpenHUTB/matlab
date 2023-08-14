function state=getMeshMode(obj)
    if isscalar(obj)
        state=obj.MesherStruct.MeshingChoice;
    elseif iscell(obj)
        state=cellfun(@getMeshMode,obj,'UniformOutput',false);
    else
        state=arrayfun(@getMeshMode,obj,'UniformOutput',false);
    end
end