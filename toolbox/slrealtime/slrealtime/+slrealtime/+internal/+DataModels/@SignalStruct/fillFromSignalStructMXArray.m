function fillFromSignalStructMXArray(this,signalStruct)





    this.blockPath=signalStruct.blockpath.convertToCell;
    this.portIndex=signalStruct.portindex;
    this.stateName=signalStruct.statename;
    this.signalName=signalStruct.signame;
    this.signalType=signalStruct.type;


end
