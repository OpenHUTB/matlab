function ret=isSignalLogged(hPort,dlo)



    ret=strcmpi(get(hPort,'DataLogging'),'on');



    if ret&&~isempty(dlo)
        [defLog,si]=dlo.getSettingsForSignal(...
        get(hPort,'Parent'),...
        get(hPort,'PortNumber'),...
        '',...
        false,...
        get(hPort,'Name'),...
        false);



        if~defLog
            if isempty(si)||~si.LoggingInfo.DataLogging
                ret=false;
            end
        end
    end
end
