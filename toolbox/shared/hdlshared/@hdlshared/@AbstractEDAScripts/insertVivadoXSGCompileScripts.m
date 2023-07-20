function insertVivadoXSGCompileScripts(this,topfid,topname)




    hModel=bdroot;
    hdriver=hdlmodeldriver(hModel);



    vivadoSysgenQueryFlow=downstream.queryflowmodesenum.VIVADOSYSGEN;


    if~isempty(hdriver)&&isprop(hdriver,'DownstreamIntegrationDriver')
        oldhDI=hdriver.DownstreamIntegrationDriver;
    else
        oldhDI=[];
    end



    hDI=downstream.DownstreamIntegrationDriver(hModel,false,false,'',vivadoSysgenQueryFlow,hdriver,false,false,true);



    createVivadoPrj(hDI);


    simCmdsTclPath=createSimCommandsTclFile(hDI);




    generateSimScripts(hDI,simCmdsTclPath);






    vivadoSimScriptDir=fullfile(hDI.getProjectPath,sprintf('%s_vivado.sim',this.TopLevelName),'sim_1','behav');








    genScriptsPostFix=hDI.hToolDriver.hEmitter.tclExternalSimScriptsPostFix;
    relScriptFileList=processGeneratedSimScripts(topname,this.getDUTLanguage,vivadoSimScriptDir,genScriptsPostFix);


    prjName=vivadoSysgenQueryFlow.getTclDirName;
    hdlsrcRelVivadoSimScriptDir=fullfile(prjName,sprintf('%s_vivado.sim',this.TopLevelName),'sim_1','behav');
    fprintf(topfid,'set curDir [pwd]\n');
    fprintf(topfid,'cd %s\n',strrep(hdlsrcRelVivadoSimScriptDir,'\','/'));
    fprintf(topfid,'do %s\n',strrep(relScriptFileList.compile,'\','/'));
    if isstruct(relScriptFileList)&&length(fieldnames(relScriptFileList))==2
        fprintf(topfid,'do %s\n',strrep(relScriptFileList.elaborate,'\','/'));
    end
    fprintf(topfid,'cd $curDir\n');



    hdriver.DownstreamIntegrationDriver=oldhDI;
end

function relScriptFileList=processGeneratedSimScripts(topname,dutlang,vivadoSimScriptDir,genScriptsPostFix)


    if isempty(genScriptsPostFix)
        genScriptsPostFix={''};
    end

    numGenScripts=length(genScriptsPostFix);
    relScriptFileList=cellfun(@(x)[topname,x,'.do'],genScriptsPostFix,'UniformOutput',false);
    scriptFileList=cellfun(@(x)fullfile(vivadoSimScriptDir,x),relScriptFileList,'UniformOutput',false);
    switch numGenScripts
    case 1
        relScriptFileList=cell2struct(relScriptFileList,{'compile'},1);
        scriptFileList=cell2struct(scriptFileList,{'compile'},1);
        compileDoFileContent=removeModelSimQuitTags(scriptFileList.compile,true);
        compileDoFileContent=removeAndSaveSimCmds(vivadoSimScriptDir,topname,compileDoFileContent);
    case 2
        relScriptFileList=cell2struct(relScriptFileList,{'compile','elaborate'},2);
        scriptFileList=cell2struct(scriptFileList,{'compile','elaborate'},2);
        compileDoFileContent=removeModelSimQuitTags(scriptFileList.compile,true);
        removeModelSimQuitTags(scriptFileList.elaborate);
    end



    insertHdlPrintTargetCodegenHeaders(hdlsynthtoolenum.Vivado,dutlang,scriptFileList.compile,compileDoFileContent);
end

function createVivadoPrj(hDI)
    hDI.hToolDriver.hEmitter.updateCreateProjectTcl;
    hDI.hToolDriver.hTool.lockCurrentDir;
    hDI.hToolDriver.hEmitter.generateTcl(1);

    [systemStatus,resultStr]=hDI.hToolDriver.hTool.runTclFile(hDI.hToolDriver.hEmitter.TclFileName);
    [systemStatus,resultStr]=validateTclExecStatus(hDI,systemStatus,resultStr);
    if systemStatus
        error(message('hdlcoder:validate:xsgvivsimscriptsgenfailure',hDI.getDutName,resultStr));
    end
end

function simCmdsTclPath=createSimCommandsTclFile(hDI)

    vivadoSysgenQueryFlow=hDI.queryFlowOnly;


    [prjDir,prjTclFileName,~]=fileparts(vivadoSysgenQueryFlow.getTclFilePath(hDI));

    simCmdsTclFileName=[prjTclFileName,'_simCmds.tcl'];
    simCmdsTclPath=fullfile(prjDir,simCmdsTclFileName);
    fid=fopen(simCmdsTclPath,'w');
    if fid==-1
        error(message('hdlcommon:workflow:UnableCreateTclFile',simCmdsTclPath));
    end
    if~isempty(hDI.hToolDriver.hEmitter.tclExternalSimScriptGen)
        fprintf(fid,'%s\n',hDI.hToolDriver.hEmitter.tclExternalSimScriptGen{:});
    end
    fclose(fid);
end

function generateSimScripts(hDI,simCmdsTclPath)
    hDI.hToolDriver.hTool.CustomTclFile={simCmdsTclPath};
    hDI.hToolDriver.hEmitter.generateCustomTcl;
    [systemStatus,resultStr]=hDI.hToolDriver.hTool.runTclFile(hDI.hToolDriver.hEmitter.CustomTclFileName);
    [systemStatus,resultStr]=validateTclExecStatus(hDI,systemStatus,resultStr);
    if systemStatus
        error(message('hdlcoder:validate:xsgvivsimscriptsgenfailure',hDI.getDutName,resultStr));
    end
end

function doFileContent=removeModelSimQuitTags(doFilePath,skipWrite)
    if nargin<2
        skipWrite=false;
    end
    doFileContent='';

    if exist(doFilePath,'file')
        doFileContent=fileread(doFilePath);
        doFileContent=regexprep(doFileContent,'onbreak\s+{(\s+)?\w+\s+\W(\s+)?\w(\s+)?}','');
        doFileContent=regexprep(doFileContent,'onerror\s+{(\s+)?\w+\s+\W(\s+)?\w(\s+)?}','');
        doFileContent=regexprep(doFileContent,'quit\s+\W(\s+)?\w+','');

        if~skipWrite
            fid=fopen(doFilePath,'w');
            if fid==-1
                error(message('hdlcommon:workflow:UnableCreateFile',doFilePath));
            end
            fprintf(fid,'%s',doFileContent);
            fclose(fid);
        end
    end

end

function newDoFileContent=removeAndSaveSimCmds(vivadoSimScriptDir,topname,doFileContent)
    newDoFileContent=doFileContent;

    vsimCmdIdx=regexp(doFileContent,'vsim\s+-','once');
    if isempty(vsimCmdIdx)
        return
    end




    newDoFileContent=doFileContent(1:vsimCmdIdx-1);
    simDoFileContent=doFileContent(vsimCmdIdx:end);
    simDoFilePath=fullfile(vivadoSimScriptDir,[topname,'_simulate.do']);

    fid=fopen(simDoFilePath,'w');
    if fid==-1
        error(message('hdlcommon:workflow:UnableCreateFile',simDoFilePath));
    end
    fprintf(fid,'%s',simDoFileContent);
    fclose(fid);
end

function insertHdlPrintTargetCodegenHeaders(target,dutlang,doFilePath,doFileContent)
    fid=fopen(doFilePath,'w');
    if fid==-1
        error(message('hdlcommon:workflow:UnableCreateFile',doFilePath));
    end




    [~,vmapCmdIdx]=regexp(doFileContent,'(?<vmapCmd>vmap.[^\n]+)','names','once');
    if~isempty(vmapCmdIdx)
        fprintf(fid,'%s\n',doFileContent(1:vmapCmdIdx-1));
        fprintf(fid,hdlprinttargetcodegenheaders(target,dutlang,true));
        fprintf(fid,'\n%s\n',doFileContent(vmapCmdIdx:end));
    end

    fclose(fid);
end

function[status,log]=validateTclExecStatus(hDI,systemStatus,resultStr)
    status=systemStatus;
    log=resultStr;






    captureError=hDI.hToolDriver.hTool.cmd_captureError;
    if~isempty(captureError)
        logStr=resultStr;%#ok<NASGU>
        for ii=1:length(captureError)
            cmdCapture=captureError{ii};
            cmdStr=sprintf('regexp(logStr, ''%s'', ''once'')',cmdCapture);
            cmdResult=eval(cmdStr);
            if~isempty(cmdResult)

                status=1;

                log=logStr(cmdResult:end);
                break;
            end
        end
    end

end



