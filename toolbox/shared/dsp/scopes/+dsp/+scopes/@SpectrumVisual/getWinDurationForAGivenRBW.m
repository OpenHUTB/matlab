function[winDuration,winLength]=getWinDurationForAGivenRBW(this,RBW)





    win=getPropertyValue(this,'Window');
    customWin=getPropertyValue(this,'CustomWindow');
    SLA=evalPropertyValue(this,'SidelobeAttenuation');
    Fs=this.SpectrumObject.SampleRate;
    desiredRBW=RBW;
    [winDuration,winLength]=dsp.scopes.getWinDurationForAGivenRBW(desiredRBW,win,customWin,SLA,Fs);
end
