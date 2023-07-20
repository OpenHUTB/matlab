function val=getColumns(h)



















    [SAME_AS_COLS,BPS_COLS,SBS_COLS,USER_NAMED_COLS,INT_COLS]=deal(0,14,54,55,6);

    untranslatedEntries=h.Block.getPropAllowedValues([h.Prefix,'Mode']);
    modeString=untranslatedEntries{h.Mode+1};

    switch(modeString)
    case 'Binary point scaling'
        val=BPS_COLS;
    case 'Slope and bias scaling'
        val=SBS_COLS;
    otherwise
        val=SAME_AS_COLS;
    end


