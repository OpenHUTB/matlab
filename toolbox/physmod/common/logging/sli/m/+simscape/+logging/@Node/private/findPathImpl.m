function[isValid,nodePath]=findPathImpl(node,source)






    nodePath='';
    isValid=false;
    try
        source=pm_charvector(source);
    catch ME
        ME.throwAsCaller();
    end

    try
        isModelLoaded=is_simulink_loaded&&...
        bdIsLoaded(simscape.logging.internal.get_model_name(node));
        [isValid,nodePath]=simscape.logging.internal.find_node_path(...
        node,source,isModelLoaded);
    catch ME %#ok<NASGU>



    end

end



