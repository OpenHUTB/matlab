function out=genConfigCheckReportTable(currentModelName,configSetMatFileName,varargin)










    if length(varargin)>=2&&~isempty(varargin{1})&&~isempty(varargin{2})

        fullModelName=varargin{1};
        subsystemName=varargin{2};
    else
        fullModelName=currentModelName;
        subsystemName=currentModelName;
    end

    if length(varargin)>2
        rptFileName=varargin{3};
    else
        rptFileName='';
    end

    table=Advisor.Table(3,1);
    table.setBorder(0);
    table.setAttribute('cellpadding','0');

    aHref_CS=Advisor.Element;
    aText=Advisor.Text;
    aElement=Advisor.Element;


    aHref_CS.setTag('a');


    aHref_CS.setAttribute('href',[configSetMatFileName,'?',currentModelName]);
    aHref_CS.setAttribute('id','linkToCS');
    aHref_CS.setAttribute('style','display:none');
    link_txt='click to open';
    aHref_CS.setContent(link_txt);

    aHiddenLink_CS=Advisor.Element;
    aHiddenLink_CS.setTag('span');
    aHiddenLink_CS.setAttribute('style','');
    aHiddenLink_CS.setAttribute('id','linkToCS_disabled');
    aHiddenLink_CS.setAttribute('title',DAStudio.message('RTW:report:SummaryLinkUnavailable'));
    aHiddenLink_CS.setContent(link_txt);


    aText.setContent([DAStudio.message('RTW:report:SummaryConfigSetLinkLabel'),' '...
    ,aHref_CS.emitHTML,aHiddenLink_CS.emitHTML]);
    table.setEntry(1,1,aText.emitHTML);


    checkResult=coder.internal.configCheckReportHelper('readModelAdvisorCheckReport',fullModelName,subsystemName);

    if length(checkResult.op)==1
        objectiveText='Code generation objective: ';
        validateText='Validation result: ';
    else
        objectiveText='Code generation objectives: ';
        validateText='Validation result: ';
    end

    if isempty(checkResult.op)
        [resultText,resultColor]=coder.internal.configCheckReportHelper('xlateCheckResult','Unspecified');
        aElement.setContent(resultText);
        aElement.setAttribute('Color',resultColor);
        aElement.setTag('font');
        aaElement=Advisor.Element;
        aaElement.setContent(aElement.emitHTML);
        aaElement.setTag('b');
        table.setEntry(2,1,[objectiveText,aaElement.emitHTML]);
    elseif(length(checkResult.op)==1)
        aText.setContent([objectiveText,checkResult.op{1}]);
        table.setEntry(2,1,aText.emitHTML);
    else
        objectives_List=Advisor.List;
        objectives_List.setType('Numbered');
        for i=1:length(checkResult.op)
            objectives_List.addItem(checkResult.op{i});
        end
        table.setEntry(2,1,[objectiveText,objectives_List.emitHTML]);
    end


    if~isempty(checkResult.MA_SanityCheckReportFileName)
        aHref_MA=Advisor.Element;
        aHref_MA.setTag('a');
        [advisor_rpt_folder,filename,ext]=fileparts(checkResult.MA_SanityCheckReportFileName);
        [advisor_rpt_folder_parent,advisor_rpt_folder]=fileparts(advisor_rpt_folder);
        fileattrib(advisor_rpt_folder_parent,'+w','','s');
        copyfile(advisor_rpt_folder_parent,fileparts(rptFileName),'f');
        rptFile=['./',advisor_rpt_folder,'/',filename,ext];
        aHref_MA.setAttribute('href',rptFile);
        aHref_MA.setAttribute('id','CodeGenAdvCheck');
        aHref_MA.setContent(checkResult.result);
        aText.setContent([validateText,aHref_MA.emitHTML]);
    else
        aText.setContent([validateText,checkResult.result]);
    end
    table.setEntry(3,1,aText.emitHTML);
    out=table.emitHTML;


