function oType=loop_getObjectType(h,obj,ps)









    if nargin<2|isempty(obj)
        oType='Chart';
    else
        oType=ps.getObjectType(obj);

    end