

function setPartDirty(model,hmiID)
    validateattributes(model,{'char'},{});
    validateattributes(hmiID,{'char'},{});

    bd=get_param(model,'Object');


    obj=get_param(model,'Packager');
    Simulink.HMI.Utils.addHMIParts(obj,hmiID);


    id=...
    [Simulink.HMI.Utils.FileKeeper.HMI_GUI_ID_PREFIX,hmiID];
    bd.setDirty(id,true);


    id=...
    [Simulink.HMI.Utils.FileKeeper.HMI_BND_ID_PREFIX,hmiID];
    bd.setDirty(id,true);


    bd.setDirty(Simulink.HMI.Utils.FileKeeper.HMI_OPT_ID,true);
end

