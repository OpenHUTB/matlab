




function SLCIMatlabObjects

    mlock;

    mdladvRoot=ModelAdvisor.Root;


    objectID='MLBlocks';
    preCallBack=@slciModel_pre;
    callBack=@(system)(CheckMLBlocks(system,objectID));
    postCompile=true;
    publishCheck(mdladvRoot,'MATLABFunctionBlocksUsage',objectID,...
    preCallBack,callBack,postCompile)


    objectID='MLData';
    preCallBack=@slciModel_pre;
    callBack=@(system)(CheckMLObjects(system,objectID));
    postCompile=true;
    publishCheck(mdladvRoot,'MATLABFunctionDataUsage',objectID,...
    preCallBack,callBack,postCompile);


    objectID='MLAst';
    preCallBack=@slciRunMatlabCheck_pre;
    callBack=@(system)(CheckMLObjects(system,objectID));
    postCompile=false;
    publishCheck(mdladvRoot,'MATLABFunctionCodeUsage',objectID,...
    preCallBack,callBack,postCompile);


    preCallBack=@slciModel_pre;
    callBack=@(system)(CheckCodeAnalyzer(system));
    publishCodeAnalyzerCheck(mdladvRoot,'MATLABCodeAnalyzer',...
    preCallBack,callBack);

end


function ftFinalList=CheckMLBlocks(system,objType)
    ftFinalList=iterateMLBlocks(system,objType);
end


function ftFinalList=CheckMLObjects(system,objType)
    ftFinalList=iterateMLObjects(system,objType);
end


function[ftFinalList,resultHandles]=CheckCodeAnalyzer(system)

    [result,ftFinalList,resultHandles]=...
    slci.internal.runCodeAnalyzerCheck(system);
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(result);
end


function publishCheck(mdladvRoot,ID,object,preCallBack,callBack,postCompile)

    rec=ModelAdvisor.Check(['mathworks.slci.',ID]);
    rec.Title=DAStudio.message('Slci:compatibility:MatlabObjectsCheckTitle',...
    DAStudio.message(['Slci:compatibility:',object]));
    rec.TitleTips=DAStudio.message('Slci:compatibility:MatlabObjectsCheckTitleTips',...
    DAStudio.message(['Slci:compatibility:',object]));
    rec.CSHParameters.MapKey='ma.slci';
    rec.CSHParameters.TopicID=['mathworks.slci.',ID];
    rec.setCallbackFcn(callBack,'None','StyleOne');
    rec.LicenseName={'Simulink_Code_Inspector'};
    rec.PreCallbackHandle=preCallBack;
    rec.PostCallbackHandle=@slciModel_post;
    if postCompile
        rec.CallbackContext='PostCompile';
        rec.Value=false;
    else
        rec.Value=true;
    end
    rec.SupportExclusion=false;
    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@modifyCodeSet);
    modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
    modifyAction.Description=DAStudio.message('Slci:compatibility:MatlabObjectsCheckModifyTip',...
    DAStudio.message(['Slci:compatibility:',object]));
    modifyAction.Enable=false;
    rec.setAction(modifyAction);
    mdladvRoot.publish(rec,'Simulink Code Inspector');
end


function publishCodeAnalyzerCheck(mdladvRoot,ID,preCallBack,callBack)

    rec=ModelAdvisor.Check(['mathworks.slci.',ID]);
    rec.Title=DAStudio.message('Slci:compatibility:MatlabCodeAnalyzerCheckTitle');
    rec.TitleTips=DAStudio.message('Slci:compatibility:MatlabCodeAnalyzerCheckTitleTips');
    rec.CSHParameters.MapKey='ma.slci';
    rec.CSHParameters.TopicID=['mathworks.slci.',ID];
    rec.setCallbackFcn(callBack,'None','StyleThree');
    rec.LicenseName={'Simulink_Code_Inspector'};
    rec.PreCallbackHandle=preCallBack;
    rec.PostCallbackHandle=@slciModel_post;
    rec.SupportExclusion=false;
    rec.Value=true;
    mdladvRoot.publish(rec,'Simulink Code Inspector');
end

function result=modifyCodeSet(taskobj)
    result=ModelAdvisor.Paragraph;
    mdladvObj=taskobj.MAObj;

    resObj=mdladvObj.getCheckResult(taskobj.MAC);
    for ik=1:numel(resObj)

        unModifiedList={};
        modifiedList={};

        if~isempty(resObj{ik}.ListObj)

            constraint=resObj{ik}.UserData.Constraint;
            title=resObj{ik}.subTitle;

            hasAutoFix=constraint.hasAutoFix();
            if~hasAutoFix
                noFixText=DAStudio.message('Slci:compatibility:NoAutofixSupport');
                ftNoFix=ModelAdvisor.FormatTemplate('ListTemplate');
                ftNoFix.setSubTitle(title);
                ftNoFix.setSubResultStatusText(noFixText);

                ftNoFix.setListObj(resObj{ik}.ListObj);
                ftNoFix.setSubBar(true);
                result.addItem(ftNoFix.emitContent);
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
                ftFix=ModelAdvisor.FormatTemplate('ListTemplate');
                ftFix.setSubTitle(title);
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
            result.addItem(ModelAdvisor.LineBreak);
        end
    end
end