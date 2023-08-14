function arrangeSystem(model,varargin)









    if(ischar(model)||isstring(model))
        bdHandle=get_param(model,'Handle');
    elseif(isreal(model))
        bdHandle=model;
    end


    obj=get_param(bdroot(model),'Object');
    obj.localAutoLayout(bdHandle,varargin{:});

end


