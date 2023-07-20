function outputSensor=conicalSensor(asset,varargin)%#codegen




    coder.allowpcode('plain');


    if coder.target('MATLAB')
        scalarOrVector='vector';
    else
        scalarOrVector='scalar';
    end
    validateattributes(asset,...
    {'matlabshared.satellitescenario.Satellite','matlabshared.satellitescenario.GroundStation',...
    'matlabshared.satellitescenario.Gimbal'},...
    {'nonempty',scalarOrVector},'conicalSensor','PARENT',1);


    numAssets=numel(asset);
    asset=asset.Handles;

    if coder.target('MATLAB')

        for idx=1:numAssets
            if~isvalid(asset{idx})
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'PARENT');
                error(msg);
            end
        end
    end


    simulator=asset{1}.Simulator;


    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
    'shared_orbit:orbitPropagator:UnableAddAssetOrAnalysisIncorrectSimStatus',...
    'conical sensor');

    if coder.target('MATLAB')

        for idx=1:numel(asset)
            if~isequal(asset{idx}.Simulator,simulator)
                msg='shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject';
                error(message(msg,"PARENT("+idx+")"));
            end
        end
    end


    [name,mountingLocationParsed,mountingAnglesParsed,maxViewAngleParsed]=parseInputs(varargin{:});


    functionName='conicalSensor';
    validatedMountingLocation=matlabshared.satellitescenario.internal.validateMountingLocationOrAngles(...
    mountingLocationParsed,numAssets,functionName,true);


    numSensorsML=size(validatedMountingLocation,2);


    validatedMountingAngles=matlabshared.satellitescenario.internal.validateMountingLocationOrAngles(...
    mountingAnglesParsed,numAssets,functionName,false);


    numSensorsMA=size(validatedMountingAngles,2);


    validatedNames=matlabshared.satellitescenario.internal.validateName(...
    name,numAssets,functionName);


    numSensorsN=numel(validatedNames);


    validatedMaxViewAngle=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    maxViewAngleParsed,numAssets,functionName,'MaxViewAngle');
    validateattributes(validatedMaxViewAngle,...
    {'numeric'},...
    {'positive','<',180},...
    functionName,'MaxViewAngle');


    numSensorsMVA=numel(validatedMaxViewAngle);

    if coder.target('MATLAB')


        numSensors=max([numSensorsML,numSensorsMA,numSensorsN,numSensorsMVA,numAssets]);
    else
        numSensors=1;
    end


    outputSensor=matlabshared.satellitescenario.ConicalSensor;
    handles=cell(1,numSensors);
    outputSensor.Handles=handles;


    if simulator.NumConicalSensors==0
        simulator.ConicalSensors=repmat(simulator.ConicalSensorStruct,1,numSensors);
    else
        newSensorStruct=repmat(simulator.ConicalSensorStruct,1,numSensors);
        simulator.ConicalSensors=[simulator.ConicalSensors,newSensorStruct];
    end
    for idx=1:numSensors

        if isscalar(asset)
            currentAsset=asset{1};
        else
            currentAsset=asset{idx};
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


        if isscalar(validatedMaxViewAngle)
            maxViewAngle=validatedMaxViewAngle;
        else
            maxViewAngle=validatedMaxViewAngle(idx);
        end


        sensor=matlabshared.satellitescenario.ConicalSensor(...
        name,mountingLocation,mountingAngles,...
        maxViewAngle,currentAsset);


        existingSensors=currentAsset.ConicalSensors;


        if isempty(existingSensors)||~currentAsset.pConicalSensorsAddedBefore
            currentAsset.ConicalSensors=sensor;
            currentAsset.pConicalSensorsAddedBefore=true;
        else
            currentAsset.ConicalSensors=[existingSensors,sensor];
        end

        if coder.target('MATLAB')

            outputSensor.Handles{idx}=sensor.Handles{1};
        else
            outputSensor=sensor;
        end
    end


    advance(simulator,simulator.Time);


    simulator.NeedToSimulate=true;

    if coder.target('MATLAB')
        scenario=asset{1}.Scenario;

        if isa(scenario,'satelliteScenario')
            scenario.NeedToSimulate=true;


            scenario.addToScenarioGraphics(reshape(outputSensor,1,[]));
        end
    end
end

function[name,mountingLocation,mountingAngles,maxViewAngle]=parseInputs(varargin)

    coder.allowpcode('plain');

    paramNames={'Name','MountingLocation','MountingAngles','MaxViewAngle'};
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
    name=coder.internal.getParameterValue(pstruct.Name,'',varargin{:});
    mountingLocation=coder.internal.getParameterValue(pstruct.MountingLocation,[0;0;0],varargin{:});
    mountingAngles=coder.internal.getParameterValue(pstruct.MountingAngles,[0;0;0],varargin{:});
    maxViewAngle=coder.internal.getParameterValue(pstruct.MaxViewAngle,30,varargin{:});
end

