function validateGenerateDCM(h)







    xilinxObj=h.mXilinxAIObj;

    userParam=h.mWorkflowInfo.userParam;



    if~userParam.genClockModule
        return;
    end







    if~xilinxObj.isApiInstalled
        error(message('EDALink:WorkflowManager:validateGenerateDCM:noxilinxapi'));
    end



    xver=xilinxObj.getIseVersion;
    xver=str2num(strtok(xver,'.'));
    if isempty(xver)||xver<11
        error(message('EDALink:WorkflowManager:validateGenerateDCM:noxilinxapi'));
    end



    params=struct();


    params.Family=userParam.projectTarget.family;
    params.Device=userParam.projectTarget.device;
    params.Package=userParam.projectTarget.package;
    params.Speed=userParam.projectTarget.speed;


    params.ModuleName='tempname';



    params.InputClock.Period=userParam.clkinPeriod;


    params.OutputClocks{1}.Name='clkout';
    params.OutputClocks{1}.Period=userParam.clkoutPeriod;

    [success,errMsg]=xilinxObj.checkClock(params);
    if~success

        error(message('EDALink:WorkflowManager:validateGenerateDCM:failedvendorcheck',errMsg));
    end



