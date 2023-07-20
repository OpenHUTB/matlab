function violations=checkSignalLabels(system)




    violations=[];

    buscreator_outputs='off';

    feature('scopedaccelenablement','off');

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    inputParams=mdladvObj.getInputParameters;
    outBlockTypes=inputParams{2}.Value;
    inBlockTypes=inputParams{3}.Value;
    followlinkParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');

    allBlocks=getBlocksOfTypes(system,outBlockTypes,followlinkParam.Value,lookundermaskParam.Value);
    allBlocks=mdladvObj.filterResultWithExclusion(allBlocks);

    ports=get_param(allBlocks,'Ports');
    parents=get_param(allBlocks,'Parent');

    for i=1:length(allBlocks)
        lh=get_param(allBlocks{i},'LineHandles');
        bt=get_param(allBlocks{i},'BlockType');
        try
            mt=slprivate('is_stateflow_based_block',parents{i});
        catch
            mt=0;
        end
        for j=1:ports{i}(2)
            if(lh.Outport(j)~=-1)
                allsinks=get_param(lh.Outport(j),'DstPortHandle');
                hiliteHandle=get_param(lh.Outport(j),'SrcPortHandle');
                if(isempty(allsinks)~=0)||(isempty(find(allsinks==-1,1))~=0)
                    lh_obj=get_param(lh.Outport(j),'Object');
                    if isempty(lh_obj.Name)&&(~mt)
                        switch bt
                        case 'From'
                            if strcmp(get_param(allBlocks{i},'IconDisplay'),'Tag')==1&&...
                                strcmp(lh_obj.signalPropagation,'off')==1
                                vObj=ModelAdvisor.ResultDetail;
                                ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                                vObj.Title=DAStudio.message('ModelAdvisor:styleguide:na_0008_subtitle1');
                                violations=[violations;vObj];%#ok<AGROW>
                            end

                        case 'DataStoreRead'


                        case 'Constant'


                            Value=get_param(allBlocks{i},'Value');
                            if~isnan(str2double(Value))||isConstBlockTruncated(allBlocks{i})
                                vObj=ModelAdvisor.ResultDetail;
                                ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                                vObj.Title=DAStudio.message('ModelAdvisor:styleguide:na_0008_subtitle1');
                                violations=[violations;vObj];%#ok<AGROW>
                            end

                        case 'BusSelector'


                        otherwise

                            if strcmp(bt,'Inport')
                                buscreator_outputs=get_param(allBlocks{i},'IsBusElementPort');
                            end

                            if strcmp(lh_obj.signalPropagation,'off')==1&&~strcmp(buscreator_outputs,'on')
                                vObj=ModelAdvisor.ResultDetail;
                                ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                                vObj.Title=DAStudio.message('ModelAdvisor:styleguide:na_0008_subtitle1');
                                violations=[violations;vObj];%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
    end

    allBlocks=getBlocksOfTypes(system,inBlockTypes,followlinkParam.Value,lookundermaskParam.Value);
    allBlocks=mdladvObj.filterResultWithExclusion(allBlocks);

    parents=get_param(allBlocks,'Parent');
    ports=get_param(allBlocks,'Ports');


    for i=1:length(allBlocks)
        lh=get_param(allBlocks{i},'LineHandles');
        try
            mt=slprivate('is_stateflow_based_block',parents{i});
        catch
            mt=0;
        end
        for j=1:ports{i}(1)
            if lh.Inport(j)~=-1
                allsources=get_param(lh.Inport(j),'SrcPortHandle');
                hiliteHandle=get_param(lh.Inport(j),'DstPortHandle');
                if(isempty(allsources)~=0)||(isempty(find(allsources==-1,1))~=0)
                    lh_obj=get_param(lh.Inport(j),'Object');
                    if isempty(lh_obj.Name)&&(~mt)


                        if strcmp(lh_obj.signalPropagation,'off')==1


                            allsources_parent=get_param(allsources,'Parent');


                            if strcmp(get_param(allsources_parent,'BlockType'),'Inport')
                                buscreator_outputs=get_param(allsources_parent,'IsBusElementPort');
                            else
                                buscreator_outputs='off';
                            end
                            if~strcmp(buscreator_outputs,'on')
                                vObj=ModelAdvisor.ResultDetail;
                                ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
                                vObj.Title=DAStudio.message('ModelAdvisor:styleguide:na_0008_subtitle2');
                                violations=[violations;vObj];%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
    end
end


function retblks=getBlocksOfTypes(system,blkTypes,followLink,lookunderMask)
    retblks={};
    for i=1:size(blkTypes,1)


        blocks=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followLink,...
        'LookUnderMasks',lookunderMask,...
        'FindAll','off',...
        'Type','block',...
        'BlockType',blkTypes{i,1},...
        'MaskType',blkTypes{i,2});
        retblks=[retblks;blocks];%#ok<AGROW>
    end

    retblks=retblks(cellfun(@(x)~Advisor.Utils.isChildOfShippingBlock(x),retblks));
end

function bResult=isConstBlockTruncated(block)
    Value=get_param(block,'Value');
    pos=get_param(block,'position');
    blockH=get_param(block,'handle');
    rt=SLM3I.Util.getDiagram(get_param(blockH,'parent'));
    blkm3i=SLM3I.SLDomain.handle2DiagramElement(blockH);
    size=slcheck.utils.getBlockTextSize(blkm3i,Value);
    bResult=abs(pos(3)-pos(1))<size(3);
end
