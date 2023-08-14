






function[subStatus,subResult,violations]=checkParameterNames(system,regexpParameterNames,...
    prefix,reservedNames,conventionParameterNames)
    violations=[];

    subStatus=true;

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubBar(false);
    ft.setColTitles({...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_ParameterUsedIn'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Name'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_DefinedIn'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Reason')});

    parameters=Simulink.findVars(system,'SearchMethod','cached');

    for index=1:numel(parameters)
        thisParameter=parameters(index);
        parameterName=thisParameter.Name;
        [isValid,issue,reason]=...
        Advisor.Utils.Naming.isNameValid(parameterName,regexpParameterNames,...
        reservedNames,prefix,conventionParameterNames);
        if~isValid
            users=thisParameter.Users;
            users=Advisor.Utils.Naming.filterUsersInShippingLibraries(users);
            if~isempty(users)
                subStatus=false;
                usedIn=ModelAdvisor.Paragraph;
                for i=1:numel(users)
                    usedIn.addItem(ModelAdvisor.Text(users{i}));
                    if i~=numel(users)
                        usedIn.addItem(ModelAdvisor.LineBreak());
                    end
                end
                locactionText=thisParameter.SourceType;
                ft.addRow({usedIn,issue,locactionText,reason});
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',thisParameter);
                vObj.RecAction=issue;
                violations=[violations;vObj];%#ok<AGROW>                
            end
        end
    end

    subResult=ft;
end

