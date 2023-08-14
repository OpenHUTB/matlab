function status=generateCoregenBlk(targetCompInventory,coregenBlkName,coregenModule,coregenParamsFile,extraArgs,latency,num)


    if(nargin<6)
        num=1;
    end

    shouldGenerateCoregenBlock=true;
    if targetCompInventory.contains(coregenBlkName)
        shouldGenerateCoregenBlock=false;
    end
    targetCompInventory.add(coregenBlkName,coregenModule,latency,false,'',num);
    status=0;
    if~shouldGenerateCoregenBlock
        return;
    end

    targetDir=targetCompInventory.getXilinxProjectPathBase(latency,false);
    if isempty(targetDir)
        error(message('hdlcommon:targetcodegen:TargetDirNotInferred'));
    end

    resourceUsage=xilinxtarget.generateResourceUsage(coregenModule,coregenParamsFile,coregenBlkName);
    if~isempty(resourceUsage)
        targetCompInventory.setResourceUsage(coregenBlkName,resourceUsage,-1,latency);
    end


    cmd=sprintf('%s -b "%s" -intstyle silent',targetcodegen.xilinxdriver.getToolPath(),coregenParamsFile);

    ext=targetCompInventory.getExtension;

    try
        hdldisp(message('hdlcoder:hdldisp:CoregenStart',coregenBlkName,latency));
        currDir=pwd;
        targetCompInventory.createDirIfNeeded(targetDir);
        cd(targetDir);
        pathToFile=sprintf('%s%s%s%s',pwd,filesep,coregenBlkName,ext);
        incrCodeGen=targetcodegen.xilinxCoreGenIncrementalCodeGenDriver({pathToFile},[coregenBlkName,'_signature.txt']);
        incrCodeGen.retrieveSignature(cmd);
        skip=incrCodeGen.checkIncrementCodegenStatus();
        if skip

            hdldisp(message('hdlcommon:targetcodegen:IncrementalCodeGenMessage',pathToFile));
        else

            [status,cmdlog]=system(cmd);
            if status

                cd(currDir);
                delete(coregenParamsFile);
                error(message('hdlcommon:targetcodegen:XilinxCoregenError',cmdlog));
            end
        end

        if~skip
            incrCodeGen.writeIncrementCodegenSignature();
        end
        incrCodeGen.printIncrementCodegenSignature();

        cd(currDir);
        hdldisp(message('hdlcoder:hdldisp:Done'));
    catch me
        cd(currDir);
        rethrow(me);
    end
end


