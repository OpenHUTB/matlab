function currentnode=insertnode(handle,node)




    child=TflDesigner.node(handle,node);

    if isempty(handle.children)
        handle.children=child;
    else
        handle.children(end+1)=child;
    end

    handle.refreshchildrencache(false);


    handle.lastactionnodepath=child.Name;
    currentnode=child;



