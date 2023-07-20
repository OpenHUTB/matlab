function[RBW,NENBW,spectrogramMessage]=getCurrentRBW(this,span)









    NENBW=[];
    spectrogramMessage=false;
    if strcmp(getPropertyValue(this,'RBWSource'),'Auto')
        if(isSpectrogramMode(this)||isCombinedViewMode(this))&&strcmp(getPropertyValue(this,'TimeResolutionSource'),'Property')
            timeResolution=evalPropertyValue(this,'TimeResolution');
            RBW=1/timeResolution;
            spectrogramMessage=true;
        else
            RBW=span/1024;
        end
    else
        [RBW,~,~]=evaluateVariable(this.Application,getPropertyValue(this,'RBW'));
    end
end
