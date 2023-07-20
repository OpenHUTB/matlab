function reportName=generateReport(this,taskNode)












    if~isa(taskNode,'ModelAdvisor.Node')
        DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.Node');
    end


    [counterStructure,summaryTable]=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',taskNode);


    WorkDir=this.getWorkDir;
    reportName=modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',taskNode,WorkDir);











    [~,name,ext]=fileparts(reportName);
    database_reportName=[name,ext];
    savedRptInfo=this.Database.loadData('allrptinfo','reportName',database_reportName);
    if~isempty(savedRptInfo)
        savedRptInfo=savedRptInfo(end);
        if exist(reportName,'file')
            if(counterStructure.generateTime<=savedRptInfo(end).generateTime)&&...
                ~this.runInBackground
                return;
            end
        end
    end



    loc_generateReport(this,reportName,taskNode,counterStructure,summaryTable);


    if taskNode.Index+1>0
        counterStructure.reportName=database_reportName;
        this.Database.saveData('allrptinfo',counterStructure);
    end
end

function loc_generateReport(this,reportName,taskNode,counterStructure,summaryTable)
    [path,name,ext]=fileparts(reportName);
    cr=newline;

    [nodesRpt,noSyncCounter]=modeladvisorprivate('modeladvisorutil2','emitHTMLforTaskNode',taskNode,this.CheckCellArray);


    headhtmlSource=modeladvisorprivate('modeladvisorutil2','createReportHeaderSection',...
    this,true,taskNode,counterStructure.generateTime,noSyncCounter);

    if isa(taskNode,'ModelAdvisor.Task')
        views=ModelAdvisor.Report.CheckStyleFactory.getSupportedStyles();
        viewNames=ModelAdvisor.Report.CheckStyleFactory.getSupportedStyleNames(views);
    else
        views=ModelAdvisor.Report.TaskAdvisorStyleFactory.getSupportedStyles();
        viewNames=ModelAdvisor.Report.TaskAdvisorStyleFactory.getSupportedStyleNames();
    end

    if slfeature('ModelAdvisorGenerateNewStyleViewSwitchInReport')>0
        switchViewLink=createSwitchViewLink(path,name,ext,viewNames);
    else
        switchViewLink='';
    end


    f=fopen(reportName,'w','n','utf-8');
    if f==-1
        DAStudio.error('Simulink:tools:MAUnableCreateFilesInDirectory',pwd);
    end

    htmlSource=[headhtmlSource,switchViewLink,summaryTable];


    htmlSource=[htmlSource,cr,nodesRpt,cr];



    htmlSource=[htmlSource,cr,'</div>',cr,'</div>'];


    htmlSource=modeladvisorprivate('modeladvisorutil2','embedImagesInHTML',htmlSource);
    htmlSource=[htmlSource,cr,'</body>  '];
    htmlSource=[htmlSource,cr,'</html>  '];


    fprintf(f,'%s',htmlSource);
    fclose(f);


    if slfeature('ModelAdvisorGenerateNewStyleViewSwitchInReport')>0
        for viewIndex=1:numel(views)
            if viewIndex==1
                continue;
            end
            currentReportName=[path,filesep,name,'_',num2str(viewIndex-1),ext];
            f=fopen(currentReportName,'w','n','utf-8');
            if f==-1
                DAStudio.error('Simulink:tools:MAUnableCreateFilesInDirectory',pwd);
            end

            htmlSource=[headhtmlSource,switchViewLink,summaryTable];


            rptObj=ModelAdvisor.Report.StyleFactory.creator(views{viewIndex});
            newStyleReportFt=rptObj.generateReport(taskNode);
            newStyleHTML='';
            for i=1:numel(newStyleReportFt)
                if isa(newStyleReportFt{i},'ModelAdvisor.FormatTemplate')
                    newStyleHTML=[newStyleHTML,newStyleReportFt{i}.emitContent.emitHTML];%#ok<AGROW>
                else
                    newStyleHTML=[newStyleHTML,newStyleReportFt{i}.emitHTML];%#ok<AGROW>
                end
            end

            htmlSource=[htmlSource,cr,newStyleHTML,cr];



            htmlSource=[htmlSource,cr,'</div>',cr,'</div>'];


            htmlSource=modeladvisorprivate('modeladvisorutil2','embedImagesInHTML',htmlSource);
            htmlSource=[htmlSource,cr,'</body>  '];
            htmlSource=[htmlSource,cr,'</html>  '];


            fprintf(f,'%s',htmlSource);
            fclose(f);
        end
    end

end

function ft=createSwitchViewLink(path,name,ext,viewNames)
    ft='';
    ft=[ft,'   <style type="text/css">'];
    ft=[ft,'    #sidebar ul { background: #eee; padding: 10px; opacity: 0.8 } '];
    ft=[ft,'    #sidebar li { margin: 0 0 0 20px; } '];
    ft=[ft,'    #sidebar { width: 190px; position: fixed; right: 5%; top: 15%; margin: 0 0 0 110px; }'];
    ft=[ft,'   </style>'];
    ft=[ft,'   <div id="sidebar">'];
    ft=[ft,'	  	<ul>'];
    for viewIndex=1:numel(viewNames)
        if viewIndex==1

            reportName=[path,filesep,name,ext];
        else
            reportName=[path,filesep,name,'_',num2str(viewIndex-1),ext];
        end
        RptLink=ModelAdvisor.Text(viewNames{viewIndex});
        RptLink.setHyperlink(reportName);
        ft=[ft,'		    <li>',RptLink.emitHTML,'</li>'];
    end
    ft=[ft,'		</ul>	'];
    ft=[ft,'	</div>'];

end

