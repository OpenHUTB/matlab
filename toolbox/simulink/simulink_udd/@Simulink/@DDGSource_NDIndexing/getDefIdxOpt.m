function idxopt=getDefIdxOpt(this)




    block=this.getBlock;
    lstIdxOptsForDefVal=block.getPropAllowedValues('IdxOptString');

    idxopt=lstIdxOptsForDefVal{2};

end
