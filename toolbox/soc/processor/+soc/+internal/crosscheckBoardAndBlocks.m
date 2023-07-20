function crosscheckBoardAndBlocks(modelName)




    boardName=get_param(modelName,'HardwareBoard');



    blocksAndCompatibleBoards={
    {'Audio Capture','Audio Playback','Video Capture','Video Display'},{'Embedded Linux Board'};
    {'Interprocess Data Write','Interprocess Data Read'},{'TI Delfino F28379D LaunchPad','TI Delfino F2837xD','TI F2838xD (SoC)'}
    };


    [nRows,~]=size(blocksAndCompatibleBoards);

    for iRow=1:nRows
        blocks=blocksAndCompatibleBoards{iRow,1};
        boards=blocksAndCompatibleBoards{iRow,2};
        for iBlks=1:numel(blocks)
            thisBlkMaskType=blocks{iBlks};


            blk=find_system(modelName,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FindAll','on','MaskType',thisBlkMaskType);
            if~isempty(blk)
                if~ismember(boardName,boards)
                    error(message('codertarget:peripherals:IncompatibleBlocks',thisBlkMaskType,boardName));
                end
            end
        end
    end

end
