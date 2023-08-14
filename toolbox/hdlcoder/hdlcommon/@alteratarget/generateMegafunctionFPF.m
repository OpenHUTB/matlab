function status=generateMegafunctionFPF(targetCompInventory,megafunctionName,ipgArgs,latencyFreq,isFreqDriven,num,dryRun,deviceInfo)










    dispMsg=false;
    if(~isempty(targetCompInventory))
        if(targetCompInventory.contains(megafunctionName)==false)
            dispMsg=true;
        end
        targetCompInventory.add(megafunctionName,megafunctionName,latencyFreq,isFreqDriven,alteratarget.getExtraDir(ipgArgs,deviceInfo{1}),num);
        targetDir=targetCompInventory.getBlockPath(latencyFreq,isFreqDriven);
        if isempty(targetDir)
            error(message('hdlcommon:targetcodegen:TargetDirNotInferred'));
        end
        ext=targetCompInventory.getExtension;
    else
        ext='.vhd';
    end


    pathToIPG=targetcodegen.alterafpfdriver.getToolPath();
    cmd=sprintf('%s %s',pathToIPG,ipgArgs);
    try
        if(dispMsg)
            if(~isFreqDriven)
                hdldisp(message('hdlcoder:hdldisp:AlteraMegafunction',megafunctionName,latencyFreq));
            else
                hdldisp(message('hdlcoder:hdldisp:AlteraMegafunction1',megafunctionName,latencyFreq));
            end
        end
        currDir=pwd;
        if(~isempty(targetCompInventory))
            hdlDir=targetCompInventory.getCodegendir;
            if(~isdir(hdlDir))
                hdlDir=targetCompInventory.createDirIfNeeded(hdlDir);
            end
            cd(hdlDir);
            targetCompInventory.createDirIfNeeded(targetDir);
            cd(targetDir);
        end
        pathToFile=getMegaFunctionFilePath([megafunctionName,ext],ipgArgs,deviceInfo{1});
        pathToCodegenLogFile=fullfile(pwd,[megafunctionName,'_log.mat']);
        pathToSignatureFile=[megafunctionName,'_signature.txt'];
        incrCodeGen=targetcodegen.alteraIPGenerateIncrementalCodeGenDriver({pathToCodegenLogFile},pathToSignatureFile);
        incrCodeGen.retrieveSignature(cmd);
        skip=incrCodeGen.checkIncrementCodegenStatus();
        if skip

            logs=load(pathToCodegenLogFile);
            cmdStatus=logs.cmdStatus;
            cmdLog=logs.cmdLog;
            if(exist(pathToFile,'file')==2)
                if(dispMsg)
                    hdldisp(message('hdlcommon:targetcodegen:IncrementalCodeGenMessage',pathToFile));
                end
            end
        else
            synthTool=hdlgetparameter('SynthesisTool');
            if strcmpi(synthTool,'Intel Quartus Pro')
                pathToQuartusPro=hdlgetpathtoquartuspro;
                [qproPath,~,~]=fileparts(pathToQuartusPro);



                if strcmpi(deviceInfo{1},'Agilex')
                    qshPath=fullfile(qproPath,'quartus_sh');
                    qproVersionCmd=sprintf('%s -h',qshPath);
                    [~,Ver]=system(qproVersionCmd);
                    qproVerstr=regexp(Ver,'Version\s*([\d\.]*)\s*Build','tokens');
                    qproVersion=qproVerstr{1}{:};
                    if str2double(qproVersion(1:4))<20.1
                        error(message('hdlcommon:workflow:HFPNotSupportedAgilex'));
                    end
                end




                system(cmd);

                pathToQuartusPro=hdlgetpathtoquartuspro;
                [qproPath,~,~]=fileparts(pathToQuartusPro);
                pathToQIPG=fullfile(qproPath,'quartus_ipgenerate');
                ipgArgsQIPG='--generate_project_ip_file --synthesis=vhdl --simulation=verilog --generate_ip_file --ip_file=';
                ipExt='.ip';
                cmdQIPG=sprintf('%s %s %s%s%s',pathToQIPG,megafunctionName,ipgArgsQIPG,megafunctionName,ipExt);




                TclFileName='createTempProj.tcl';
                fid=fopen(TclFileName,'w');
                fprintf(fid,'# This is .tcl file to generate temp project\n\n');
                fprintf(fid,'set myProject "%s"\n',megafunctionName);
                fprintf(fid,'set myProjectFile "%s.qpf"\n',megafunctionName);
                fprintf(fid,'set Family "%s"\n',deviceInfo{1});

                fprintf(fid,'load_package flow\n');
                fprintf(fid,'project_new $myProject\n');
                fprintf(fid,'set_global_assignment -name FAMILY "%s"\n',deviceInfo{1});

                fprintf(fid,'set_global_assignment -name IP_FILE "%s.ip"\n',megafunctionName);
                fprintf(fid,'project_close\n');
                fclose(fid);
                pathToTclCmd=fullfile(qproPath,'quartus_sta -t');
                cmdStr=sprintf('%s %s',pathToTclCmd,TclFileName);
                [~,~]=system(cmdStr);
                delete(TclFileName);


                [cmdStatus,cmdLog]=system(cmdQIPG);


                alteraIPLibName=getMegaFunctionLibName(megafunctionName);


                copyfile(fullfile(megafunctionName,'synth'),'synth');

                copyfile(fullfile(megafunctionName,alteraIPLibName,'synth'),fullfile('synth',megafunctionName,alteraIPLibName));


                rmdir(fullfile(megafunctionName),'s');
                rmdir('qdb','s');
                delete *.qpf;
                delete *.qsf;
                delete *.ip;
            else

                [cmdStatus,cmdLog]=system(cmd);
            end

            save(pathToCodegenLogFile,'cmdStatus','cmdLog');
            incrCodeGen.writeIncrementCodegenSignature();
        end

        [logStatus,achievedLatency,achievedFreq]=parseLog(megafunctionName,cmdLog,latencyFreq,isFreqDriven);
        if(logStatus==0&&cmdStatus==0)
            status.status=0;
            status.achievedFreq=achievedFreq;
            status.achievedLatency=achievedLatency;
            status.IP=megafunctionName;
            status.path=fileparts(pathToFile);
        elseif(logStatus==1&&cmdStatus~=0&&dryRun)
            status.status=1;
        else

            cd(currDir);
            error(message('hdlcommon:targetcodegen:AlteraMegaWizardError',sprintf('%s\n%s\n%s',cmdLog,'command to run:',cmd)));
        end

        assert(status.status==0||status.status==1);
        if status.status==1
            assert(dryRun);
        else
            if(~isempty(targetCompInventory))

                resourceUsage=alteratarget.generateResourceUsageFPF(megafunctionName,cmd,deviceInfo{1});
                if(~isempty(resourceUsage))
                    targetCompInventory.setResourceUsage(megafunctionName,resourceUsage,status.achievedFreq,status.achievedLatency);
                end
            end
            assert(status.status==0);
            if(dispMsg)
                if(isFreqDriven)
                    hdldisp(message('hdlcommon:targetcodegen:AltfpLatency',status.IP,status.achievedLatency));
                end
            end
        end

        incrCodeGen.printIncrementCodegenSignature();

        cd(currDir);
        if(dispMsg)
            hdldisp(message('hdlcoder:hdldisp:Done'));
        end
    catch me
        cd(currDir);
        rethrow(me);
    end
end

function filePath=getMegaFunctionFilePath(fileName,cmd,deviceFamily)
    extraDir=alteratarget.getExtraDir(cmd,deviceFamily);
    synthTool=hdlgetparameter('SynthesisTool');
    if strcmpi(synthTool,'Intel Quartus Pro')
        [~,folderName,~]=fileparts(fileName);
        filePath=fullfile(pwd,folderName,extraDir,fileName);
    else
        filePath=fullfile(pwd,extraDir,fileName);
    end
end

function alteraIPLibName=getMegaFunctionLibName(megafunctionName)
    alteraIPList=dir(megafunctionName);
    alteraIPdirlist=alteraIPList([alteraIPList(:).isdir]);
    alteraIPContents=alteraIPdirlist(~ismember({alteraIPdirlist(:).name},{'.','..'}));
    alteraIPFolders={alteraIPContents.name};
    alteraIPFolderLocation=startsWith(alteraIPFolders,'altera');
    alteraIPLibName=char(alteraIPFolders(alteraIPFolderLocation));
end

function[result,latency,frequency]=parseLog(megafunctionName,cmdLog,latencyFreq,isFreqDriven)

    frequency=latencyFreq;
    latency=latencyFreq;
    doneFlag=sprintf('%s: Done',megafunctionName);
    if(isFreqDriven)
        passFlag=sprintf('%s: Latency on .+ is (\\d+) cycle',megafunctionName);
        passTokens=regexpi(cmdLog,passFlag,'tokens','once');
        if(~isempty(passTokens))
            latency=str2double(passTokens{1});
        else
            latency=-1;
        end
        failureFlag=sprintf('%s: Failed to generate HDL for current parameters',megafunctionName);
    else
        passFlag=sprintf('%s: Could achieve (\\d+) cycles latency maximum at Frequency (\\d+) MHz',megafunctionName);
        passTokens=regexpi(cmdLog,passFlag,'tokens','once');
        if(~isempty(passTokens))
            latency=str2double(passTokens{1});
            frequency=str2double(passTokens{2});
        else
            frequency=-1;
        end
        failureFlag=sprintf('%s: Could not achieve the requested latency',megafunctionName);
    end

    foundDone=~isempty(strfind(cmdLog,doneFlag));
    foundFailure=~isempty(strfind(cmdLog,failureFlag));
    foundPass=~isempty(passTokens);

    assert(~(foundPass==true&&foundFailure==true));
    if(foundDone)
        if(foundPass)
            result=0;
        elseif(foundFailure)
            result=1;
        else
            result=2;
        end
    else
        result=2;
    end
end

