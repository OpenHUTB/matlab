function[inprate,outprate]=gettbclkrate(this)%#ok












    inprate=ceil(this.RateChangeFactors(1)/this.RateChangeFactors(2));
    outprate=1;

