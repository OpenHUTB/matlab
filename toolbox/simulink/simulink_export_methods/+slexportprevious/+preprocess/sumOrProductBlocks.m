function sumOrProductBlocks(obj)







    if isR2006bOrEarlier(obj.ver)

        types={'Sum','Product'};
        for idx=1:length(types)
            blockType=types{idx};

            sumBlks=slexportprevious.utils.findBlockType(obj.modelName,blockType);

            for i=1:length(sumBlks)
                blk=sumBlks{i};
                mode=get_param(blk,'CollapseMode');
                if isequal(blockType,'Product')
                    elemwise=isequal(get_param(blk,'Multiplication'),'Element-wise(.*)');
                else
                    elemwise=true;
                end

                ports=get_param(blk,'Ports');
                numInps=ports(1);



                if numInps==1&&elemwise&&isequal(mode,'Specified dimension')









                    obj.replaceWithEmptySubsystem(blk);
                end

            end
        end
    end

