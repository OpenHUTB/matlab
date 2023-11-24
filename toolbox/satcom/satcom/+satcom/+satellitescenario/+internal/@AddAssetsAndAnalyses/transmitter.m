function outputTx=transmitter(asset,varargin)%#codegen

    coder.allowpcode('plain');

    if coder.target('MATLAB')
        scalarOrVector='vector';
    else
        scalarOrVector='scalar';
    end
    validateattributes(asset,...
    {'matlabshared.satellitescenario.Satellite','matlabshared.satellitescenario.GroundStation',...
    'matlabshared.satellitescenario.Gimbal'},...
    {'nonempty',scalarOrVector},'transmitter','PARENT',1);


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
    'transmitter');

    if coder.target('MATLAB')

        for idx=1:numel(asset)
            if~isequal(asset{idx}.Simulator,simulator)
                msg='shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject';
                error(message(msg,"PARENT("+idx+")"));
            end
        end
    end


    [nameParsed,mountingLocationParsed,mountingAnglesParsed,frequencyParsed,...
    bitRateParsed,powerParsed,systemLossParsed,antennaParsed]=parseInputs(varargin{:});


    functionName='transmitter';
    validatedMountingLocation=matlabshared.satellitescenario.internal.validateMountingLocationOrAngles(...
    mountingLocationParsed,numAssets,functionName,true);


    numTxML=size(validatedMountingLocation,2);


    validatedMountingAngles=matlabshared.satellitescenario.internal.validateMountingLocationOrAngles(...
    mountingAnglesParsed,numAssets,functionName,false);


    numTxMA=size(validatedMountingAngles,2);


    validatedNames=matlabshared.satellitescenario.internal.validateName(...
    nameParsed,numAssets,functionName);


    numTxN=numel(validatedNames);


    validatedFrequency=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    frequencyParsed,numAssets,functionName,'Frequency');
    validateattributes(validatedFrequency,...
    {'numeric'},...
    {'positive'},...
    'transmitter','Frequency');


    numTxF=numel(validatedFrequency);


    validatedBitRate=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    bitRateParsed,numAssets,functionName,'BitRate');
    validateattributes(validatedBitRate,...
    {'numeric'},...
    {'positive'},...
    'transmitter','BitRate');


    numTxBR=numel(validatedBitRate);


    validatedPower=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    powerParsed,numAssets,functionName,'Power');


    numTxP=numel(validatedPower);


    validatedSystemLoss=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    systemLossParsed,numAssets,functionName,'SystemLoss');
    validateattributes(validatedSystemLoss,...
    {'numeric'},...
    {'nonnegative'},...
    'transmitter','SystemLoss');


    numTxSL=numel(validatedSystemLoss);


    if coder.target('MATLAB')
        validatedAntenna=satcom.satellitescenario.internal.validateAntenna(...
        antennaParsed,numAssets,functionName);
        numTxA=numel(validatedAntenna);
    else
        validatedAntenna=[];
        numTxA=0;
    end



    if coder.target('MATLAB')
        numTx=max([numTxML,numTxMA,numTxN,numTxF,numTxBR,numTxP,numTxSL,numTxA,numAssets]);
    else
        numTx=1;
    end


    outputTx=satcom.satellitescenario.Transmitter;
    handles=cell(1,numTx);
    outputTx.Handles=handles;

    if simulator.NumTransmitters==0
        simulator.Transmitters=repmat(simulator.TransmitterStruct,1,numTx);
    else
        newTransmitterStruct=repmat(simulator.TransmitterStruct,1,numTx);
        simulator.Transmitters=[simulator.Transmitters,newTransmitterStruct];
    end
    for idx=1:numTx

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


        if isscalar(validatedFrequency)
            frequency=validatedFrequency;
        else
            frequency=validatedFrequency(idx);
        end


        if isscalar(validatedBitRate)
            bitRate=validatedBitRate;
        else
            bitRate=validatedBitRate(idx);
        end


        if isscalar(validatedPower)
            power=validatedPower;
        else
            power=validatedPower(idx);
        end


        if isscalar(validatedSystemLoss)
            systemLoss=validatedSystemLoss;
        else
            systemLoss=validatedSystemLoss(idx);
        end


        if~isempty(coder.target)
            antenna=[];
        else
            if isempty(validatedAntenna)||isscalar(validatedAntenna)
                antenna=validatedAntenna;
            else
                antenna=validatedAntenna(idx);
            end
        end


        tx=satcom.satellitescenario.Transmitter(...
        name,mountingLocation,mountingAngles,...
        frequency,bitRate,power,systemLoss,...
        antenna,currentAsset);


        existingTx=currentAsset.Transmitters;


        if isempty(existingTx)||~currentAsset.pTransmittersAddedBefore
            currentAsset.Transmitters=tx;
            currentAsset.pTransmittersAddedBefore=true;
        else
            currentAsset.Transmitters=[existingTx,tx];
        end


        if coder.target('MATLAB')
            outputTx.Handles{idx}=tx.Handles{1};
        else
            outputTx=tx;
        end
    end


    advance(simulator,simulator.Time)


    simulator.NeedToSimulate=true;

    if coder.target('MATLAB')
        scenario=asset{1}.Scenario;
        if isa(scenario,'satelliteScenario')
            scenario.NeedToSimulate=true;


            scenario.addToScenarioGraphics(reshape(outputTx,1,[]));
        end
    end
end

function[name,mountingLocation,mountingAngles,frequency,bitRate,power,systemLoss,antenna]=parseInputs(varargin)

    coder.allowpcode('plain');

    paramNames={'Name','MountingLocation','MountingAngles','Frequency','BitRate','Power','SystemLoss','Antenna'};
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
    name=coder.internal.getParameterValue(pstruct.Name,'',varargin{:});
    mountingLocation=coder.internal.getParameterValue(pstruct.MountingLocation,[0;0;0],varargin{:});
    mountingAngles=coder.internal.getParameterValue(pstruct.MountingAngles,[0;0;0],varargin{:});
    frequency=coder.internal.getParameterValue(pstruct.Frequency,14e9,varargin{:});
    bitRate=coder.internal.getParameterValue(pstruct.BitRate,10,varargin{:});
    power=coder.internal.getParameterValue(pstruct.Power,17,varargin{:});
    systemLoss=coder.internal.getParameterValue(pstruct.SystemLoss,5,varargin{:});
    antenna=coder.internal.getParameterValue(pstruct.Antenna,[],varargin{:});
end


