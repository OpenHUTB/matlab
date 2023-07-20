function[tempbody,tempsignals]=gettapsumout(this,input1,input2,output)





    rmode=this.Roundmode;
    [tapsumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [tapsumsaturation]=deal(omode);


    [tempbody,tempsignals]=hdlfilteradd(input1,input2,output,...
    tapsumrounding,tapsumsaturation);


