classdef CodeMetricsBase<coder.report.ReportPageBase






    properties(Hidden)
        InReportInfo=false
        BuildDir=''
        msgs=[]
        targetisCPP=false;
    end

    properties(Hidden,Transient)
        slFeatureReportV2=false
        forceGenHyperlinkToSource=false;
        htmlfileExistMap=containers.Map
    end

    methods
    end

    methods(Access=private)
        fileTable=getHTMLFileInfo(obj)
        out=getHTMLGlobalVariable(obj)
        out=getHTMLCLassMember(obj)
        [table,rowNumber]=getHTMLGlobvalVariableStructTable(obj,members,lvl,id,rowNumber,hasMdlRefVars,colWidthsInPercent,colAlignment)
        [table,rowNumber]=getHTMLClassStructTable(obj,members,lvl,id,rowNumber,hasMdlRefVars,colWidthsInPercent,colAlignment)
        table=getHTMLFcnInfoTableView(obj)
        fcnTable=getHTMLFcnInfo(obj)
        title=getFunctionTitle(obj,fcn,fcnName)
        table=getHTMLMemoryMetrics(obj,metrics,bRptLOC)
        txt=getFcnNameWithHyperlink(obj,fcn)
        [table,row,fcnVisited,myTotal]=getSubFcnTable(obj,fcn,lvl,metrics,groupId,row,fcnVisited,ignoreChild,nodePosition,bRptLOC)
        out=getOnloadJSFcn(~)
        addMetaData(obj)
        fileInfo=getReportFileInfo(obj)
        out=getLinks2SourceFiles(obj)
        out=getFileNames(obj)
        bGenHyperlink=getGenHyperlinkFlag(~)
    end

    methods(Hidden=true)
        introduction=getHTMLIntroduction(~)
        initMessages(obj)
        textFcn=addNumOfCalls(obj,fcn_text,fcn,parent,nCalled)
        emitJS(obj,filename)
        fillFileInformation(obj,chapter)
        function ret=isSLReportV2(~)
            ret=false;
        end
    end
end




