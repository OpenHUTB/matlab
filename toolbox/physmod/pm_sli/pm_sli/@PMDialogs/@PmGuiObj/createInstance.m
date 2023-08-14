function hNewObj=createInstance(hThis,fullClsNameStr)





    hNewObj=0;
    fcn=hThis.CreateInstanceFcn;
    if(isempty(fcn))
        pm_abort('PmGuiObj Object is missing a CreateInstanceFcn object handle.');
        return;
    end

    hNewObj=invoke(fcn,fullClsNameStr,hThis.BlockHandle);
