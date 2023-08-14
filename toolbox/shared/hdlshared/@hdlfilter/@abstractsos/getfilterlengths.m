function fl=getfilterlengths(this)




    uff=this.getHDLParameter('userspecified_foldingfactor');
    mults=this.getHDLParameter('filter_nummultipliers');

    if(mults==-1)
        [~,ffactor]=this.getSerialPartForFoldingFactor('foldingfactor',uff);
    else
        [~,ffactor]=this.getSerialPartForFoldingFactor('multipliers',mults);
    end
    fl=ffactor;


