function pmsl_markmodeldirty(bd)







    if~isempty(bd)
        bd=get_param(bd.Handle,'Object');
        bd.setDirty('blockDiagram',true);
    end




