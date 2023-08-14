function IS_SL_ENUM=isStaSLEnumType(varIn)



    IS_SL_ENUM=Simulink.data.isSupportedEnumObject(varIn)||isa(varIn,'Simulink.IntEnumType');

