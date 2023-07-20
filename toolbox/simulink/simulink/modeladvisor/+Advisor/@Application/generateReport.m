
























function reportname=generateReport(this,varargin)











    p=inputParser();
    p.addParameter('location','.');
    p.addParameter('name','');
    p.parse(varargin{:});
    in=p.Results;

    if~exist(in.location,'dir')
        DAStudio.error('Advisor:base:App_UnknownLocation',in.location);
    end

    if isempty(in.name)
        name=this.AnalysisRoot;
    else
        name=in.name;
    end

    reportName=regexprep(name,'\W','_');
    fullReportLocation=fullfile(in.location,reportName);

    if~exist(fullReportLocation,'dir')

        mkdir(fullReportLocation);
    end

    if this.AnalyzeVariants
        variants=this.VariantManager.findVariants;
        if~isempty(variants)
            reportNamesCollection={};
            for i=1:numel(variants)
                this.swapValueSet(variants{i}.Name);
                [compIds,reportNames]=locGenerateReport(this,fullReportLocation,variants{i}.Name);
                reportNamesCollection=[reportNamesCollection,reportNames];%#ok<AGROW>
            end
            reportNames=reportNamesCollection;
        else
            variants={};
            [compIds,reportNames]=locGenerateReport(this,fullReportLocation,'');
        end
    else
        variants={};
        [compIds,reportNames]=locGenerateReport(this,fullReportLocation,'');
    end



    generateSummaryReport(this,fullReportLocation,compIds,reportNames,variants);

    reportname=fullfile(fullReportLocation,'report.html');
end

function[compIds,reportNames]=locGenerateReport(this,fullReportLocation,variantName)

    compIds=this.CompId2MAObjIdxMap.keys;
    reportNames=cell(size(compIds));

    for n=1:length(compIds)

        idx=this.CompId2MAObjIdxMap(compIds{n});
        maObj=this.MAObjs{idx};

        rootNode=maObj.TaskAdvisorRoot;

        if this.UseTempDir
            this.OriginalDir=pwd;
            addpath(pwd);
            cd(this.TempDir);
        end

        tempName=maObj.generateReport(rootNode);

        if this.UseTempDir
            cd(this.OriginalDir);
            rmpath(this.OriginalDir);
        end


        compReportName=getReportName(variantName,compIds{n});
        copyfile(tempName,fullfile(fullReportLocation,compReportName),'f');

        reportNames{n}=compReportName;
    end
end

function reportName=getReportName(variantName,componentName)
    if isempty(variantName)
        reportName=['report_',regexprep(componentName,'\W','_'),'.html'];
    else
        reportName=['report_',variantName,'_',regexprep(componentName,'\W','_'),'.html'];
    end
end

function generateSummaryReport(this,location,compIds,reportNames,variants)

    sysResults=this.getResults();

    doc=ModelAdvisor.Document();
    doc.setTitle([DAStudio.message('ModelAdvisor:engine:CmdAPIMASummaryReport'),...
    ' - ',this.AnalysisRoot]);


    meta=ModelAdvisor.Element('meta','charset','UTF-8');
    meta.IsSingletonTag=true;
    doc.addHeadItem(meta);

    style=ModelAdvisor.Element('style','type','text/css');
    lb=sprintf('\n');
    styles=['table.AdvTableNoBorder{ border-collapse:collapse; margin:0px 0px 20px 0px; border:none; }',lb,...
    'table.AdvTableNoBorder td { padding-left:5px; padding-right:5px; border:none; }',lb,...
    'table.AdvTable { border-collapse:collapse; border:1px solid #ececec; border-right:none; border-bottom:none; }',lb,...
    'table.AdvTable th { padding-left:5px; padding-right:5px; color:#fff; line-height:120%; ',...
    'background:#80a0c1 url(data:image/gif;base64,R0lGODlhAQAaAKIAAHSRr3mXtn+fv2V/mX2cvG2JpVxzi4CgwSH5BAAAAAAALAAAAAABABoAAAMJeLrcLCSAMkwCADs=) repeat-x bottom left; border-right: 1px solid #ececec; border-bottom: 1px solid #ececec; }',lb,...
    '.AdvTable td { padding-left:5px; padding-right:5px; border-right:1px solid #ececec; border-bottom: 1px solid #ececec; }',lb,...
    ];
    style.addContent(styles);
    doc.addHeadItem(style);


    t=ModelAdvisor.Table(3,2);
    t.setBorder(0);
    t.setAttribute('class','AdvTableNoBorder');
    t.setAttribute('style','width:100%;margin-bottom: 20px;');


    div=ModelAdvisor.Element('div','style','text-align:center;');
    title=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:CmdAPIMASummary'));
    title.setBold(true);
    div.addContent(title);
    t.setEntry(1,1,div);
    t.setEntryColspan(1,1,2);


    v=ver('Simulink');
    versionStr=num2str(v.Version);

    span=ModelAdvisor.Element('span','style','color:#800000;');
    span.setContent(versionStr);
    versionText=ModelAdvisor.Text([DAStudio.message('ModelAdvisor:engine:CmdAPISLVer'),': ']);
    t.setEntry(2,1,[versionText,span]);


    span=ModelAdvisor.Element('span','style','color:#800000;');
    span.setContent(date);
    dateText=ModelAdvisor.Text([DAStudio.message('ModelAdvisor:engine:CmdAPICurrentRun'),': ']);
    t.setEntry(2,2,[dateText,span]);


    if isempty(this.TaskManager)||isempty(this.TaskManager.ConfigFilePath)
        configUsed=DAStudio.message('ModelAdvisor:engine:CmdAPINotApplicable');
    else
        configUsed=this.TaskManager.ConfigFilePath;
    end
    configText=ModelAdvisor.Text([DAStudio.message('ModelAdvisor:engine:CmdAPIConfigFile'),': ',configUsed]);
    t.setEntry(3,1,configText);


    configText=ModelAdvisor.Text([DAStudio.message('ModelAdvisor:engine:CmdAPINumSystems'),': ',num2str(length(sysResults))]);
    t.setEntry(3,2,configText);


    doc.addItem(t);



    if~isempty(sysResults)
        t=locGenerateRptLinkTable(this,sysResults,reportNames,compIds,variants);

        doc.addItem(t);

        if~isempty(variants)
            lb=ModelAdvisor.LineBreak;
            doc.addItem(lb);
            t=ModelAdvisor.Table(length(variants),2);
            t.setColHeading(1,'Variant Name');
            t.setColHeading(2,'Variant Description');
            for i=1:length(variants)
                t.setEntry(i,1,variants{i}.Name);
                t.setEntry(i,2,variants{i}.Description);
            end
            doc.addItem(t);
        end











    else
        doc.addItem(ModelAdvisor.Paragraph('No results available.'));
    end


    fid=fopen(fullfile(location,'report.html'),'w','n','utf-8');
    html=doc.emitHTML;
    fwrite(fid,html,'char');
    fclose(fid);

end

function t=locGenerateRptLinkTable(this,sysResults,reportNames,compIds,variants)
    if isempty(variants)
        t=ModelAdvisor.Table(length(sysResults),6);
        t.setColHeading(1,DAStudio.message('ModelAdvisor:engine:CmdAPISystem'));
        t.setColHeading(2,DAStudio.message('ModelAdvisor:engine:CmdAPIPassed'));
        t.setColHeading(3,DAStudio.message('ModelAdvisor:engine:CmdAPIFailed'));
        t.setColHeading(4,DAStudio.message('ModelAdvisor:engine:CmdAPIWarnings'));
        t.setColHeading(5,DAStudio.message('ModelAdvisor:engine:CmdAPINotRun'));
        t.setColHeading(6,DAStudio.message('ModelAdvisor:engine:CmdAPIMAReport'));
        for n=1:length(sysResults)
            t.setEntry(n,1,sysResults(n).system);
            t.setEntry(n,2,num2str(sysResults(n).numPass));
            t.setEntry(n,3,num2str(sysResults(n).numFail));
            t.setEntry(n,4,num2str(sysResults(n).numWarn));
            t.setEntry(n,5,num2str(sysResults(n).numNotRun));

            reportLink=ModelAdvisor.Text(sysResults(n).system);

            report=reportNames(strcmp(compIds,sysResults(n).ComponentId));

            if~isempty(report)
                reportLink.setHyperlink(report{1});

                t.setEntry(n,6,reportLink);
            else
                t.setEntry(n,6,'-');
            end
        end
    else
        t=ModelAdvisor.Table(1,7);
        t.setColHeading(1,DAStudio.message('ModelAdvisor:engine:CmdAPIVariants'));
        t.setColHeading(2,DAStudio.message('ModelAdvisor:engine:CmdAPISystem'));
        t.setColHeading(3,DAStudio.message('ModelAdvisor:engine:CmdAPIPassed'));
        t.setColHeading(4,DAStudio.message('ModelAdvisor:engine:CmdAPIFailed'));
        t.setColHeading(5,DAStudio.message('ModelAdvisor:engine:CmdAPIWarnings'));
        t.setColHeading(6,DAStudio.message('ModelAdvisor:engine:CmdAPINotRun'));
        t.setColHeading(7,DAStudio.message('ModelAdvisor:engine:CmdAPIMAReport'));
        currentRow=0;
        for vc=1:length(variants)
            this.swapValueSet(variants{vc}.Name);
            sysResults=this.getResults();
            for n=1:length(sysResults)
                currentRow=currentRow+1;
                t.expand(currentRow,7);
                t.setEntry(currentRow,1,variants{vc}.Name);
                t.setEntry(currentRow,2,sysResults(n).system);
                t.setEntry(currentRow,3,num2str(sysResults(n).numPass));
                t.setEntry(currentRow,4,num2str(sysResults(n).numFail));
                t.setEntry(currentRow,5,num2str(sysResults(n).numWarn));
                t.setEntry(currentRow,6,num2str(sysResults(n).numNotRun));

                reportLink=ModelAdvisor.Text([variants{vc}.Name,'/',sysResults(n).system]);

                report=getReportName(variants{vc}.Name,sysResults(n).ComponentId);

                if~isempty(report)
                    reportLink.setHyperlink(report);

                    t.setEntry(currentRow,7,reportLink);
                else
                    t.setEntry(currentRow,7,'-');
                end
            end
        end
    end
end