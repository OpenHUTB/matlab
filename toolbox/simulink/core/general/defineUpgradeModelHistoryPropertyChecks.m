function defineUpgradeModelHistoryPropertyChecks







    check=ModelAdvisor.Check('mathworks.design.SLXModelProperties');
    check.Title=DAStudio.message('Simulink:tools:SLXModelPropertyTaskTitle');
    check.setCallbackFcn(@i_ReportOnModelProperties,'None','StyleOne');
    check.TitleTips=DAStudio.message('Simulink:tools:SLXModelPropertyTaskTitle');
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='SLXModelProperties';
    check.Visible=true;
    check.Enable=true;
    check.Value=true;
    check.SupportLibrary=true;


    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@i_ActionUpdateModelProperties);
    modifyAction.Name=DAStudio.message('Simulink:tools:SLXModelPropertyTaskModifyActionName');
    modifyAction.Description=DAStudio.message('Simulink:tools:SLXModelPropertyTaskModifyActionDesc');
    modifyAction.Enable=true;
    check.setAction(modifyAction);



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.publish(check,'Simulink');

end

function[passedChecks,propertyNames,...
    defaultPropertyValues,currentPropertyValues]=i_CheckModelProperties(modelName)

    propertyNames=i_propertyNames();
    defaultPropertyValues=i_defaultPropertyValues(propertyNames);
    currentPropertyValues=i_propertyValues(modelName,propertyNames);



    passedChecks=false(size(propertyNames));

    ind=strcmp('ModifiedByFormat',propertyNames);
    passedChecks(ind)=strcmp(defaultPropertyValues{ind},...
    currentPropertyValues{ind});


    ind=strcmp('ModifiedDateFormat',propertyNames);
    passedChecks(ind)=strcmp(defaultPropertyValues{ind},...
    currentPropertyValues{ind});




    ind=strcmp('ModelVersionFormat',propertyNames);
    passedChecks(ind)=~isempty(strfind(currentPropertyValues{ind},...
    '%<AutoIncrement:'));

end

function results=i_ReportOnModelProperties(sys)

    modelName=bdroot(sys);
    results={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    mdladvObj.setCheckResultStatus(false);


    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    msgStr=DAStudio.message('Simulink:tools:SLXModelPropertyTaskDisplayName');
    ft.setSubTitle(msgStr);
    ft.setInformation(DAStudio.message('Simulink:tools:SLXModelPropertyTaskInfo'));
    ft.setSubBar(0);
    results{end+1}=ft;

    [passedChecks,propertyNames,...
    defaultPropertyValues,currentPropertyValues]=i_CheckModelProperties(modelName);

    passed=all(passedChecks);
    mdladvObj.setCheckResultStatus(passed);
    mdladvObj.setActionEnable(~passed);


    for jj=1:numel(propertyNames)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        if passedChecks(jj)

            ft.setSubResultStatus('pass');
            msgStr=DAStudio.message('Simulink:tools:SLXModelPropertySuccessOne',propertyNames{jj});
            ft.setSubResultStatusText(msgStr);
        else

            ft.setSubResultStatus('warn');
            msgStr=DAStudio.message('Simulink:tools:SLXModelPropertyFailOne',...
            propertyNames{jj},currentPropertyValues{jj},defaultPropertyValues{jj});
            msgStr=i_fix_html(msgStr);
            ft.setSubResultStatusText(msgStr);
        end
        ft.setSubBar(0);
        results{end+1}=ft;%#ok<AGROW>
    end


    if~passed
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubBar(0);
        ft.setRecAction(DAStudio.message('Simulink:tools:SLXModelPropertyRecAction'));
        results{end+1}=ft;
    end

end

function result=i_ActionUpdateModelProperties(taskObj)






    result=ModelAdvisor.Paragraph();
    mdladvObj=taskObj.MAObj;
    modelName=bdroot(mdladvObj.System);

    [passedChecks,propertyNames,defaultPropertyValues]=...
    i_CheckModelProperties(modelName);

    for jj=1:numel(passedChecks)
        if~passedChecks(jj)
            try
                set_param(modelName,propertyNames{jj},defaultPropertyValues{jj});
                result.addItem(i_fix_html(...
                DAStudio.message('Simulink:tools:SLXModelPropertyRecWorked',...
                propertyNames{jj},defaultPropertyValues{jj})));
            catch E

                result.addItem(DAStudio.message('Simulink:tools:SLXModelPropertyRecFailed',...
                propertyNames{jj}));
                result.addItem(E.message);
            end
            result.addItem(ModelAdvisor.LineBreak);
        end
    end

end

function propertyNames=i_propertyNames()

    propertyNames={...
    'ModifiedByFormat',...
    'ModifiedDateFormat',...
'ModelVersionFormat'...
    };
end

function defaultPropertyValues=i_defaultPropertyValues(propertyNames)

    persistent propertyValues
    if isempty(propertyValues)

        [~,tempModel]=fileparts(tempname);
        new_system(tempModel,'model');
        propertyValues=i_propertyValues(tempModel,propertyNames);
        close_system(tempModel,0);
    end
    defaultPropertyValues=propertyValues;
end

function propertyValues=i_propertyValues(modelName,propertyNames)

    propertyValues=cell(size(propertyNames));
    for jj=1:numel(propertyNames)
        propertyValues{jj}=get_param(modelName,propertyNames{jj});
    end
end

function msgStr=i_fix_html(msgStr)

    msgStr=strrep(msgStr,'<','&#60;');
    msgStr=strrep(msgStr,'>','&#62;');
end




