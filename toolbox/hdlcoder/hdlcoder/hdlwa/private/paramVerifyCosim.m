function paramVerifyCosim(taskobj)




    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;



    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    SkipVerifyCosim=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask'));


    hDI.SkipVerifyCosim=SkipVerifyCosim.Value;

end

