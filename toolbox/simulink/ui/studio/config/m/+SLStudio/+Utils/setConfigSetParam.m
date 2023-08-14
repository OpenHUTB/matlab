function setConfigSetParam(model,param,value)




    bd={};


    if~isempty(model)&&isa(model,'Simulink.BlockDiagram')
        bd=model;
    elseif(ischar(model)||ishandle(model))&&isa(get_param(model,'Object'),'Simulink.BlockDiagram')
        bd=get_param(model,'Object');
    end
    if~isempty(bd)
        cs=getActiveConfigSet(bd);


        try
            configset.internal.setParam(cs,param,value);
        catch %#ok<CTCH>
            return
        end
    end
end
