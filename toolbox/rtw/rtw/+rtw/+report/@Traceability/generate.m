function generate(~,varargin)




    if nargin>=2
        obj=varargin{1};
    else
        return;
    end

    if Simulink.report.ReportInfo.featureReportV2
        [traceStatus,reportInfo,cfg]=getSaveTraceInfoStatus(obj);


        buildDir=obj.BuildDirectory;
        htmlDir=fullfile(buildDir,'html','pages');
        if~isfolder(htmlDir)


            htmlDir=fullfile(buildDir,'html');
        end
        htmlDirParent=fullfile(buildDir,'html');
        currModel=obj.ModelName;
        traceRptName=coder.internal.slcoderReport('getTraceReportFileName',currModel,htmlDir);
        [rootsys,subsys,bMdlRef]=getSystemNames(obj);



        try
            traceInfoFile=fullfile(htmlDirParent,[currModel,'_traceInfo.js'],'f');
            if isfile(traceInfoFile)
                movefile(traceInfoFile,htmlDir);
            end
        catch
        end

        if traceStatus.bSaveTraceInfo


            traceInfo_fileList={};
            sortedFileInfoList=reportInfo.getSortedFileInfoList;
            for n=1:sortedFileInfoList.NumFiles
                if(isequal(fileparts(sortedFileInfoList.FileName{n}),buildDir)||...
                    isequal(fileparts(sortedFileInfoList.FileName{n}),'$(BuildDir)'))
                    traceInfo_fileList{length(traceInfo_fileList)+1}=sortedFileInfoList.FileName{n};%#ok<AGROW>
                end
            end
            h=coder.internal.slcoderReport('saveTraceInfo',rootsys,buildDir,traceInfo_fileList,bMdlRef,subsys,currModel,reportInfo);
            coder.internal.slcoderReport('generateHighlightMessageFile',fullfile(htmlDir,'rtwmsg.html'));
            fpath=fileparts(traceRptName);
            if traceStatus.gentrace

                h.emitJS(fullfile(fpath,[currModel,'_traceInfo.js']));
            end
            if traceStatus.bLink2Webview
                h.emitSidMapJS(fullfile(fpath,[currModel,'_sid_map.js']));
            end
            if traceStatus.gentracerpt
                coder.internal.slcoderReport('generateTraceReport',h,traceRptName,cfg);
            else
                coder.internal.slcoderReport('generateEmptyTraceReport',traceRptName,currModel);
            end
        else

            coder.internal.slcoderReport('clearTraceInfo',rootsys,htmlDir);
            bIsERTTarget=reportInfo.IsERTTarget;
            protectingCurrentModel=Simulink.ModelReference.ProtectedModel.protectingModel(currModel);
            if bIsERTTarget&&~protectingCurrentModel
                coder.internal.slcoderReport('generateEmptyTraceReport',traceRptName,currModel);
            end
        end
    end
end

function[traceStatus,reportInfo,cfg]=getSaveTraceInfoStatus(obj)



    traceStatus=struct(...
    'gentrace',false,...
    'gentracerpt',false,...
    'bLink2Webview',false,...
    'hlink',false,...
    'bSaveTraceInfo',false...
    );

    reportInfo=rtw.report.getReportInfo(obj.ModelName,obj.BuildDirectory);
    cfg=obj.Config;

    traceStatus.hlink=strcmp(cfg.IncludeHyperlinkInReport,'on');
    traceStatus.bLink2Webview=reportInfo.hasWebview;

    if strcmp(cfg.GenerateTraceReport,'on')||...
        strcmp(cfg.GenerateTraceReportSl,'on')||...
        strcmp(cfg.GenerateTraceReportSf,'on')||...
        strcmp(cfg.GenerateTraceReportEml,'on')
        traceStatus.gentracerpt=true;
    end

    if strcmp(cfg.GenerateTraceInfo,'on')
        traceStatus.gentrace=true;
    end

    traceStatus.bSaveTraceInfo=...
    (traceStatus.gentrace||traceStatus.gentracerpt||(traceStatus.bLink2Webview&&traceStatus.hlink));
end

function[rootsys,subsys,bMdlRef]=getSystemNames(obj)

    bMdlRef=~strcmp(obj.ModelReferenceTargetType,'NONE');
    reportInfo=rtw.report.getReportInfo(obj.ModelName,obj.BuildDirectory);

    if bMdlRef
        subsys='';
    else
        subsys=reportInfo.SourceSubsystem;
    end

    if isempty(subsys)

        rootsys=getfullname(obj.ModelName);
    else

        if slfeature('RightClickBuild')==0
            rootsys=strtok(subsys,'/:');
        else
            rootsys=obj.ModelName;
        end
    end

end
