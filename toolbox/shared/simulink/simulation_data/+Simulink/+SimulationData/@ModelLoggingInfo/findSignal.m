function idxs=findSignal(this,bpath,portIdx)

























    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'findSignal');
    end


    narginchk(2,3);



    if isa(bpath,'Simulink.SimulationData.BlockPath')&&...
        length(bpath)==1
        search=bpath;
    else
        search=Simulink.BlockPath(bpath);
    end


    if nargin<3
        portIdx=1;
    elseif~isscalar(portIdx)||~isnumeric(portIdx)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoInvalidFindSignalPort');
    end


    idxs=Simulink.SimulationData.ModelLoggingInfo.findSignals(...
    this.signals_,...
    search,...
    double(portIdx));

end
