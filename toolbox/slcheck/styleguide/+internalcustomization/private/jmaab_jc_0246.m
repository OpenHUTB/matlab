function jmaab_jc_0246






    checkID='jc_0246';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0246');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip'])];
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportHighlighting=true;
    rec.Value=false;

    rec.setLicense({styleguide_license});

    [inputParamList,gridLayout]=Advisor.Utils.Naming.getLengthRestrictionInputParams('JMAAB');
    rec.setInputParametersLayoutGrid(gridLayout);
    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@Advisor.Utils.Naming.inputParam_NameLength);


    rec.setCallbackFcn(@checkCallBack,'PostCompile','StyleOne');

    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end


function[ResultDescription]=checkCallBack(system)
    ResultDescription={};
    prefix='ModelAdvisor:jmaab:NamingCheck';
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setInformation(DAStudio.message('ModelAdvisor:jmaab:jc_0246_subtitle'));
    ft.setSubBar(false);

    ft.setColTitles({...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_ParameterUsedIn'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Name'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_DefinedIn')});

    [FailingNames,minLength,maxLength,ft]=checkAlgo(mdlAdvObj,system,ft);

    if~isempty(FailingNames)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0246_fail'));
        ft.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0246_recAction',...
        num2str(minLength),num2str(maxLength)));
        ft.setTableInfo(FailingNames);
        mdlAdvObj.setCheckResultStatus(false);
    else
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0246_pass'));
        mdlAdvObj.setCheckResultStatus(true);
    end
    ResultDescription{end+1}=ft;

end


function[FailingNames,minLength,maxLength,ft]=checkAlgo(mdlAdvObj,system,ft)

    inputParams=mdlAdvObj.getInputParameters;
    [minLength,maxLength]=Advisor.Utils.Naming.validateInputParam_Length(inputParams,'JMAAB');
    FailingNames={};

    parameters=Simulink.findVars(system,'SearchMethod','cached');

    for index=1:numel(parameters)
        thisParameter=parameters(index);
        parameterName=thisParameter.Name;
        Failures={};
        bFlag=length(parameterName)<minLength||length(parameterName)>maxLength;

        if bFlag
            users=thisParameter.Users;
            users=Advisor.Utils.Naming.filterUsersInShippingLibraries(users);
            if~isempty(users)
                usedIn=ModelAdvisor.Paragraph;
                for i=1:numel(users)
                    usedIn.addItem(ModelAdvisor.Text(users{i}));
                    if i~=numel(users)
                        usedIn.addItem(ModelAdvisor.LineBreak());
                    end
                end
                locactionText=thisParameter.SourceType;
                Failures{1}=usedIn;
                Failures{2}=parameterName;
                Failures{3}=locactionText;
            end
        end
        FailingNames=[FailingNames;Failures];%#ok
    end

end

