function UpdateFimath(block,hb,h,slMsgName)







    FoldStr=hb.InputFimath;
    expFoldStr=['fimath(...',10...
    ,'''RoundMode'', ''floor'',...',10...
    ,'''OverflowMode'', ''wrap'',...',10...
    ,'''ProductMode'', ''KeepLSB'', ''ProductWordLength'', 32,...',10...
    ,'''SumMode'', ''KeepLSB'', ''SumWordLength'', 32,...',10...
    ,'''CastBeforeSum'', false)'];
    FnewStr=['fimath(...',10...
    ,'''RoundMode'', ''floor'',...',10...
    ,'''OverflowMode'', ''wrap'',...',10...
    ,'''ProductMode'', ''KeepLSB'', ''ProductWordLength'', 32,...',10...
    ,'''SumMode'', ''KeepLSB'', ''SumWordLength'', 32,...',10...
    ,'''CastBeforeSum'', true)'];

    if strcmpi(FoldStr,expFoldStr)
        if askToReplace(h,block);

            reason=DAStudio.message(slMsgName,h.cleanLocationName(block));
            if(doUpdate(h))
                hb.InputFimath=FnewStr;
            end
            appendTransaction(h,block,reason,{{'set',hb,'InputFimath',FnewStr}});
        end
    end

end
