function header=getHeader(obj)

    if isscalar(obj)&&obj.pShowAllProperties

        header={};
    else

        header=getHeader@matlab.mixin.CustomDisplay(obj);
    end
