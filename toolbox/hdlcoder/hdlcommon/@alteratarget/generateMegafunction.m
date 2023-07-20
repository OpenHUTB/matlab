function status=generateMegafunction(targetCompInventory,megafunctionName,megafunctionModule,megafunctionParamsFile,latency,num)


    if(nargin<6)
        num=1;
    end

    shouldGenerateMegaFunction=true;
    if targetCompInventory.contains(megafunctionName)
        shouldGenerateMegaFunction=false;
    end
    targetCompInventory.add(megafunctionName,megafunctionModule,latency,false,'',num);
    status=0;
    if~shouldGenerateMegaFunction
        return;
    end
    targetDir=targetCompInventory.getBlockPath(latency,false);
    if isempty(targetDir)
        error(message('hdlcommon:targetcodegen:TargetDirNotInferred'));
    end
    ext=targetCompInventory.getExtension;

    resourceUsage=alteratarget.generateResourceUsage(megafunctionModule,megafunctionParamsFile,megafunctionName);
    if~isempty(resourceUsage)
        targetCompInventory.setResourceUsage(megafunctionName,resourceUsage,-1,latency);
    end


    cmd=sprintf('%s -silent module=%s -f:"%s" %s%s',...
    targetcodegen.alteradriver.getToolPath(),...
    megafunctionModule,...
    megafunctionParamsFile,...
    megafunctionName,...
    ext);
    try
        hdldisp(message('hdlcoder:hdldisp:AlteraMegafunction',megafunctionName,latency));
        currDir=pwd;
        hC=hdlcurrentdriver;
        hdlDir=hC.hdlGetCodegendir;
        cd(hdlDir);
        targetCompInventory.createDirIfNeeded(targetDir);
        cd(targetDir);
        pathToFile=sprintf('%s%s%s%s',pwd,filesep,megafunctionName,ext);
        incrCodeGen=targetcodegen.alteraMegaFunctionIncrementalCodeGenDriver({pathToFile},[megafunctionName,'_signature.txt']);
        incrCodeGen.retrieveSignature(cmd);
        skip=incrCodeGen.checkIncrementCodegenStatus();
        if skip

            hdldisp(message('hdlcommon:targetcodegen:IncrementalCodeGenMessage',pathToFile));
        else

            [status,cmdLog]=system(cmd);
            if status

                cd(currDir);
                delete(megafunctionParamsFile);
                error(message('hdlcommon:targetcodegen:AlteraMegaWizardError',cmdLog));
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


