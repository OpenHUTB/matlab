function Replace2DTableLookup(block,h)





    if askToReplace(h,block)


        entries=GetMaskEntries(block);
        RowIndex=entries{1};
        ColumnIndex=entries{2};
        OutputValues=entries{3};

        libBlock=sprintf('built-in/Lookup2D');

        funcSet=uReplaceBlock(h,block,libBlock,'x',RowIndex,'y',ColumnIndex,'t',OutputValues);
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
