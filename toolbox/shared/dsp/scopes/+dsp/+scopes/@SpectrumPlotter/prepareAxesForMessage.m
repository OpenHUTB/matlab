function prepareAxesForMessage(this,msgVisible)



    if this.CCDFMode&&~msgVisible
        set(this.Axes,'Layer','bottom');
    else
        set(this.Axes,'Layer','top');
    end
end
