function arithShiftBlock(obj)








    if isR2010bOrEarlier(obj.ver)
        ashiftBlks=obj.findBlocksOfType('ArithShift');

        if~isempty(ashiftBlks)

            for i=1:numel(ashiftBlks)



                set_param(ashiftBlks{i},'BitShiftNumberSource','Dialog');
            end

            obj.replaceWithLibraryLink(ashiftBlks,'simulink/Logic and Bit\nOperations/Shift\nArithmetic',...
            {'nBitShiftRight','nBitShiftRight';...
            'nBinPtShiftRight','nBinPtShiftRight'});
        end

    end






