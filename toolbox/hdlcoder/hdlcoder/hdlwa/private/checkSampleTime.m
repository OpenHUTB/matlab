function[ResultDescription,ResultDetails]=checkSampleTime(system)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    hdlcoderObj=hdlmodeldriver(bdroot(system));

    try

        [oldDriver,oldMode,oldAutosaveState]=hdlcoderObj.inithdlmake;
        hs.oldDriver=oldDriver;
        hs.oldMode=oldMode;
        hs.oldAutosaveState=oldAutosaveState;

    catch ME

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
        ME.message,ME.cause,{},{},ME.getReport);

        return;
    end

    try
        checks=[];


        mdlName=bdroot(system);
        hDriver=hdlmodeldriver(mdlName);
        hDI=hDriver.DownstreamIntegrationDriver;
        if hDI.isFILWorkflow

            solverType=get_param(mdlName,'SolverType');
            multitaskingMode=get_param(mdlName,'EnableMultiTasking');
            if strcmp(solverType,'Fixed-step')&&strcmp(multitaskingMode,'on')
                filcheck.path=hDriver.getStartNodeName;
                filcheck.type='model';
                taskID='com.mathworks.HDL.CheckSampleTime';
                msgStr=message('hdlcoder:workflow:ChangeToSingleTasking').getString;
                actionLink=sprintf('<a href="matlab:set_param(%s,''EnableMultiTasking'',''off''); hdlturnkey.resetHDLWATask(''%s'');">%s</a>',...
                cleanBlockNameForQuotedDisp(mdlName),taskID,msgStr);
                filcheck.message=message('hdlcoder:workflow:FILSolverMode',actionLink).getString;
                filcheck.level='Error';
                filcheck.MessageID='hdlcoder:workflow:FILSolverMode';
                checks=[checks,filcheck];
            end
        end



        hcc=gethdlcc(bdroot(system));


        hcc.createCLI;

    catch ME

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
        ME.message,ME.cause,{},{},ME.getReport);


        hdlcoderObj.cleanup(hs,false);
        return;
    end


    [ResultDescription,ResultDetails]=publishResults(mdladvObj,checks,'Running Check Sample Times');


    hdlcoderObj.cleanup(hs,false);
