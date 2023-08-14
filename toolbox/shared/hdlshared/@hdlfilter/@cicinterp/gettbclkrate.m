function[inprate,outprate]=gettbclkrate(this)







    if hdlgetparameter('RateChangePort')
        tbinprate=resolveTBRateStimulus(this);
    else
        tbinprate=this.InterpolationFactor;
    end
    inprate=tbinprate*hdlgetparameter('foldingfactor');
    outprate=hdlgetparameter('foldingfactor')/inprate;

