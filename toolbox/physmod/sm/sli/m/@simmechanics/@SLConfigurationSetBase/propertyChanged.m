function propertyChanged(configset,event)






    bd=configset.getBlockDiagram;




    if~isempty(bd)
        set_param(bd.Handle,'Dirty','on');
    end
