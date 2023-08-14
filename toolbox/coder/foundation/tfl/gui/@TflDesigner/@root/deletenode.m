function nextnode=deletenode(handle,nodetodelete,cut)










    if~cut
        for idx=1:length(nodetodelete.children)
            delete(nodetodelete.children(idx));
        end
        nodetodelete.children=[];
    end

    if handle~=nodetodelete
        idx=find(handle.children==nodetodelete);


        if~cut
            delete(handle.children(idx));
        end

        handle.children(idx)=[];

        handle.refreshchildrencache(true);

        if idx<=length(handle.children)
            nextnode=handle.children(idx);
        elseif idx>length(handle.children)&&~isempty(handle.children)
            nextnode=handle.children(idx-1);
        else


            handle.resettablecounter;
            nextnode=handle;
        end
    else
        handle.refreshchildrencache(true);
        handle.resettablecounter;
        nextnode=handle;
    end




