function generateBDWImportScripts(this,sysCTB,dName)













    fprintf('\n');
    hdldisp(message('hdlcoder:hdldisp:StratusImporterRun'));
    d=pwd;
    cd(hdlGetCodegendir);
    stratusPrjDir='stratus_prj';
    dName=[this.hHDLDriver.getParameter('module_prefix'),dName];

    if exist(stratusPrjDir,'dir')
        [~,~]=system(sprintf("rm -r %s",stratusPrjDir));
    end
    [~,~]=system(sprintf("mkdir %s",stratusPrjDir));


    if contains(sysCTB,"HDL Test bench stimulus")
        [~,~]=system(sprintf("cp *.hpp *.dat *.tcl %s",stratusPrjDir));
        cd(stratusPrjDir);

        importCmd=sprintf("bdw_import -force -template ml_cynw_p2p %sClass.hpp",dName);
        [~,logTxt]=system(importCmd);

    elseif contains(sysCTB,"Test bench with random input stimulus")
        [~,~]=system(sprintf("cp *.hpp *.tcl %s",stratusPrjDir));
        cd(stratusPrjDir);

        importCmd=sprintf("bdw_import -force -template ml_cynw_p2p_rand_tb %sClass.hpp",dName);
        [~,logTxt]=system(importCmd);
    end


    logFileName=[dName,'_bdw_import_log.txt'];

    fid=fopen(logFileName,'w');
    if fid==-1
        error(message('hdlcoder:matlabhdlcoder:openfile',logFileName));
    end
    fprintf(fid,'%s',logTxt);
    fclose(fid);

    if~isempty(logTxt)&&contains(logTxt,"Import successful")
        prjFile='project.tcl';
        dirName=fullfile(hdlGetCodegendir,stratusPrjDir);
        prjFilePath=fullfile(dirName,prjFile);
        cmd_openTargetTool=sprintf("openStratusProject('%s')",fullfile(dirName));

        prjLink=sprintf('<a href="matlab:downstream.DownstreamIntegrationDriver.%s"> %s </a>',...
        cmd_openTargetTool,prjFilePath);

        msg=message('hdlcoder:hdldisp:WorkingOnBlock',prjFile,hdlgetfilelink(prjFilePath));
        hdldisp(msg);

        msg=message('hdlcoder:workflow:GeneratingProject',"Cadence Stratus",prjLink);
        hdldisp(msg);

        hdldisp(message('hdlcoder:hdldisp:WorkingOnBlock',logFileName,hdlgetfilelink(fullfile(hdlGetCodegendir,stratusPrjDir,logFileName))));
        hdldisp(message('hdlcoder:hdldisp:StratusBdwImportSuccess'));
    else
        hdldisp(message('hdlcoder:hdldisp:WorkingOnBlock',logFileName,hdlgetfilelink(fullfile(hdlGetCodegendir,stratusPrjDir,logFileName))));
        error(message('hdlcoder:hdldisp:StratusBdwImportFailure',logFileName));
    end

    if contains(sysCTB,"Test bench with random input stimulus")


        fprintf('\n');
        hdldisp(message('hdlcoder:hdldisp:StratusSimSetupRun'));

        [~,simSetupLog]=system("make sim_setup");


        simSetupFileName=[dName,'_sim_setup_log.txt'];

        fid=fopen(simSetupFileName,'w');
        if fid==-1
            error(message('hdlcoder:matlabhdlcoder:openfile',simSetupFileName));
        end
        fprintf(fid,'%s',simSetupLog);
        fclose(fid);

        hdldisp(message('hdlcoder:hdldisp:WorkingOnBlock',simSetupFileName,hdlgetfilelink(fullfile(hdlGetCodegendir,stratusPrjDir,simSetupFileName))));

        if~isempty(simSetupLog)&&contains(simSetupLog,"Simulation setup complete")
            hdldisp(message('hdlcoder:hdldisp:StratusSimSetupSuccess'));
        else
            error(message('hdlcoder:hdldisp:StratusSimSetupFailure',simSetupFileName));
        end
    end

    cd(d);
end

