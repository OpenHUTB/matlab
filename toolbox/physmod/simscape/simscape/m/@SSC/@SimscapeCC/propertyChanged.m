function propertyChanged(this,event)






    bd=this.getBlockDiagram;




    if~isempty(bd)
        set_param(bd.Handle,'Dirty','on');
    end



