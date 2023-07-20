function deactivateBindMode(modelName)


    if isempty(find_system('Name',modelName,'type','block_diagram'))

        return;
    end
    modelObj=get_param(modelName,'Object');
    BindMode.BindMode.disableBindMode(modelObj);
end