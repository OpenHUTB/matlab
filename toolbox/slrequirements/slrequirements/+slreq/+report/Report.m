classdef Report<mlreportgen.dom.LockedDocument

















































    properties(Constant)

        ARTIFACT_LIST_TARGET='ArtifactListTable';
        ARTIFACT_LIST_SLREQ_TARGET='SLReqListTable';
        ARTIFACT_LIST_SLMODEL_TARGET='SLModelListTable';
        ARTIFACT_LIST_SLTEST_TARGET='SLTestListTable';
        ARTIFACT_LIST_SLDATA_TARGET='SLDataListTable';
        ARTIFACT_LIST_OTHER_TARGET='OtherListTable';

        CHANGED_LINK_LIST_TARGET='ChangedLinkListTable';
    end
    properties(GetAccess=public,SetAccess=public)


        FormatOptions=struct('newPageforChapter',true,...
        'newPageforSection',false);

        ReportOptions=slreq.report.utils.getDefaultOptions();

    end


    properties(GetAccess=public,SetAccess=private)


        SLReqSet=[];
        ArtifactList;

        ArtifactInfo;
        CachedTemplateNameToReportPartMap;
    end

    properties(Hidden=true,Access=public)
        ShowUI=false;

    end

    properties(Hidden=true,SetAccess=private,GetAccess=private)
        ReqSetTitle=[];
        WarningStack={};
    end


    methods

        function rpt=Report(reqSets,varargin)
            p=inputParser;
            addParameter(p,'Type','docx',@(x)ismember(x,{'docx','htmx','html','pdf'}));
            addParameter(p,'ReportOptions',slreq.report.utils.getDefaultOptions());
            addParameter(p,'NewPageForChapter',true);
            addParameter(p,'NewPageForSection',false);
            addParameter(p,'ReqSetTitle','Requirement Set ');
            addParameter(p,'ShowUI',false);

            parse(p,varargin{:});

            tempPath=p.Results.ReportOptions.templatePath;
            [~,~,rpttype]=fileparts(p.Results.ReportOptions.reportPath);
            if strcmp(rpttype,'.html')
                rpttype1='html-file';
            elseif strcmp(rpttype,'.htmx')
                rpttype1='html';
            else
                rpttype1=rpttype(2:end);
            end
            rpt=rpt@mlreportgen.dom.LockedDocument(p.Results.ReportOptions.reportPath,...
            rpttype1,tempPath);
            if isa(reqSets,'slreq.ReqSet')
                rpt.SLReqSet=[reqSets.dataObject];
            else
                rpt.SLReqSet=reqSets;
            end

            rpt.ReportOptions=p.Results.ReportOptions;

            slreq.report.utils.checkMLReportGenLicense(rpt);

            rpt.ShowUI=p.Results.ShowUI;
            rpt.ReportOptions=p.Results.ReportOptions;
            rpt.FormatOptions.newPageForChapter=p.Results.NewPageForChapter;
            rpt.FormatOptions.newPageForSection=p.Results.NewPageForSection;
            rpt.ArtifactList=containers.Map('KeyType','char','ValueType','any');
            if iscell(p.Results.ReqSetTitle)
                rpt.ReqSetTitle=p.Results.ReqSetTitle;
            else
                rpt.ReqSetTitle={p.Results.ReqSetTitle};
            end

            rpt.resetCachedPartObjects();
        end


        function resetCachedPartObjects(rpt)
            rpt.CachedTemplateNameToReportPartMap=containers.Map('KeyType','char','valuetype','any');
        end


        function fill(rpt)


            rpt.resetCachedPartObjects();
            w=onCleanup(@()rpt.resetCachedPartObjects());
            clearArtifactList();
            clearLinkList();
            total=2;

            if rpt.ReportOptions.includes.toc

                total=total+1;
            end

            if rpt.ReportOptions.openReport

                total=total+1;
            end

            if rpt.ReportOptions.includes.links

                total=total+1;
            end

            for index=1:length(rpt.SLReqSet)
                reqSet=rpt.SLReqSet(index);
                if strcmp(reqSet.name,'default')&&...
                    strcmp(reqSet.filepath,'default.slreqx')
                    continue;
                end
                allReqs=reqSet.getAllItems;

                total=total+length(allReqs)+1;
            end

            slreq.utils.updateProgress(rpt.ShowUI,...
            'reset',...
            getString(message('Slvnv:slreq:ReportGenProgressBarStart')),...
            total);

            slreq.utils.updateProgress(rpt.ShowUI,...
            'update',...
            getString(message('Slvnv:slreq:ReportGenProgressBarFillTitle')));
            rpt.fillTitle
            if rpt.ReportOptions.includes.toc
                slreq.utils.updateProgress(rpt.ShowUI,...
                'update',...
                getString(message('Slvnv:slreq:ReportGenProgressBarFillTOC')));
                rpt.fillTOC;
            end

            rpt.fillBody;

            if reqmgt('rmiFeature','TraceabilityTable')
                if rpt.ReportOptions.includes.traceabilityTables
                    rpt.fillTraceabilityTable();
                end
            end

            rpt.fillAppendix();

            slreq.utils.updateProgress(rpt.ShowUI,...
            'update',...
            getString(message('Slvnv:slreq:ReportGenProgressBarFinishFill')));
        end


        function fillTitle(rpt)

            titlepagePart=slreq.report.ReportTitlePart(rpt);
            titlepagePart.fill();
            append(rpt,titlepagePart);
        end


        function fillTOC(rpt)

            tableofcontentsPart=slreq.report.ReportTOCPart(rpt);
            tableofcontentsPart.fill();
            append(rpt,tableofcontentsPart);
        end


        function fillBody(rpt)
            import slreq.report.*

            for setIdx=1:length(rpt.SLReqSet)
                dataReqSet=rpt.SLReqSet(setIdx);
                if strcmp(dataReqSet.name,'default')&&...
                    strcmp(dataReqSet.filepath,'default.slreqx')
                    continue;
                end

                reqSetPart=slreq.report.ReqSetPart(rpt);
                reqSetPart.SetInfo=dataReqSet;



                if rpt.ReportOptions.includes.customAttributes
                    attributeRegistry=slreq.data.ReqData.getInstance.getCustomAttributeRegistries(rpt.SLReqSet(setIdx));


                    reqSetPart.AllCustomAttributes=attributeRegistry.toArray();
                end
                slreq.utils.updateProgress(rpt.ShowUI,...
                'update',...
                getString(message(...
                'Slvnv:slreq:ReportGenProgressBarFillBodyReqSet',...
                rpt.SLReqSet(setIdx).name)));

                reqSetPart.fill();
                append(rpt,reqSetPart);
                if setIdx<length(rpt.SLReqSet)
                    br=mlreportgen.dom.PageBreak();
                    append(rpt,br);
                end
            end
        end


        function fillTraceabilityTable(rpt)
            import slreq.report.*
            ttPart=slreq.report.TraceabilityTablePart(rpt);
            ttPart.setReqSet(rpt.SLReqSet);
            ttPart.fill();
            append(rpt,ttPart);
            br=mlreportgen.dom.PageBreak();
            append(rpt,br);
        end



        function fillAppendix(this)
            if slreq.report.ReportAppendixPart.ArtifactList.Count~=0||...
                slreq.report.ReportAppendixPart.LinkList.Count~=0
                br=mlreportgen.dom.PageBreak();
                append(this,br);
                appendix=slreq.report.ReportAppendixPart(this);
                appendix.fill()
                append(this,appendix);
            end
        end
    end

    methods(Hidden=true,Access=public)

        function dumpWarning(this)
            if~isempty(this.WarningStack)
                warningStack=unique(this.WarningStack);
                for index=1:length(warningStack)
                    rmiut.warnNoBacktrace(warningStack{index});
                end
            end
        end
    end
end


function clearArtifactList()
    artiList=slreq.report.ReportAppendixPart.ArtifactList;
    allKeys=artiList.keys;
    artiList.remove(allKeys);
end


function clearLinkList()
    artiList=slreq.report.ReportAppendixPart.LinkList;
    allKeys=artiList.keys;
    artiList.remove(allKeys);
end
