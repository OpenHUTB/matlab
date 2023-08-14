






function registerCheck(checkId,group,license)

    [prefix,mapKey,topicId]=getCheckInfo(checkId);

    check=ModelAdvisor.Common.hisl_0032([],prefix);

    rec=ModelAdvisor.Check(checkId);
    rec.Title=check.getText('Hisl0032_Title');
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:hism:hisl_0032_guideline']),newline,check.getText('Hisl0032_TitleTips')];
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.CSHParameters.MapKey=mapKey;
    rec.CSHParameters.TopicID=topicId;
    rec.LicenseName=license;

    rec.setInputParametersLayoutGrid([7,4]);

    rec.setCallbackFcn(@checkCallback,'PostCompile','DetailStyle');
    rec.setReportStyle('ModelAdvisor.Report.DefaultStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.DefaultStyle'});


    isVisible=false;
    Row=0;





    Row=Row+1;

    parBlockNamesConvention=ModelAdvisor.InputParameter;
    parBlockNamesConvention.Name=check.getText('Hisl0032_ParName_BlockNames_Convention');
    parBlockNamesConvention.Type='Enum';
    parBlockNamesConvention.Entries={'MAAB','Custom','None'};
    parBlockNamesConvention.Enable=true;
    parBlockNamesConvention.Visible=isVisible;
    parBlockNamesConvention.Description=check.getText('Hisl0032_ParDesc_BlockNames_Convention');
    parBlockNamesConvention.setRowSpan([Row,Row]);
    parBlockNamesConvention.setColSpan([1,1]);

    parBlockNamesRegexp=ModelAdvisor.InputParameter;
    parBlockNamesRegexp.Name=check.getText('Hisl0032_ParName_BlockNames_Regexp');
    parBlockNamesRegexp.Type='String';
    parBlockNamesRegexp.Value=Advisor.Utils.Naming.getRegExp('MAAB');
    parBlockNamesRegexp.Enable=false;
    parBlockNamesRegexp.Visible=isVisible;
    parBlockNamesRegexp.Description=check.getText('Hisl0032_ParDesc_BlockNames_Regexp');
    parBlockNamesRegexp.setRowSpan([Row,Row]);
    parBlockNamesRegexp.setColSpan([2,4]);





    Row=Row+1;

    parSignalNamesConvention=ModelAdvisor.InputParameter;
    parSignalNamesConvention.Name=check.getText('Hisl0032_ParName_SignalNames_Convention');
    parSignalNamesConvention.Type='Enum';
    parSignalNamesConvention.Entries={'MAAB','Custom','None'};
    parSignalNamesConvention.Enable=true;
    parSignalNamesConvention.Visible=isVisible;
    parSignalNamesConvention.Description=check.getText('Hisl0032_ParDesc_SignalNames_Convention');
    parSignalNamesConvention.setRowSpan([Row,Row]);
    parSignalNamesConvention.setColSpan([1,1]);

    parSignalNamesRegexp=ModelAdvisor.InputParameter;
    parSignalNamesRegexp.Name=check.getText('Hisl0032_ParName_SignalNames_Regexp');
    parSignalNamesRegexp.Type='String';
    parSignalNamesRegexp.Value=Advisor.Utils.Naming.getRegExp('MAAB');
    parSignalNamesRegexp.Enable=false;
    parSignalNamesRegexp.Visible=isVisible;
    parSignalNamesRegexp.Description=check.getText('Hisl0032_ParDesc_SignalNames_Regexp');
    parSignalNamesRegexp.setRowSpan([Row,Row]);
    parSignalNamesRegexp.setColSpan([2,4]);





    Row=Row+1;

    parParameterNamesConvention=ModelAdvisor.InputParameter;
    parParameterNamesConvention.Name=check.getText('Hisl0032_ParName_ParameterNames_Convention');
    parParameterNamesConvention.Type='Enum';
    parParameterNamesConvention.Entries={'MAAB','Custom','None'};
    parParameterNamesConvention.Enable=true;
    parParameterNamesConvention.Visible=isVisible;
    parParameterNamesConvention.Description=check.getText('Hisl0032_ParDesc_ParameterNames_Convention');
    parParameterNamesConvention.setRowSpan([Row,Row]);
    parParameterNamesConvention.setColSpan([1,1]);

    parParameterNamesRegexp=ModelAdvisor.InputParameter;
    parParameterNamesRegexp.Name=check.getText('Hisl0032_ParName_ParameterNames_Regexp');
    parParameterNamesRegexp.Type='String';
    parParameterNamesRegexp.Value=Advisor.Utils.Naming.getRegExp('MAAB');
    parParameterNamesRegexp.Enable=false;
    parParameterNamesRegexp.Visible=isVisible;
    parParameterNamesRegexp.Description=check.getText('Hisl0032_ParDesc_ParameterNames_Regexp');
    parParameterNamesRegexp.setRowSpan([Row,Row]);
    parParameterNamesRegexp.setColSpan([2,4]);





    Row=Row+1;

    parBusNamesConvention=ModelAdvisor.InputParameter;
    parBusNamesConvention.Name=check.getText('Hisl0032_ParName_BusNames_Convention');
    parBusNamesConvention.Type='Enum';
    parBusNamesConvention.Entries={'MAAB','Custom','None'};
    parBusNamesConvention.Enable=true;
    parBusNamesConvention.Visible=isVisible;
    parBusNamesConvention.Description=check.getText('Hisl0032_ParDesc_BusNames_Convention');
    parBusNamesConvention.setRowSpan([Row,Row]);
    parBusNamesConvention.setColSpan([1,1]);

    parBusNamesRegexp=ModelAdvisor.InputParameter;
    parBusNamesRegexp.Name=check.getText('Hisl0032_ParName_BusNames_Regexp');
    parBusNamesRegexp.Type='String';
    parBusNamesRegexp.Value=Advisor.Utils.Naming.getRegExp('MAAB');
    parBusNamesRegexp.Enable=false;
    parBusNamesRegexp.Visible=isVisible;
    parBusNamesRegexp.Description=check.getText('Hisl0032_ParDesc_BusNames_Regexp');
    parBusNamesRegexp.setRowSpan([Row,Row]);
    parBusNamesRegexp.setColSpan([2,4]);





    Row=Row+1;

    parStateflowNamesConvention=ModelAdvisor.InputParameter;
    parStateflowNamesConvention.Name=check.getText('Hisl0032_ParName_StateflowNames_Convention');
    parStateflowNamesConvention.Type='Enum';
    parStateflowNamesConvention.Entries={'MAAB','Custom','None'};
    parStateflowNamesConvention.Enable=true;
    parStateflowNamesConvention.Visible=isVisible;
    parStateflowNamesConvention.Description=check.getText('Hisl0032_ParDesc_StateflowNames_Convention');
    parStateflowNamesConvention.setRowSpan([Row,Row]);
    parStateflowNamesConvention.setColSpan([1,1]);

    parStateflowNamesRegexp=ModelAdvisor.InputParameter;
    parStateflowNamesRegexp.Name=check.getText('Hisl0032_ParName_StateflowNames_Regexp');
    parStateflowNamesRegexp.Type='String';
    parStateflowNamesRegexp.Value=Advisor.Utils.Naming.getRegExp('MAAB');
    parStateflowNamesRegexp.Enable=false;
    parStateflowNamesRegexp.Visible=isVisible;
    parStateflowNamesRegexp.Description=check.getText('Hisl0032_ParDesc_StateflowNames_Regexp');
    parStateflowNamesRegexp.setRowSpan([Row,Row]);
    parStateflowNamesRegexp.setColSpan([2,4]);

    rec.setInputParameters({...
    parBlockNamesConvention,...
    parBlockNamesRegexp,...
    parSignalNamesConvention,...
    parSignalNamesRegexp,...
    parParameterNamesConvention,...
    parParameterNamesRegexp,...
    parBusNamesConvention,...
    parBusNamesRegexp,...
    parStateflowNamesConvention,...
parStateflowNamesRegexp...
    });

    rec.setInputParametersCallbackFcn(@inputParameterCallback);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,group);

end

function[prefix,mapKey,topicId]=getCheckInfo(checkId)
    switch checkId
    case 'mathworks.hism.hisl_0032'
        prefix='ModelAdvisor:do178b:';
        mapKey='ma.hism';
        topicId=checkId;
    otherwise
        prefix='';
        mapKey='';
        topicId='';
    end
end

function ResultDescription=checkCallback(system,checkObj)

    prefix=getCheckInfo(checkObj.Id);

    check=ModelAdvisor.Common.hisl_0032(system,prefix);
    check.execute();

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(check.getStatus());
    ResultDescription=check.getResult();

    violations=check.getViolations();
    if isempty(violations)
        checkObj.setResultDetails(Advisor.Utils.createResultDetailObjs('','IsViolation',false));
    else
        checkObj.setResultDetails(violations);
    end


end

function inputParameterCallback(taskObject,tag,~)
    switch class(taskObject)
    case 'ModelAdvisor.Task'
        inputParameters=taskObject.Check.InputParameters;
    case 'ModelAdvisor.ConfigUI'
        inputParameters=taskObject.InputParameters;
    otherwise
        return;
    end
    switch tag
    case 'InputParameters_1',index1=1;index2=2;
    case 'InputParameters_3',index1=3;index2=4;
    case 'InputParameters_5',index1=5;index2=6;
    case 'InputParameters_7',index1=7;index2=8;
    case 'InputParameters_9',index1=9;index2=10;
    otherwise
        return;
    end


    switch inputParameters{index1}.Value
    case 'MAAB'
        value=Advisor.Utils.Naming.getRegExp('MAAB');

        inputParameters{index2}.Value=value;
        inputParameters{index2}.Enable=false;

    case 'Custom'

        value=Advisor.Utils.Naming.getRegExp('MAAB');

        inputParameters{index2}.Value=value;
        inputParameters{index2}.Enable=true;

    case 'None'
        value=DAStudio.message('ModelAdvisor:do178b:Hisl0032_NotApplicable');

        inputParameters{index2}.Value=value;
        inputParameters{index2}.Enable=false;

    otherwise
        return;
    end

end

