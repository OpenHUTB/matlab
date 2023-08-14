function setStartMessage(this,startMsg)




    if isa(startMsg,'Advisor.Element')
        startMsg=startMsg.emitHTML;
    end
    this.StartMessage=startMsg;
