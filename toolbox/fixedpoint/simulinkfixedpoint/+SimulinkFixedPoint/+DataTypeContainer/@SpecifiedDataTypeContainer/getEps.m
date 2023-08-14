function epsVal=getEps(this)





    if(~this.isEpsCalculated)
        this.calculateEps;
    end
    epsVal=this.eps;
end