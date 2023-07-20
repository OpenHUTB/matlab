function setSignalTmAvgSampleRate(this,id,value,notifyFlag)
    if nargin<4
        notifyFlag=true;
    end

    this.sigRepository.setSignalTmAvgSampleRate(id,value);

    if notifyFlag
        notify(this,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',id,value,'tmAvgSampleRate'));
    end
end