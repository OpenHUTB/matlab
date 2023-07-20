function triggerBlock(obj)








    if isR2009bOrEarlier(obj.ver)
        blks=find_system(obj.modelName,'SearchDepth',1,'BlockType','TriggerPort');
        if~isempty(blks)

            assert(length(blks)==1);
            blk=blks{1};

            doReplacement=false;

            trigType=get_param(blk,'TriggerType');
            switch(trigType)
            case 'function-call'
                doReplacement=false;

            case{'rising','falling','either'}
                doReplacement=true;

            otherwise
                assert(0,'Unknown trigger type');
            end

            if doReplacement
                obj.replaceWithEmptySubsystem(blk);
            end
        end
    end
