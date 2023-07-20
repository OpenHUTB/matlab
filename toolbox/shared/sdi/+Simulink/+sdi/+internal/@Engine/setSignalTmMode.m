function setSignalTmMode(this,id,value,notifyFlag)













    str=validatestring(value,{'none','samples','fs','ts','tv','resampled','inherentTimetable','inherentTimeseries','inherentLabeledSignalSet','spectrogram','preprocessBackup','file'});
    if nargin<4
        notifyFlag=true;
    end

    this.sigRepository.setSignalTmMode(id,str);

    if notifyFlag
        notify(this,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',id,value,'tmMode'));
    end
end