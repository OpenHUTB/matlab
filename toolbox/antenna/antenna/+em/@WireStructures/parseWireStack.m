function parseWireStack(obj,varargin)

    isObjectInput=false;
    if~isempty(varargin)
        if isscalar(varargin)
            if cellfun(@(x)isa(x,'em.Antenna')||...
                isa(x,'em.Array'),varargin)
                tempAnt=varargin{:};
                [isConv,messCell]=tempAnt.isConvertable2Wire;
                if isConv
                    varargin={};
                    isObjectInput=true;
                else
                    error(message(messCell{:}));
                end

            elseif cellfun(@(x)isa(x,'planeWaveExcitation'),varargin)
                tempAnt=varargin{:};
                error(message(...
                'antenna:antennaerrors:WireStackConversionNotSupported',...
                class(tempAnt)));








            else
                tempAnt=varargin{:};

                if isa(tempAnt,'customArrayGeometry')
                    error(message(['antenna:antennaerrors:'...
                    ,'WireStackConversionNotSupported'],...
                    'customArrayGeometry'))
                end
            end
        end
    end

    parserObj=inputParser;
    if~isObjectInput
        tempAnt=dipole;
    end


    mc=metaclass(tempAnt);
    propname={mc.PropertyList.Name};
    isPubProp=strcmpi({mc.PropertyList.SetAccess},'public');
    isVisProp=~[mc.PropertyList.Hidden];
    propGroups=getPropertyGroups(tempAnt);
    isDispProp=ismember(propname,fieldnames(propGroups.PropertyList));
    getPairs=get(tempAnt);
    fNames=fieldnames(getPairs);
    fVals=struct2cell(getPairs);
    if isprop(tempAnt,'Element')&&numel(tempAnt.Element)>1
        keepInd=~strcmpi('NumElements',fNames);
        fNames=fNames(keepInd);
        fVals=fVals(keepInd);
    end
    isSetPair=ismember(fNames,propname(isPubProp&isVisProp&isDispProp));
    nameValPairs=reshape([fNames(isSetPair).';fVals(isSetPair).'],1,[]);
    source=feval(class(tempAnt),nameValPairs{:});
    obj.Source=source;

    if isa(tempAnt,'planeWaveExcitation')
        tempName=['Plane wave excitation of a '...
        ,lower(tempAnt.Element.wireName('Singular'))];
        [wiresWithFeed,tempExtraConns,messCell]=tempAnt.Element.createWires;
        tempWires=cell(size(wiresWithFeed));
        isDGWire=cellfun(@(x)isa(x,'em.wire.solver.DeltaGapPECWire'),...
        wiresWithFeed);
        tempFeedsLocations=cell2mat(cellfun(@(x)x.GapLocations.',...
        wiresWithFeed(isDGWire),'UniformOutput',false).');
        for wireInd=1:length(tempWires)
            if isDGWire(wireInd)

                tempWires{wireInd}=em.wire.solver.BasicPECWire(...
                wiresWithFeed{wireInd}.wireNodesOrig,...
                wiresWithFeed{wireInd}.SegmentRadius,...
                wiresWithFeed{wireInd}.EdgeType);
            else
                tempWires{wireInd}=wiresWithFeed{wireInd};
            end
        end
    else
        tempName=tempAnt.wireName('Singular');
        [tempWires,tempExtraConns,messCell]=tempAnt.createWires;
        isDGWire=cellfun(@(x)isa(x,'em.wire.solver.DeltaGapPECWire'),...
        tempWires);
        for extraConnInd=1:length(tempExtraConns)
            obj.ExtraConnsWireInd{extraConnInd}.PrevParts(1)=...
            find([tempWires{:}]==...
            tempExtraConns{extraConnInd}.PrevParts(1),1);
            for nextPartInd=1:numel(tempExtraConns{extraConnInd}.NextParts)
                obj.ExtraConnsWireInd{extraConnInd}.NextParts(nextPartInd)=...
                find([tempWires{:}]==...
                tempExtraConns{extraConnInd}.NextParts(nextPartInd),1);
            end
        end
        tempFeedsLocations=cell2mat(cellfun(@(x)x.GapLocations.',...
        tempWires(isDGWire),'UniformOutput',false).');
    end
    obj.Wires=tempWires;
    obj.ExtraConns=tempExtraConns;
    [isTooClose,distGrid]=checkIntersect(obj,[],2.5);
    if isTooClose
        if checkIntersect(obj,distGrid)
            error(message('antenna:antennaerrors:WiresIntersecting'));
        end
        ApproxBrokenMsg=message(...
        'antenna:antennaerrors:ThinWireApproxInvalid').string;
        messCell=[messCell,{message(...
        'antenna:antennaerrors:WiresTooClose','3',ApproxBrokenMsg)}];
    end


    [~,uniqueMessInd]=unique(cellfun(@(x)x.string,messCell));
    for messInd=1:length(uniqueMessInd)
        warning(messCell{uniqueMessInd(messInd)});
    end
    obj.WirePositions=zeros(length(tempWires),3);
    obj.FeedLocationsInt=tempFeedsLocations;
    if isa(tempAnt,'em.Array')
        if isa(tempAnt,'conformalArray')
            elemPos=tempAnt.ElementPosition;
        else
            elemPos=obj.FeedLocation;
        end
        taper=tempAnt.AmplitudeTaper;
        phaseSh=tempAnt.PhaseShift*pi/180;
        if isa(tempAnt.Element,'dipoleCrossed')
            if isscalar(taper)
                taper=repmat(taper,1,tempAnt.NumElements);
            end
            if isscalar(phaseSh)
                phaseSh=repmat(phaseSh,1,tempAnt.NumElements);
            end
            tempPhaseShifts=reshape((tempAnt.Element.FeedPhase(:)*pi/180)+...
            phaseSh,1,[]);
            tempFeedsVoltages=reshape(tempAnt.Element.FeedVoltage(:)*...
            taper,1,[]);
        else
            if isscalar(taper)
                taper=repmat(taper,1,size(elemPos,1));
            end
            if isscalar(phaseSh)
                phaseSh=repmat(phaseSh,1,size(elemPos,1));
            end
            [tempPhaseShifts,tempFeedsVoltages]=...
            em.internal.calcPhaseShiftAndVoltageForConformal(tempAnt.Element,...
            elemPos,taper,phaseSh);
        end
        tempPhaseShifts=tempPhaseShifts*180/pi;
    elseif isa(tempAnt,'dipoleCrossed')
        feedVoltage=tempAnt.FeedVoltage;
        if isscalar(feedVoltage)
            feedVoltage=repmat(feedVoltage,2,1);
        end
        feedPhase=tempAnt.FeedPhase;
        if isscalar(feedPhase)
            feedPhase=repmat(feedPhase,2,1);
        end
        [tempPhaseShifts,tempFeedsVoltages]=...
        em.internal.calcPhaseShiftAndVoltageForConformal(tempAnt.Element,...
        tempAnt.FeedLocation,feedVoltage,feedPhase);
    else
        if~isa(tempAnt,'planeWaveExcitation')
            tempFeedsVoltages=1;
            tempDirection=[];
            tempPolarization=[];
        else
            tempDirection=tempAnt.Direction;
            tempPolarization=tempAnt.Polarization;
            tempFeedsVoltages=0;
        end
        tempPhaseShifts=0;
    end





    addParameter(parserObj,'Name',tempName);
    if~isa(tempAnt,'planeWaveExcitation')
        addParameter(parserObj,'FeedVoltage',tempFeedsVoltages);
        addParameter(parserObj,'FeedPhase',tempPhaseShifts);
    else
        addParameter(parserObj,'Direction',tempDirection);
        addParameter(parserObj,'Polarization',tempPolarization);
    end
    addParameter(parserObj,'Tilt',tempAnt.Tilt);
    addParameter(parserObj,'TiltAxis',tempAnt.TiltAxis);
    parse(parserObj,varargin{:});



    obj.Name=parserObj.Results.Name;
    if~isa(tempAnt,'planeWaveExcitation')
        obj.FeedVoltage=parserObj.Results.FeedVoltage;
        obj.FeedPhase=parserObj.Results.FeedPhase;
    else
        obj.Direction=parserObj.Results.Direction;
        obj.Polarization=parserObj.Results.Polarization;
    end
    obj.Tilt=parserObj.Results.Tilt;
    obj.TiltAxis=parserObj.Results.TiltAxis;

    if~isempty(obj.Wires)&&~isempty(obj.FeedLocationsInt)&&...
        ~isempty(obj.Source)
        obj.createInternalWires;

        if isa(tempAnt,'planeWaveExcitation')
            obj.setExtraMeshNodes(tempAnt.Element.createWiresExtraMeshNodes);
        else
            obj.setExtraMeshNodes(tempAnt.createWiresExtraMeshNodes);
        end
    end

end