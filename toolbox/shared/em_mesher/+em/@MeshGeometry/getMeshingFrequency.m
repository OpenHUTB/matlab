function lambda=getMeshingFrequency(obj)

    if isscalar(obj)
        lambda=obj.MesherStruct.MeshingFrequency;
    elseif iscell(obj)
        lambda=cell2mat(cellfun(@getMeshingFrequency,obj,'UniformOutput',false));
    else
        lambda=cell2mat(arrayfun(@getMeshingFrequency,obj,'UniformOutput',false));
    end







end