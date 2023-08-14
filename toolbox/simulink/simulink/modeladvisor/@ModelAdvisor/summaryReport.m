function summaryReport(cmdLinerun,varargin)












    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    CR=newline;
    if isempty(cmdLinerun)
        DAStudio.error('ModelAdvisor:engine:CmdAPIInputArgumentsError');
    else
        for i=1:length(cmdLinerun)
            if isempty(cmdLinerun{i})
                DAStudio.error('ModelAdvisor:engine:CmdAPIInputArgumentsError');
            end
        end
    end

    inputParamParser=parseInputParameters(varargin);
    inputArgs=inputParamParser.Results;


    if isempty(inputArgs.OutputFolder)
        fileGenCfg=Simulink.fileGenControl('getConfig');
        rootBDir=fileGenCfg.CacheFolder;
    else
        rootBDir=inputArgs.OutputFolder;
    end


    v=ver('Simulink');
    versionStr=num2str(v.Version);

    numModels=length(cmdLinerun);
    if~iscell(cmdLinerun)&&numModels==1
        t=cmdLinerun;
        cmdLinerun={};
        cmdLinerun{1}=t;
    end
    WorkDir='';
    htmlStr=[];strNotRun=[];
    for i=1:numModels
        if~isempty(cmdLinerun{i}.CheckResultObjs)
            path=cmdLinerun{i}.getData('mdladvinfo.path');
        else
            path={cmdLinerun{i}.system};
        end
        if(isempty(path))
            path={cmdLinerun{i}.system};
        end
        WorkDir=rtwprivate('rtw_create_directory_path',rootBDir,'slprj','modeladvisor',path{1:1:end});
        mdlNotRun=cmdLinerun{i}.numPass==-1||cmdLinerun{i}.numFail==-1||cmdLinerun{i}.numWarn==-1;
        if~mdlNotRun
            fid=fopen([WorkDir,'/report.html'],'w','n','utf-8');
            htmlreport=cmdLinerun{i}.getData('htmlreport');
            fwrite(fid,htmlreport,'char');
            fclose(fid);

            idx=strfind(cmdLinerun{i}.system,'/');
            if~isempty(idx)
                model=cmdLinerun{i}.system(1:idx(1)-1);
            else
                model=cmdLinerun{i}.system;
            end

            htmlStr=[htmlStr,'<tr>',CR,''];%#ok<AGROW>
            shrinkSys=cmdLinerun{i}.system;
            sysPath=which(model);
            if length(shrinkSys)>50
                shrinkSys=['...',shrinkSys(length(shrinkSys)-50:end)];
            end



            htmlStr=[htmlStr,'',CR,'<td><a title= "',sysPath,'" href="matlab: open_system(''',model,''');  open_system(''',cmdLinerun{i}.system,''') "> ',shrinkSys,'</a></td>'];%#ok<AGROW>
            htmlStr=[htmlStr,'',CR,'<td align = "center">',num2str(cmdLinerun{i}.numPass),'</td>'];%#ok<AGROW>
            htmlStr=[htmlStr,'',CR,'<td align = "center">',num2str(cmdLinerun{i}.numFail),'</td>'];%#ok<AGROW>


            htmlStr=[htmlStr,'',CR,'<td align = "center">',num2str(cmdLinerun{i}.numWarn),'</td>'];%#ok<AGROW>        
            htmlStr=[htmlStr,'',CR,'<td align = "center">',num2str(cmdLinerun{i}.numNotRun),'</td>'];%#ok<AGROW>



            if strfind(cmdLinerun{i}.reportFileName,'report.html')


                relativePath=strrep(WorkDir,[rootBDir,filesep,'slprj',filesep,'modeladvisor',filesep],'');
                relativePath=[relativePath,filesep,'report.html'];%#ok<AGROW>
                reportDisplayName='../Report.html';
            else
                [~,name,ext]=fileparts(cmdLinerun{i}.reportFileName);
                reportDisplayName=[name,ext];
                relativePath=cmdLinerun{i}.reportFileName;
            end

            htmlStr=[htmlStr,'',CR,'<td align = "center"><a title="',relativePath,'" href="',relativePath,'"> ',reportDisplayName,' </a></td>'];%#ok<AGROW>
            htmlStr=[htmlStr,'',CR,'</tr>'];%#ok<AGROW>

            warnId={};
            failId={};
            warnIdx=[];
            failIdx=[];
            for j=1:length(cmdLinerun{i}.CheckResultObjs)
                if strcmp(cmdLinerun{i}.CheckResultObjs(j).status,'Pass')
                elseif strcmp(cmdLinerun{i}.CheckResultObjs(j).status,'Warning')
                    tstr=['CheckRecord_',num2str(cmdLinerun{i}.CheckResultObjs(j).index)];
                    warnId=[warnId,tstr];%#ok<AGROW>
                    warnIdx=[warnIdx,j];%#ok<AGROW>
                else
                    tstr=['CheckRecord_',num2str(cmdLinerun{i}.CheckResultObjs(j).index)];
                    failId=[failId,tstr];%#ok<AGROW>
                    failIdx=[failIdx,j];%#ok<AGROW>
                end
            end
        else
            if isempty(cmdLinerun{i}.getData('mdladvinfo.ConfigFilePathInfo.name'))
                strNotRun=[strNotRun,'<tr><td><b>',cmdLinerun{i}.system,'</b>: ',cmdLinerun{i}.getData('report'),'</td></tr>'];%#ok<AGROW>
            else
                strNotRun=[strNotRun,'<tr><td><b>',cmdLinerun{i}.system,'</b>: ',DAStudio.message('ModelAdvisor:engine:CmdAPIEmptyConfig'),'</td></tr>'];%#ok<AGROW>
            end
        end
    end

    strNotRun=['<br/><br/><b>',DAStudio.message('ModelAdvisor:engine:CmdAPISystemsNotRun'),'</b><br/><table>',CR,'',strNotRun,'',CR,'</table>'];

    imgs=modeladvisorprivate('modeladvisorutil2','getDataURLImages');
    warningImg=imgs{1};
    passedImg=imgs{2};
    failedImg=imgs{3};
    notrunImg=imgs{4};

    if~isempty(htmlStr)
        htmlStr=['<br/><br/><br/><b>',DAStudio.message('ModelAdvisor:engine:CmdAPISystemsRun'),'</b>',CR,'<table border = "2">',CR,'<tr>',CR,'<th>',DAStudio.message('ModelAdvisor:engine:CmdAPISystem'),'</th>',...
        '',CR,'<th><IMG ',passedImg,'/>',DAStudio.message('ModelAdvisor:engine:CmdAPIPassed'),'</th>',...
        '',CR,'<th><IMG ',failedImg,'/>',DAStudio.message('ModelAdvisor:engine:CmdAPIFailed'),'</th>',...
        '',CR,'<th><IMG ',warningImg,'/>',DAStudio.message('ModelAdvisor:engine:CmdAPIWarnings'),'</th>',...
        '',CR,'<th><IMG ',notrunImg,'/>',DAStudio.message('ModelAdvisor:engine:CmdAPINotRun'),'</th><th>',DAStudio.message('ModelAdvisor:engine:CmdAPIMAReport'),'</th>',CR,'</tr>',...
        htmlStr,...
        '',CR,'</table> '];
    else
        htmlStr=['<br/><b>',DAStudio.message('ModelAdvisor:engine:CmdAPISystemsRun'),'</b><br/>',DAStudio.message('ModelAdvisor:engine:CmdAPINotApplicable')];
    end

    numModelsPassed=0;
    numModelsFailed=0;
    numModelsNotRun=0;
    numModelsWarn=0;

    for ii=1:numModels
        if cmdLinerun{ii}.numWarn==-1||cmdLinerun{ii}.numFail==-1||cmdLinerun{ii}.numPass==-1
            numModelsNotRun=numModelsNotRun+1;
        elseif cmdLinerun{ii}.numWarn==0&&cmdLinerun{ii}.numFail==0
            numModelsPassed=numModelsPassed+1;
        elseif cmdLinerun{ii}.numFail~=0
            numModelsFailed=numModelsFailed+1;
        else
            numModelsWarn=numModelsWarn+1;
        end
    end
    configUsed=DAStudio.message('ModelAdvisor:engine:CmdAPINotApplicable');
    for ii=1:numModels
        if~isempty(cmdLinerun{ii}.CheckResultObjs)&&~isempty(cmdLinerun{ii}.getData('mdladvinfo.ConfigFilePathInfo.name'))
            configUsed=cmdLinerun{ii}.getData('mdladvinfo.ConfigFilePathInfo.name');
            break;
        end
    end

    str2=['<br/><b>',DAStudio.message('ModelAdvisor:engine:CmdAPIRunSummary'),'</b><table>',CR,'<tr>',CR,'<td>',DAStudio.message('ModelAdvisor:engine:CmdAPISysPassed'),'</td><td>  ',DAStudio.message('ModelAdvisor:engine:CmdAPIOf',num2str(numModelsPassed),num2str(numModels)),'</td>',CR,'</tr>',...
    '<tr>',CR,'<td>',DAStudio.message('ModelAdvisor:engine:CmdAPISysWarnings'),'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>',CR,'<td >',DAStudio.message('ModelAdvisor:engine:CmdAPIOf',num2str(numModelsWarn),num2str(numModels)),'</td>',CR,'</tr>',...
    '<tr>',CR,'<td>',DAStudio.message('ModelAdvisor:engine:CmdAPISysFailed'),'</td>',CR,'<td>  ',DAStudio.message('ModelAdvisor:engine:CmdAPIOf',num2str(numModelsFailed),num2str(numModels)),'</td>',CR,'</tr>.'];
    if numModelsNotRun~=0
        str2=[str2,'',CR,'<tr><td>',DAStudio.message('ModelAdvisor:engine:CmdAPISysNotRun'),'</td>',CR,'<td>  ',DAStudio.message('ModelAdvisor:engine:CmdAPIOf',num2str(numModelsNotRun),num2str(numModels)),' </td>',CR,'</tr>'];
    else
        strNotRun=[];
    end

    str2=[str2,CR,'</table>'];
    for i=1:numModels
        date=datestr(cmdLinerun{i}.getData('geninfo.generateTime'));
        if~isempty(date)
            break;
        end
    end
    if isempty(date)
        date=DAStudio.message('ModelAdvisor:engine:CmdAPINotApplicable');
    end
    checkListIds=[];
    invalidCheckID=[];
    if strcmp(configUsed,DAStudio.message('ModelAdvisor:engine:CmdAPINotApplicable'))
        for i=1:length(cmdLinerun)
            if~isempty(cmdLinerun{i}.CheckResultObjs)
                for j=1:length(cmdLinerun{i}.CheckResultObjs)
                    if~strcmp(cmdLinerun{i}.CheckResultObjs(j).status,'Invalid Check ID')
                        checkListIds=[checkListIds,'',CR,'<tr><td>',cmdLinerun{i}.CheckResultObjs(j).checkID,'</td></tr>'];%#ok<AGROW>
                    else
                        invalidCheckID=[invalidCheckID,'',CR,'<tr><td>',cmdLinerun{i}.CheckResultObjs(j).checkID,'</td></tr>'];%#ok<AGROW>
                    end
                end
                break
            end
        end

        if~isempty(checkListIds)
            checkListIds=['<br/><br/><table><th align = "left">',DAStudio.message('ModelAdvisor:engine:CmdAPIValidCheckIDs'),'</th>',checkListIds,'<table>'];
        else
            checkListIds=['<br/><b>',DAStudio.message('ModelAdvisor:engine:CmdAPIValidCheckIDs'),'</b><br/>',DAStudio.message('ModelAdvisor:engine:CmdAPINotApplicable'),'<br/>'];
        end
        if~isempty(invalidCheckID)
            invalidCheckID=['<br/>',CR,'<table><th align = "left">',DAStudio.message('ModelAdvisor:engine:CmdAPIInvalidCheckIDs'),'</th>',...
            invalidCheckID,'',CR,'<table>'];
        end
    end

    htmlTitle=[DAStudio.message('ModelAdvisor:engine:CmdAPIMASummaryReport'),' - ',pwd];
    headStr='<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>';
    str=['<html>',CR,'<body>',CR,'<head>',headStr,'<title>',htmlTitle,CR,'</title></head>',...
    '<table width="100%" border="0">',CR,'<tr>',CR,'<td colspan="2" align="center"><b>',DAStudio.message('ModelAdvisor:engine:CmdAPIMASummary'),'</b></td>',CR,'</tr>',...
    '',CR,'<tr>',CR,'<td align="left"><b>',DAStudio.message('ModelAdvisor:engine:CmdAPISLVer'),': <font color="#800000">',versionStr,'</font></b></td> ',CR,'',...
    '<td align="right"><b>',DAStudio.message('ModelAdvisor:engine:CmdAPICurrentRun'),': <font color="#800000">',date,'</font></b></td></tr> ',CR,'',...
    '<tr><td align="left"><b>',DAStudio.message('ModelAdvisor:engine:CmdAPIConfigFile'),': ',configUsed,'</b></td>',CR,'',...
    '<td align="right"><b>',DAStudio.message('ModelAdvisor:engine:CmdAPINumSystems'),': ',num2str(numModels),'</b></td>',CR,'</tr>',CR,'</table>',...
    str2,htmlStr,strNotRun,checkListIds,invalidCheckID,...
    '</body>',CR,'<html>'];

    if isempty(inputArgs.OutputFolder)
        summaryReportPath=[rootBDir,filesep,'slprj',filesep,'modeladvisor',filesep,'summaryReport.html'];
    else
        summaryReportPath=[inputArgs.OutputFolder,filesep,'summaryReport.html'];
    end
    fid=fopen(summaryReportPath,'w','n','utf8');
    fwrite(fid,str,'char');
    fclose(fid);
    if strcmpi(inputArgs.DisplayReport,'on')
        web(summaryReportPath);
    end

end


function ipParser=parseInputParameters(ipValues)
    ipParser=inputParser;

    addParameter(ipParser,'OutputFolder','',@(x)ischar(x));
    addParameter(ipParser,'DisplayReport','on',@(x)ischar((validatestring(x,{'on','off'}))))
    parse(ipParser,ipValues{:});
end
