classdef(Abstract)Interface<handle




    methods(Abstract)
        flag=isUnknown(this);
        flag=isFloat(this);
        flag=isFixed(this);
        flag=isInherited(this);
        flag=isAlias(this);
        flag=isEnum(this);
        flag=isBoolean(this);
        flag=isBus(this);
        flag=isDouble(this);
        flag=isSingle(this);
        flag=isHalf(this);
        flag=isBuiltInInteger(this);
        flag=isScaledDouble(this);
        minVal=min(this);
        maxVal=max(this);
        epsVal=getEps(this);
    end
end
