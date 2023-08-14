function isBus=isBusSignal(this,sigName)
    isBus=~isempty(regexp(sigName,this.BusRx,'once'));
end