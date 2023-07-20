function readers=getReader(params,models)



    models=getModels(params,models);
    readers(numel(params))=stm.internal.VariableReader.BaseWorkspace;
    sourceTypes={params.SourceType};
    mask=sourceTypes==stm.internal.VariableReader.BaseWorkspace.Type;
    if any(mask)
        readers(mask)=arrayfun(@(param,model)stm.internal.VariableReader.BaseWorkspace(param,model),params(mask),models(mask));
    end
    mask=sourceTypes==stm.internal.VariableReader.ModelWorkspace.Type;
    if any(mask)
        readers(mask)=arrayfun(@(param,model)stm.internal.VariableReader.ModelWorkspace(param,model),params(mask),models(mask));
    end
    mask=stm.internal.VariableReader.BlockParameter.isBlockParameter(sourceTypes);
    if any(mask)
        readers(mask)=arrayfun(@(param,model)stm.internal.VariableReader.BlockParameter(param,model),params(mask),models(mask));
    end
    mask=sourceTypes==stm.internal.VariableReader.ModelParameter.Type;
    if any(mask)
        readers(mask)=arrayfun(@(param,model)stm.internal.VariableReader.ModelParameter(param,model),params(mask),models(mask));
    end
    mask=stm.internal.VariableReader.DataDictionary.isSldd(sourceTypes);
    if any(mask)
        readers(mask)=arrayfun(@(param,model)stm.internal.VariableReader.DataDictionary(param,model),params(mask),models(mask));
    end
end

function models=getModels(params,models)
    models=string(models);
    assert(isscalar(models)||numel(params)==numel(models));
    if isscalar(models)

        models=repmat(models,size(params));
    end


    mdlRef={params.ModelReference};
    mask=strlength(mdlRef)>0;
    models(mask)=mdlRef(mask);
end
