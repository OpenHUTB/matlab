function ResultDescription=modelAdvisorCheck_EmbeddedCoderbugReport(system,prodNames,varargin)



    import matlab.io.xml.dom.*
    emptyResults=false;
    pageNum=1;
    ver=['R',version('-release')];

    result=true;
    ftList={};

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
    keywords={'"Incorrect+Code+Generation"',...
    ''};

    tableInfo={};
    tableList={};
    for k=1:length(keywords)
        while(~emptyResults)
            url=ModelAdvisor.Common.modelAdvisor_BugReportURL(prodNames,'EC',num2str(pageNum),keywords{k});
            status=true;
            try
                fName=websave(url,[ModelAdvisor.getWorkDir(system),filesep,'bugreport',num2str(k),'.xml']);
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
                    descNode=items.item(i).getElementsByTagName('description');
                    description=char(descNode.item(0).getTextContent);
                    titleNode=items.item(i).getElementsByTagName('title');
                    title=char(titleNode.item(0).getTextContent);
                    pubDateNode=items.item(i).getElementsByTagName('pubDate');
                    pubDate=char(pubDateNode.item(0).getTextContent);
                    pubDate=pubDate(6:16);
                    linkNode=items.item(i).getElementsByTagName('link');
                    txt=char(linkNode.item(0).getTextContent);
                    bugReportLink=ModelAdvisor.Text(txt(end-5:end));
                    bugReportLink.hyperlink=['matlab: web(''',txt,''' , ''','-browser',''') '];
                    if(datenum(pubDate)>date)
                        tableInfo=[tableInfo;{bugReportLink,title,pubDate}];
                    end
                end
                pageNum=pageNum+1;
            end
        end
        tableList{end+1}=tableInfo;
        tableInfo={};
        emptyResults=false;
        pageNum=1;
    end

    tableList=updateTableList(tableList);

    for i=1:length(tableList)
        ft=ModelAdvisor.FormatTemplate('TableTemplate');
        if~isempty(keywords{i})
            ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:ECBugReportCheckSubtitleKeyword',strrep(keywords{i},'+',' ')));
        else
            ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:ECBugReportCheckSubtitleNoKeyword'));
        end

        ft.setColTitles({DAStudio.message('ModelAdvisor:engine:BugReportColTitle1'),...
        DAStudio.message('ModelAdvisor:engine:BugReportColTitle2'),...
        DAStudio.message('ModelAdvisor:engine:BugReportColTitle3')});
        if~isempty(tableList{i})
            result=false;
            ft.setSubResultStatus('warn');
            if~status
                ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckWarnException'));
                ft.setRecAction(DAStudio.message('ModelAdvisor:engine:BugReportCheckRecActionException'));
            else
                if~isempty(keywords{i})
                    if date==0
                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:ECBugReportCheckWarn',num2str(size(tableList{i},1)),strrep(keywords{i},'+',' '),ver));
                    else
                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:ECBugReportCheckWarnWithDate',num2str(size(tableList{i},1)),strrep(keywords{i},'+',' '),ver,datestr(date,2)));
                    end
                else
                    if date==0
                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:ECBugReportCheckWarnNoKeyword',num2str(size(tableList{i},1)),ver));
                    else
                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:ECBugReportCheckWarnNoKeywordWithDate',num2str(size(tableList{i},1)),ver,datestr(date,2)));
                    end
                end
                ft.setRecAction(DAStudio.message('ModelAdvisor:engine:BugReportCheckRecAction'));
                tableList{i}=formatBoldCategories(tableList{i},keywords);
                ft.setTableInfo(tableList{i});
            end
        elseif~status
            ft.setSubResultStatus('warn');
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckWarnException'));
            ft.setRecAction(DAStudio.message('ModelAdvisor:engine:BugReportCheckRecActionException'));
        else
            ft.setSubResultStatus('pass');
            if~isempty(keywords{i})
                if date~=0
                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckKeywordPass',prodNames,strrep(keywords{i},'+',' '),ver,datestr(date,2)));
                else
                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckKeywordPassNodate',prodNames,strrep(keywords{i},'+',' '),ver));
                end
            else
                if date~=0
                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckNoKeywordPass',prodNames,ver,datestr(date,2)));
                else
                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:BugReportCheckNoKeywordPassNodate',prodNames,ver));
                end
            end
        end
        ftList{end+1}=ft;
    end

    checkText=DAStudio.message('ModelAdvisor:engine:BugReportsCheckNote',prodNames,ver);

    ftList{1}.setCheckText(checkText);
    ft.setSubBar(false);
    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(result);
    ResultDescription=ftList;
end

function tableList=updateTableList(tableList)
    t=tableList{2};

    emptyIdx=[];
    for i=1:size(tableList{2},1)
        found=false;
        for j=1:size(tableList{1},1)
            if strcmp(tableList{2}{i,1}.Content,tableList{1}{j,1}.Content)
                found=true;
                break;
            end
        end
        if found
            t{i,1}='';
            emptyIdx=[emptyIdx,i];
        end
    end

    emptyIdx=setdiff(1:size(tableList{2},1),emptyIdx);

    tableList{2}=tableList{2}(emptyIdx,:);
end

function tableInfo=formatBoldCategories(tableInfo,categories)
    for i=1:size(tableInfo,1)
        for j=1:length(categories)
            categories{j}=strrep(strrep(categories{j},'+',' '),'"','');
            if~isempty(categories{j})
                tableInfo{i,2}=regexprep(tableInfo{i,2},categories{j},['<b>',categories{j},'</b>'],'ignorecase');
            end
        end
    end
end


