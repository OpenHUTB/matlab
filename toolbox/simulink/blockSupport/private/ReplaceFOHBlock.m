function ReplaceFOHBlock(blk,h)





    if askToReplace(h,blk)
        sys=getContext(h);
        warnNoReplace=DAStudio.message('SimulinkUpgradeEngine:engine:warnBeforeBlockReplaceFOH',sys);
        funcSet=uReplaceBlock(h,blk,'built-in/FirstOrderHold');
        appendTransaction(h,blk,warnNoReplace,{funcSet});
    end

end
