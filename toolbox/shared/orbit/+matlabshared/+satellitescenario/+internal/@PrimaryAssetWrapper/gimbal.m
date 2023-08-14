function outputGimbal=gimbal(asset,varargin)%#codegen





























































































































    coder.allowpcode('plain');


    if coder.target('MATLAB')
        scalarOrVector='vector';
    else
        scalarOrVector='scalar';
    end
    validateattributes(asset,...
    {'matlabshared.satellitescenario.Satellite','matlabshared.satellitescenario.GroundStation'},...
    {'nonempty',scalarOrVector},'gimbal','PARENT',1);


    numAssets=numel(asset);
    assetHandles=asset.Handles;
    if coder.target('MATLAB')

        for idx=1:numAssets
            if~isvalid(assetHandles{idx})
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'PARENT');
                error(msg);
            end
        end
    end


    simulator=assetHandles{1}.Simulator;


    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
    'shared_orbit:orbitPropagator:UnableAddAssetOrAnalysisIncorrectSimStatus',...
    'gimbal');

    if coder.target('MATLAB')

        for idx=1:numel(assetHandles)
            if~isequal(assetHandles{idx}.Simulator,simulator)
                msg='shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject';
                error(message(msg,"PARENT("+idx+")"));
            end
        end
    end


    [name,mountingLocationParsed,mountingAnglesParsed]=parseInputs(varargin{:});


    functionName='gimbal';
    validatedMountingLocation=matlabshared.satellitescenario.internal.validateMountingLocationOrAngles(...
    mountingLocationParsed,numAssets,functionName,true);


    numGimbalsML=size(validatedMountingLocation,2);


    validatedMountingAngles=matlabshared.satellitescenario.internal.validateMountingLocationOrAngles(...
    mountingAnglesParsed,numAssets,functionName,false);


    numGimbalsMA=size(validatedMountingAngles,2);


    validatedNames=matlabshared.satellitescenario.internal.validateName(...
    name,numAssets,functionName);


    numGimbalsN=size(validatedNames,2);

    if coder.target('MATLAB')


        numGimbals=max([numGimbalsML,numGimbalsMA,numGimbalsN,numAssets]);
    else
        numGimbals=1;
    end


    outputGimbal=matlabshared.satellitescenario.Gimbal;
    handles=cell(1,numGimbals);
    outputGimbal.Handles=handles;


    if simulator.NumGimbals==0
        simulator.Gimbals=repmat(simulator.GimbalStruct,1,numGimbals);
    else
        newGimbalStruct=repmat(simulator.GimbalStruct,1,numGimbals);
        simulator.Gimbals=[simulator.Gimbals,newGimbalStruct];
    end
    for idx=1:numGimbals

        if isscalar(assetHandles)
            currentAsset=assetHandles{1};
        else
            currentAsset=assetHandles{idx};
        end


        if isscalar(validatedNames)
            name=validatedNames{1};
        else
            name=validatedNames{idx};
        end


        if size(validatedMountingLocation,2)==1
            mountingLocation=validatedMountingLocation(1:3,1);
        else
            mountingLocation=validatedMountingLocation(1:3,idx);
        end


        if size(validatedMountingAngles,2)==1
            mountingAngles=validatedMountingAngles(1:3,1);
        else
            mountingAngles=validatedMountingAngles(1:3,idx);
        end

        gim=matlabshared.satellitescenario.Gimbal(name,...
        mountingLocation,mountingAngles,currentAsset);


        existingGimbals=currentAsset.Gimbals;


        if isempty(existingGimbals)||~currentAsset.pGimbalsAddedBefore
            currentAsset.Gimbals=gim;
            currentAsset.pGimbalsAddedBefore=true;
        else
            currentAsset.Gimbals=[existingGimbals,gim];
        end

        if coder.target('MATLAB')

            outputGimbal.Handles{idx}=gim.Handles{1};
        else
            outputGimbal=gim;
        end
    end


    advance(simulator,simulator.Time);


    simulator.NeedToSimulate=true;

    if coder.target('MATLAB')
        scenario=assetHandles{1}.Scenario;
        if isa(scenario,'satelliteScenario')
            scenario.NeedToSimulate=true;


            scenario.addToScenarioGraphics(reshape(outputGimbal,1,[]));


            updateViewersIfAutoShow([assetHandles{:}]);
        end
    end
end

function[name,mountingLocation,mountingAngles]=parseInputs(varargin)
    paramNames={'Name','MountingLocation','MountingAngles'};
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
    name=coder.internal.getParameterValue(pstruct.Name,'',varargin{:});
    mountingLocation=coder.internal.getParameterValue(pstruct.MountingLocation,[0;0;0],varargin{:});
    mountingAngles=coder.internal.getParameterValue(pstruct.MountingAngles,[0;0;0],varargin{:});
end

