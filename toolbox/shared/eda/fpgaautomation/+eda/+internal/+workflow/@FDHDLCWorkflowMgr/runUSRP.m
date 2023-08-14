function status=runUSRP(h)




    status=0;

    fpgaObj=h.mAutoInterfaceObj;
    hdlcData=h.mWorkflowInfo.hdlcData;
    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;

    hdldisp('Generating HDL files for USRP2 filter customization');









    rxHDLFiles=createRxObject(hdlcData);
    txHDLFiles=createTxObject(hdlcData);


    continueOnWarn=false;
    success=h.checkProjectOverwrite(continueOnWarn);
    if~success
        status=1;
        return;
    end


    hdlcFullDir=h.getHdlFullDir;
    genFiles=h.getGenFilePath(hdlcFullDir,hdlcData.hdlFiles);

    if~isempty(rxHDLFiles)
        genFiles=[genFiles,h.getGenFilePath(hdlcFullDir,rxHDLFiles)];
    end

    if~isempty(txHDLFiles)
        genFiles=[genFiles,h.getGenFilePath(hdlcFullDir,txHDLFiles)];
    end


    orgDir=pwd;
    h.makeProjectDir;
    cd(userParam.projectLoc);

    try





        makeLoc1=fullfile(userParam.usrpLoc,'top','u2_rev3','Makefile');
        makeLoc2=fullfile(userParam.usrpLoc,'Makefile');

        if exist(makeLoc1,'file')
            fpgaSrc=fullfile(userParam.usrpLoc,'/');
            makeFile=makeLoc1;
            tclHelper=fullfile(userParam.usrpLoc,'top','tcl','ise_helper.tcl');
        elseif exist(makeLoc2,'file')
            fpgaSrc=fullfile(userParam.usrpLoc,'..','../');
            makeFile=makeLoc2;
            tclHelper=fullfile(userParam.usrpLoc,'..','tcl','ise_helper.tcl');
        end

        try
            h.copyMakefile(makeFile,fpgaSrc);
            h.copyTclHelper(tclHelper);
        catch me
            error(message('EDALink:FDHDLCWorkflowMgr:runUSRP:parsemaketcl'));
        end



        h.deleteExistingProject;


        disp(' ');
        hdldisp('Creating ISE project based on makefile:');
        disp(formatDispStr(makeFile,2));

        makeErrMsg='Failed to create ISE project for USRP2 FPGA.';
        runMake(h,'createproject',makeErrMsg);






        projPath=h.getProjectPath(pwd,userParam.projectName,...
        tdkParam.projectOldExt);

        if strcmpi(userParam.usrpOutput,'ISE project')
            [statusStr,tclStr]=fpgaObj.openProject(projPath.fileName,projPath.filePath);
        else


            [statusStr,tclStr]=fpgaObj.openProject(projPath.fileName);
        end


        [stat,cmd]=fpgaObj.addFiles(genFiles);

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,formatDispStr('Generated files:',2),stat];


        [stat,cmd]=fpgaObj.closeProject;

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,stat];


        tclFile=tdkParam.tclCmdFile;
        tclErrMsg='Failed to add generated files to ISE project for USRP2 FPGA.';
        h.writeTclScript(tclFile,tclStr,tclErrMsg);


        xtclRtn=h.executeTclScript(tclFile,tclErrMsg);


        disp(statusStr);
        if~isempty(xtclRtn)
            hdldisp(['ISE messages:',char(10),xtclRtn]);
        end




        if strcmpi(userParam.usrpOutput,'FPGA bitstream')
            disp(' ');
            hdldisp('Running synthesis in ISE.');
            hdldisp('This will take some time. Please wait ...');

            makeErrMsg='Failed to synthesize ISE project for USRP2 FPGA.';
            runMake(h,'synthesize',makeErrMsg);

            disp(' ');
            hdldisp('Running implementation and bitstream generation in ISE.');
            hdldisp('This will take some time. Please wait ...');

            makeErrMsg='Failed to generate bitstream for USRP2 FPGA.';
            runMake(h,'generatebit',makeErrMsg);

            disp(' ');
            hdldisp('Finished running ISE processes. Please examine the project results.');
            hdldisp(['Project: ',fpgaObj.getProjectLink(projPath.filePath)]);
            disp(' ');
        end


        cd(orgDir);

    catch me
        cd(orgDir);
        rethrow(me);
    end


    function rxHDLFiles=createRxObject(hdlcData)

        rx=eda.internal.usrp2impl.dsp_core_rx;
        rx.Partition.Lang='verilog';
        rx.Partition.Type='HW';
        rx.gBuild;


        dutName=hdlcData.dutName;
        filterDut=rx.findComponent('Name','USRPFilterRX');
        filterDut=filterDut{1};

        filterDut.UniqueName=[dutName(1:end-2),'rx'];


        rx.gUnify;
        rx.gCodeGen(hdlcData.hdlPropSet);

        rxHDLFiles=rx.HDLFiles;


        function txHDLFiles=createTxObject(hdlcData)

            tx=eda.internal.usrp2impl.dsp_core_tx;
            tx.Partition.Lang='verilog';
            tx.Partition.Type='HW';
            tx.gBuild;


            filterDut=tx.findComponent('Name','USRPFilterTX');
            filterDut=filterDut{1};
            filterDut.UniqueName=hdlcData.dutName;


            tx.gUnify;
            tx.gCodeGen(hdlcData.hdlPropSet);

            txHDLFiles=tx.HDLFiles;


            function makeRtn=runMake(h,process,makeErrMsg)

                switch process
                case 'createproject'
                    makeOpt='proj';
                case 'compile'
                    makeOpt='check';
                case 'synthesize'
                    makeOpt='synth';
                case 'generatebit'
                    makeOpt='bin';
                case 'all'
                    makeOpt='all';
                otherwise
                    error(message('EDALink:FDHDLCWorkflowMgr:runUSRP:undefinedbuildopt'));
                end

                [makeStat,makeRtn]=system(['make ',makeOpt]);
                if makeStat
                    if~isempty(makeRtn)


                        errlog='edalink.log';
                        h.writeTclScript(errlog,makeRtn,'',false);

                        disp(' ');
                        disp(['Error: ',makeErrMsg]);
                        disp('Check log file below for details.');

                        errlink=['<a href="matlab:edit(''',fullfile(pwd,errlog),''')">',fullfile(pwd,errlog),'</a>'];
                        disp(errlink);
                    end
                    error(message('EDALink:FDHDLCWorkflowMgr:runUSRP:runmake',makeErrMsg));
                end


