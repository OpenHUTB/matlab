function propertyChanged(h,~)




    bd=h.getModel;



    if~isempty(bd)
        set_param(bd,'Dirty','on');
    end
