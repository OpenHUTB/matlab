function SLCIMixChecks



    mdladvRoot=ModelAdvisor.Root;
    rec=ModelAdvisor.Check('mathworks.slci.RootOutportBlocksUsage');
    rec.Title=DAStudio.message('Slci:compatibility:RootOutportUsageTitle');
    rec.TitleTips=DAStudio.message('Slci:compatibility:RootOutportUsageTitleTips');
    rec.CSHParameters.MapKey='ma.slci';
    rec.CSHParameters.TopicID='mathworks.slci.RootOutportBlocksUsage';
    rec.setCallbackFcn(@RootOutportUsageCallback,'None','StyleOne');
    rec.Value=false;
    rec.LicenseName={'Simulink_Code_Inspector'};
    rec.PreCallbackHandle=@slciModel_pre;
    rec.PostCallbackHandle=@slciModel_post;
    rec.CallbackContext='PostCompile';
    rec.SupportExclusion=true;
    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@modifyCodeSet);
    modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
    modifyAction.Description=DAStudio.message('Slci:compatibility:ModelWideConstraintsModifyTip');
    modifyAction.Enable=false;
    rec.setAction(modifyAction);
    mdladvRoot.publish(rec,'Simulink Code Inspector');

    rec1=ModelAdvisor.Check('mathworks.slci.BusUsage');
    rec1.Title=DAStudio.message('Slci:compatibility:BusUsageTitle');
    rec1.TitleTips=DAStudio.message('Slci:compatibility:BusUsageTitleTips');
    rec1.CSHParameters.MapKey='ma.slci';
    rec1.CSHParameters.TopicID='mathworks.slci.BusUsage';
    rec1.setCallbackFcn(@BusUsageCallback,'None','StyleOne');
    rec1.Value=false;
    rec1.LicenseName={'Simulink_Code_Inspector'};
    rec1.PreCallbackHandle=@slciModel_pre;
    rec1.PostCallbackHandle=@slciModel_post;
    rec1.CallbackContext='PostCompile';
    rec1.SupportExclusion=true;
    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@modifyCodeSet);
    modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
    modifyAction.Description=DAStudio.message('Slci:compatibility:ModelWideConstraintsModifyTip');
    modifyAction.Enable=false;
    rec1.setAction(modifyAction);
    mdladvRoot.publish(rec1,'Simulink Code Inspector');

    rec2=ModelAdvisor.Check('mathworks.slci.SharedUtilsUsage');
    rec2.Title=DAStudio.message('Slci:compatibility:SharedUtilsUsageTitle');
    rec2.TitleTips=DAStudio.message('Slci:compatibility:SharedUtilsUsageTitleTips');
    rec2.CSHParameters.MapKey='ma.slci';
    rec2.CSHParameters.TopicID='mathworks.slci.SharedUtils';
    rec2.setCallbackFcn(@SharedUtilsCallback,'None','StyleOne');
    rec2.Value=false;
    rec2.LicenseName={'Simulink_Code_Inspector'};
    rec2.PreCallbackHandle=@slciModel_pre;
    rec2.PostCallbackHandle=@slciModel_post;
    rec2.CallbackContext='PostCompile';
    rec2.SupportExclusion=true;
    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@modifyCodeSet);
    modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
    modifyAction.Description=DAStudio.message('Slci:compatibility:ModelWideConstraintsModifyTip');
    modifyAction.Enable=false;
    rec2.setAction(modifyAction);
    mdladvRoot.publish(rec2,'Simulink Code Inspector');

    rec3=ModelAdvisor.Check('mathworks.slci.SampleTimesUsage');
    rec3.Title=DAStudio.message('Slci:compatibility:SampleTimesUsageTitle');
    rec3.TitleTips=DAStudio.message('Slci:compatibility:SampleTimesUsageTitleTips');
    rec3.CSHParameters.MapKey='ma.slci';
    rec3.CSHParameters.TopicID='mathworks.slci.SampleTimesUsage';
    rec3.setCallbackFcn(@SampleTimesCallback,'None','StyleOne');
    rec3.Value=false;
    rec3.LicenseName={'Simulink_Code_Inspector'};
    rec3.PreCallbackHandle=@slciModel_pre;
    rec3.PostCallbackHandle=@slciModel_post;
    rec3.CallbackContext='PostCompile';
    rec3.SupportExclusion=true;
    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@modifyCodeSet);
    modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
    modifyAction.Description=DAStudio.message('Slci:compatibility:ModelWideConstraintsModifyTip');
    modifyAction.Enable=false;
    rec3.setAction(modifyAction);
    mdladvRoot.publish(rec3,'Simulink Code Inspector');

    rec4=ModelAdvisor.Check('mathworks.slci.ConditionallyExecuteInputs');
    rec4.Title=DAStudio.message('Slci:compatibility:ConditionallyExecuteInputsTitle');
    rec4.TitleTips=DAStudio.message('Slci:compatibility:ConditionallyExecuteInputsTitleTips');
    rec4.CSHParameters.MapKey='ma.slci';
    rec4.CSHParameters.TopicID='mathworks.slci.ConditionallyExecuteInputs';
    rec4.setCallbackFcn(@ConditionallyExecuteInputsCallback,'None','StyleOne');
    rec4.Value=false;
    rec4.LicenseName={'Simulink_Code_Inspector'};
    rec4.PreCallbackHandle=@slciModel_pre;
    rec4.PostCallbackHandle=@slciModel_post;
    rec4.CallbackContext='PostCompile';
    rec4.SupportExclusion=true;
    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@modifyCodeSet);
    modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
    modifyAction.Description=DAStudio.message('Slci:compatibility:ModelWideConstraintsModifyTip');
    modifyAction.Enable=false;
    rec4.setAction(modifyAction);
    mdladvRoot.publish(rec4,'Simulink Code Inspector');
end

function ftList=RootOutportUsageCallback(system)
    ftList=[];
    result=true;
    constraintEnums={'ConstantRootOutport','BusRootOutport'};
    for i=1:numel(constraintEnums)
        ft=checkModelWideConstraint(constraintEnums{i},system);
        if(i<numel(constraintEnums))
            ft{end}.setSubBar(true);
        end
        ftList=[ftList,ft];
        if strcmpi(ft{1}.SubresultStatus,'Warn')
            result=false;
        end
    end
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(result);
end

function ftList=BusUsageCallback(system)
    ftList=[];
    result=true;
    constraintEnums={'HiddenBusConversion','BusExpansion'};
    for i=1:numel(constraintEnums)
        ft=checkModelWideConstraint(constraintEnums{i},system);
        if(i<numel(constraintEnums))
            ft{end}.setSubBar(true);
        end
        ftList=[ftList,ft];
        if strcmpi(ft{1}.SubresultStatus,'Warn')
            result=false;
        end
    end
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(result);
end

function ftList=SharedUtilsCallback(system)
    ftList=[];
    result=true;
    constraintEnums={'SharedUtilitiesSymbols','SharedUtilitiesTargetLangStandard',...
    'SharedUtilitiesCodeStyle','SharedUtilitiesPortableWordSizes'};
    for i=1:numel(constraintEnums)
        ft=checkModelWideConstraint(constraintEnums{i},system);
        if(i<numel(constraintEnums))
            ft{end}.setSubBar(true);
        end
        ftList=[ftList,ft];%#ok
        if strcmpi(ft{1}.SubresultStatus,'Warn')
            result=false;
        end
    end
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(result);
end


function ftList=SampleTimesCallback(system)
    ftList=[];
    result=true;
    constraintEnums={'SampleTimes','ExplicitPartitions'};
    for i=1:numel(constraintEnums)
        ft=checkModelWideConstraint(constraintEnums{i},system);
        if(i<numel(constraintEnums))
            ft{end}.setSubBar(true);
        end
        ftList=[ftList,ft];%#ok
        if strcmpi(ft{1}.SubresultStatus,'Warn')
            result=false;
        end
    end
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(result);
end


function ftList=ConditionallyExecuteInputsCallback(system)
    ftList=[];
    result=true;
    constraintEnums={'ConditionallyExecuteInputs','EnabledConditionallyExecuteInputs'};
    for i=1:numel(constraintEnums)
        ft=checkModelWideConstraint(constraintEnums{i},system);
        if(i<numel(constraintEnums))
            ft{end}.setSubBar(true);
        end
        ftList=[ftList,ft];%#ok
        if strcmpi(ft{1}.SubresultStatus,'Warn')
            result=false;
        end
    end
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(result);
end

function result=modifyCodeSet(taskobj)
    result=ModelAdvisor.Paragraph;
    mdladvObj=taskobj.MAObj;

    resObj=mdladvObj.getCheckResult(taskobj.MAC);
    for ik=1:numel(resObj)

        if strcmp(resObj{ik}.subResultStatus,'Warn')

            unModifiedList={};
            modifiedList={};

            constraint=resObj{ik}.UserData.Constraint;
            title=resObj{ik}.subTitle;

            hasAutoFix=constraint.hasAutoFix();
            if~hasAutoFix
                noFixText=DAStudio.message('Slci:compatibility:NoAutofixSupport');
                ftNoFix=ModelAdvisor.FormatTemplate('ListTemplate');
                ftNoFix.setSubTitle(title);
                ftNoFix.setSubResultStatusText(noFixText);
                if~isempty(resObj{ik}.ListObj)

                    ftNoFix.setListObj(resObj{ik}.ListObj);
                end
                ftNoFix.setSubBar(true);
                result.addItem(ftNoFix.emitContent);
            else
                ftFix=ModelAdvisor.FormatTemplate('ListTemplate');
                ftFix.setSubTitle(title);
                if isempty(resObj{ik}.ListObj)
                    status=constraint.fix();
                    [~,~,passText,~]=constraint.getMAStrings(true,'fix');

                    if status
                        ftFix.setSubResultStatusText(passText);

                    else
                        propertyName=constraint.getFailingConfigurationParameter();
                        UnmodifiedSettingText=DAStudio.message('Slci:compatibility:UnmodifiedSettings',...
                        propertyName);
                        ftFix.setSubResultStatusText(UnmodifiedSettingText);
                    end
                    ftFix.setSubBar(true);
                    result.addItem(ftFix.emitContent);
                else
                    statusFlag=[];
                    for ih=1:numel(resObj{ik}.ListObj)
                        blk=resObj{ik}.ListObj{ih};

                        status=constraint.fix(blk);
                        statusFlag=[statusFlag;status];%#ok<AGROW>


                        if~status
                            unModifiedList{end+1}=blk;%#ok<AGROW>
                        else
                            modifiedList{end+1}=blk;%#ok<AGROW>
                        end
                    end
                    [~,~,passText,~]=constraint.getMAStrings(true,'fix');
                    warnText=DAStudio.message('Slci:compatibility:UnmodifiedObjects');
                    ftFix.setSubResultStatusText(DAStudio.message('Slci:compatibility:PostFix'));

                    ftFix.setListObj(modifiedList);
                    ftFix.setSubBar(false);
                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                    ft.setSubResultStatusText(warnText);

                    ft.setListObj(unModifiedList);
                    ft.setSubBar(false);

                    if all(statusFlag)
                        ftFix.setInformation(passText);
                        ftFix.setSubBar(true);
                        result.addItem(ftFix.emitContent);
                    elseif all(~statusFlag)
                        ft.setSubTitle(title);
                        ft.setSubBar(true);
                        result.addItem(ft.emitContent);
                    else
                        result.addItem(ftFix.emitContent);
                        ft.setSubBar(true);
                        result.addItem(ft.emitContent);
                    end
                end
            end
            result.addItem(ModelAdvisor.LineBreak);
        end
    end
end