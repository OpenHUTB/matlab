function[rnd,ofmode]=conv2hdlroundoverflow(this)




    if strcmpi(this.arithmetic,'fixed')
        rnd=get(this,'RoundMode');
        if this.overflowmode
            ofmode='saturate';
        else
            ofmode='wrap';
        end
    else
        rnd='floor';
        ofmode=false;
    end


