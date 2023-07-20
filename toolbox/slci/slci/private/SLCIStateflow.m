function SLCIStateflow



    mlock;
    sfObjects={DAStudio.message('Slci:compatibility:Charts'),...
    DAStudio.message('Slci:compatibility:MATLABActionLanguage'),...
    DAStudio.message('Slci:compatibility:Transitions'),...
    DAStudio.message('Slci:compatibility:Junctions'),...
    DAStudio.message('Slci:compatibility:Data'),...
    DAStudio.message('Slci:compatibility:Events'),...
    DAStudio.message('Slci:compatibility:States'),...
    DAStudio.message('Slci:compatibility:GraphicalFunctions'),...
    DAStudio.message('Slci:compatibility:TruthTables')...
    };
    mdladvRoot=ModelAdvisor.Root;
    for i=1:numel(sfObjects)
        ID=strrep(sfObjects{i},' ','');
        ID=strrep(ID,'-','');
        rec=ModelAdvisor.Check(['mathworks.slci.',ID,'SFObjsUsage']);
        rec.Title=DAStudio.message('Slci:compatibility:StateflowObjectsTitle',sfObjects{i});
        rec.TitleTips=DAStudio.message('Slci:compatibility:StateflowObjectsTitleTips',sfObjects{i});
        rec.CSHParameters.MapKey='ma.slci';
        rec.CSHParameters.TopicID=['mathworks.slci.',ID,'StateflowUsage'];
        rec.setCallbackFcn((@(system)(CheckSFObjects(system,sfObjects{i}))),'None','StyleOne');
        rec.Value=false;
        rec.LicenseName={'Simulink_Code_Inspector'};
        rec.PreCallbackHandle=@slciModel_pre;
        rec.PostCallbackHandle=@slciModel_post;
        rec.CallbackContext='PostCompile';
        rec.SupportExclusion=false;
        if strcmpi(ID,'charts')
            rec.SupportsEditTime=true;
        end
        modifyAction=ModelAdvisor.Action;
        modifyAction.setCallbackFcn(@modifyCodeSet);
        modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
        modifyAction.Description=DAStudio.message('Slci:compatibility:StateflowObjectsModifyTip',sfObjects{i});
        modifyAction.Enable=false;
        rec.setAction(modifyAction);
        mdladvRoot.publish(rec,'Simulink Code Inspector');
    end
end
function ftFinalList=CheckSFObjects(system,objType)
    ftFinalList=iterateSFObjs(system,objType);
end


function violations=iterateSFObjs(system,objType)
    violations=[];
    modelObj=getSLCIModelObj();
    objs=modelObj.getObjType(objType);
    constraintsToObjsMap=containers.Map;
    constraintMap=containers.Map;
    for i=1:numel(objs)
        if iscell(objs(i))
            constraints=objs{i}.getConstraints;
        else
            constraints=objs(i).getConstraints;
        end
        for j=1:numel(constraints)
            [failure,~]=constraints{j}.checkCompatibility();
            key=constraints{j}.getID;
            constraintMap(key)=constraints{j};
            if~isKey(constraintsToObjsMap,key)
                constraintsToObjsMap(key)=[];
            end
            if~isempty(failure)
                temp=constraintsToObjsMap(key);
                temp=[temp,constraints{j}];%#ok
                constraintsToObjsMap(key)=temp;
            end
        end
    end
    keys=constraintsToObjsMap.keys;


    SID={};
    for ii=1:numel(objs)
        if iscell(objs(ii))
            t=objs{ii}.getSID;
        else
            t=objs(ii).getSID;
        end
        if iscell(t)
            SID{end+1}=t{1};
        else
            SID{end+1}=t;
        end
    end
    result=true;
    if isempty(keys)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatusText(DAStudio.message('Slci:compatibility:NoSFObjectsFound',objType));
        violations{end+1}=ft;
    end
    for i=1:numel(keys)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        if isempty(constraintsToObjsMap(keys{i}))
            try
                ft.setSubTitle(DAStudio.message(['Slci:compatibility:',keys{i},'ConstraintSubTitle']));
                ft.setInformation(DAStudio.message(['Slci:compatibility:',keys{i},'ConstraintInfo']));
            catch
                assert(isKey(constraintMap,keys{i}));
                constraint=constraintMap(keys{i});
                [SubTitle,Information,~,~]=constraint.getMAStrings(true);
                ft.setSubTitle(SubTitle);
                ft.setInformation(Information);
            end
            ft.UserData.Sid=SID;
            ft.setSubResultStatus('Pass');
            if~isempty(objs)
                ft.setSubResultStatusText(DAStudio.message('Slci:compatibility:AllSFObjectsCompatible',objType));
            else
                ft.setSubResultStatusText(DAStudio.message('Slci:compatibility:NoSFObjectsFound',objType));
            end
        else
            constraints=constraintsToObjsMap(keys{i});
            [SubTitle,Information,~,~]=constraints(1).getMAStrings(true);
            try
                ft.setSubTitle(DAStudio.message(['Slci:compatibility:',keys{i},'ConstraintSubTitle']));
                ft.setInformation(DAStudio.message(['Slci:compatibility:',keys{i},'ConstraintInfo']));
            catch
                ft.setSubTitle(SubTitle);
                ft.setInformation(Information);
            end
            if false
                StatusText=DAStudio.message('Slci:compatibility:PrereqConstraintsWarn');
                RecAction='';
                for k=1:numel(failures)
                    [~,~,tempstatusText,tempRecAction]=failures(k).getMAStrings();
                    StatusText=[StatusText,' ',tempstatusText];
                    RecAction=[RecAction,' ',tempRecAction];
                end
            else
                [SubTitle,Information,StatusText,RecAction]=constraints(1).getMAStrings(false);
                ft.UserData.ID=constraints(1).getID;
                ft.UserData.Sid=constraints(1).getSID;
            end
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(StatusText);
            ft.setRecAction(RecAction);
            handle={};
            for j=1:numel(constraints)
                sid=constraints(j).getOwner().getSID;
                if isempty(sid)
                    try
                        sid=constraints(j).getOwner().getRootAstOwner.getSID;
                    catch
                    end
                end
                if~isempty(sid)
                    handle{end+1}=sid;%#ok
                end
            end
            handle=unique(handle);
            ft.setListObj(handle);
            ft.UserData.Constraint=constraints;
            result=false;
        end
        violations{end+1}=ft;%#ok
    end
    violations{1}.setSubTitle(DAStudio.message('Slci:compatibility:SFObjectsCheckSubtitle',objType));
    violations{1}.setInformation(DAStudio.message('Slci:compatibility:SFObjectsCheckDescription',objType));

    if isempty(violations)
        violations{end}.setSubBar(true);
    else
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(result);
        violations{end}.setSubBar(false);
    end
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

                    status=constraint(ih).fix(blk);
                    statusFlag=[statusFlag;status];%#ok<AGROW>


                    if~status
                        unModifiedList{end+1}=resObj{ik}.ListObj{ih};%#ok<AGROW>
                    else
                        modifiedList{end+1}=resObj{ik}.ListObj{ih};%#ok<AGROW>
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


