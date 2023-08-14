function stringBlocks(obj)




    if isReleaseOrEarlier(obj.ver,'R2019b')
        blkTypeR2019b={'StringCount','StringContains'};
        for i=1:numel(blkTypeR2019b)
            allBlksOfAType=slexportprevious.utils.findBlockType(obj.modelName,blkTypeR2019b{i});
            obj.replaceWithEmptySubsystem(allBlksOfAType);
        end



        stringLengthFindBlocks=[slexportprevious.utils.findBlockType(obj.modelName,'StringLength');...
        slexportprevious.utils.findBlockType(obj.modelName,'StringFind')];
        if(~isempty(stringLengthFindBlocks))
            for i=1:length(stringLengthFindBlocks)
                blk=stringLengthFindBlocks{i};
                if strcmp(get_param(blk,'OutDataTypeStr'),'Inherit: Inherit via internal rule')~=1
                    obj.replaceWithEmptySubsystem(blk);
                end
            end
        end
    end

    if isReleaseOrEarlier(obj.ver,'R2018b')
        obj.appendRule('<Block<BlockType|StringToASCII><OutputVectorSize:rename MaximumLength>>');
    end

    if isReleaseOrEarlier(obj.ver,'R2017b')
        blkTypeR2017b={'StringConstant','StringLength','ASCIIToString','ComposeString',...
        'ScanString','Substring','StringFind','ToString',...
        'StringToDouble','StringToASCII','StringCompare','StringToEnum',...
        'StringConcatenate'};
        for i=1:numel(blkTypeR2017b)
            allBlksOfAType=slexportprevious.utils.findBlockType(obj.modelName,blkTypeR2017b{i});
            obj.replaceWithEmptySubsystem(allBlksOfAType);

        end

    end
end

