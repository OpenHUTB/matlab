function s=flyingQualitiesStructDefinition(n)





    structDefinition={
    'root',[];
    'oscillatoryMode','';
    'zeta',[];
    'wn',[];
    'T2',[];
    'Tc',[];
    'response','';
    'description','';
    "RequirementSource","";
    "RequirementName","";
    "ID","";
    "FlyingQualityLevel","";
    "FlightPhase","";
    "AircraftClass","";
    "Verified",false;
    }';

    s=repmat(struct(structDefinition{:}),1,n);

end
