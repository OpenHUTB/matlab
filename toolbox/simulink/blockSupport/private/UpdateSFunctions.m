function UpdateSFunctions(block,h)

    appendCompileCheck(h,block,@loc_collectBlockData,@loc_updateBlocks);
end



function blockInfo=loc_collectBlockData(block,~)

    blockInfo.hasPaddedBusIOIssue=strcmp(get_param(block,'HasPaddedBusIOIssue'),'on');

    blockInfo.lctDiagInfo=[];
    blockInfo.hasLctFileIssue=false;

    sfcnName=get_param(block,'FunctionName');
    sfcnPath=loc_findSFunctionPath(sfcnName);
    if isempty(sfcnPath)
        return
    end


    cfgFile=fullfile(sfcnPath,'rtwmakecfg.m');
    if isfile(cfgFile)
        [status,~,needFix]=legacycode.lct.util.fixRtwMakeCfgFile(cfgFile,true);
        if needFix
            blockInfo.lctDiagInfo=[blockInfo.lctDiagInfo;loc_makeDiagStruct(cfgFile,status,needFix)];
        end
    end


    cfgFile=fullfile(sfcnPath,[sfcnName,'_makecfg.m']);
    if isfile(cfgFile)
        [status,~,needFix]=legacycode.lct.util.fixRtwMakeCfgFile(cfgFile,true);
        if needFix
            blockInfo.lctDiagInfo=[blockInfo.lctDiagInfo;loc_makeDiagStruct(cfgFile,status,needFix)];
        end
    end


    tlcFile=fullfile(sfcnPath,[sfcnName,'.tlc']);
    if isfile(tlcFile)
        [status,~,needFix]=legacycode.lct.util.fixTlcBlockFile(tlcFile,true);
        if needFix
            blockInfo.lctDiagInfo=[blockInfo.lctDiagInfo;loc_makeDiagStruct(tlcFile,status,needFix)];
        end
    end

    blockInfo.hasLctFileIssue=~isempty(blockInfo.lctDiagInfo);
end


function loc_updateBlocks(block,h,blockInfo)
    if~blockInfo.hasPaddedBusIOIssue&&~blockInfo.hasLctFileIssue
        return
    end

    sfcnName=get_param(block,'FunctionName');
    compileState=h.CompileState;



    compileStateData=h.getCheckData('UpdateSFunctionsWithPaddedBuses');
    if isempty(compileStateData)||(compileStateData.compileState~=compileState)
        compileStateData.compileState=compileState;
        compileStateData.processed={};
        compileStateData.processedRtwMakecfgFile={};
    end




    if ismember(sfcnName,compileStateData.processed)
        return
    else
        compileStateData.processed{end+1}=sfcnName;
        h.setCheckData('UpdateSFunctionsWithPaddedBuses',compileStateData);
    end

    functionSet={};
    reasonSet={};
    if blockInfo.hasPaddedBusIOIssue
        if~isempty(get_param(block,'WizardData'))

            reasonSet={DAStudio.message('SimulinkBlocks:upgrade:upgradeSFunctionBuilderWithPaddedBus')};
            func1=@()loc_updateSFunctionBuilder(block,sfcnName);
            functionSet={func1};
        else
            [commands,sfcnPath]=loc_getLegacyCodeToolCommands(block);
            if isempty(commands)

                reasonSet={DAStudio.message('SimulinkBlocks:upgrade:upgradeOtherSFunctionWithPaddedBus')};
            else

                reasonSet={DAStudio.message('SimulinkBlocks:upgrade:upgradeLegacyCodeToolWithPaddedBus')};
                func1=@()loc_updateLegacyCodeToolSFunction(commands,sfcnName,sfcnPath);
                functionSet={func1};
            end
        end
    end

    if blockInfo.hasLctFileIssue
        for ii=1:numel(blockInfo.lctDiagInfo)
            [~,fname,fext]=fileparts(blockInfo.lctDiagInfo(ii).filePath);
            if fext==".m"
                if fname=="rtwmakecfg"

                    if ismember(blockInfo.lctDiagInfo(ii).filePath,compileStateData.processedRtwMakecfgFile)
                        continue
                    else
                        compileStateData.processedRtwMakecfgFile{end+1}=blockInfo.lctDiagInfo(ii).filePath;
                        h.setCheckData('UpdateSFunctionsWithPaddedBuses',compileStateData);
                    end
                end
                reasonSet{end+1}=DAStudio.message('SimulinkBlocks:upgrade:upgradeLegacyCodeToolRtwMakeCfgFile');%#ok<AGROW>
                if blockInfo.lctDiagInfo(ii).status==0

                    functionSet{end+1}=@()loc_updateLegacyCodeToolFile(blockInfo.lctDiagInfo(ii).filePath,false);%#ok<AGROW> 
                end
            elseif fext==".tlc"
                reasonSet{end+1}=DAStudio.message('SimulinkBlocks:upgrade:upgradeLegacyCodeToolTlcBlockFile');%#ok<AGROW>
                if blockInfo.lctDiagInfo(ii).status==0

                    commands=loc_getLegacyCodeToolCommands(block,true);
                    functionSet{end+1}=@()loc_updateLegacyCodeToolFile(blockInfo.lctDiagInfo(ii).filePath,true,commands);%#ok<AGROW>
                end
            else
                continue
            end
        end
    end

    if numel(reasonSet)>1

        reason='';
        for ii=1:numel(reasonSet)
            reason=sprintf('%s<br>- %s',reason,reasonSet{ii});
        end
    else
        reason=reasonSet{1};
    end

    loc_handleUpgrade(h,block,reason,functionSet);
end



function loc_handleUpgrade(h,block,reason,functionSet)
    if askToReplace(h,block)
        if(doUpdate(h))
            for idx=1:length(functionSet)
                fcn=functionSet{idx};
                fcn();
            end
        end

        appendTransaction(h,block,reason,functionSet);
    end
end



function loc_updateSFunctionBuilder(block,sfcnName)
    fcnToTry=@()loc_runSFunctionBuilderCommands(block,sfcnName);
    sfcnPath=loc_findSFunctionPath(sfcnName);
    loc_executeInTempDirFirst(fcnToTry,sfcnPath);
end


function loc_runSFunctionBuilderCommands(block,sfcnName)
    handle=get_param(block,'Handle');
    appdata=sfunctionwizard(handle,'GetApplicationData');
    sfunctionwizard(handle,'Build',appdata);
    sfunctionwizard(handle,'delete');
    clear(sfcnName);
end


function loc_executeInTempDirFirst(fcnToTry,sfcnPath)
    if nargin<2||isempty(sfcnPath)
        sfcnPath=pwd;
    end

    function loc_doCleanup(adir,apath,atempdir)
        cd(adir);
        path(apath);
        rmdir(atempdir,'s');
    end

    tempName=loc_createTemporaryDirectory();
    currPath=path;
    origDir=pwd;

    ocRestore=onCleanup(@()loc_doCleanup(origDir,currPath,tempName));

    addpath(pwd);
    cd(tempName);


    fcnToTry();


    cd(sfcnPath);
    fcnToTry();
    ocRestore.delete();
end



function loc_updateLegacyCodeToolSFunction(commands,sfcnName,sfcnPath)
    fcnToTry=@()loc_runLegacyCodeToolCommands(commands,sfcnName);
    loc_executeInTempDirFirst(fcnToTry,sfcnPath);
end


function loc_updateLegacyCodeToolFile(filePath,isTLC,cmds)
    if nargin<3
        cmds={};
    end
    if isTLC
        if isempty(cmds)
            [status,msg]=legacycode.lct.util.fixTlcBlockFile(filePath);
        else
            fcnToTry=@()loc_runLegacyCodeToolCommands(cmds,'');
            loc_executeInTempDirFirst(fcnToTry);
        end
    else
        [status,msg]=legacycode.lct.util.fixRtwMakeCfgFile(filePath);
    end
    if status==2
        DAStudio.error('SimulinkBlocks:upgrade:upgradeLegacyCodeToolFileFailed',...
        filePath,getString(msg));
    end
end


function loc_runLegacyCodeToolCommands(commands,sfcnName)
    for idx=1:length(commands)
        command=commands{idx};
        evalc(command);
    end

    clear(sfcnName);
end


function tempName=loc_createTemporaryDirectory()
    tempName=tempname;
    mkdir(tempName);
end


function sfcnPath=loc_findSFunctionPath(sfcnName)
    mexName=[sfcnName,'.',mexext];
    mexFile=which(mexName);
    if isfile(mexFile)
        sfcnPath=fileparts(mexFile);
    else
        sfcnPath='';
    end
end


function[lctCommands,sfcnPath]=loc_getLegacyCodeToolCommands(block,isTLC)
    if nargin<2
        isTLC=false;
    end
    lctCommands={};

    sfcnName=get_param(block,'FunctionName');
    sfcnPath=loc_findSFunctionPath(sfcnName);
    if~isempty(sfcnPath)
        if isTLC
            cFile=fullfile(sfcnPath,[sfcnName,'.tlc']);
        else

            cFile=fullfile(sfcnPath,[sfcnName,'.c']);
            if~isfile(cFile)

                cFile=fullfile(sfcnPath,[sfcnName,'.cpp']);
            end
        end
        if isfile(cFile)
            lctCommands=loc_parseLegacyCodeToolFile(cFile);
        end
    end
end


function lctCommands=loc_parseLegacyCodeToolFile(cFile)
    lctCommands={};
    fid=fopen(cFile);
    if fid==-1
        return
    end

    ocFile=onCleanup(@()fclose(fid));




    state=0;

    startline='%%%-MATLAB_Construction_Commands_Start';
    endline='%%%-MATLAB_Construction_Commands_End';
    while 1
        tline=fgetl(fid);
        if~ischar(tline)
            break
        end

        switch state
        case 0
            if~isempty(regexp(tline,startline,'once'))
                state=1;
            end

        case 1
            if~isempty(regexp(tline,endline,'once'))
                state=2;
                break
            else
                lctCommands{end+1}=tline;%#ok<AGROW>
            end
        end
    end

    if state~=2

        lctCommands={};
    end
end


function s=loc_makeDiagStruct(filePath,status,needsUpdate)
    s=struct(...
    'filePath',filePath,...
    'status',status,...
    'needsUpdate',needsUpdate...
    );
end
