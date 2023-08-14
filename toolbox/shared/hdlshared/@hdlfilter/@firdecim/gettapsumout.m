function[tempbody,tempsignals]=gettapsumout(this,input1,input2,output,sym)





    rmode=this.Roundmode;
    [tapsumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [tapsumsaturation]=deal(omode);

    if strcmpi(sym,'symmetric')
        [tempbody,tempsignals]=hdlfilteradd(input1,input2,output,...
        tapsumrounding,tapsumsaturation);
    elseif strcmpi(sym,'antisymmetric')
        [tempbody,tempsignals]=hdlfiltersub(input1,input2,output,...
        tapsumrounding,tapsumsaturation);
    end





