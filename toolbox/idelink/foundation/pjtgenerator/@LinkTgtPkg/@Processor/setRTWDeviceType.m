function setRTWDeviceType(h,modelName)




    cs=getActiveConfigSet(modelName);
    set_param(cs,'ProdHWDeviceType',h.ProdHWDeviceType);
