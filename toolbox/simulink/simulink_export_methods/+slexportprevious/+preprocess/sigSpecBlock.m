function sigSpecBlock(obj)







    if isR2010aOrEarlier(obj.ver)
        sigSpecBlocks=slexportprevious.utils.findBlockType(obj.modelName,'SignalSpecification');

        if~isempty(sigSpecBlocks)
            for i=1:length(sigSpecBlocks)
                blk=sigSpecBlocks{i};

                dt=get_param(blk,'OutDataTypeStr');

                if contains(dt,'Bus: ')
                    set_param(blk,'OutDataTypeStr','Inherit: auto');
                end
            end
        end


        removeBTPrm=slexportprevious.rulefactory.removeInBlockType('BusOutputAsStruct','SignalSpecification');
        obj.appendRule(removeBTPrm);
    end
