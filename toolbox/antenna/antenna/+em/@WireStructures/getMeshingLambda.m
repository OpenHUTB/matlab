function lambda=getMeshingLambda(obj)

    if isscalar(obj)
        lambda=obj.MesherStruct.MeshingLambda;
    elseif iscell(obj)
        lambda=cell2mat(cellfun(@getMeshingLambda,obj,'UniformOutput',false));
    else
        lambda=cell2mat(arrayfun(@getMeshingLambda,obj,'UniformOutput',false));
    end







end