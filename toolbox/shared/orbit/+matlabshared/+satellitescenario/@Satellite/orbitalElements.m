function elements=orbitalElements(sat)





























































































    validateattributes(sat,{'matlabshared.satellitescenario.Satellite'},{'scalar'},...
    'orbitalElements','SAT',1);
    if~isvalid(sat)
        msg=message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
        'SAT');
        error(msg);
    end

    elements=orbitalElements(sat.Handles{1});
end


