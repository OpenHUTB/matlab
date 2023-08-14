function sat=walkerDelta(scenario,r,i,T,P,F,varargin)%#codegen




    coder.allowpcode('plain');

    if isempty(coder.target)&&~builtin('license','checkout','Aerospace_Toolbox')

        error(message("MATLAB:license:NoFeature","walkerDelta","Aerospace_Toolbox"))
    end


    validateattributes(scenario,{'satelliteScenario'},{'scalar'},'walkerDelta','SCENARIO',1);
    if isempty(coder.target)&&~isvalid(scenario)
        msg=message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
        'SCENARIO');
        error(msg);
    end


    validateattributes(r,"numeric",{"real","scalar",">",Aero.spacecraft.centralbody.Earth.EquatorialRadius},"walkerDelta","r",2);
    validateattributes(i,"numeric",{"real","scalar"},"walkerDelta","i",3);%#ok<*CLARRSTR> 
    validateattributes(T,"numeric",{"real","scalar","positive"},"walkerDelta","T",4);
    validateattributes(P,"numeric",{"real","scalar","positive"},"walkerDelta","P",5);
    validateattributes(F,"numeric",{"real","scalar","nonnegative","<",P},"walkerDelta","F",6);


    paramNames={"RAAN","ArgumentOfLatitude","Name","OrbitPropagator"};
    pstruct=coder.internal.parseParameterInputs(paramNames,struct('PartialMatching','unique'),varargin{:});
    nameValueArgs.RAAN=coder.internal.getParameterValue(pstruct.RAAN,0,varargin{:});
    nameValueArgs.ArgumentOfLatitude=coder.internal.getParameterValue(pstruct.ArgumentOfLatitude,0,varargin{:});
    nameValueArgs.Name=coder.internal.getParameterValue(pstruct.Name,"WalkerDelta",varargin{:});
    nameValueArgs.OrbitPropagator=coder.internal.getParameterValue(pstruct.OrbitPropagator,"two-body-keplerian",varargin{:});

    if isempty(coder.target)&&mod(T,P)~=0
        error(message('spacecraft:scenario:TPMismatch'))
    end

    S=floor(T/P);


    semiMajorAxis=r*ones(1,T);
    eccentricity=zeros(1,T);
    inclination=i*ones(1,T);


    raanInterval=360/P;
    raan0=nameValueArgs.RAAN;
    raanFinal=raan0+((P-1)*raanInterval);
    raanOfPlanes=raan0:raanInterval:raanFinal;

    raan=sort(repmat(raanOfPlanes,1,S));




    argOfPeriapsis=zeros(1,T);
    argLatInterval=360/S;
    argLat0=nameValueArgs.ArgumentOfLatitude;
    argLatFinal=argLat0+((S-1)*argLatInterval);
    trueAnomalyForEachPlane=argLat0:argLatInterval:argLatFinal;

    phiInterval=F*360/T;
    phi=phiInterval*(0:P-1);
    trueAnomaly=zeros(1,T);
    for planeIdx=1:P

        trueAnomaly(raan==raanOfPlanes(planeIdx))=trueAnomalyForEachPlane+phi(planeIdx);
    end


    names=cell(T,1);
    for idx=1:T
        names{idx}=[char(nameValueArgs.Name),'_',num2str(idx)];
    end


    sat=satellite(scenario,semiMajorAxis,eccentricity,inclination,...
    raan,argOfPeriapsis,trueAnomaly,"Name",names,...
    "OrbitPropagator",nameValueArgs.OrbitPropagator);

end