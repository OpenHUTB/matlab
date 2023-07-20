function tf=isModelLoaded(name)








    try
        tf=inmem('-isloaded',name)...
        &&strcmp(get_param(name,'type'),'block_diagram');
    catch
        tf=false;
    end
end
