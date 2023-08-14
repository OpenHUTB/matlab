function setSignalTmStartTimeUnits(this,id,value,notifyFlag)
    str=validatestring(value,{'ps','ns','us','ms','s','mins','minutes','hours','days','years'});
    if nargin<4
        notifyFlag=true;
    end

    this.sigRepository.setSignalTmStartTimeUnits(id,str);

    if notifyFlag
        notify(this,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',id,value,'tmStartTimeUnits'));
    end
end