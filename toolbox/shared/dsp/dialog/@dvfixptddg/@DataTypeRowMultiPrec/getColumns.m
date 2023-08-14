function val=getColumns(this)




















    [SAME_AS_COLS,BPS_COLS,SBS_COLS,WL_COLS]=deal(0,14,54,6);

    untranslatedEntries=this.Block.getPropAllowedValues([this.Prefix,'Mode']);
    modeString=untranslatedEntries{this.Mode+1};

    switch(modeString)
    case 'Same word length as input'
        val=SAME_AS_COLS;
    case 'Specify word length'
        val=WL_COLS;
    case 'Binary point scaling'
        val=BPS_COLS;
    case 'Slope and bias scaling'
        val=SBS_COLS;
    otherwise
        val=SAME_AS_COLS;
    end
