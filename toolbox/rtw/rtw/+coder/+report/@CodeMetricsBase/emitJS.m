function emitJS(obj,filename)



    fid=fopen(filename,'w','n','utf-8');
    fwrite(fid,sprintf('function CodeMetrics() {\n'),'char');
    fwrite(fid,sprintf('\t this.metricsArray = {};\n'),'char');
    fwrite(fid,sprintf('\t this.metricsArray.var = new Array();\n'),'char');
    fwrite(fid,sprintf('\t this.metricsArray.fcn = new Array();\n'),'char');
    try
        for i=1:length(obj.Data.GlobalVarInfo)
            str=sprintf('\t this.metricsArray.var["%s"] = {file: "%s",\n\tsize: %d};\n',strrep(obj.Data.GlobalVarInfo(i).Name,'\','\\'),strrep(strrep(obj.Data.GlobalVarInfo(i).File{1},'\','\\'),'"','\"'),obj.Data.GlobalVarInfo(i).Size);
            fwrite(fid,str,'char');
        end
        for i=1:length(obj.Data.FcnInfo)
            str=sprintf('\t this.metricsArray.fcn["%s"] = {file: "%s",\n\tstack: %d,\n\tstackTotal: %d};\n',strrep(obj.Data.FcnInfo(i).Name,'\','\\'),strrep(strrep(obj.Data.FcnInfo(i).File{1},'\','\\'),'"','\"'),obj.Data.FcnInfo(i).Stack,obj.Data.FcnInfo(i).StackTotal);
            fwrite(fid,str,'char');
        end
    catch me
        fclose(fid);
        rethrow(me);
    end
    fwrite(fid,sprintf('\t this.getMetrics = function(token) { \n'),'char');
    fwrite(fid,sprintf('\t\t var data;\n'),'char');
    fwrite(fid,sprintf('\t\t data = this.metricsArray.var[token];\n'),'char');
    fwrite(fid,sprintf('\t\t if (!data) {\n'),'char');
    fwrite(fid,sprintf('\t\t\t data = this.metricsArray.fcn[token];\n'),'char');
    fwrite(fid,sprintf('\t\t\t if (data) data.type = "fcn";\n'),'char');
    fwrite(fid,sprintf('\t\t } else { \n'),'char');
    fwrite(fid,sprintf('\t\t\t data.type = "var";\n'),'char');
    fwrite(fid,sprintf('\t\t }\n\t return data; }; \n'),'char');


    fwrite(fid,sprintf('\t %s\n',emitSummaryJS(obj)),'char');

    fwrite(fid,sprintf('\t}\n'),'char');
    fwrite(fid,sprintf('CodeMetrics.instance = new CodeMetrics();\n'),'char');
    fclose(fid);
end

function out=emitSummaryJS(obj)
    accumulatedGlobalVar=0;
    for i=1:length(obj.Data.GlobalVarInfo)
        accumulatedGlobalVar=accumulatedGlobalVar+obj.Data.GlobalVarInfo(i).Size;
    end
    maximumFcnStack=0;
    for i=1:length(obj.Data.FcnInfo)
        currentStack=obj.Data.FcnInfo(i).Stack;
        if(currentStack>maximumFcnStack)
            maximumFcnStack=currentStack;
        end
    end
    if~obj.isSLReportV2
        out=['this.codeMetricsSummary = ''<a href="',obj.ModelName,'_metrics.html">','Global Memory: ',num2str(accumulatedGlobalVar),'(bytes) Maximum Stack: ',num2str(maximumFcnStack),'(bytes)</a>'';'];
    else
        metricsReportName=[obj.ModelName,'_metrics'];
        callBackStr=sprintf("return postParentWindowMessage({message:\\'gotoReportPage\\', pageName:\\'%s\\'});",metricsReportName);
        infoStr=['Global Memory: ',num2str(accumulatedGlobalVar),'(bytes) Maximum Stack: ',num2str(maximumFcnStack),'(bytes)'];
        out=sprintf('this.codeMetricsSummary = ''<a href="javascript:void(0)" onclick="%s">%s</a>'';',callBackStr,infoStr);
    end
end
