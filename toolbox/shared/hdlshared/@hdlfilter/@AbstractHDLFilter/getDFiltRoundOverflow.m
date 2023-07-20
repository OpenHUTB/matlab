function[rmode,omode]=getDFiltRoundOverflow(this)




    rmode=this.RoundMode;
    if this.OverflowMode
        omode='saturate';
    else
        omode='wrap';
    end



