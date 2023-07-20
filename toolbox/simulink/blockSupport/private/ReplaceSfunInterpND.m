function ReplaceSfunInterpND(block,h)






    if~doUpdate(h)

        reason=DAStudio.message('SimulinkBlocks:upgrade:SFunInterpND');
        appendTransaction(h,block,reason,{});
    end


end
