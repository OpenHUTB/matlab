function value=getConfigSetParam(model,param,default)




    value={};
    bd={};


    if~isempty(model)&&(isa(model,'Simulink.BlockDiagram'))
        bd=model;
    elseif(ischar(model)||ishandle(model))&&(isa(get_param(model,'Object'),'Simulink.BlockDiagram'))
        bd=get_param(model,'Object');
    end
    if~isempty(bd)
        cs=getActiveConfigSet(bd);


        try
            value=get_param(cs,param);
        catch %#ok<CTCH>
            if nargin==3
                value=default;
            end
            return
        end
    end
end
