function selectorBlocks(obj)








    if isR2009aOrEarlier(obj.ver)
        selectorBlks=slexportprevious.utils.findBlockType(obj.modelName,'Selector');

        for i=1:length(selectorBlks)
            blk=selectorBlks{i};
            optCell=get_param(blk,'IndexOptionArray');
            newOptUsed=strcmp('Starting and ending indices (port)',optCell);
            if any(newOptUsed)
                optCell(newOptUsed)={'Index vector (port)'};
                set_param(blk,'IndexOptionArray',optCell);
            end
        end
    end

    if isR2006bOrEarlier(obj.ver)


        assignmentBlks=slexportprevious.utils.findBlockType(obj.modelName,'Assignment');

        if~isempty(selectorBlks)||~isempty(assignmentBlks)

            tempModel=obj.getTempMdl;
            selList={'Select all','Assign all'};
            blockTypeList={'Selector','Assignment'};
            blkLists={selectorBlks,assignmentBlks};
            for idx=1:length(blkLists)
                for i=1:length(blkLists{idx})
                    blk=blkLists{idx}{i};

                    numDims=str2double(get_param(blk,'NumberOfDimensions'));
                    idxOpts=get_param(blk,'IndexOptionArray');
                    sampleTime=get_param(blk,'SampleTime');
                    orient=get_param(blk,'Orientation');
                    pos=get_param(blk,'Position');

                    blankBlk=true;

                    if~isnan(numDims)&&length(numDims)==1&&floor(numDims)==numDims&&(eval(sampleTime)==-1||isequal(blockTypeList{idx},'Assignment'))
                        if numDims==1













                            if length(idxOpts)==1&&~isequal(idxOpts{1},'Starting and ending indices (port)')
                                blankBlk=false;
                            end
                        elseif numDims==2
                            if length(idxOpts)==2&&~isequal(idxOpts{1},'Starting and ending indices (port)')&&~isequal(idxOpts{2},'Starting and ending indices (port)')
                                if isequal(idxOpts{1},selList{idx})||isequal(idxOpts{2},selList{idx})
                                    blankBlk=false;
                                elseif isequal(idxOpts{1},'Index vector (dialog)')||isequal(idxOpts{1},'Index vector (port)')
                                    switch idxOpts{2}
                                    case{'Index vector (dialog)','Index vector (port)'}
                                        blankBlk=false;
                                    end
                                elseif isequal(idxOpts{1},'Starting index (dialog)')||isequal(idxOpts{1},'Starting index (port)')
                                    switch idxOpts{2}
                                    case{'Starting index (dialog)','Starting index (port)'}
                                        blankBlk=false;
                                    end
                                end
                            end
                        end
                    end

                    if~blankBlk
                        if isInVersionInterval(obj.ver,'R2006a','R2006b')
                            obj.appendRule(i_getrule(blk,'InputType'));
                            obj.appendRule(i_getrule(blk,'ElementSrc'));
                            obj.appendRule(i_getsidrule(blk,'Elements'));
                            obj.appendRule(i_getrule(blk,'RowSrc'));
                            obj.appendRule(i_getsidrule(blk,'Rows'));
                            obj.appendRule(i_getrule(blk,'ColumnSrc'));
                            obj.appendRule(i_getsidrule(blk,'Columns'));
                            obj.appendRule(i_getrule(blk,'IndexIsStartValue'));
                            if idx==1
                                obj.appendRule(i_getrule(blk,'OutputPortSize'));
                            elseif idx==2
                                obj.appendRule(i_getrule(blk,'OutputDimensions'));
                            end
                        end
                    else
                        obj.replaceWithEmptySubsystem(blk);
                    end
                end
            end

        end
    end
end

function str=i_getrule(block,param)
    identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(block);
    str=slexportprevious.rulefactory.addParameterToBlock(identifyBlock,param,...
    get_param(block,param));
end

function str=i_getsidrule(block,param)
    identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(block);
    str=slexportprevious.rulefactory.addParameterToBlock(identifyBlock,param,...
    slexportprevious.utils.escapeSIDFormat(get_param(block,param)));
end
