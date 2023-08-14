function createInternalWires(obj)
    if~isa(obj.Source,'planeWaveExcitation')
        if length(obj.FeedVoltage)==1
            feedVoltage=repmat(obj.FeedVoltage,...
            size(obj.FeedLocationsInt,1),1);
        else
            feedVoltage=obj.FeedVoltage;
        end
        if length(obj.FeedPhase)==1
            feedPhase=repmat(obj.FeedPhase,size(obj.FeedLocationsInt,1),1);
        else
            feedPhase=obj.FeedPhase;
        end
    else
        feedVoltage=zeros(size(obj.FeedLocationsInt,1),1);
        feedPhase=zeros(size(obj.FeedLocationsInt,1),1);
    end




    DeltaGapWiresInds=cellfun(@(x)isa(x,'em.wire.solver.DeltaGapPECWire'),...
    obj.Wires);
    isOnWTot=false(1,size(obj.FeedLocationsInt,1));
    obj.MesherStruct.Geometry.wireNodes=cell(length(obj.Wires),1);
    partAntennaRealCell=cell(length(obj.Wires),1);
    partAntennaCell=cell(length(obj.Wires),1);
    allOrigNodes=zeros(3,0);
    minWireRadius=obj.Wires{1}.SegmentRadius;
    maxWireRadius=obj.Wires{1}.SegmentRadius;
    for WireInd=1:length(obj.Wires)
        if DeltaGapWiresInds(WireInd)





            WiresFeedsLocation=obj.Wires{WireInd}.GapLocations;


            isFeedLocMemb=ismember(WiresFeedsLocation.',...
            obj.FeedLocationsInt,'Row');
            if~any(isFeedLocMemb)
                error(message(...
                'antenna:antennaerrors:WiresFeedsMismatchInWireStack'));
            end


            [isWMemb,WMembInd]=...
            ismember(obj.FeedLocationsInt,WiresFeedsLocation.','Row');


            isOnWTot=isOnWTot|isWMemb.';


            obj.WiresInt{WireInd}=copy(obj.Wires{WireInd});


            obj.WiresInt{WireInd}.Voltages(WMembInd(WMembInd>0))=...
            feedVoltage(isWMemb).*exp(feedPhase(isWMemb)*1j);
            obj.FeedWireIntInd(isWMemb)=WireInd;
            obj.FeedIndInWireInt(isWMemb)=WMembInd(isWMemb);
            FeedsNotFoundYetInWires=obj.FeedLocationsInt(~isOnWTot,:);
            FeedVoltMagNotFoundYetInWires=feedVoltage(~isOnWTot);
            FeedPhaseNotFoundYetInWires=feedPhase(~isOnWTot);
            FeedsOnThisWire=...
            obj.Wires{WireInd}.isOnWire(FeedsNotFoundYetInWires.');
            obj.WiresInt{WireInd}.GapPositions_=...
            [obj.Wires{WireInd}.GapPositions_...
            ,obj.Wires{WireInd}.relLocationOnWire(...
            FeedsNotFoundYetInWires(FeedsOnThisWire,:).')];
            obj.WiresInt{WireInd}.Voltages=[obj.WiresInt{WireInd}.Voltages...
            ,FeedVoltMagNotFoundYetInWires(FeedsOnThisWire).*...
            exp(FeedPhaseNotFoundYetInWires(FeedsOnThisWire)*1j)];
            notOnWTotInd=find(~isOnWTot);
            obj.FeedWireIntInd(notOnWTotInd(FeedsOnThisWire))=WireInd;
            obj.FeedIndInWireInt(notOnWTotInd(FeedsOnThisWire))=...
            (1:length(notOnWTotInd(FeedsOnThisWire)))+...
            length(obj.Wires{WireInd}.GapPositions_);
            isOnWTot(~isOnWTot)=FeedsOnThisWire;
        else



            WiresFeedsLocation=zeros(3,0);
            FeedsNotFoundYetInWires=obj.FeedLocationsInt(~isOnWTot,:);
            FeedsOnThisWire=...
            obj.Wires{WireInd}.isOnWire(FeedsNotFoundYetInWires.');
            FeedVoltMagNotFoundYetInWires=feedVoltage(~isOnWTot);
            FeedPhaseNotFoundYetInWires=feedPhase(~isOnWTot);
            if~isa(obj.Source,'planeWaveExcitation')&&any(FeedsOnThisWire)
                obj.WiresInt{WireInd}=...
                em.wire.solver.DeltaGapPECWire(...
                obj.Wires{WireInd}.wireNodesOrig,...
                obj.Wires{WireInd}.SegmentRadius,...
                obj.Wires{WireInd}.EdgeType,...
                obj.Wires{WireInd}.relLocationOnWire(...
                FeedsNotFoundYetInWires(FeedsOnThisWire,:).'));
                obj.WiresInt{WireInd}.Voltages=...
                FeedVoltMagNotFoundYetInWires(FeedsOnThisWire).*...
                exp(FeedPhaseNotFoundYetInWires(FeedsOnThisWire)*1j);
            else
                obj.WiresInt{WireInd}=copy(obj.Wires{WireInd});
            end
            notOnWTotInd=find(~isOnWTot);
            obj.FeedWireIntInd(notOnWTotInd(FeedsOnThisWire))=WireInd;
            obj.FeedIndInWireInt(notOnWTotInd(FeedsOnThisWire))=...
            (1:length(notOnWTotInd(FeedsOnThisWire)));
            isOnWTot(~isOnWTot)=FeedsOnThisWire;
        end
        [feedSegs,feedOffsets]=...
        obj.WiresInt{WireInd}.findSegment([WiresFeedsLocation...
        ,FeedsNotFoundYetInWires(FeedsOnThisWire,:).']);

        wireNodes=obj.orientGeom(obj.WiresInt{WireInd}.wireNodesOrig);
        obj.MesherStruct.Geometry.wireNodes{WireInd}=wireNodes;
        obj.WiresInt{WireInd}.wireNodesOrig=wireNodes;
        obj.WiresInt{WireInd}.SegmentEdges=[wireNodes(:,1).';...
        wireNodes(:,end).'];
        wiresCell=cell(size(wireNodes,2)-1,1);
        for wireNodeInd=1:size(wireNodes,2)-1
            wiresCell{wireNodeInd}=...
            em.wire.wire('StartPoint',wireNodes(:,wireNodeInd).',...
            'EndPoint',wireNodes(:,wireNodeInd+1).','WireDiameter',...
            2*obj.WiresInt{WireInd}.SegmentRadius);
            locInd=find(feedSegs==wireNodeInd,1);
            if~isempty(locInd)
                wiresCell{wireNodeInd}.FeedOffset=feedOffsets(locInd);
            end
        end
        partAntennaCell{WireInd}=em.wire.partAntenna(wiresCell{:});
        partAntennaRealCell{WireInd}=clone(em.wire.partAntenna(wiresCell{:}));
        allOrigNodes=[allOrigNodes,wireNodes];%#ok<AGROW>
        minWireRadius=min(minWireRadius,obj.WiresInt{WireInd}.SegmentRadius);
        maxWireRadius=max(maxWireRadius,obj.WiresInt{WireInd}.SegmentRadius);
    end


    for extraConnInd=1:length(obj.ExtraConns)
        obj.ExtraConnsInt{extraConnInd}=copy(obj.ExtraConns{extraConnInd});
        obj.ExtraConnsInt{extraConnInd}.PrevParts(1)=...
        obj.WiresInt{obj.ExtraConnsWireInd{extraConnInd}.PrevParts(1)};
        PhantomParts=repmat(em.wire.partAntenna,...
        numel(obj.ExtraConns{extraConnInd}.NextParts),1);
        for nextPartInd=1:numel(obj.ExtraConns{extraConnInd}.NextParts)
            obj.ExtraConnsInt{extraConnInd}.NextParts(nextPartInd)=...
            obj.WiresInt{obj.ExtraConnsWireInd{extraConnInd}.NextParts(...
            nextPartInd)};
            if obj.ExtraConnsInt{extraConnInd}.NextSegSides(nextPartInd)==0
                PhantomParts(nextPartInd)=partAntennaCell{...
                obj.ExtraConnsWireInd{extraConnInd}.NextParts(...
                nextPartInd)}.Parts(1);
            else
                PhantomParts(nextPartInd)=partAntennaCell{...
                obj.ExtraConnsWireInd{extraConnInd}.NextParts(...
                nextPartInd)}.Parts(end);
            end
        end
        if obj.ExtraConnsInt{extraConnInd}.PrevSegSides==1
            partAntennaCell{obj.ExtraConnsWireInd{...
            extraConnInd}.PrevParts(1)}.Parts(end).PhantomNextParts=...
            PhantomParts;
        else
            partAntennaCell{obj.ExtraConnsWireInd{...
            extraConnInd}.PrevParts(1)}.Parts(1).PhantomNextParts=...
            PhantomParts;
        end
    end


    wiresReal=add(partAntennaRealCell{:});
    wiresReal=wiresReal.flatten;


    obj.MesherStruct.Geometry.volDataReal=wiresReal.makeVolume;





    allOrigNodes=reshape(uniquetol(allOrigNodes.',...
    em.WireStructures.MinRelDist,'ByRows',true),[],1,3);
    allNorms=vecnorm(allOrigNodes-permute(allOrigNodes,[2,1,3]),2,3);
    mindist=min(allNorms(allNorms>em.WireStructures.MinRelDist));
    maxdist=max(allNorms(:));
    wireRadMultiplier=floor(max(1,min(0.2*mindist/maxWireRadius,...
    0.01*maxdist/minWireRadius)));
    for WireInd=1:length(obj.Wires)
        for partInd=1:length(partAntennaCell{WireInd}.Parts)
            partAntennaCell{WireInd}.Parts(partInd).WireDiameter=...
            partAntennaCell{WireInd}.Parts(partInd).WireDiameter*...
            wireRadMultiplier;
        end
    end
    obj.MesherStruct.Geometry.wires=add(partAntennaCell{:});
    obj.MesherStruct.Geometry.wires=obj.MesherStruct.Geometry.wires.flatten;
    obj.MesherStruct.Geometry.volData=...
    obj.MesherStruct.Geometry.wires.makeVolume;
    obj.MesherStruct.Geometry.wireRadMultiplier=wireRadMultiplier;
    obj.MesherStruct.HasStructureVisChanged=0;
    if~all(isOnWTot)
        error(message('antenna:antennaerrors:FeedLocationsNotOnWires'));
    end
end
