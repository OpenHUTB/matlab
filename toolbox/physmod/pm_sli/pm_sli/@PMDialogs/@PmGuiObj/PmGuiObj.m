function hObj=PmGuiObj()







    hObj=PMDialogs.PmGuiObj;
    hObj.Name='DefaultName';
    hObj.assignObjId();
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;
