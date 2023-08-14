function[fileURL,urlAppend]=model2code(sids,rptInfo)



    [licenseCheck,MissingLicense]=rtw.report.checkOutLicenseForTraceability();

    if~licenseCheck
        DAStudio.error('RTW:report:Model2CodeLicenseError',strjoin(MissingLicense,', '));
    end

    try
        sids=Simulink.ID.getSID(sids);
    catch
    end
    if~iscell(sids)
        sids={sids};
    end
    model=strtok(sids{1},':/');
    fileLineMap=containers.Map;

    traceInfo=[];
    if coder.internal.slcoderReport('existTraceInfo',model)
        traceInfo=RTW.TraceInfo.instance(model);
        if isempty(traceInfo.BuildDir)
            traceInfo.setBuildDir('');
        end
        for idx=1:length(sids)
            sid=sids{idx};
            reg=traceInfo.getRegistry(sid,'NeedMergeAllInlineTrace',false);
            if~isempty(reg)&&~isempty(reg.location)
                for i=1:length(reg.location)
                    if(isTraceableFile(traceInfo,reg.location(i).file))
                        [~,filename,ext]=fileparts(reg.location(i).file);
                        filename=[filename,ext];
                        if~fileLineMap.isKey(filename)
                            fileLineMap(filename)=containers.Map('KeyType','int32','ValueType','char');
                        end
                        lineMap=fileLineMap(filename);
                        lineMap(reg.location(i).line)='';%#ok
                    end
                end
            end
        end
    end



    blockSid=sids{1};


    if~isempty(rptInfo.SourceSubsystem)
        inCodeTraceInfo=coder.trace.getTraceInfo(rptInfo.SourceSubsystem);
    else
        inCodeTraceInfo=coder.trace.getTraceInfo(model);
    end

    if~isempty(inCodeTraceInfo)
        tracedFiles=inCodeTraceInfo.files;
        for idx=1:length(sids)
            sid=sids{idx};
            if~isempty(rptInfo.SourceSubsystem)
                sid=[rptInfo.ModelName,...
                Simulink.ID.getSubsystemBuildSID(sid,rptInfo.SourceSubsystem)];
            end
            r=inCodeTraceInfo.getModelToCode(sid);
            for i=1:length(r.tokens)
                fileName=tracedFiles{r.tokens(i).fileIdx+1};
                if~fileLineMap.isKey(fileName)
                    fileLineMap(fileName)=containers.Map('KeyType','int32','ValueType','char');
                end
                lineMap=fileLineMap(fileName);
                lineMap(r.tokens(i).line)='';%#ok
            end
        end
    end

    files=fileLineMap.keys;
    urlId='';
    if~isempty(files)
        if~rtw.report.ReportInfo.featureReportV2
            urlId='[';
        else
            urlId='{"data": [';
        end
        for i=1:length(files)
            aFile=files{i};
            if~rtw.report.ReportInfo.featureReportV2

                [p,f,e]=fileparts(aFile);
                aFile=fullfile(p,[f,'_',e(2:end),'.html']);
            end
            lines=fileLineMap(files{i}).keys;
            if numel(lines)>0
                ids=['["',int2str(lines{1}),'"'];
                for j=2:numel(lines)
                    ids=[ids,',"',int2str(lines{j}),'"'];
                end

                if~rtw.report.ReportInfo.featureReportV2
                    urlId=[urlId,'{file: "',aFile,'", id: ',ids,']},'];%#ok<*AGROW>
                else
                    urlId=[urlId,'{"file": "',aFile,'", "line": ',ids,']},'];%#ok<*AGROW>
                end
            end
        end
        if~rtw.report.ReportInfo.featureReportV2
            urlId=[urlId(1:end-1),']'];
        else
            urlId=[urlId(1:end-1),']}'];
        end
    end

    rtwName='';
    if length(sids)==1&&~isempty(traceInfo)
        reg=traceInfo.getRegistry(blockSid,'NeedMergeAllInlineTrace',false);
        if~isempty(reg)
            rtwName=Simulink.report.ReportInfo.escapeSpecialCharInJS(reg.rtwname);
            rtwName=strrep(urlencode(rtwName),'+','%20');
        end
    end
    if~isempty(files)
        urlArgs=['?useExternalBrowser=false&inCodeTrace=true&numBlocks=',num2str(length(sids)),'&block=',sid,'&traceData=',urlId];
        if~isempty(rtwName)
            urlArgs=[urlArgs,'&rtwname=',rtwName];
        end
        fileURL=Simulink.document.fileURL(rptInfo.getReportFileFullName,urlArgs);
    else
        error_msgId='';
        if length(sids)>1
            error_msgId='rtwMsg_noTraceForSelectedBlocks';
        else
            if~isempty(traceInfo)&&~isempty(reg)
                error_msgId=traceInfo.getReason('',reg);
            end
        end
        fileURL=displayMessage(rptInfo,error_msgId,blockSid,rtwName);
    end

    if~rtw.report.ReportInfo.featureReportV2
        urlAppend=[];
        rptInfo.show(fileURL);
    else
        urlAppend=rptInfo.show(blockSid,urlId);
    end
end

function result=isTraceableFile(traceInfo,file)
    result=false;
    for i=1:length(traceInfo.generatedFiles)
        if(strcmp(file,traceInfo.generatedFiles{i}))
            result=true;
            break;
        end
    end
end

function out=displayMessage(reportInfo,msgId,blockSid,rtwName)
    if isempty(msgId)
        fileURL=Simulink.document.fileURL(reportInfo.getReportFileFullName,['?useExternalBrowser=false&inCodeTrace=true&block=',blockSid,'&traceData=']);
    else
        msg=strrep(msgId,'RTW:traceInfo:','rtwMsg_');
        fileURL=Simulink.document.fileURL(reportInfo.getReportFileFullName,...
        ['?msg=',msg,'&block=',blockSid,'&model2code_src=model']);
    end
    if~isempty(rtwName)
        fileURL=[fileURL,'&rtwname=',rtwName];
    end
    out=fileURL;
end

