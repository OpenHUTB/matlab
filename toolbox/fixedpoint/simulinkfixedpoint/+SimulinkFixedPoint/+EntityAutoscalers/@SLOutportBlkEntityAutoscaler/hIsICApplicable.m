function y=hIsICApplicable(~,blkObj)





    y=false;

    parentObj=blkObj.getParent;

    parentH=parentObj.Handle;





    blkTypes={'TriggerPort','EnablePort','ActionPort',...
    'WhileIterator','ForIterator'};

    for i=1:length(blkTypes)
        blk=find_system(parentH,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'BlockType',blkTypes{i});
        if~isempty(blk)
            y=true;
            return;
        end
    end

