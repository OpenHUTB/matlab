function out=genConfigCheckReportElements(currentModelName,configSetMatFileName,varargin)










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

    aHref_CS=Advisor.Element;


    configTextElement=Advisor.Text;


    objectivesTextElement=Advisor.Text;


    resultTextElement=Advisor.Text;


    aElement=Advisor.Element;

    if~Simulink.report.ReportInfo.featureReportV2
        aHref_CS.setTag('a');
        aHref_CS.setAttribute('href',[configSetMatFileName,'?',currentModelName]);
        aHref_CS.setAttribute('id','linkToCS');
        aHref_CS.setAttribute('style','display:none');
        link_txt=message('RTW:report:SummaryConfigSetLink').getString;
        aHref_CS.setContent(link_txt);

        aHiddenLink_CS=Advisor.Element;
        aHiddenLink_CS.setTag('span');
        aHiddenLink_CS.setAttribute('style','');
        aHiddenLink_CS.setAttribute('id','linkToCS_disabled');
        aHiddenLink_CS.setAttribute('title',message('RTW:report:SummaryLinkUnavailable').getString);
        aHiddenLink_CS.setContent(link_txt);


        configTextElement.setContent(...
        [aHref_CS.emitHTML,aHiddenLink_CS.emitHTML]);
    else


        oldDir=pwd;
        aHref_CS.setTag('a');

        rootfolder=fileparts(rptFileName);
        cd(fullfile(rootfolder,'..'));
        rootfolder=pwd;
        [relPath,csName,csExt]=fileparts(fullfile(rootfolder,[configSetMatFileName,'?',currentModelName]));
        if~exist(relPath,'dir')


            [relPath,csName,csExt]=fileparts(fullfile([configSetMatFileName,'?',currentModelName]));
        end
        cd(relPath);
        csFile=fullfile(pwd,[csName,csExt]);
        csFile=strrep(csFile,'\','/');
        csFile=['file:///',csFile];
        onclickCb=sprintf('return postParentWindowMessage({message:''legacyMCall'', expr:''%s(\\''%s\\'')''});',...
        'coder.internal.viewCodeConfigsetFromReport',csFile);
        aHref_CS.setAttribute('onclick',onclickCb);
        aHref_CS.setAttribute('id','linkToCS_V2');
        aHref_CS.setAttribute('href','javascript:void(0)');
        link_txt=message('RTW:report:SummaryConfigSetLink').getString;
        aHref_CS.setContent(link_txt);


        configTextElement.setContent(aHref_CS.emitHTML);


        cd(oldDir);
    end


    checkResult=coder.internal.configCheckReportHelper('readModelAdvisorCheckReport',fullModelName,subsystemName);


    if isempty(checkResult.op)
        [resultText,resultColor]=coder.internal.configCheckReportHelper('xlateCheckResult','Unspecified');
        aElement.setContent(resultText);
        aElement.setAttribute('Color',resultColor);
        aElement.setTag('font');
        aaElement=Advisor.Element;
        aaElement.setContent(aElement.emitHTML);
        aaElement.setTag('b');
        objectivesTextElement.setContent([aaElement.emitHTML]);
    elseif(length(checkResult.op)==1)
        objectivesTextElement.setContent(['<span style="color:black">',checkResult.op{1},'</span>']);
    else
        objectivesString=checkResult.op{1};
        for i=2:length(checkResult.op)
            objectivesString=[objectivesString,', ',checkResult.op{i}];%#ok
        end
        objectivesTextElement.setContent(['<span style="color:black">',objectivesString,'</span>']);
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
        resultTextElement.setContent([aHref_MA.emitHTML]);
    else
        resultTextElement.setContent([checkResult.result]);
    end
    out=[configTextElement;objectivesTextElement;resultTextElement];



