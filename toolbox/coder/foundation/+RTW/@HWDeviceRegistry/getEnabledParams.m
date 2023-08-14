function params=getEnabledParams(h)





    hwParams=RTW.HWProp.getHardwareParams;
    params=hwParams(h.Enabled);
end