function out=showAPMModeWidget(hObj,varargin)



    hCS=hObj.getConfigSet();

    depParam='FPGADesign.IncludeAXIInterconnectMonitor';
    if codertarget.data.isParameterInitialized(hCS,depParam)
        out=codertarget.data.getParameterValue(hCS,depParam);
    else
        out=0;
    end
end


