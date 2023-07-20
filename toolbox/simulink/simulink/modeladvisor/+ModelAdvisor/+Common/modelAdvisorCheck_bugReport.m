function ResultDescription=modelAdvisorCheck_bugReport(system,prodNames,varargin)



    import matlab.io.xml.dom.*
    emptyResults=false;
    pageNum=1;
    tableInfo={};
    ver=['R',version('-release')];
    ftList={};

    result=true;


    highlightWords={};
    if~isempty(varargin)
        highlightWords=varargin{1};
    end
    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=modelAdvisorObject.getInputParameters;
    if isempty(inputParams{1}.value)
        date=0;
    else
        iDate=inputParams{1}.value;
        iDate=regexprep(iDate,'\','/');
        idx=strfind(iDate,'/');
        if isempty(idx)||length(idx)~=2||...
            str2double(iDate(1:idx(1)-1))>12||...
            str2double(iDate(idx(1)+1:idx(2)-1))>31
            ResultDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:BugReportCheckInputParamInvalid'),{'fail'});
            return;
        end
        date=datenum(iDate);
    end
    for k=1:length(prodNames)
        while(~emptyResults)
            status=true;
            url=ModelAdvisor.Common.modelAdvisor_BugReportURL(prodNames{k},'',num2str(pageNum),'');
            try
                fName=websave([modelAdvisorObject.getWorkDir,filesep,'bugreport',num2str(k),'.xml'],url);
            catch
                status=false;
            end
            if~status
                break;
            else
                tree=parseFile(Parser,fName);
                xRoot=tree.getDocumentElement;
                items=xRoot.getElementsByTagName('item');
                len=items.getLength;
                emptyResults=(len==0);
                for i=0:len-1
                    titleNode=items.item(i).getElementsByTagName('title');
                    title=char(titleNode.item(0).getTextContent);
                    title=regexprep(title,'<.*?>','');
                    pubDateNode=items.item(i).getElementsByTagName('pubDate');
                    pubDate=char(pubDateNode.item(0).getTextContent);
                    pubDate=pubDate(6:16);
                    linkNode=items.item(i).getElementsByTagName('link');
                    txt=char(linkNode.item(0).getTextContent);





                    if strcmp(txt(end),'/')
                        txt=txt(1:end-1);
                    end
                    hyperlinkComponents=regexp(txt,'/','split');
                    bugReportLink=ModelAdvisor.Text(hyperlinkComponents{end});

                    bugReportLink.hyperlink=['matlab: web(''',txt,''' , ''','-browser',''') '];
                    if(datenum(pubDate)>date)
                        tableInfo=[tableInfo;{bugReportLink,title,pubDate}];%#ok<AGROW>
                    end
                end
                pageNum=pageNum+1;
            end
        end

        emptyResults=false;
        pageNum=1;

        ft=ModelAdvisor.FormatTemplate('TableTemplate');
        ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:BugReportsSubcheckTitle',prodNames{k}));
        ft.setInformation(DAStudio.message('ModelAdvisor:engine:BugReportsSubcheckInfo',prodNames{k},ver));
        ft.setColTitles({DAStudio.message('ModelAdvisor:engine:BugReportColTitle1'),...
        DAStudio.message('ModelAdvisor:engine:BugReportColTitle2'),...
        DAStudio.message('ModelAdvisor:engine:BugReportColTitle3')});
        if~isempty(tableInfo)||~status
            result=false;
            ft.setSubResultStatus('warn');
            if~status
                ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckWarnException'));
                ft.setRecAction(DAStudio.message('ModelAdvisor:engine:BugReportCheckRecActionException'));
            else
                if date==0
                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckWarn',num2str(size(tableInfo,1)),prodNames{k},ver));
                else
                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckWarnWithDate',num2str(size(tableInfo,1)),prodNames{k},ver,datestr(date,2)));
                end
                ft.setRecAction(DAStudio.message('ModelAdvisor:engine:BugReportCheckRecAction'));
                tableInfo=formatBoldCategories(tableInfo,highlightWords);
                ft.setTableInfo(tableInfo);
            end
            tableInfo={};
        else
            ft.setSubResultStatus('pass');
            if date==0
                ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckPass',prodNames{k},ver));
            else
                ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckPassWithDate',prodNames{k},ver,datestr(date,2)));
            end
        end
        ftList{end+1}=ft;%#ok<AGROW>
    end

    checkInfo=DAStudio.message('ModelAdvisor:engine:BugReportsCheckNote',prodNames{k},ver);
    if length(ftList)==1
        ftList{1}.SubTitle='';
        ftList{1}.setInformation(checkInfo);
    else
        ftList{1}.setCheckText(checkInfo);
    end

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(result);

    ft.setSubBar(false);
    ResultDescription=ftList;
end


function tableInfo=formatBoldCategories(tableInfo,categories)
    if isempty(categories)
        return;
    end
    for i=1:size(tableInfo,1)
        for j=1:length(categories)
            tableInfo{i,2}=regexprep(tableInfo{i,2},categories{j},['<b>',categories{j},'</b>']);
        end
    end
end


