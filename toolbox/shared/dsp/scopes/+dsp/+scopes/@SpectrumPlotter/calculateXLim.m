function newXLim=calculateXLim(this)




    if this.CCDFMode
        newXLim=[0,20];
    else

        newXLim=this.FrequencyLimits;
    end
end
