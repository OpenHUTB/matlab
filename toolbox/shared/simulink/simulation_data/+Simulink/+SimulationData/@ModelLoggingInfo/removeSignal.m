function this=removeSignal(this,idx)





    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'removeSignal');
    end


    narginchk(2,2);


    if~isscalar(idx)||~isnumeric(idx)||...
        idx<1||idx>length(this.signals_)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoInvalidRemoveSignalVal',...
        length(this.signals_));
    end


    this=this.removeSignals_(idx);

end
