function createEmptyFigForUnsupportedSignal(this,sigID,sigName)
    clr=getSignalLineColor(this,sigID);
    displayName=strcat(sigName,getString(message('SDI:sdi:NotSupportedSignal')));
    options={'Color',clr,'DisplayName',displayName};
    plot(NaN,options{:});
end