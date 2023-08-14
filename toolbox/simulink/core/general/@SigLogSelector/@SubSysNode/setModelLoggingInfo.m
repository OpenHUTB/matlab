function setModelLoggingInfo(h,mi)






    me=SigLogSelector.getExplorer;
    me.isSettingDataLoggingOveride=true;


    topMdl=h.getTopModelName;


    set_param(topMdl,'DataLoggingOverride',mi);


    me.isSettingDataLoggingOveride=false;
end
