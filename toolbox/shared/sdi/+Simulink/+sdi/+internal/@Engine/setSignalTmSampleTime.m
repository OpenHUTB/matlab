function setSignalTmSampleTime(this,id,value,notifyFlag)
    if nargin<4
        notifyFlag=true;
    end

    this.sigRepository.setSignalTmSampleTime(id,value);

    if notifyFlag
        notify(this,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',id,value,'tmSampleTime'));
    end
end