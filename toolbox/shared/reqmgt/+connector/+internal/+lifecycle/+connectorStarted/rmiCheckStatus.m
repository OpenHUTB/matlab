function rmiCheckStatus()
%connector.internal.lifecycle.connectorStarted.rmiCheckStatus() enable HTTP
    
    % Called automatically on MATLAB Connector startup.
    % 
    % Check the stored preference for unsecure HTTP option,
    % force connector into unsecure mode depending on user preference.
    % Default is FALSE.
    
    %   Copyright 2018-2019 MathWorks
    
    
    % Using internal RMI Settings API for efficiency:
    if rmipref('UnsecureHttpRequests')
        
        connector.internal.ensureRestMatlabOn();
    
    end
    
end
