function ReplaceCloseFcnWithEmptyStr(block,h)








    if askToReplace(h,block)
        funcSet=uSafeSetParam(h,block,'CloseFcn','');
        reasonStr=DAStudio.message('SimulinkBlocks:upgrade:fromBlockCloseFcnCallback');
        appendTransaction(h,block,reasonStr,{funcSet});
    end

end
