function styleguide_jc_0131()










    rec=ModelAdvisor.Check('mathworks.maab.jc_0131');
    rec.Title=DAStudio.message(['ModelAdvisor:styleguide:'...
    ,'jc0131Title']);
    rec.TitleTips=DAStudio.message(['ModelAdvisor:styleguide:'...
    ,'jc0131Tip']);
    rec.setCallbackFcn(@jc_0131_Callback,'None','DetailStyle');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0131Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end






function jc_0131_Callback(system,CheckObj)

    feature('scopedaccelenablement','off');

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);

    followlinkParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.LookUnderMasks');

    bResultStatus=true;




    searchResult=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',followlinkParam.Value,...
    'LookUnderMasks',lookundermaskParam.Value,...
    'BlockType','RelationalOperator');

    if isempty(searchResult)
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:jc0131CheckDesc'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0131NoRelopBlocks'));

    else
        relopBlks={};
        for i=1:length(searchResult)
            c1=false;
            c2=false;
            obj=get_param(searchResult{i},'Object');
            if(length(obj.linehandles.Inport)==2)
                if obj.linehandles.Inport(1)~=-1
                    lh1=get_param(obj.linehandles.Inport(1),'Object');
                    if lh1.SrcBlockHandle~=-1
                        srcBlkType=getSourceBlock(lh1.SrcBlockHandle);
                        c1=strcmpi(srcBlkType,'Constant');
                    end
                end
                if(obj.linehandles.Inport(2)~=-1)
                    lh2=get_param(obj.linehandles.Inport(2),'Object');
                    if lh2.SrcBlockHandle~=-1
                        srcBlkType=getSourceBlock(lh2.SrcBlockHandle);
                        c2=strcmpi(srcBlkType,'Constant');
                    end
                end


                if c1&&~c2
                    relopBlks{end+1}=searchResult{i};%#ok<AGROW>
                end
            end
        end

        relopBlks=modelAdvisorObject.filterResultWithExclusion(relopBlks);

        bResultStatus=isempty(relopBlks);
        if bResultStatus
            ElementResults=Advisor.Utils.createResultDetailObjs('',...
            'IsViolation',false,...
            'Description',DAStudio.message('ModelAdvisor:styleguide:jc0131CheckDesc'),...
            'Status',DAStudio.message('ModelAdvisor:styleguide:jc0131relopConstLocationCorrect'));
        else
            ElementResults=Advisor.Utils.createResultDetailObjs(relopBlks,...
            'Description',DAStudio.message('ModelAdvisor:styleguide:jc0131CheckDesc'),...
            'Status',DAStudio.message('ModelAdvisor:styleguide:jc0131relopConstLocation'),...
            'RecAction',DAStudio.message('ModelAdvisor:styleguide:jc0131_RecAct'));
        end
    end

    modelAdvisorObject.setCheckResultStatus(bResultStatus);
    CheckObj.setResultDetails(ElementResults);
end


function srcBlkType=getSourceBlock(srcBlkHndle)
    tempSrcBlkHndle=srcBlkHndle;
    while(strcmp('through',get_param(tempSrcBlkHndle,'Commented')))
        LineHandles=get_param(tempSrcBlkHndle,'LineHandles');
        InportHandle=LineHandles.Inport;
        if(InportHandle~=-1)
            tempSrcBlkHndle=get_param(InportHandle,'SrcBlockHandle');
        else
            break
        end
    end
    srcBlkType=get_param(tempSrcBlkHndle,'BlockType');
end
