function computePowerColorExtents(this,minVal,maxVal)






    if this.SpectrogramLineCounter>0
        S=this.ScaledSpectrogram{:};
        minPower=real(mean(min(S(1:this.SpectrogramLineCounter,:))));
        minPower=max(minPower,minVal);
        minPower=min(minPower,maxVal);
        maxPower=real(max(max(S(1:this.SpectrogramLineCounter,:))));
        maxPower=max(maxPower,minVal);
        maxPower=min(maxPower,maxVal);
        this.PowerColorExtents=[minPower,maxPower];
    end
end
