function compInfo=utilGetDelayBlocks(model)



    compInfo={};

    DelayLengthThreshold=10;
    SizeThreshold=1000;



    orig_list=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','Delay','UseCircularBuffer','off');


    if isempty(orig_list)
        return;
    end

    list={};
    for i=1:length(orig_list)
        blk=orig_list{i};
        if(strcmp(get_param(blk,'InputProcessing'),'Elements as channels (sample based)'))
            list{end+1}=orig_list{i};
        else
            if(strcmp(get_param(blk,'InputProcessing'),'Inherited'))
                list{end+1}=orig_list{i};
            end
        end
    end


    if isempty(list)
        return;
    end




    blkName=struct('BlockName','');
    retVal={};
    for i=1:length(list)
        blk=list{i};

        isSample=true;
        if(strcmp(get_param(blk,'InputProcessing'),'Inherited'))
            p=get_param(blk,'CompiledPortFrameData');
            isSample=~p.Outport;
        end


        if(isSample)
            p=get_param(blk,'CompiledPortWidths');
            width=p.Outport;

            if(strcmp(get_param(blk,'DelayLengthSource'),'Dialog'))
                dLen=slResolve(get_param(blk,'DelayLength'),blk,'expression');
            else
                dLen=slResolve(get_param(blk,'DelayLengthUpperLimit'),blk,'expression');
            end

            if((dLen>=DelayLengthThreshold)&&((dLen*width)>=SizeThreshold))
                blkName.BlockName=blk;
                retVal{end+1}=blkName;
            end
        end

    end
    compInfo=retVal;
end

