function styleguide_db_0081




    rec=ModelAdvisor.Check('mathworks.maab.db_0081');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0081Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0081Tip');
    rec.setCallbackFcn(@db_0081_StyleOneCallback,'None','DetailStyle');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0081Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='all';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);

end

function db_0081_StyleOneCallback(system,CheckObj)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    [resultData]=getCheckInformation(mdladvObj,system);

    CheckObj.setResultDetails(updateMdladvObj(mdladvObj,resultData));
end

function ElementResults=updateMdladvObj(mdladvObj,resultData)
    feature('scopedaccelenablement','off');
    if(isempty(resultData.badBlocks))
        mdladvObj.setCheckResultStatus(true);
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:db_0081_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:db0081PassMsg'));
    else

        mdladvObj.setCheckResultStatus(false);
        ElementResults=Advisor.Utils.createResultDetailObjs(resultData.badBlocks,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:db_0081_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:db0081FailMsg'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:db0081FailMsgFix'));
    end
end

function[resultData]=getCheckInformation(mdladvObj,system)
    followlinkParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');




    blks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',followlinkParam.Value,...
    'LookUnderMasks',lookundermaskParam.Value,...
    'type','block');

    portcon=get_param(blks,'PortConnectivity');
    ports=get_param(blks,'Ports');





    numBlks=length(blks);
    resultData.failedBlocks={};
    resultData.badBlocks={};
    for inx=1:numBlks
        for jnx=1:ports{inx}(1)
            if(portcon{inx}(jnx).SrcBlock==-1)
                resultData.failedBlocks{end+1}=blks{inx};
            end
        end

        for jnx=1:ports{inx}(2)
            lh=get_param(blks{inx},'LineHandles');
            if(lh.Outport(jnx)==-1)
                resultData.failedBlocks{end+1}=blks{inx};
            else






                allsinks=get_param(lh.Outport(jnx),'DstPortHandle');

                if(isempty(allsinks)==0)&&(isempty(find(allsinks==-1))==0)
                    resultData.failedBlocks{end+1}=blks{inx};
                end
            end
        end
    end
    resultData.failedBlocks=unique(resultData.failedBlocks);

    resultData.failedBlocks=mdladvObj.filterResultWithExclusion(resultData.failedBlocks);

    ignorePortsInVariantBlock=[];
    for i=1:length(resultData.failedBlocks)
        parent=get_param(resultData.failedBlocks{i},'Parent');
        objParams=get_param(parent,'ObjectParameters');
        if(isfield(objParams,'BlockType')&&strcmpi(get_param(parent,'BlockType'),'SubSystem')&&strcmpi(get_param(parent,'Variant'),'on'))
            ignorePortsInVariantBlock=[ignorePortsInVariantBlock,i];%#ok<AGROW>
        end
    end
    for i=1:length(resultData.failedBlocks)
        if isempty(find(ignorePortsInVariantBlock==i))
            resultData.badBlocks{end+1}=resultData.failedBlocks{i};
        end
    end
end
