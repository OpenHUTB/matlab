function defineCGOCheck






    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.codegen.CodeGenSanity');
    rec.Title=getString(message('Simulink:tools:MATitleCodeGenSanityCheck'));
    rec.TitleTips=getString(message('Simulink:tools:MATitleTipCodeGenSanityCheck'));
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='com.mathworks.MA.codegensanity';
    rec.setCallbackFcn(@ExecCheckSanity,'None','StyleOne');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={'Real-Time_Workshop'};
    myAction=ModelAdvisor.Action;
    myAction.setCallbackFcn(@cgoFixIt);
    myAction.Name=getString(message('Simulink:tools:MACodeGenSanityCheckFixButtonTitle'));
    myAction.Description=getString(message('Simulink:tools:MATitleCodeGenSanityCheckFixButtonDescr'));
    rec.setAction(myAction);
    mdladvRoot.register(rec);


    rec=ModelAdvisor.Check('mathworks.codegen.checkEnableMemcpy');
    rec.Title=getString(message('Simulink:tools:MATitleCheckEnableMemcpy'));
    rec.TitleTips=getString(message('Simulink:tools:MATitletipCheckEnableMemcpy'));
    rec.CSHParameters.MapKey='ma.rtw';
    rec.CSHParameters.TopicID='mathworks.codegen.checkEnableMemcpy';
    rec.setCallbackFcn(@ExecCheckEnableMemcpy,'None','StyleOne');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={'Real-Time_Workshop'};
    myAction=ModelAdvisor.Action;
    myAction.setCallbackFcn(@fixEnableMemcpy);
    myAction.Name=getString(message('Simulink:tools:MAforCodeGenAdvisorCheckEnableMemcpyFixButton'));
    myAction.Description=getString(message('Simulink:tools:MAforCodeGenAdvisorCheckEnableMemcpyFixButtonDesc'));
    rec.setAction(myAction);
    mdladvRoot.register(rec);

end




function ResultString=ExecCheckSanity(system)


    passString=['<font color="#008000">',getString(message('Simulink:tools:MATCodeGenSanityCheckPassMsg')),'</font>'];

    model=bdroot(system);
    cs=getActiveConfigSet(model);
    mdlObj=cs.get_param('ObjectivePriorities');
    ertTarget=false;
    try
        ertTarget=strcmpi(get_param(cs,'IsERTTarget'),'on');
    catch
    end

    modelName=get_param(model,'Name');
    encodedModelName=modeladvisorprivate('HTMLjsencode',modelName,'encode');

    encodedModelName=[encodedModelName{:}];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    cgo=mdladvObj.getTaskObj('com.mathworks.cgo.group');
    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};

    if isa(cs,'Simulink.ConfigSetRef')
        isCSRef=true;
        cs=cs.getResolvedConfigSetCopy;
    else
        isCSRef=false;
    end

    objectives=mdlObj;
    if isa(cgo,'CodeGenAdvisor.Group')
        if~strcmp(cgo.Objectives,'initial value')
            if ertTarget==cgo.isERT
                objectives=cgo.Objectives;
            else
                cgo.isERT=ertTarget;
                cgo.Objectives=objectives;
            end
        end
    end



    ertTargetCode=strcmpi(get_param(cs,'IsERTTarget'),'on');

    if ertTargetCode
        targetCode=1;
    else
        targetCode=0;
    end

    csObj=rtw.codegenObjectives.ConfigSetProp;
    csObj.driver(objectives,targetCode,cs);

    if isempty(csObj)||csObj.error==1
        Msg=getString(message('Simulink:tools:MATCodeGenSanityCheckNoObjective'));
        ObjMsg=['<br><br> ',getString(message('Simulink:tools:MATCodeGenSanityCheckNoObjectiveMsg'))];
        result=[Msg,ObjMsg];
        ResultString=result;
        return;
    end

    objName=csObj.objName;

    cm=DAStudio.CustomizationManager;

    if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0&&...
        cm.ObjectiveCustomizer.initialized
        for i=1:length(objName)
            objName{i}=cm.ObjectiveCustomizer.IDToNameHash.get(objName{i});
        end
    end


    if~isempty(objName)
        objNameStr=loc_translate(objName{1},cm);

        for i=2:length(objName)
            transName=loc_translate(objName{i},cm);
            if~isempty(transName)
                objNameStr=[objNameStr,', ',transName];
            end
        end
    end

    if~isempty(mdlObj)
        mdlObjNameStr=loc_translate(mdlObj{1},cm);

        for i=2:length(mdlObj)
            transName=loc_translate(mdlObj{i},cm);
            if~isempty(transName)
                mdlObjNameStr=[mdlObjNameStr,', ',transName];
            end
        end
    else
        mdlObjNameStr=getString(message('RTW:configSet:sanityCheckUnspecified'));
    end

    isObjEqual=isequal(objectives,mdlObj);
    noWarning=true;

    propertyUnMatched={};
    indexUnMatched=0;
    paramsOfInterest=cell(1,1);

    propertyNames=cell(1,1);
    nameIdx=1;
    for i=1:csObj.lenOfLists{1}
        propertyName=csObj.scriptLists{1}{i}.name;
        propertyNames{nameIdx}=propertyName;
        nameIdx=nameIdx+1;
    end

    for i=1:csObj.lenOfLists{1}
        settingRecommended=csObj.scriptLists{1}{i}.value;
        settingRecommendedLower=lower(settingRecommended);

        if strfind(settingRecommendedLower,'any')>0
            continue;
        end

        switch(settingRecommendedLower)
        case 'no impact'
            continue;
        case{'on','off','error','warning','none'}
            settingRecommended=settingRecommendedLower;
        end

        propertyName=csObj.scriptLists{1}{i}.name;

        if strcmp(propertyName,'SystemTargetFile')&&strcmpi(settingRecommendedLower,'ert.tlc')
            if cs.get_param('IsERTTarget')
                continue;
            end
        end

        id=csObj.scriptLists{1}{i}.id;
        reversed=strcmp(csObj.Parameters(id).reversed,'Y');

        check=find(ismember(cs.getProp,propertyName)==1);
        if isempty(check)||~check
            continue;
        end

        try
            propertySetting=cs.get_param(propertyName);
        catch err
            if strcmp(err.identifier,'Simulink:ConfigSet:IgnoredParam')

            else
                disp(err.message);
            end
            continue;
        end

        if strcmpi(propertyName,'SignalResolutionControl')
            switch propertySetting
            case 'UseLocalSettings'
                propertySetting='Explicit only';
            case 'TryResolveAll'
                propertySetting='Explicit and implicit';
            case 'TryResolveAllWithWarning'
                propertySetting='Explicit and warn implicit';
            end
        end

        if isnumeric(propertySetting)
            settingRecommendedNumeric=str2double(settingRecommendedLower);
            equal=(settingRecommendedNumeric==propertySetting);
        else
            if~isnan(str2double(propertySetting))&&~isempty(str2double(propertySetting))&&isnumeric(str2double(propertySetting))
                settingRecommendedNumeric=str2double(settingRecommendedLower);
                equal=(settingRecommendedNumeric==str2double(propertySetting));
            else
                value1=lower(strrep(propertySetting,' ',''));
                value2=lower(strrep(settingRecommended,' ',''));

                if strcmpi(value2,'warning')&&strcmpi(value1,'error')
                    equal=true;
                else
                    equal=strcmpi(value1,value2);%#ok
                    if reversed

                        if strcmpi(value2,'off')
                            settingRecommended='on';
                            propertySetting='off';
                        else
                            settingRecommended='off';
                            propertySetting='on';
                        end
                    end
                end
            end
        end

        paramInfo=configset.getParameterInfo(model,propertyName);
        ui.Param=paramInfo.Name;
        ui.Prompt=paramInfo.Description;
        ui.Type=paramInfo.Type;
        ui.Entries=paramInfo.AllowedDisplayValues;

        if~isempty(ui.Prompt)
            p.name=ui.Prompt;
        else
            p.name=propertyName;
        end

        p.ui=ui;
        p.setting=propertySetting;
        p.reversed=reversed;
        paramsOfInterest{end+1}.param=p;

        if~equal
            if~strcmp(ui.Type,'NonUI')
                indexUnMatched=indexUnMatched+1;
                propertyUnMatched{indexUnMatched}.name=propertyName;%#ok<*AGROW>

                if~isempty(ui.Prompt)
                    propertyUnMatched{indexUnMatched}.nameUI=ui.Prompt;
                else
                    propertyUnMatched{indexUnMatched}.nameUI=propertyName;
                end

                if isempty(propertySetting)
                    propertySetting='(empty)';
                end

                propertyUnMatched{indexUnMatched}.ui=ui;
                propertyUnMatched{indexUnMatched}.existingValue=propertySetting;
                propertyUnMatched{indexUnMatched}.recommendedValue=settingRecommended;
                propertyUnMatched{indexUnMatched}.reversed=reversed;
                noWarning=false;
            end
        end
    end

    if isObjEqual
        objStr=DAStudio.message('Simulink:tools:CGACheckObjEqual',objNameStr);
    else
        objStr=DAStudio.message('Simulink:tools:CGACheckObj',objNameStr,mdlObjNameStr);
    end

    objResult.name='ObjectivePriorities';
    objResult.nameUI='Objectives';
    objResult.ui=slCfgPrmDlg(modelName,'Param2UI',objResult.name,1);
    objResult.existingValue=mdlObjNameStr;
    objResult.recommendedValue=objNameStr;
    objResult.reversed=false;
    if isObjEqual
        currentCheckObj.ResultData=propertyUnMatched;
    else
        currentCheckObj.ResultData=[{objResult},propertyUnMatched];
    end

    if noWarning
        ft=ModelAdvisor.FormatTemplate('TableTemplate');



        info={};
        ft.setColTitles({getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableColName1')),...
        getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableColName4'))});
        if isObjEqual
            ft.setTableTitle([passString,'<br> ',objStr,'<br> ',...
            getString(message('Simulink:tools:MATCodeGenSanityCheckPassMsg2'))]);
        else
            ft.setTableTitle([objStr,'<br><br> ',getString(message('Simulink:tools:MATCodeGenSanityCheckPassMsg2'))]);
        end

        len=length(paramsOfInterest);
        for i=2:len
            nameUI=strrep(paramsOfInterest{i}.param.name,':','');
            value=paramsOfInterest{i}.param.setting;

            if paramsOfInterest{i}.param.reversed
                if strcmpi(value,'off')
                    value='on';
                else
                    value='off';
                end
            end

            if isnumeric(value)
                value=num2str(value);
            end

            ui=paramsOfInterest{i}.param.ui;

            link=loc_CreateConfigSetHref(nameUI,encodedModelName,ui.Param);

            info=[info;{link},{value}];
        end

        ft.setTableInfo(info);
        clear csObj;

    else

        ft=ModelAdvisor.FormatTemplate('TableTemplate');


        info={};
        ft.setColTitles({getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableColName1')),...
        getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableColName2')),...
        getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableColName3'))});
        ft.setTableTitle([objStr,'<br><br>',getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableTitle'))]);

        for i=1:indexUnMatched
            nameUI=strrep(propertyUnMatched{i}.nameUI,':','');
            value1=propertyUnMatched{i}.existingValue;
            if isnumeric(value1)
                value1=num2str(value1);
            end
            value2=propertyUnMatched{i}.recommendedValue;

            ui=propertyUnMatched{i}.ui;

            link=loc_CreateConfigSetHref(nameUI,encodedModelName,ui.Param);

            info=[info;{link},{value1},{value2}];
        end

        ft.setTableInfo(info);
        clear csObj;

    end

    mdladvObj.setActionEnable(~(noWarning&&isObjEqual)&&~isCSRef);
    mdladvObj.setCheckResultStatus(noWarning&&isObjEqual);
    ResultString=ft;

end





function result=cgoFixIt(taskobj)
    mdladvObj=taskobj.MAObj;
    mdladvObj.setActionEnable(false);

    system=mdladvObj.System;

    model=bdroot(system);
    cs=getActiveConfigSet(model);

    cgo=mdladvObj.getTaskObj('com.mathworks.cgo.group');
    objectives=cs.get_param('ObjectivePriorities');
    if isa(cgo,'CodeGenAdvisor.Group')
        if~strcmp(cgo.Objectives,'initial value')
            objectives=cgo.Objectives;
        end
    end

    cs.set_param('ObjectivePriorities',objectives);

    modelName=get_param(model,'Name');
    encodedModelName=modeladvisorprivate('HTMLjsencode',modelName,'encode');
    encodedModelName=[encodedModelName{:}];

    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
    unmatched=currentCheckObj.ResultData;
    totalNum=length(unmatched);
    unchanged=0;




    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    info={};
    ft.setColTitles({getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableColName1')),...
    getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableColName2a')),...
    getString(message('Simulink:tools:MATCodeGenSanityCheckResultTableColName2'))});
    ft.setTableTitle('Table of parameters with value changed');

    if~isempty(unmatched)
        for i=1:totalNum
            currentParam=unmatched{i};
            param=currentParam.name;
            value=currentParam.recommendedValue;
            reversed=currentParam.reversed;

            switch value
            case 'enable all as error'
                value='EnableAllAsError';
            case 'use local settings'
                value='UseLocalSettings';
            case 'disable all'
                value='DisableAll';
            case 'enable all as warning'
                value='EnableAllAsWarning';
            case 'macros'
                value='Macros';
            case 'literals'
                value='Literals';
            case 'individual arguments'
            case 'structure reference'
            case 'maximum'
                value='Maximum';
            end

            if strcmpi(currentParam.ui.Type,'enum')
                if isfield(currentParam.ui,'Entries')&&sum(ismember(upper(currentParam.ui.Entries),upper(value)))>0
                end
            end

            if strcmp(param,'ObjectivePriorities')
                nameUI=strrep(unmatched{i}.nameUI,':','');
                value1=unmatched{i}.existingValue;
                value2=unmatched{i}.recommendedValue;
                ui=unmatched{i}.ui;

                link=loc_CreateConfigSetHref(nameUI,encodedModelName,ui.Param);
                info=[info;{link},{value1},{value2}];

            else

                if cs.getPropEnabled(param)
                    try
                        if reversed
                            if strcmpi(value,'off')
                                value='on';
                            else
                                value='off';
                            end
                        end

                        cs.set_param(param,value);

                        nameUI=strrep(unmatched{i}.nameUI,':','');
                        value1=unmatched{i}.existingValue;
                        if isnumeric(value1)
                            value1=num2str(value1);
                        end
                        value2=unmatched{i}.recommendedValue;

                        ui=unmatched{i}.ui;

                        link=loc_CreateConfigSetHref(nameUI,encodedModelName,ui.Param);

                        info=[info;{link},{value1},{value2}];
                    catch me
                        ui_caught=slCfgPrmDlg(cs,'Param2UI',param);
                        parameterName='';
                        if~isempty(ui_caught)
                            parameterName=['(',ui_caught.Prompt,')'];
                        end

                        errtext=[me.message,parameterName];
                        hf=errordlg(errtext,'Error');
                        me=MException('Simulink:CodeGenAdvisorError',errtext);
                        set(hf,'tag','CodeGenAdvisorFixError');
                        setappdata(hf,'MException',me);
                    end
                else
                    unchanged=unchanged+1;
                end
            end
        end
    end

    if~isempty(info)
        ft.setTableInfo(info);
    end

    if unchanged==0
        unchangedMessage=getString(message('Simulink:tools:MATCodeGenSanityCheckFixAll'));
    elseif unchanged==1
        unchangedMessage=getString(message('Simulink:tools:MATCodeGenSanityCheckFixManualSingular'));
    else
        unchangedMessage=DAStudio.message('Simulink:tools:MATCodeGenSanityCheckFixManual',unchanged);
    end

    changed=totalNum-unchanged;

    if changed==0
        changedMessage=getString(message('Simulink:tools:MATCodeGenSanityCheckFixNoChange'));
    elseif changed==1
        changedMessage=getString(message('Simulink:tools:MATCodeGenSanityCheckFixPartlySingular'));
    else
        changedMessage=DAStudio.message('Simulink:tools:MATCodeGenSanityCheckFixPartly',changed);
    end

    if changed==0
        result=ModelAdvisor.Text([changedMessage,' ',unchangedMessage]);
    else
        if unchanged>0
            ft.setInformation([changedMessage,' ',unchangedMessage]);
        else
            ft.setInformation(unchangedMessage);
        end
        result=ft;
    end

    mdladvObj.setActionEnable(false);

end





function result=ExecCheckEnableMemcpy(system)

    model=bdroot(system);

    modelName=get_param(model,'Name');
    encodedModelName=modeladvisorprivate('HTMLjsencode',modelName,'encode');
    encodedModelName=[encodedModelName{:}];

    passString=['<p /><font color="#008000">','Passed','</font>'];
    model=bdroot(system);
    cs=getActiveConfigSet(model);

    objectives=cs.get_param('ObjectivePriorities');
    enableMemcpy=cs.get_param('EnableMemcpy');

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    mdladvObj.setActionEnable(false);

    needToCheck=false;
    objectiveTxt='';
    for i=1:length(objectives)
        if~strcmpi(objectives{i},'ROM efficiency')&&...
            ~strcmpi(objectives{i},'Execution efficiency')
            continue;
        end

        if isempty(objectiveTxt)
            objectiveTxt=objectives{i};
        else
            objectiveTxt=[objectiveTxt,', ',objectives{i}];
        end

        needToCheck=true;
    end

    if~needToCheck
        result=[passString,'<br><br>',getString(message('Simulink:tools:MACheckEnableMemcpyResultNA'));];
        mdladvObj.setCheckResultStatus(true);
        return;
    end

    if strcmpi(enableMemcpy,'off')
        ui=slCfgPrmDlg(modelName,'Param2UI','EnableMemcpy');

        link=loc_CreateConfigSetHref(ui.Prompt,encodedModelName,ui.Param);

        result=[DAStudio.message('Simulink:tools:MACheckEnableMemcpyResultWarning',objectiveTxt),'<br><br>',link];
        mdladvObj.setActionEnable(true);
        mdladvObj.setCheckResultStatus(false);
        return;
    end

    info=DAStudio.message('Simulink:tools:MACheckEnableMemcpyResultPassed',objectiveTxt);
    result=[passString,info];
    mdladvObj.setCheckResultStatus(true);

end





function result=fixEnableMemcpy(taskobj)

    mdladvObj=taskobj.MAObj;
    mdladvObj.setActionEnable(false);
    system=mdladvObj.System;
    model=bdroot(system);
    cs=getActiveConfigSet(model);

    try
        cs.set_param('EnableMemcpy','On');
    catch ME
        result=ME.message;
        return;
    end

    result='The configuration parameter ''EnableMemcpy'' has been successfully turned on.';
    mdladvObj.setActionEnable(false);

end





function htmlStr=loc_CreateConfigSetHref(inputStr,encodedModelName,paramName)
    htmlStr=['<a href="matlab: modeladvisorprivate openCSAndHighlight ',encodedModelName,' ',paramName,'"> ',inputStr,'</a>'];
end

function transName=loc_translate(objName,cm)
    if isempty(objName)
        transName='';
        return;
    end

    transName=objName;
    switch objName
    case{'Efficiency'}
        transName=getString(message('RTW:configSet:sanityCheckEfficiency'));
    case{'Traceability'}
        transName=getString(message('RTW:configSet:sanityCheckTraceability'));
    case{'Safety precaution'}
        transName=getString(message('RTW:configSet:sanityCheckSafetyprecaution'));
    case{'Debugging'}
        transName=getString(message('RTW:configSet:sanityCheckDebugging'));
    case{'Execution efficiency'}
        transName=getString(message('RTW:configSet:sanityCheckEfficiencyspeed'));
    case{'ROM efficiency'}
        transName=getString(message('RTW:configSet:sanityCheckEfficiencyROM'));
    case{'RAM efficiency'}
        transName=getString(message('RTW:configSet:sanityCheckEfficiencyRAM'));
    case{'MISRA C:2012 guidelines'}
        transName=getString(message('RTW:configSet:sanityCheckMisrac'));
    otherwise
        if~cm.ObjectiveCustomizer.initialized
            transName='';
        end
    end
end





