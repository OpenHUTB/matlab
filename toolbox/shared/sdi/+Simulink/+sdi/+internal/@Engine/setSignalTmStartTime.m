function setSignalTmStartTime(this,id,value,notifyFlag)
    if nargin<4
        notifyFlag=true;
    end

    this.sigRepository.setSignalTmStartTime(id,value);

    if notifyFlag
        notify(this,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',id,value,'tmStartTime'));
    end
end