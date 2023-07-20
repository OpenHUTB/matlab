function emitWebview(obj)





    obj.WebviewFileName='';
    if strcmp(obj.Config.GenerateWebview,'on')
        if isempty(ver('rptgenext'))
            MSLDiagnostic('RTW:report:SimulinkRptGenNotInstalled').reportAsWarning;
        elseif~builtin('license','checkout','SIMULINK_Report_Gen')
            MSLDiagnostic('RTW:report:WebviewMissRptGenLicense').reportAsWarning;
        elseif~matlab.ui.internal.hasDisplay
            MSLDiagnostic('RTW:report:WebviewNoDisplay').reportAsWarning;
        elseif~obj.featureWebview2()
            locEmitWebview1(obj);
        else
            locEmitWebview2(obj);
        end
    end
end

function locEmitWebview2(obj)
    if~isempty(obj.SourceSubsystem)
        modelname=obj.SourceSubsystem;
    else
        modelname=obj.ModelName;
    end
    loc_SetLibrarySfChartActiveInstanceToModelBlock(bdroot(modelname));
    try
        reportDir=getReportDir(obj);
        if Simulink.report.ReportInfo.featureReportV2&&isa(obj,'rtw.report.ReportInfo')
            reportDir=fullfile(reportDir,'pages');
        end
        cacheDir=tempname;
        mkdir(cacheDir);
        warning('off','slreportgen_webview:json_writer:MalformedJsonFile');
        warningOn=onCleanup(@()warning('on','slreportgen_webview:json_writer:MalformedJsonFile'));
        obj.WebviewFileName=slwebview(modelname,...
        'SearchScope','CurrentAndBelow',...
        'LookUnderMasks','All',...
        'FollowLinks','on',...
        'PackagingType','unzipped',...
        'PackageFolder',cacheDir,...
        'PackageName','webview',...
        'ViewFile',false);
        if strfind(obj.WebviewFileName,cacheDir)
            filePath=obj.WebviewFileName(length(cacheDir)+1:end);
            obj.WebviewFileName=fullfile(reportDir,filePath);
        end
        obj.Dirty=true;


        fileattrib(cacheDir,'+w','','s');
        movefile(fullfile(cacheDir,'*'),reportDir,'f');

        coder.internal.coderCopyfile(...
        fullfile(matlabroot,'toolbox','rtw','rtw','+coder','+report','resources','webview_codegen.js'),...
        fullfile(reportDir,'webview_codegen.js'));
        rmdir(cacheDir);
    catch ME
        obj.WebviewFileName='';
        if strcmp(ME.identifier,'glue2:portal:BadContextCannotUpdateBlockGraphics')
            MSLDiagnostic('RTW:report:GenerateWebviewInSimulation',['rtw.report.generate(''',modelname,''')']).reportAsWarning;
        else
            rethrow(ME);
        end
    end
end

function locEmitWebview1(obj)
    if~isempty(obj.SourceSubsystem)
        modelname=obj.SourceSubsystem;
    else
        modelname=obj.ModelName;
    end
    htmlDir=obj.getReportDir;
    if Simulink.report.ReportInfo.featureReportV2&&isa(obj,'rtw.report.ReportInfo')
        htmlDir=fullfile(htmlDir,'pages');
    end
    Oldpwd=pwd;
    cd(htmlDir);
    try
        if Simulink.internal.useFindSystemVariantsMatchFilter()
            webview_fname=slwebview1(modelname,'SearchScope','CurrentAndBelow','LookUnderMasks','All',...
            'FollowLinks','on','ViewFile',false,'KeepLibInModelView',true,...
            'MatchFilter',@Simulink.match.codeCompileVariants,...
            'UseSIDFlag',true,...
            'EmlStyleSheetFileName','ecoder_eml2html.xsl');
        else
            webview_fname=slwebview1(modelname,'SearchScope','CurrentAndBelow','LookUnderMasks','All',...
            'FollowLinks','on','ViewFile',false,'KeepLibInModelView',true,...
            'Variants','ActivePlusCodeVariants',...
            'UseSIDFlag',true,...
            'EmlStyleSheetFileName','ecoder_eml2html.xsl');
        end
        obj.WebviewFileName=webview_fname;
        obj.Dirty=true;
        fileattrib(webview_fname,'+w');
        [~,fname]=fileparts(webview_fname);
        folder_name=[fname,'_files'];

        fileattrib(folder_name,'+w','','s');
        movefile(fullfile(folder_name,'*'),'.','f');
        movefile('index.html',webview_fname,'f');
        rmdir(folder_name,'s');
        cd(Oldpwd);
    catch ME
        obj.WebviewFileName='';
        cd(Oldpwd);
        if strcmp(ME.identifier,'glue2:portal:BadContextCannotUpdateBlockGraphics')
            MSLDiagnostic('RTW:report:GenerateWebviewInSimulation',['rtw.report.generate(''',modelname,''')']).reportAsWarning;
            return;
        end
        rethrow(ME);
    end
end

function loc_SetLibrarySfChartActiveInstanceToModelBlock(model)






    if Simulink.internal.useFindSystemVariantsMatchFilter()
        blocks=find_system(model,'LookUnderMasks','on','FollowLinks','on',...
        'MatchFilter',@Simulink.match.codeCompileVariants,...
        'LookUnderReadProtectedSubsystems','on','MaskType','Stateflow');
    else
        blocks=find_system(model,'LookUnderMasks','on','FollowLinks','on','Variants','ActivePlusCodeVariants','LookUnderReadProtectedSubsystems','on','MaskType','Stateflow');
    end

    modelH=get_param(model,'Handle');
    for i=1:length(blocks)
        block=blocks{i};
        refBlock=get_param(block,'ReferenceBlock');
        if~isempty(refBlock)


            sfChartId=sfprivate('block2chart',block);
            if modelH~=bdroot(sfprivate('getActiveInstance',sfChartId))
                blockH=get_param(block,'handle');
                sfprivate('setActiveInstance',sfChartId,blockH);
            end
        end
    end
end



