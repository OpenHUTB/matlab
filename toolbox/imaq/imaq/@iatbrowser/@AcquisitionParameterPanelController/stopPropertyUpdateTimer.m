function stopPropertyUpdateTimer(this)
    if~isempty(this.propertyUpdateTimer)&&isa(this.propertyUpdateTimer,'timer')&&isvalid(this.propertyUpdateTimer)
        stop(this.propertyUpdateTimer);
        drawnow;
    end

end

