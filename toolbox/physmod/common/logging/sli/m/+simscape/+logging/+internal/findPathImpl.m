function[isValid,nodePath]=findPathImpl(node,block)








    try
        if numel(node)>1
            pm_message('physmod:common:logging:sli:dataexplorer:NonScalarNode','findPath');
        end
        if ischar(block)
            block=pm_charvector(block);
        end
        isModelLoaded=is_simulink_loaded&&...
        bdIsLoaded(simscape.logging.internal.get_model_name(node));

        [isValid,nodePath]=simscape.logging.internal.find_node_path(node,...
        block,isModelLoaded);
    catch ME
        ME.throwAsCaller();
    end

end
