function ReplaceSfunPrelookup(block,h)






    if~doUpdate(h)

        reason=DAStudio.message('SimulinkBlocks:upgrade:SFunPrelookup');
        appendTransaction(h,block,reason,{});
    end

end
