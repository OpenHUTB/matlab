function styleguide_db_0110





    rec=ModelAdvisor.Check('mathworks.maab.db_0110');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0110Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0110Tip');
    rec.setCallbackFcn(@db_0110_StyleOneCallback,'None','DetailStyle');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0110Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='all';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});


    function db_0110_StyleOneCallback(system,CheckObj)

        feature('scopedaccelenablement','off');

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);

        failedHdls=CheckTunableExpressions(mdladvObj,system);
        failedHdls=unique(failedHdls);


        failedHdls=mdladvObj.filterResultWithExclusion(failedHdls);


        if(isempty(failedHdls))

            mdladvObj.setCheckResultStatus(true);
            ElementResults=Advisor.Utils.createResultDetailObjs('',...
            'IsViolation',false,...
            'Description',DAStudio.message('ModelAdvisor:styleguide:db_0110_Info'),...
            'Status',DAStudio.message('ModelAdvisor:styleguide:db0110Pass'));

        else

            text=ModelAdvisor.Text();
            text.setContent(DAStudio.message('ModelAdvisor:styleguide:db0110FailFix_0'));
            subList=ModelAdvisor.List();
            setType(subList,'bulleted');
            addItem(subList,DAStudio.message('ModelAdvisor:styleguide:db0110FailFix_1'));
            addItem(subList,DAStudio.message('ModelAdvisor:styleguide:db0110FailFix_2'));
            addItem(subList,DAStudio.message('ModelAdvisor:styleguide:db0110FailFix_3'));

            mdladvObj.setCheckResultStatus(false);
            ElementResults=Advisor.Utils.createResultDetailObjs(failedHdls,...
            'Description',DAStudio.message('ModelAdvisor:styleguide:db_0110_Info'),...
            'Status',DAStudio.message('ModelAdvisor:styleguide:db0110Fail'),...
            'RecAction',[text.emitHTML,subList.emitHTML]);

        end
        CheckObj.setResultDetails(ElementResults);

        function failed=CheckTunableExpressions(mdladvObj,system)
            failed=[];


































            followlinkParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
            lookundermaskParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');



            allBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',followlinkParam.Value,'LookUnderMasks',lookundermaskParam.Value,'FindAll','off','Type','block');
            bObjs=get_param(allBlocks,'Object');


            for i=1:length(allBlocks)
                tunableProps=Advisor.Utils.Simulink.getTunableProperties(bObjs{i}.BlockType);


                for j=1:length(tunableProps)
                    propValue=bObjs{i}.(tunableProps{j});
                    mId='([a-zA-Z_]\w*)';
                    Ident=regexp(propValue,mId,'match');
                    if(~isempty(Ident))


                        mIdOnly='^\s*[a-zA-Z_]\w*\s*$';
                        matchIdx=regexp(strrep(propValue,'.',''),mIdOnly);%#ok<RGXP1>
                        if(isempty(matchIdx))








                            for k=1:length(Ident)
                                inGlobalScope=existsInGlobalScope(bdroot(system),Ident{k});
                                if(inGlobalScope)
                                    failed(end+1)=bObjs{i}.Handle;%#ok<AGROW>
                                    break;
                                else
                                    mdlWS=get_param(bdroot(system),'ModelWorkspace');
                                    if(~isempty(mdlWS))
                                        inMdlWS=mdlWS.whos;

                                        if find(strcmp({inMdlWS.name},Ident{k}))
                                            failed(end+1)=bObjs{i}.Handle;%#ok<AGROW>
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end


