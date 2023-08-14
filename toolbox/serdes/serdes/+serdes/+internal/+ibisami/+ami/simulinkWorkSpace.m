function simulinkWorkSpace=simulinkWorkSpace(tree)





    if~tree.UsesSimulinkWorkSpace||isempty(tree.modelHandle)
        simulinkWorkSpace=[];
    else
        simulinkWorkSpace=get_param(tree.modelHandle,'ModelWorkspace');
    end
end

