function[rnd,ofmode]=conv2hdlroundoverflow(this)






    rnd=get(this,'RoundMode');
    if this.overflowmode
        ofmode='saturate';
    else
        ofmode='wrap';
    end


