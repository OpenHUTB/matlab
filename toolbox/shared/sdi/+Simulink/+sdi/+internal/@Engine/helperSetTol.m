function helperSetTol(this,id,value,func,warningmssg,enum)
    if(strcmpi(enum,'abs')||strcmpi(enum,'rel'))&&(isinf(value)||value<0)


        error(message('SDI:sdi:InvalidTolerance'));
    end
    func(id,value);
    this.dirty=true;
    notify(this,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
    id,value,enum));
end