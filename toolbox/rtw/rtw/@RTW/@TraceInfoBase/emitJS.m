function emitJS(h,filename)





    fid=fopen(filename,'w','n','utf-8');
    bHasWebview=false;
    if isa(h,'RTW.TraceInfo')
        reportInfo=h.getReportInfo();
        bHasWebview=reportInfo.hasWebview;
    end
    if~isa(h,'RTW.TraceInfo')||bHasWebview

        fwrite(fid,sprintf('function RTW_Sid2UrlHash() {\n'),'char');
        fwrite(fid,sprintf('\tthis.urlHashMap = new Array();\n'),'char');
        reportPath=h.getCodeGenRptFullPathName;
        reasonMap=h.getBlockReductionReasons;
        try
            arrayfun(@(x)(locWriteCodeLocation(fid,h,x,reasonMap,reportPath)),h.Registry);
        catch me
            fclose(fid);
            rethrow(me);
        end
        fwrite(fid,sprintf('\tthis.getUrlHash = function(sid) { return this.urlHashMap[sid];}\n}\n'),'char');
        fwrite(fid,sprintf('RTW_Sid2UrlHash.instance = new RTW_Sid2UrlHash();\n'),'char');
    end

    if isa(h,'RTW.TraceInfo')
        systemMap=reportInfo.SystemMap;
        modelName=reportInfo.ModelName;
        sourceSubsys=reportInfo.SourceSubsystem;
        isRTW=true;
    else
        systemMap=[];
        modelName=h.Model;
        sourceSubsys='';
        isRTW=false;
    end
    coder.internal.slcoderReport('genRTWnameSIDMap',fid,h.registry,systemMap,modelName,sourceSubsys,isRTW);

    fclose(fid);

    function locWriteCodeLocation(fid,h,reg,reasonMap,reportPath)
        location=reg.location;
        if isempty(location)
            msgId=h.getReason(reasonMap,reg);

            if~strcmp(msgId,'RTW:traceInfo:virtualBlock')&&...
                ~strcmp(msgId,'RTW:traceInfo:maskedSubSystem')
                url=h.displayMessage(reportPath,msgId,reg.sid);
            else
                url='';
            end
        else
            url=h.highlightCodeLocations(location);
        end
        [~,hash]=strtok(url,'?');
        if~isempty(hash)

            hash=strrep(hash,'"','\"');
            str=sprintf('\tthis.urlHashMap["%s"] = "%s";\n',reg.sid,hash(2:end));
            fwrite(fid,sprintf('\t/* %s */\n',reg.rtwname),'char');
            fwrite(fid,str,'char');
        end


