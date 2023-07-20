function ReplaceGraphScope(block,h)






    if askToReplace(h,block)
        oldEntries=GetMaskEntries(block);
        CheckEntries(block,oldEntries,4);

        TimeRange=oldEntries{1};
        Ymin=oldEntries{2};
        Ymax=oldEntries{3};


        funcSet=uReplaceBlock(h,block,'built-in/Scope',...
        'TimeRange',TimeRange,...
        'YMin',Ymin,'YMax',Ymax);

        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
