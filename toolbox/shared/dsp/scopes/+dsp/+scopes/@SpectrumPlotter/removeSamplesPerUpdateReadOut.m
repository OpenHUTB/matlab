function readoutRemovedFlag=removeSamplesPerUpdateReadOut(this)



    readoutRemovedFlag=false;
    if~isempty(this.SamplesPerUpdateReadOut)
        delete(this.SamplesPerUpdateReadOut);
        prepareAxesForMessage(this,false);
        this.SamplesPerUpdateReadOut=[];
        this.SamplesPerUpdateMsgStatus=false;
        readoutRemovedFlag=true;
    end
end
