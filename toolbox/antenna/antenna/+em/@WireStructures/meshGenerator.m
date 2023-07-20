function meshGenerator(obj,varargin)




    if obj.useCCode
        obj.Medium=em.wire.solver.BasicHomMedium(1,1);
    else
        obj.Medium=em.wire.solver.BasicHomMediumM(1,1);
    end
    obj.createInternalWires;
    if isa(obj.Source,'planeWaveExcitation')
        obj.Medium.EMSolObj.EincFunc=@obj.Ex_inc;
    end


    allFieldNames=fields(obj.MesherStruct.Mesh);
    allFieldVals=struct2cell(obj.MesherStruct.Mesh);

    neededFieldInd=ismember(allFieldNames,{'MaxEdgeLength'});
    emptyFields=cellfun(@(x)isempty(x),allFieldVals(neededFieldInd));
    if any(emptyFields)
        nonEmptyFieldNames=allFieldNames(neededFieldInd);
        nonEmptyFieldNames=nonEmptyFieldNames(emptyFields);
        delimiters=[repmat({', '},1,length(nonEmptyFieldNames)-1),{'.'}];
        error(message('antenna:antennaerrors:NoWireMeshParams',[' '...
        ,cell2mat(reshape([nonEmptyFieldNames.';delimiters],...
        1,[]))]));
    end
    if isempty(obj.MesherStruct.Mesh.MeshGrowthRate)
        if~isempty(obj.Source)

            [~,gr]=obj.Source.calculateWireMeshParams(1);
        else
            gr=2.0;
        end
        obj.MesherStruct.Mesh.MeshGrowthRate=gr;
    end

    frequency=obj.MesherStruct.MeshingFrequency;
    meshingLambda=obj.getMeshingLambda;
    partAntennaCell=cell(length(obj.WiresInt),1);
    partAntennaMPtCell=cell(length(obj.WiresInt),1);
    partAntennaBothCell=cell(length(obj.WiresInt),1);
    totwireNodes=cell(length(obj.WiresInt),1);
    totMatchPts=cell(length(obj.WiresInt),1);
    totBothPts=cell(length(obj.WiresInt),1);
    messCell={};
    TotWireParts=0;
    TotMatrixSize=0;
    for wireInd=1:length(obj.WiresInt)
        if~isempty(obj.MesherStruct.Mesh.ExtraMeshNodes{wireInd})
            extraNodesOnThisWire=...
            obj.orientGeom(obj.MesherStruct.Mesh.ExtraMeshNodes{wireInd});
            [extraNodeSegs,extraNodeDist]=...
            obj.WiresInt{wireInd}.findSegment(extraNodesOnThisWire);
            extraNodesOnThisWire=...
            extraNodesOnThisWire(:,logical(extraNodeSegs));
            extraNodeSegs=extraNodeSegs(logical(extraNodeSegs));
            [~,sortInd]=sort(extraNodeSegs+extraNodeDist);
            extraNodeSegs=extraNodeSegs(sortInd);
            extraNodesOnThisWire=extraNodesOnThisWire(:,sortInd);
            wireNodesOrig=obj.WiresInt{wireInd}.wireNodesOrig;
            for extraNodesOnThisWireInd=1:size(extraNodesOnThisWire,2)
                addInd=extraNodeSegs(extraNodesOnThisWireInd)+...
                extraNodesOnThisWireInd-1;
                wireNodesOrig=[wireNodesOrig(:,1:addInd)...
                ,extraNodesOnThisWire(:,extraNodesOnThisWireInd)...
                ,wireNodesOrig(:,addInd+1:end)];
            end
            obj.WiresInt{wireInd}.wireNodesOrig=wireNodesOrig;
        end
        NFSegLen=em.WireStructures.r2NFSegLenRatio*...
        obj.WiresInt{wireInd}.SegmentRadius;
        r2NFSegLenRatio=em.WireStructures.r2NFSegLenRatio;
        nMatchPtNFSeg=em.WireStructures.nMatchPtNFSeg;
        if obj.MesherStruct.Mesh.MaxEdgeLength<=NFSegLen
            r2NFSegLenRatio=obj.MesherStruct.Mesh.MaxEdgeLength/...
            obj.WiresInt{wireInd}.SegmentRadius;
            nMatchPtNFSeg=max(2,floor(nMatchPtNFSeg*1.001*...
            obj.MesherStruct.Mesh.MaxEdgeLength/NFSegLen));
            if strcmp(obj.MesherStruct.MeshingChoice,'manual')
                messCell=[messCell,{message(...
                'antenna:antennaerrors:WireMaxEdgeLengthTooSmall',...
                num2str(em.WireStructures.r2NFSegLenRatio))}];%#ok<AGROW>
            end
        end
        vInd=(obj.FeedWireIntInd==wireInd);
        if isempty(vInd)||...
            ~isa(obj.WiresInt{wireInd},'em.wire.solver.DeltaGapPECWire')
            obj.WiresInt{wireInd}.Initialize(obj.Medium,...
            reshape(frequency,1,1,[]),r2NFSegLenRatio,nMatchPtNFSeg,...
            obj.MesherStruct.Mesh.MaxEdgeLength,...
            obj.MesherStruct.Mesh.MeshGrowthRate,...
            obj.MesherStruct.Mesh.MaxEdgeLength,[],true);
        else
            obj.WiresInt{wireInd}.Initialize(obj.Medium,[],...
            reshape(frequency,1,1,[]),r2NFSegLenRatio,nMatchPtNFSeg,...
            obj.MesherStruct.Mesh.MaxEdgeLength,...
            obj.MesherStruct.Mesh.MeshGrowthRate,...
            obj.MesherStruct.Mesh.MaxEdgeLength,[],true);
        end
        wireNodes=obj.WiresInt{wireInd}.wireNodes;
        totwireNodes{wireInd}=wireNodes;
        TotMatrixSize=TotMatrixSize+2*(size(wireNodes,2)-1);
        NodePos=SegmentsPosOnWire(obj.WiresInt{wireInd});
        if~isempty(meshingLambda)&&(obj.WiresInt{wireInd}.SegmentRadius>...
            em.WireStructures.maxr2lambda*meshingLambda)
            ApproxBrokenMsg=message(...
            'antenna:antennaerrors:ThinWireApproxInvalid').string;
            messCell=[messCell,{message(...
            'antenna:antennaerrors:WireRadiusTooLargeForMeshLambda',...
            num2str(em.WireStructures.maxr2lambda),...
            num2str(em.WireStructures.maxr2lambda*meshingLambda),...
            ApproxBrokenMsg)}];%#ok<AGROW>
        end


        if any(diff(NodePos)<(NFSegLen-sqrt(eps(NFSegLen))))
            if any(diff(NodePos)<em.WireStructures.minr2SegLenRatio*...
                obj.WiresInt{wireInd}.SegmentRadius)
                if strcmp(obj.MesherStruct.MeshingChoice,'manual')
                    error(message(...
                    'antenna:antennaerrors:WireMeshNodesTooCloseErr',...
                    num2str(em.WireStructures.minr2SegLenRatio)));
                else
                    error(message(...
                    'antenna:antennaerrors:WireMeshNodesForcedTooClose',...
                    num2str(em.WireStructures.minr2SegLenRatio)));
                end
            end


            if~ismember('antenna:antennaerrors:WireMaxEdgeLengthTooSmall',...
                cellfun(@(x)x.Identifier,messCell,'UniformOutput',false))
                ApproxBrokenMsg=message(...
                'antenna:antennaerrors:ThinWireApproxInvalid').string;
                messCell=[messCell,{message(...
                'antenna:antennaerrors:WireMeshNodesTooClose',...
                num2str(em.WireStructures.r2NFSegLenRatio),...
                ApproxBrokenMsg)}];%#ok<AGROW>
            end
        end
        wiresCell=cell(size(wireNodes,2)-1,1);
        for wireNodeInd=1:size(wireNodes,2)-1
            wiresCell{wireNodeInd}=...
            em.wire.wire('StartPoint',wireNodes(:,wireNodeInd).',...
            'EndPoint',wireNodes(:,wireNodeInd+1).');
        end
        matchPts=obj.WiresInt{wireInd}.MatchingPoints;
        totMatchPts{wireInd}=matchPts;
        TotMatrixSize=TotMatrixSize+size(matchPts,2);
        wiresMPtCell=cell(size(matchPts,2)-1,1);
        for mPtInd=1:size(matchPts,2)-1
            wiresMPtCell{mPtInd}=...
            em.wire.wire('StartPoint',matchPts(:,mPtInd).',...
            'EndPoint',matchPts(:,mPtInd+1).');
        end


        bothPts=[wireNodes(:,2:end-1),matchPts];
        [~,ptsSortInd]=...
        sort(obj.WiresInt{wireInd}.relLocationOnWire(bothPts));
        bothPts=[wireNodes(:,1),bothPts(:,ptsSortInd),wireNodes(:,end)];
        totBothPts{wireInd}=bothPts;
        wiresBothCell=cell(size(bothPts,2)-1,1);
        for bothInd=1:size(bothPts,2)-1
            wiresBothCell{bothInd}=...
            em.wire.wire('StartPoint',bothPts(:,bothInd).',...
            'EndPoint',bothPts(:,bothInd+1).','WireDiameter',...
            2*obj.WiresInt{wireInd}.SegmentRadius*...
            obj.MesherStruct.Geometry.wireRadMultiplier);
        end
        partAntennaCell{wireInd}=em.wire.partAntenna(wiresCell{:});
        partAntennaMPtCell{wireInd}=em.wire.partAntenna(wiresMPtCell{:});
        partAntennaBothCell{wireInd}=em.wire.partAntenna(wiresBothCell{:});
        TotWireParts=TotWireParts+(size(totwireNodes{wireInd},2)-1)+...
        sum(obj.WiresInt{wireInd}.EdgeType==1)+...
        (size(totwireNodes{wireInd},2)-2);
    end

    [~,uniqueMessInd]=unique(cellfun(@(x)x.string,messCell));
    for messInd=1:length(uniqueMessInd)
        warning(messCell{uniqueMessInd(messInd)});
    end

    Mesh.wiresSeg=add(partAntennaCell{:});
    Mesh.wiresSeg=Mesh.wiresSeg.flatten;
    Mesh.volDataSeg=Mesh.wiresSeg.makeMesh;
    Mesh.wiresMPt=add(partAntennaMPtCell{:});
    Mesh.wiresMPt=Mesh.wiresMPt.flatten;
    Mesh.volDataMPt=Mesh.wiresMPt.makeMesh;


    for extraConnInd=1:length(obj.ExtraConns)
        PhantomParts=repmat(em.wire.partAntenna,...
        numel(obj.ExtraConns{extraConnInd}.NextParts),1);
        for nextPartInd=1:numel(obj.ExtraConns{extraConnInd}.NextParts)
            obj.ExtraConnsInt{extraConnInd}.NextParts(nextPartInd)=...
            obj.WiresInt{obj.ExtraConnsWireInd{extraConnInd}.NextParts(...
            nextPartInd)};
            if obj.ExtraConnsInt{extraConnInd}.NextSegSides(nextPartInd)==0
                PhantomParts(nextPartInd)=partAntennaBothCell{...
                obj.ExtraConnsWireInd{extraConnInd}.NextParts(...
                nextPartInd)}.Parts(1);
            else
                PhantomParts(nextPartInd)=partAntennaBothCell{...
                obj.ExtraConnsWireInd{extraConnInd}.NextParts(...
                nextPartInd)}.Parts(end);
            end
        end
        if obj.ExtraConnsInt{extraConnInd}.PrevSegSides==1
            partAntennaBothCell{obj.ExtraConnsWireInd{...
            extraConnInd}.PrevParts(1)}.Parts(end).PhantomNextParts=...
            PhantomParts;
        else
            partAntennaBothCell{obj.ExtraConnsWireInd{...
            extraConnInd}.PrevParts(1)}.Parts(1).PhantomNextParts=...
            PhantomParts;
        end
    end
    TotWireParts=TotWireParts+length(obj.ExtraConns);
    obj.Medium.EMSolObj.ZmatObj.Matrix=zeros(TotMatrixSize,TotMatrixSize,0);
    obj.Medium.EMSolObj.ZmatObj.isNotPrealloc=false;

    lastColor=1;
    for wireInd=1:length(partAntennaBothCell)
        for partInd=1:length(partAntennaBothCell{wireInd}.Parts)
            partAntennaBothCell{wireInd}.Parts(partInd).Color=lastColor;
            lastColor=lastColor+2;
        end
    end

    Mesh.wiresBoth=add(partAntennaBothCell{:});
    Mesh.wiresBoth=Mesh.wiresBoth.flatten(true);
    Mesh.volDataBoth=Mesh.wiresBoth.makeVolume(true);
    Mesh.wireNodes=totwireNodes;
    Mesh.matchPts=totMatchPts;
    Mesh.bothPts=totBothPts;
    Mesh.numParts=TotWireParts;


    saveMesh(obj,Mesh);

end