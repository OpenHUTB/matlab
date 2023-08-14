function out=getLoadedModelList








    if is_simulink_loaded
        out=sort(find_system('type','block_diagram'));
    else
        out={};
    end
