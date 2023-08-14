function setUnitSystem(varargin)

















    unitSys=varargin{1};


    allowedUnitSystems=["Default","SI","USCustomary"];
    validatestring(unitSys,allowedUnitSystems);
    defaultOverrides=[];
    unitSysInput=inputParser;
    addParameter(unitSysInput,'overrides',defaultOverrides,@overrideValidationFcn);
    parse(unitSysInput,varargin{2:end});
    inputResults=unitSysInput.Results;
    overridesCell={};
    for idx=1:length(inputResults.overrides)
        overridesCell{idx}=char(inputResults.overrides(idx));%#ok
    end
    Simulink.sdi.setUnitSystemAndOverrides(unitSys,overridesCell);
end

function overrideValidationFcn(overrides)
    validateattributes(overrides,{'string'},{'vector'});
end