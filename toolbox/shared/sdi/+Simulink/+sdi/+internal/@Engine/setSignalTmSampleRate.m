function setSignalTmSampleRate(this,id,value,notifyFlag)
    if nargin<4
        notifyFlag=true;
    end

    this.sigRepository.setSignalTmSampleRate(id,value);

    if notifyFlag
        notify(this,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',id,value,'tmSampleRate'));
    end
end