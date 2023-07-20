










function propertyChanged(hObj,unused)%#ok<INUSD>


    bd=hObj.getBlockDiagram();



    if~isempty(bd)
        set_param(bd.Handle,'Dirty','on');
    end
