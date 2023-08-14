function unpopulate(handle)



    clear global loadedTbl;


    for id=1:length(handle.children)
        handle.children(id).unpopulate;
        delete(handle.children(id));
    end

    handle.children=[];

    for id=1:length(handle.listeners)
        delete(handle.listeners(id));
    end

    handle.listeners=[];


