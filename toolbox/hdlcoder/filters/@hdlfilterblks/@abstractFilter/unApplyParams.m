function unApplyParams(this,pvvalues)







    for n=1:2:length(pvvalues)
        if~isempty(pvvalues{n})
            hdlsetparameter(pvvalues{n},pvvalues{n+1})
        end
    end


