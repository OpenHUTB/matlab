function defineModelInfoKeywordSubstitutionChecks





    check=ModelAdvisor.Check('mathworks.design.ModelInfoKeywordSubstitution');
    check.Title=DAStudio.message('Simulink:tools:ModelInfoKeywordSubstitutionTaskTitle');
    check.TitleTips=DAStudio.message('Simulink:tools:ModelInfoKeywordSubstitutionTaskTitle');
    check.setCallbackFcn(@i_ReportOnModelInfoBlocks,'None','StyleOne');
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='ModelInfoKeywordSubstitution';
    check.Visible=true;
    check.Enable=true;
    check.Value=true;
    check.SupportLibrary=true;



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);

end

function flag=i_isSLX(sys)
    [~,~,ext]=slfileparts(get_param(sys,'FileName'));
    flag=strcmp(ext,'.slx');
end

function msg=i_getInfoMessage(sys)
    if i_isSLX(sys)
        msg='ModelInfoKeywordSubstitutionKWSDescriptionSLX';
    else
        msg='ModelInfoKeywordSubstitutionKWSDescription';
    end
end

function ft=i_BlockUsesKeywordSubstitution(sys,block)
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubResultStatus('pass');


    maskDisplayString=get_param(block,'MaskDisplayString');
    keywordSubstitutionString='\$.*?\$';
    possibleKeywordSubstitutions=regexp(...
    strrep(maskDisplayString,'\n',newline),keywordSubstitutionString,...
    'match','dotexceptnewline');

    if~all(cellfun(@isempty,possibleKeywordSubstitutions))
        ft.setSubResultStatusText(...
        CMMessage(...
        i_getInfoMessage(sys),...
        block,...
        strjoin(possibleKeywordSubstitutions,'<br/>')));
        ft.setSubResultStatus('warn');
    end
end

function results=i_checkKeywordSubstitution(sys)
    results={};
    modelInfoBlocks=Simulink.findBlocks(sys,...
    'ReferenceBlock','simulink/Model-Wide Utilities/Model Info',...
    Simulink.FindOptions('LookInsideSubsystemReference',false));

    for i=1:numel(modelInfoBlocks)
        modelInfoBlock=getfullname(modelInfoBlocks(i));

        ftKWS=i_BlockUsesKeywordSubstitution(sys,modelInfoBlock);



        ftKWS.setSubTitle(...
        CMMessage('ModelInfoKeywordSubstitutionBlockTitle',modelInfoBlock));
        ftKWS.setSubBar(1);

        results{end+1}=ftKWS;%#ok<AGROW>
    end
end

function pass=i_StatusToBool(status)
    pass=strcmpi(status,'pass');
end

function result=i_generateResultStatus(ft)
    result=i_StatusToBool(ft.SubResultStatus);
end

function warningMessage=CMMessage(msg,varargin)
    msgID=['Simulink:tools:',msg];
    warningMessage=DAStudio.message(msgID,varargin{:});
end

function results=i_ReportOnModelInfoBlocks(sys)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    results={};

    ftKWS=i_checkKeywordSubstitution(sys);
    results=[results,ftKWS];

    overallResult=all(cellfun(@i_generateResultStatus,results));
    mdladvObj.setCheckResultStatus(overallResult);
end
