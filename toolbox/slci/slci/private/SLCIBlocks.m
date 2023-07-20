


function SLCIBlocks


    mlock;
    libraries={DAStudio.message('Slci:compatibility:Sources'),...
    DAStudio.message('Slci:compatibility:SignalRouting'),...
    DAStudio.message('Slci:compatibility:MathOperations'),...
    DAStudio.message('Slci:compatibility:SignalAttributes'),...
    DAStudio.message('Slci:compatibility:LogicalandBitOperations'),...
    DAStudio.message('Slci:compatibility:LookupTables'),...
    DAStudio.message('Slci:compatibility:UserDefinedFunction'),...
    DAStudio.message('Slci:compatibility:PortsandSubsystems'),...
    DAStudio.message('Slci:compatibility:Discontinuities'),...
    DAStudio.message('Slci:compatibility:Sinks'),...
    DAStudio.message('Slci:compatibility:Discrete'),...
    DAStudio.message('Slci:compatibility:Stateflow'),...
    DAStudio.message('Slci:compatibility:String'),...
    };
    mdladvRoot=ModelAdvisor.Root;
    for i=1:numel(libraries)
        ID=strrep(libraries{i},' ','');
        ID=strrep(ID,'-','');
        rec=ModelAdvisor.Check(['mathworks.slci.',ID,'BlocksUsage']);
        rec.Title=DAStudio.message('Slci:compatibility:SimulinkLibraryBlocksTitle',libraries{i});
        rec.TitleTips=DAStudio.message('Slci:compatibility:SimulinkLibraryBlocksTitleTips',libraries{i});
        rec.CSHParameters.MapKey='ma.slci';
        rec.CSHParameters.TopicID=['mathworks.slci.',ID,'BlocksUsage'];
        rec.setCallbackFcn((@(system)(CheckBlockTypes(system,libraries{i}))),'None','StyleOne');
        rec.Value=false;
        rec.SupportsEditTime=true;
        rec.LicenseName={'Simulink_Code_Inspector'};
        rec.PreCallbackHandle=@slciModel_pre;
        rec.PostCallbackHandle=@slciModel_post;
        rec.CallbackContext='PostCompile';
        rec.SupportExclusion=true;
        modifyAction=ModelAdvisor.Action;
        modifyAction.setCallbackFcn(@modifyCodeSet);
        modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
        modifyAction.Description=DAStudio.message('Slci:compatibility:BlocksModifyTip',libraries{i});
        modifyAction.Enable=false;
        rec.setAction(modifyAction);
        mdladvRoot.publish(rec,'Simulink Code Inspector');
    end
end

function ftFinalList=CheckBlockTypes(system,library)

    if~strcmpi(library,'MatlabFunction')
        blockTypes=lookupBlocks(library);
        ftFinalList=iterateBlocks(system,blockTypes);
    end
end


function blockTypes=lookupBlocks(library)
    [libraries,blocktype]=slci.compatibility.blockSupportedList;
    blockLookup=containers.Map(libraries,blocktype);
    blockTypes=blockLookup(library);
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
                obj=constraint.getOwner;
                for ih=1:numel(resObj{ik}.ListObj)
                    sid=resObj{ik}.ListObj{ih};
                    obj.setSID(sid);

                    status=constraint.fix();
                    statusFlag=[statusFlag;status];%#ok<AGROW>

                    if~status
                        unModifiedList{end+1}=sid;%#ok<AGROW>
                    else
                        modifiedList{end+1}=sid;%#ok<AGROW>
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

