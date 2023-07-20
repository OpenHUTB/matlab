function[ResultDescription,ResultDetails]=runUsrpBuild(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};



    inputParams=mdladvObj.getInputParameters('com.mathworks.HDL.SetTargetDevice');
    usrpBoard=inputParams{2};



    inputParams=mdladvObj.getInputParameters('com.mathworks.HDL.RunUSRP');
    usrpSourceFolder=inputParams{1};

    try
        ubinfo=USRPFPGATarget.USRPBuildInfo;
        ubinfo.Board=usrpBoard.value;



        ubinfo.UsrpRootDir=usrpSourceFolder.value;




        hdriver=hdlcoderargs(system);
        hDI=hdriver.DownstreamIntegrationDriver;
        ubinfo.setOutputFolder(getFullUsrpDir(hDI));

        wflow=USRPFPGATarget.USRPWorkflowManager(ubinfo,[],hdriver);%#ok<NASGU>


        if isempty(hDI.buildFPGAOptions)
            buildcmd=['wflow.build(''FirstFPGAProcess'', ''ProjectGeneration'','...
            ,'''FinalFPGAProcess'', ''BitGeneration'','...
            ,'''QuestionDialog'', ''on'')'];
        else

            buildcmd='wflow.build(hDI.buildFPGAOptions{:})';
        end


        [logTxt,success]=evalc(buildcmd);



        if~success
            error(message('hdlcoder:usrp:BuildFailed'));
        end


        [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
        ResultDescription,ResultDetails);


        mdladvObj.setCheckResultStatus(true);

    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end






