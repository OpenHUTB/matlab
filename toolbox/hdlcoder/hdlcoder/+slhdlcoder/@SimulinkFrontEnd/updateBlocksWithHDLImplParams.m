
function updateBlocksWithHDLImplParams(this,startNodeName,configManager,blkFn)




    blockList=find_system(startNodeName,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'SearchDepth',1);


    blockList(strmatch(startNodeName,startNodeName,'exact'))=[];

    blockHandles=get_param(blockList,'Handle');
    blockHandles=cell2mat(blockHandles);
    blockInfo=classifyblocks(this,blockHandles,false);

    blocks=blockInfo.OtherBlocks;

    for k=1:length(blocks)
        slbh=blocks(k);

        blkPath=getfullname(slbh);
        typ=get_param(blkPath,'BlockType');

        switch typ
        case 'SubSystem'

            if~isempty(blkPath)
                impl=configManager.getImplementationForBlock(blkPath);
                donotrecurse=this.isAFrontEndStopSubsystem(impl,blkPath);

                if strcmp(get_param(blkPath,'Permissions'),'ReadOnly')
                    continue;
                end
                if donotrecurse
                    blkFn(this,slbh,configManager);
                else

                    blkFn(this,slbh,configManager);
                    updateBlocksWithHDLImplParams(this,blkPath,configManager,blkFn);
                end
            end

        otherwise

            blkFn(this,slbh,configManager);
        end
    end
end


