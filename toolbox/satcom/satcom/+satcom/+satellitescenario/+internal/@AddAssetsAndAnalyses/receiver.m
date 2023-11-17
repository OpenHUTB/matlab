function outputRx=receiver(asset,varargin)%#codegen

    coder.allowpcode('plain');


    if coder.target('MATLAB')
        scalarOrVector='vector';
    else
        scalarOrVector='scalar';
    end
    validateattributes(asset,...
    {'matlabshared.satellitescenario.Satellite','matlabshared.satellitescenario.GroundStation',...
    'matlabshared.satellitescenario.Gimbal'},...
    {'nonempty',scalarOrVector},'receiver','PARENT',1);


    numAssets=numel(asset);
    asset=asset.Handles;
    if coder.target('MATLAB')

        for idx=1:numel(asset)
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
    'receiver');

    if coder.target('MATLAB')

        for idx=1:numel(asset)
            if~isequal(asset{idx}.Simulator,simulator)
                msg='shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject';
                error(message(msg,"PARENT("+idx+")"));
            end
        end
    end


    [nameParsed,mountingLocationParsed,mountingAnglesParsed,gainToNoiseTemperatureRatioParsed,...
    requiredEbNoParsed,systemLossParsed,usingDefaultSystemLoss,...
    preReceiverLossParsed,usingDefaultPreReceiverLoss,antennaParsed]=...
    parseInputs(varargin{:});


    functionName='receiver';
    validatedMountingLocation=matlabshared.satellitescenario.internal.validateMountingLocationOrAngles(...
    mountingLocationParsed,numAssets,functionName,true);


    numRxML=size(validatedMountingLocation,2);


    validatedMountingAngles=matlabshared.satellitescenario.internal.validateMountingLocationOrAngles(...
    mountingAnglesParsed,numAssets,functionName,false);


    numRxMA=size(validatedMountingAngles,2);


    validatedNames=matlabshared.satellitescenario.internal.validateName(...
    nameParsed,numAssets,functionName);


    numRxN=numel(validatedNames);


    validatedGainToNoiseTemperatureRatio=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    gainToNoiseTemperatureRatioParsed,numAssets,functionName,'GainToNoiseTemperatureRatio');


    numRxG=numel(validatedGainToNoiseTemperatureRatio);


    validatedRequiredEbNo=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    requiredEbNoParsed,numAssets,functionName,'RequiredEbNo');


    numRxR=numel(validatedRequiredEbNo);


    validatedSystemLoss=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    systemLossParsed,numAssets,functionName,'SystemLoss');
    validateattributes(validatedSystemLoss,...
    {'double'},...
    {'nonnegative'},...
    functionName,'SystemLoss');


    numRxSL=numel(validatedSystemLoss);


    validatedPreReceiverLoss=matlabshared.satellitescenario.internal.validateAttachedAssetScalarParameter(...
    preReceiverLossParsed,numAssets,functionName,'PreReceiverLoss');
    validateattributes(validatedPreReceiverLoss,...
    {'double'},...
    {'nonnegative'},...
    functionName,'PreReceiverLoss');


    numRxPRL=numel(validatedPreReceiverLoss);


    if coder.target('MATLAB')
        validatedAntenna=satcom.satellitescenario.internal.validateAntenna(...
        antennaParsed,numAssets,functionName);
        numRxA=numel(validatedAntenna);
    else
        validatedAntenna=[];
        numRxA=0;
    end



    if coder.target('MATLAB')
        numRx=max([numRxML,numRxMA,numRxN,numRxG,numRxR,numRxSL,numRxPRL,numRxA,numAssets]);
    else
        numRx=1;
    end


    if isscalar(validatedSystemLoss)
        formattedSystemLoss=validatedSystemLoss*ones(1,numRx);
    else
        formattedSystemLoss=validatedSystemLoss;
    end
    if isscalar(validatedPreReceiverLoss)
        formattedPreReceiverLoss=validatedPreReceiverLoss*ones(1,numRx);
    else
        formattedPreReceiverLoss=validatedPreReceiverLoss;
    end
    for idx=1:numRx

        systemLoss=formattedSystemLoss(idx);


        preReceiverLoss=formattedPreReceiverLoss(idx);

        if systemLoss<preReceiverLoss
            if usingDefaultSystemLoss&&~usingDefaultPreReceiverLoss


                formattedSystemLoss(idx)=preReceiverLoss;
            elseif~usingDefaultSystemLoss&&usingDefaultPreReceiverLoss



                formattedPreReceiverLoss(idx)=systemLoss;
            elseif~usingDefaultSystemLoss&&~usingDefaultPreReceiverLoss


                coder.internal.errorIf(true,...
                'shared_orbit:orbitPropagator:PreReceiverLossGreaterThanSystemLoss');
            end
        elseif preReceiverLoss>systemLoss
            if usingDefaultSystemLoss&&~usingDefaultPreReceiverLoss


                formattedSystemLoss(idx)=preReceiverLoss;
            elseif~usingDefaultSystemLoss&&usingDefaultPreReceiverLoss



                formattedPreReceiverLoss(idx)=systemLoss;
            elseif~usingDefaultSystemLoss&&~usingDefaultPreReceiverLoss


                coder.internal.errorIf(true,...
                'shared_orbit:orbitPropagator:PreReceiverLossGreaterThanSystemLoss');
            end
        end
    end


    outputRx=satcom.satellitescenario.Receiver;
    handles=cell(1,numRx);
    outputRx.Handles=handles;

    if simulator.NumReceivers==0
        simulator.Receivers=repmat(simulator.ReceiverStruct,1,numRx);
    else
        newReceiverStruct=repmat(simulator.ReceiverStruct,1,numRx);
        simulator.Receivers=[simulator.Receivers,newReceiverStruct];
    end
    for idx=1:numRx

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


        if isscalar(validatedRequiredEbNo)
            requiredEbNo=validatedRequiredEbNo;
        else
            requiredEbNo=validatedRequiredEbNo(idx);
        end


        if isscalar(validatedGainToNoiseTemperatureRatio)
            gainToNoiseTemperatureRatio=validatedGainToNoiseTemperatureRatio;
        else
            gainToNoiseTemperatureRatio=validatedGainToNoiseTemperatureRatio(idx);
        end


        if isscalar(formattedSystemLoss)
            systemLoss=formattedSystemLoss;
        else
            systemLoss=formattedSystemLoss(idx);
        end


        if isscalar(formattedPreReceiverLoss)
            preReceiverLoss=formattedPreReceiverLoss;
        else
            preReceiverLoss=formattedPreReceiverLoss(idx);
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


        rx=satcom.satellitescenario.Receiver(name,...
        mountingLocation,mountingAngles,...
        requiredEbNo,gainToNoiseTemperatureRatio,...
        systemLoss,preReceiverLoss,antenna,currentAsset);


        existingRx=currentAsset.Receivers;


        if isempty(existingRx)||~currentAsset.pReceiversAddedBefore
            currentAsset.Receivers=rx;
            currentAsset.pReceiversAddedBefore=true;
        else
            currentAsset.Receivers=[existingRx,rx];
        end


        if coder.target('MATLAB')
            outputRx.Handles{idx}=rx.Handles{1};
        else
            outputRx=rx;
        end
    end


    advance(simulator,simulator.Time);


    simulator.NeedToSimulate=true;

    if coder.target('MATLAB')
        scenario=asset{1}.Scenario;
        if isa(scenario,'satelliteScenario')
            scenario.NeedToSimulate=true;


            scenario.addToScenarioGraphics(reshape(outputRx,1,[]));
        end
    end
end

function[name,mountingLocation,mountingAngles,...
    gainToNoiseTemperatureRatio,requiredEbNo,systemLoss,usingDefaultSystemLoss,...
    preReceiverLoss,usingDefaultPreReceiverLoss,antenna]=parseInputs(varargin)

    coder.allowpcode('plain');

    paramNames={'Name','MountingLocation','MountingAngles','GainToNoiseTemperatureRatio','RequiredEbNo','SystemLoss','PreReceiverLoss','Antenna'};
    pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
    name=coder.internal.getParameterValue(pstruct.Name,'',varargin{:});
    mountingLocation=coder.internal.getParameterValue(pstruct.MountingLocation,[0;0;0],varargin{:});
    mountingAngles=coder.internal.getParameterValue(pstruct.MountingAngles,[0;0;0],varargin{:});
    gainToNoiseTemperatureRatio=coder.internal.getParameterValue(pstruct.GainToNoiseTemperatureRatio,3,varargin{:});
    requiredEbNo=coder.internal.getParameterValue(pstruct.RequiredEbNo,10,varargin{:});
    systemLoss=coder.internal.getParameterValue(pstruct.SystemLoss,5,varargin{:});
    preReceiverLoss=coder.internal.getParameterValue(pstruct.PreReceiverLoss,3,varargin{:});
    antenna=coder.internal.getParameterValue(pstruct.Antenna,[],varargin{:});

    usingDefaultSystemLoss=pstruct.SystemLoss==0;
    usingDefaultPreReceiverLoss=pstruct.PreReceiverLoss==0;
end

