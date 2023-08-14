function setSignalTmSampleRateUnits(this,id,value,notifyFlag)
    str=validatestring(value,{'Hz','kHz','MHz','GHz'});
    if nargin<4
        notifyFlag=true;
    end

    this.sigRepository.setSignalTmSampleRateUnits(id,str);

    if notifyFlag
        notify(this,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',id,value,'tmSampleRateUnits'));
    end
end