






function depth=getBlockDepth(handle)

    bdHandle=bdroot(handle);
    parent=handle;
    depth=0;

    while(parent~=bdHandle)
        parent=get_param(get_param(parent,'parent'),'handle');
        depth=depth+1;
    end
