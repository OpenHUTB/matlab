function[inprate,outprate]=gettbclkrate(this)%#ok












    inprate=ceil(this.InterpolationFactor/this.DecimationFactor);
    outprate=1;

