function oType=loop_getObjectType(~,obj,ps)









    if nargin<2||isempty(obj)
        oType='SLFunctionSystem';
    else
        oType=ps.getObjectType(obj);

    end
