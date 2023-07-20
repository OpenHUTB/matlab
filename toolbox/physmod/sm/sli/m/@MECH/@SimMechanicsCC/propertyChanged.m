function propertyChanged(smc,event)






    bd=smc.getBlockDiagram;




    if~isempty(bd)
        set_param(bd.Handle,'Dirty','on');
    end




