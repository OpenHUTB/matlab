function startPropertyUpdateTimer(this)






    if~isempty(this.propertyUpdateTimer)&&isa(this.propertyUpdateTimer,'timer')&&isvalid(this.propertyUpdateTimer)
        start(this.propertyUpdateTimer);
    end

end

