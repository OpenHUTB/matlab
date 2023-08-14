function setProdHWDeviceType(hCS,deviceType)







    prop='ProdHWDeviceType';
    oldEnable=getPropEnabled(hCS,prop);
    setPropEnabled(hCS,prop,true);
    set_param(hCS,prop,deviceType);
    setPropEnabled(hCS,prop,oldEnable);
end