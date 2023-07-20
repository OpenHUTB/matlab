function h=ConfigSetAllowedUnitSystems(varargin)





    debuggingcc=varargin{1};

    if~ishandle(debuggingcc)
        disp('DebuggingCC initialization failed.');
    end

    h=Simulink.ConfigSetAllowedUnitSystems;
    set(h,'myDebuggingCC',debuggingcc);

end
