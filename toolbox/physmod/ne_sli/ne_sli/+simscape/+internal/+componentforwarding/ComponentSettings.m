classdef(Abstract)ComponentSettings











    methods(Abstract)

        value=setValue(obj,id,aValue);
        unit=setUnit(obj,id,aUnit);
        priority=setPriority(obj,id,aPriority);
        specify=setSpecify(obj,id,aSpecify);
        rtconfig=setRTConfig(obj,id,aConfig);
        class=setClass(obj,aClass);
        version=setVersion(obj,aVersion);


        value=getValue(obj,id);
        unit=getUnit(obj,id);
        priority=getPriority(obj,id);
        specify=getSpecify(obj,id);
        rtconfig=getRTConfig(obj,id);
        class=getClass(obj);
        version=getVersion(obj);
    end

end
