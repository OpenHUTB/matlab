function setCommonSOSSettings(this,hS)




    this.Coefficients=hS.SOSMatrix;

    ord=secorder(this,hS);
    this.SectionOrder=ord;

    numSec=length(ord);
    this.NumSections=numSec;

    len=length(hS.ScaleValues);

    if len==numSec+1
        this.ScaleValues=hS.ScaleValues;
    else
        this.ScaleValues=[hS.ScaleValues;ones(numSec,1)];
    end

    this.CastBeforeSum=true;

end

