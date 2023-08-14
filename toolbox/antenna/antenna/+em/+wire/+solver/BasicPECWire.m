classdef BasicPECWire<em.wire.solver.BasicWirePart




    properties
SegmentEdges
SegmentRadius
SegmentLength
        Segments=em.wire.solver.BasicPECWireSegment.empty
        Connections=em.wire.solver.BasicPECWireConnection.empty
        Terminations=em.wire.solver.BasicPECWireTermination.empty
        r2NFSegLenRatio=7
        nMatchPtNFSeg=3
maxEdgeLength
growthRate
maxMatchPtDist
maxnMatchPt
wireNodesOrig
wireNodes
isNFSeg
EdgeType

PrevParts
NextParts
AffectedByOtherPartsZ
AffectingOtherPartsZ
Medium
MatchingPoints
MatchingPointsSegInd
Freqs
    end
    methods
        function obj=BasicPECWire(wireNodesOrig,segmentRadius,...
            edgeType,medium,freqs,varargin)





            if nargin>0
                obj.wireNodesOrig=wireNodesOrig;
                obj.SegmentRadius=segmentRadius;
                obj.SegmentEdges=[wireNodesOrig(:,1).';...
                wireNodesOrig(:,end).'];
                obj.AffectedByOtherPartsZ=false;


                obj.AffectingOtherPartsZ=false;


                edgeType=edgeType(:);
                switch length(edgeType)
                case 1
                    edgeType=[edgeType,edgeType];
                case 2
                    edgeType=edgeType(:);
                otherwise
                    error(['PECWire termination must be a '...
                    ,'scalar or a vector of length 2']);
                end
                obj.EdgeType=edgeType;
                if nargin>3
                    obj.Medium=medium;
                    if nargin>5&&~isempty(varargin{1})
                        obj.r2NFSegLenRatio=varargin{1};
                        obj.nMatchPtNFSeg=varargin{2};
                    end
                    if nargin>7&&~isempty(varargin{3})
                        obj.maxEdgeLength=varargin{3};
                    else
                        obj.maxEdgeLength=obj.Medium.Lambda(freqs(end))/8;
                    end
                    if nargin>8&&~isempty(varargin{4})
                        obj.growthRate=varargin{4};
                    else
                        obj.growthRate=2.0;
                    end
                    if nargin>9&&~isempty(varargin{5})
                        obj.maxMatchPtDist=varargin{5};
                    else
                        obj.maxMatchPtDist=...
                        obj.Medium.Lambda(freqs(end))/8;
                    end
                    if nargin>10&&~isempty(varargin{6})
                        obj.maxnMatchPt=varargin{6};
                    else
                        obj.maxnMatchPt=6;
                    end
                    obj.nMatchPtNFSeg=min(obj.maxnMatchPt,...
                    obj.nMatchPtNFSeg);

                    isNFSegOrig=zeros(size(wireNodesOrig,2)-1,1);
                    [obj.wireNodes,obj.isNFSeg]=...
                    obj.FindWireNodes(wireNodesOrig,isNFSegOrig,...
                    edgeType);
                    [obj.MatchingPoints,obj.MatchingPointsSegInd]=...
                    obj.FindMatchPts;


                    if nargin<=11||~varargin{7}
                        obj.Freqs=freqs;
                        obj.Medium.EMSolObj.AddFreqs(freqs,...
                        true(length(freqs),1));
                        obj.ConnectSegments;
                    end
                end
            end
        end

        function res=Initialize(obj,medium,freqs,varargin)



            res=true;
            if isempty(obj.Medium)
                obj.Medium=medium;
                if nargin>3&&~isempty(varargin{1})
                    obj.r2NFSegLenRatio=varargin{1};
                    obj.nMatchPtNFSeg=varargin{2};
                end
                if nargin>5&&~isempty(varargin{3})
                    obj.maxEdgeLength=varargin{3};
                else
                    obj.maxEdgeLength=obj.Medium.Lambda(freqs(end))/8;
                end
                if nargin>6&&~isempty(varargin{4})
                    obj.growthRate=varargin{4};
                else
                    obj.growthRate=2.0;
                end
                if nargin>7&&~isempty(varargin{5})
                    obj.maxMatchPtDist=varargin{5};
                else
                    obj.maxMatchPtDist=obj.Medium.Lambda(freqs(end))/8;
                end
                if nargin>8&&~isempty(varargin{6})
                    obj.maxnMatchPt=varargin{6};
                else
                    obj.maxnMatchPt=6;
                end
                obj.nMatchPtNFSeg=min(obj.maxnMatchPt,obj.nMatchPtNFSeg);

                isNFSegOrig=zeros(size(obj.wireNodesOrig,2)-1,1);
                [obj.wireNodes,obj.isNFSeg]=...
                obj.FindWireNodes(obj.wireNodesOrig,isNFSegOrig,...
                obj.EdgeType);
                [obj.MatchingPoints,obj.MatchingPointsSegInd]=...
                obj.FindMatchPts;


                if nargin<=9||~varargin{7}
                    obj.Freqs=freqs;
                    obj.Medium.EMSolObj.AddFreqs(freqs,...
                    true(length(freqs),1));
                    obj.ConnectSegments;
                end
            else
                if isa(varargin{end},'matlab.ui.Figure')



                    hwait=varargin{end};
                else
                    hwait=[];
                    buildOnly=strcmp(varargin{end},'BuildOnly');
                end

                if isempty(obj.Segments)
                    if nargin<=9||~varargin{7}
                        obj.Freqs=freqs;
                        obj.Medium.EMSolObj.AddFreqs(freqs,...
                        true(length(freqs),1));
                        if~isempty(hwait)||~buildOnly
                            obj.ConnectSegments(hwait);
                        else
                            obj.ConnectSegments(hwait,'BuildOnly')
                        end
                        if~isempty(hwait)&&getappdata(hwait,'canceling')
                            return;
                        end
                    else
                        error(['Wire cannot be remeshed if already '...
                        ,'connected to a medium']);
                    end
                end
                if obj.Medium~=medium
                    error('Wire can only be placed in a single medium');
                end
                if nargin>4&&(obj.r2NFSegLenRatio~=varargin{1}||...
                    obj.nMatchPtNFSeg~=varargin{2})
                    error(['Changing ''r2NFSegLenRatio'' or '...
                    ,'''nMatchPtNFSeg'' of previously initialized '...
                    ,'wire is not supported']);
                end
                ExistingWireFreq=obj.Freqs;
                [freqsTotChk,iaWireFreq]=sort(cat(3,ExistingWireFreq,...
                freqs(:,:,~squeeze(ismembertol(freqs,...
                ExistingWireFreq,eps(max(freqs)),...
                'DataScale',1)))));%#ok<ASGLU>
                isNewWireFreqInd=squeeze(iaWireFreq>...
                length(ExistingWireFreq));
                if any(isNewWireFreqInd)
                    ExistingSolFreq=obj.Segments(1).Freqs;












                    [freqsTot,iaSolFreq]=sort(cat(3,ExistingSolFreq,...
                    freqs(:,:,~squeeze(ismembertol(freqs,...
                    ExistingSolFreq,eps(max(freqs)),...
                    'DataScale',1)))));

                    isNewSolFreqInd=squeeze(iaSolFreq>...
                    length(ExistingSolFreq));
                    obj.Medium.EMSolObj.AddFreqs(...
                    freqsTot(isNewSolFreqInd),isNewSolFreqInd);
                    obj.Freqs=freqsTot;
                    for segInd=1:length(obj.Segments)
                        if obj.UpdateWaitBar(hwait)
                            return;
                        end
                        obj.Segments(segInd).PopulateEMSolution(...
                        freqsTot(isNewWireFreqInd),isNewWireFreqInd);
                    end
                    for connInd=1:length(obj.Connections)
                        if obj.UpdateWaitBar(hwait)
                            return;
                        end
                        obj.Connections(connInd).PopulateEMSolution(...
                        freqsTot(isNewWireFreqInd),isNewWireFreqInd);
                    end
                    for termInd=1:length(obj.Terminations)
                        if obj.UpdateWaitBar(hwait)
                            return;
                        end
                        obj.Terminations(termInd).PopulateEMSolution(...
                        freqsTot(isNewWireFreqInd),isNewWireFreqInd);
                    end
                else
                    obj.Freqs=obj.Segments(1).Freqs;
                end
            end
        end

        function IVals=CalcSegIs(obj,Sm_,varargin)


            if~isempty(obj.Medium)&&~isempty(obj.Segments)
                edges=reshape([obj.Segments(:).SegmentEdges],2,3,[]);
                wireNodesDiff=diff(edges,[],1);
                WireLens=[0;squeeze(cumsum(sqrt(sum(wireNodesDiff.^2,...
                2))))];
                IVals=zeros(1,length(Sm_),...
                size(obj.Segments(1).PolyCoeffs,3));
                for segInd=1:length(obj.Segments)
                    SmSeg_=find((Sm_>=WireLens(segInd))&...
                    (Sm_<WireLens(segInd+1)));
                    if~isempty(SmSeg_)
                        IVals(:,SmSeg_,:)=...
                        obj.Segments(segInd).CalcSegIs(Sm_(SmSeg_)-...
                        WireLens(segInd),varargin{:});
                    end
                end


                edgeSm=(Sm_==WireLens(segInd+1));
                if any(edgeSm)
                    IVals(:,edgeSm,:)=obj.Segments(segInd).CalcSegIs(...
                    Sm_(edgeSm)-WireLens(segInd),varargin{:});
                end
            else
                error('Wire is not connected to a medium with wire parts');
            end
        end

        function QtagVals=CalcSegQtags(obj,Sm_,varargin)


            if~isempty(obj.Medium)&&~isempty(obj.Segments)
                edges=reshape([obj.Segments(:).SegmentEdges],2,3,[]);
                wireNodesDiff=diff(edges,[],1);
                WireLens=[0;squeeze(cumsum(sqrt(sum(wireNodesDiff.^2,...
                2))))];
                QtagVals=zeros(1,length(Sm_),...
                size(obj.Segments(1).PolyCoeffs,3));
                for segInd=1:length(obj.Segments)
                    SmSeg_=find((Sm_>=WireLens(segInd))&...
                    (Sm_<WireLens(segInd+1)));
                    if~isempty(SmSeg_)
                        QtagVals(:,SmSeg_,:)=...
                        obj.Segments(segInd).CalcSegQtags(Sm_(...
                        SmSeg_)-WireLens(segInd),varargin{:});
                    end
                end


                edgeSm=(Sm_==WireLens(segInd+1));
                if any(edgeSm)
                    QtagVals(:,edgeSm,:)=...
                    obj.Segments(segInd).CalcSegQtags(...
                    Sm_(edgeSm)-WireLens(segInd),varargin{:});
                end
            else
                error('Wire is not connected to a medium with wire parts');
            end
        end

        function EVals_cart=CalcE(obj,rp_,varargin)
            if~isempty(obj.Medium)&&~isempty(obj.Segments)
                EVals_cart=obj.Segments(1).CalcFields(rp_,'E',...
                varargin{:});
                for segInd=2:length(obj.Segments)
                    EVals_cart=EVals_cart+...
                    obj.Segments(segInd).CalcFields(rp_,'E',...
                    varargin{:});
                end
            else
                error('Wire is not connected to a medium with wire parts');
            end
        end

        function EVals_cart=CalcH(obj,rp_,varargin)
            if~isempty(obj.Medium)&&~isempty(obj.Segments)
                EVals_cart=obj.Segments(1).CalcFields(rp_,'H',...
                varargin{:});
                for segInd=2:length(obj.Segments)
                    EVals_cart=EVals_cart+...
                    obj.Segments(segInd).CalcFields(rp_,'H',...
                    varargin{:});
                end
            else
                error('Wire is not connected to a medium with wire parts');
            end
        end

        function NodePos=SegmentsPosOnWire(obj)
            if~isempty(obj.Medium)
                wireNodesDiff=diff(obj.wireNodes,[],2);
            else
                wireNodesDiff=diff(obj.wireNodesOrig,[],2);
            end
            NodePos=[0;reshape(cumsum(sqrt(sum(wireNodesDiff.^2,1))),...
            [],1)];
        end

        function loc_=relLocationOnWire(obj,locations,withinDist)
            if nargin==2
                withinDist=0;
            end
            segInds=obj.findSegment(locations,withinDist);
            segOnWireInds=segInds(logical(segInds));
            loc_=nan(1,size(locations,2));
            if~isempty(segOnWireInds)
                if~isempty(obj.Medium)
                    SegmentEdges1=obj.wireNodes(:,1:end-1);
                    SegmentEdges2=obj.wireNodes(:,2:end);
                    wireNodesDiff=diff(obj.wireNodes,[],2);
                else
                    SegmentEdges1=obj.wireNodesOrig(:,1:end-1);
                    SegmentEdges2=obj.wireNodesOrig(:,2:end);
                    wireNodesDiff=diff(obj.wireNodesOrig,[],2);
                end
                diffSeg=SegmentEdges1(:,segOnWireInds)-...
                SegmentEdges2(:,segOnWireInds);
                diffLoc1=locations(:,logical(segInds))-...
                SegmentEdges1(:,segOnWireInds);
                segNorm=vecnorm(diffSeg,2,1);
                dotProd=dot(diffLoc1,diffSeg)./segNorm;

                locPerpDist=-dotProd.*(dotProd<0);
                locPerpDist=locPerpDist+(segNorm+dotProd).*...
                (segNorm+dotProd<0);
                WireLens=sqrt(sum(wireNodesDiff.^2));
                lengthToEdges1=[0,cumsum(WireLens(1:end-1))];
                lengthToEdges1=lengthToEdges1(segOnWireInds);
                loc_(logical(segInds))=(lengthToEdges1+locPerpDist)/...
                sum(WireLens(1:end));
            end
        end

        function[segInds,segPositions_]=findSegment(obj,locations,...
            withinDist)





            if nargin==2
                withinDist=0;
            end
            if~isempty(obj.Medium)&&~isempty(obj.Segments)
                segInds=zeros(1,size(locations,2));
                segPositions_=-ones(1,size(locations,2));
                for segInd=1:length(obj.Segments)
                    [isOnSeg,segPos_]=...
                    obj.Segments(segInd).isOnSegment(locations.');
                    segInds(isOnSeg)=segInd;
                    segPositions_(isOnSeg)=segPos_(isOnSeg);
                end
            else
                if~isempty(obj.Medium)
                    SegmentEdges1=obj.wireNodes(:,1:end-1);
                    SegmentEdges2=obj.wireNodes(:,2:end);
                else
                    SegmentEdges1=obj.wireNodesOrig(:,1:end-1);
                    SegmentEdges2=obj.wireNodesOrig(:,2:end);
                end
                diffSeg=repmat(SegmentEdges1-SegmentEdges2,1,1,...
                size(locations,2));
                diffLoc1=permute(locations,[1,3,2])-...
                repmat(SegmentEdges1,1,1,size(locations,2));
                diffLoc2=permute(locations,[1,3,2])-...
                repmat(SegmentEdges2,1,1,size(locations,2));
                locPerpDist=(-dot(diffLoc2,diffSeg).*...
                (dot(diffLoc2,diffSeg)<0)+dot(diffLoc1,diffSeg).*...
                (dot(diffLoc1,diffSeg)>0))./vecnorm(diffSeg,2,1);
                locNormDist=vecnorm(cross(diffSeg,diffLoc2),2,1)./...
                vecnorm(diffSeg,2,1);
                locNormDist(locNormDist<withinDist)=0;
                locTotDist=sqrt(locPerpDist.^2+locNormDist.^2);
                [minDist,segInds]=min(locTotDist,[],2);
                segInds=squeeze(segInds).';
                isOnSeg=squeeze(minDist).'<=withinDist+...
                em.wire.solver.BasicPECWireSegment.MinRelDist*...
                obj.SegmentRadius;




                ind=((1:length(segInds))-1)*size(SegmentEdges1,2)+...
                segInds;
                segPositions_=isOnSeg.*...
                (-dot(diffLoc1(:,ind),diffSeg(:,ind))./...
                dot(diffSeg(:,ind),diffSeg(:,ind)))-(~isOnSeg);
                segInds=(isOnSeg.*segInds);
            end
        end

        function res=isOnWire(obj,locations)
            res=logical(obj.findSegment(locations));
        end

        function res=isTouchingOtherWires(obj,PrevWires,distFactor)


            if nargin==2
                distFactor=1;
            end
            rCurr=obj.SegmentRadius;
            nodesCurr=obj.wireNodesOrig;
            res=false;
            for prevWireInd=1:length(PrevWires)
                rPrev=PrevWires{prevWireInd}.SegmentRadius;
                nodesPrev=PrevWires{prevWireInd}.wireNodesOrig;
                closestNodeInd=dsearchn(nodesPrev.',nodesCurr.');
                nodeDist=vecnorm(nodesCurr-nodesPrev(:,closestNodeInd));
                distWire=nodeDist-(rPrev+rCurr)*distFactor;
                if any(distWire<=0)
                    res=true;
                    break;
                end
            end
        end

    end

    methods(Access=protected)

        function[wireNodes,isNFSeg,isOrigNodes]=FindWireNodes(obj,...
            wireNodesOrig,isNFSegOrig,edgeType)
            wireNodesDiff=diff(wireNodesOrig,[],2);
            WireLens=sqrt(sum(wireNodesDiff.^2));
            obj.SegmentLength=sum(WireLens);
            nodesOrig=size(wireNodesOrig,2);
            NFSegLen=obj.r2NFSegLenRatio*obj.SegmentRadius;
            isInitNF=edgeType(1)~=0;
            isEndNF=edgeType(2)~=0;
            isOrigNodes=true(size(wireNodesOrig,2),1);
            addedCuts=0;
            wireNodes=zeros(size(wireNodesDiff,1),0);
            isNFSeg=isNFSegOrig;
            if isInitNF
                if NFSegLen<=WireLens(1)
                    wireNodesOrig=[wireNodesOrig(:,1)...
                    ,(wireNodesOrig(:,1)+wireNodesDiff(:,1)*NFSegLen/...
                    WireLens(1)),wireNodesOrig(:,2:end)];
                    wireNodesDiff=diff(wireNodesOrig,[],2);
                    WireLens=sqrt(sum(wireNodesDiff.^2));
                    nodesOrig=nodesOrig+1;
                    wireNodes=[wireNodesOrig(:,1),wireNodes];
                    isNFSeg=[1;isNFSeg];
                    isOrigNodes=[isOrigNodes(1);false;...
                    isOrigNodes(2:end)];
                else
                    isNFSeg(1)=1;
                    wireNodes=[wireNodesOrig(:,1),wireNodes];
                end
            end
            if isEndNF
                if NFSegLen<=WireLens(end)
                    wireNodesOrig=[wireNodesOrig(:,1:end-1)...
                    ,(wireNodesOrig(:,end)-wireNodesDiff(:,end)*...
                    NFSegLen/WireLens(end)),wireNodesOrig(:,end)];
                    wireNodesDiff=diff(wireNodesOrig,[],2);
                    WireLens=sqrt(sum(wireNodesDiff.^2));
                    nodesOrig=nodesOrig+1;
                    isNFSeg=[isNFSeg;1];
                    isOrigNodes=[isOrigNodes(1:end-1);false;...
                    isOrigNodes(end)];
                else
                    isNFSeg(end)=1;
                end
            end
            ratio=1;
            isNFSegOrig=isNFSeg;
            for nodeIdx=1+isInitNF:nodesOrig-1-isEndNF
                if nodeIdx==1
                    WireLensPrev=obj.maxEdgeLength;
                else
                    if WireLens(nodeIdx-1)/ratio<obj.maxEdgeLength
                        if isNFSegOrig(nodeIdx-1)
                            WireLensPrev=WireLens(nodeIdx-1);
                        else
                            WireLensPrev=WireLens(nodeIdx-1)/ratio;
                        end
                    else
                        WireLensPrev=obj.maxEdgeLength;
                    end
                end
                if(nodeIdx+1)>length(WireLens)
                    WireLensNext=obj.maxEdgeLength;
                else
                    if WireLens(nodeIdx+1)/ratio<obj.maxEdgeLength
                        if isNFSegOrig(nodeIdx+1)
                            WireLensNext=WireLens(nodeIdx+1);
                        else
                            WireLensNext=WireLens(nodeIdx+1)/ratio;
                        end
                    else
                        WireLensNext=obj.maxEdgeLength;
                    end
                end
                if~isNFSegOrig(nodeIdx)
                    growthSegsPrevSide=...
                    floor(log(obj.maxEdgeLength/WireLensPrev)/...
                    log(obj.growthRate));
                    growthSegsNextSide=...
                    floor(log(obj.maxEdgeLength/WireLensNext)/...
                    log(obj.growthRate));
                    subSegLensPrevSide=WireLensPrev*...
                    (obj.growthRate).^(1:growthSegsPrevSide);
                    subSegLensNextSide=fliplr(WireLensNext*...
                    (obj.growthRate).^(1:growthSegsNextSide));



                    subSegLensPrevSide1=[0,subSegLensPrevSide];
                    subSegLensNextSide1=[0,fliplr(subSegLensNextSide)];
                    cumsumPrev=cumsum(subSegLensPrevSide1);
                    cumsumNext=cumsum(subSegLensNextSide1);
                    nextInd=1;
                    prevInd=1;
                    prevIndVec=zeros(length(subSegLensPrevSide1)+...
                    length(subSegLensNextSide1)-1,1);
                    nextIndVec=prevIndVec;
                    dist=nextIndVec;
                    sumLastSubSeg=dist;
                    prevIndVec(1)=1;
                    nextIndVec(1)=1;
                    dist(1)=WireLens(nodeIdx);
                    sumLastSubSeg(1)=dist(1);

                    while(prevInd<length(cumsumPrev)||...
                        nextInd<length(cumsumNext))
                        if prevInd<length(cumsumPrev)&&...
                            (nextInd==length(cumsumNext)||...
                            cumsumPrev(prevInd+1)<=...
                            cumsumNext(nextInd+1))
                            prevInd=prevInd+1;
                        elseif nextInd<length(cumsumNext)
                            nextInd=nextInd+1;
                        end
                        nextIndVec(prevInd+nextInd-1)=nextInd;
                        prevIndVec(prevInd+nextInd-1)=prevInd;
                        dist(prevInd+nextInd-1)=WireLens(nodeIdx)-...
                        cumsumPrev(prevInd)-cumsumNext(nextInd);
                        sumLastSubSeg(prevInd+nextInd-1)=...
                        (subSegLensPrevSide1(prevInd)+...
                        subSegLensNextSide1(nextInd));
                    end
                    indLast=find(flipud(dist>=sumLastSubSeg),1,'first');
                    subSegLensPrevSide=subSegLensPrevSide1(...
                    2:prevIndVec(end+1-indLast));
                    subSegLensNextSide=fliplr(subSegLensNextSide1(...
                    2:nextIndVec(end+1-indLast)));
                    midSegLen=WireLens(nodeIdx)-...
                    sum(subSegLensPrevSide)-sum(subSegLensNextSide);




                    if midSegLen>=2*obj.maxEdgeLength
                        locMaxEdgeLength=obj.maxEdgeLength;
                    else
                        if indLast<3
                            locMaxEdgeLength=sumLastSubSeg(end);
                        else
                            locMaxEdgeLength=...
                            sumLastSubSeg(end+1-indLast+2);
                        end
                        if locMaxEdgeLength<eps(WireLens(nodeIdx))
                            locMaxEdgeLength=WireLens(nodeIdx);
                        end
                    end
                    midSegCuts=floor(midSegLen/...
                    (locMaxEdgeLength+sqrt(eps(locMaxEdgeLength))));
                    subSegLensMid=midSegLen/(midSegCuts+1);

                    subSegsRelLens=[subSegLensPrevSide...
                    ,repmat(subSegLensMid,[1,midSegCuts+1])...
                    ,subSegLensNextSide]/WireLens(nodeIdx);
                    wireNodes=[wireNodes,cumsum([wireNodesOrig(:,...
                    nodeIdx),wireNodesDiff(:,nodeIdx)*...
                    subSegsRelLens(1:end-1)],2)];%#ok<AGROW>
                    newCuts=length(subSegsRelLens)-1;
                    isNFSeg=[isNFSeg(1:nodeIdx+addedCuts);...
                    zeros(newCuts,1);isNFSeg(nodeIdx+addedCuts+1:end)];
                    isOrigNodes=[isOrigNodes(1:nodeIdx+addedCuts);...
                    false(newCuts,1);...
                    isOrigNodes(nodeIdx+addedCuts+1:end)];
                    addedCuts=addedCuts+newCuts;
                else
                    wireNodes=[wireNodes...
                    ,wireNodesOrig(:,nodeIdx)];%#ok<AGROW>
                end
            end
            wireNodes(:,end+1)=wireNodesOrig(:,end);
            if isEndNF
                wireNodes=[wireNodes(:,1:end-1),wireNodesOrig(:,end-1)...
                ,wireNodes(:,end)];
            end
        end

        function[mPts,mPtsSegInd]=FindMatchPts(obj)
            if~isempty(obj.Medium)&&~isempty(obj.Segments)
                mPts=zeros(3,0);
                mPtsSegInd=[];
                for segInd=1:length(obj.Segments)
                    addedPts=obj.Segments(segInd).MatchingPoints;
                    mPts=[mPts,addedPts];%#ok<AGROW>
                    mPtsSegInd=[mPtsSegInd,segInd*...
                    ones(1,size(addedPts,2))];%#ok<AGROW>
                end
            else
                mPts=zeros(3,0);
                mPtsSegInd=[];
                nodes=size(obj.wireNodes,2);
                for nodeIdx=1:nodes-1
                    segmentInitEdge=obj.wireNodes(:,nodeIdx);
                    segmentEndEdge=obj.wireNodes(:,nodeIdx+1);
                    if obj.isNFSeg(nodeIdx)
                        MatPNum=obj.nMatchPtNFSeg;
                    else
                        segmentLen=sqrt(sum((segmentEndEdge-...
                        segmentInitEdge).^2));
                        MatPNum=max(1,...
                        ceil(segmentLen/obj.maxMatchPtDist));
                        MatPNum=min(obj.maxnMatchPt,MatPNum);
                    end
                    MatPDeltaVec=(segmentEndEdge-segmentInitEdge)/MatPNum;
                    mPts=[mPts,segmentInitEdge+...
                    ((1:MatPNum)-0.5).*MatPDeltaVec];%#ok<AGROW>
                    mPtsSegInd=[mPtsSegInd...
                    ,nodeIdx*ones(1,MatPNum)];%#ok<AGROW>
                end
            end
        end

        function ConnectSegments(obj,varargin)
            hwait=[];
            extraArgs={};
            if nargin>1
                hwait=varargin{1};
                if nargin>2
                    extraArgs=varargin(2);
                end
            end
            if obj.UpdateWaitBar(hwait)
                return;
            end
            if obj.isNFSeg(1)
                obj.Segments=...
                em.wire.solver.BasicPECWireSegment(...
                obj.wireNodes(:,1),obj.wireNodes(:,2),...
                obj.SegmentRadius,obj.Medium,obj.Freqs,[],...
                obj.nMatchPtNFSeg,[],extraArgs{:});
            else
                obj.Segments=...
                em.wire.solver.BasicPECWireSegment(...
                obj.wireNodes(:,1),obj.wireNodes(:,2),...
                obj.SegmentRadius,obj.Medium,obj.Freqs,...
                obj.maxMatchPtDist,[1,obj.maxnMatchPt],[],...
                extraArgs{:});
            end
            if obj.EdgeType(1)==1
                if obj.UpdateWaitBar(hwait)
                    return;
                end
                obj.Terminations=...
                em.wire.solver.BasicPECWireTermination(...
                obj.Segments(1),0,obj.Medium,obj.Freqs,...
                extraArgs{:});
                obj.PrevParts=obj.Terminations;
            else
                obj.PrevParts=[];
            end
            nodes=size(obj.wireNodes,2);
            for nodeIdx=2:nodes-1
                if obj.UpdateWaitBar(hwait)
                    return;
                end
                if obj.isNFSeg(nodeIdx)
                    obj.Segments(nodeIdx)=...
                    em.wire.solver.BasicPECWireSegment(...
                    obj.wireNodes(:,nodeIdx),...
                    obj.wireNodes(:,nodeIdx+1),obj.SegmentRadius,...
                    obj.Medium,obj.Freqs,[],obj.nMatchPtNFSeg,...
                    [],extraArgs{:});
                else
                    obj.Segments(nodeIdx)=...
                    em.wire.solver.BasicPECWireSegment(...
                    obj.wireNodes(:,nodeIdx),...
                    obj.wireNodes(:,nodeIdx+1),obj.SegmentRadius,...
                    obj.Medium,obj.Freqs,obj.maxMatchPtDist,...
                    [1,obj.maxnMatchPt],[],extraArgs{:});
                end
            end



            for nodeIdx=2:nodes-1
                if obj.UpdateWaitBar(hwait)
                    return;
                end
                if nodeIdx==2
                    obj.Connections=...
                    em.wire.solver.BasicPECWireConnection(...
                    obj.Segments(nodeIdx-1),1,...
                    obj.Segments(nodeIdx),0,obj.Medium,obj.Freqs,...
                    [],[],extraArgs{:});
                else
                    obj.Connections(nodeIdx-1)=...
                    em.wire.solver.BasicPECWireConnection(...
                    obj.Segments(nodeIdx-1),1,obj.Segments(nodeIdx),...
                    0,obj.Medium,obj.Freqs,[],[],extraArgs{:});
                end
            end
            if obj.EdgeType(2)==1
                if obj.UpdateWaitBar(hwait)
                    return;
                end
                obj.Terminations((obj.EdgeType(1)==1)+1)=...
                em.wire.solver.BasicPECWireTermination(...
                obj.Segments(nodes-1),1,obj.Medium,obj.Freqs,...
                extraArgs{:});
                obj.NextParts=obj.Terminations((obj.EdgeType(1)==1)+1);
            else
                obj.NextParts=[];
            end
        end

        function PopulateEMSolution(~)


        end
    end

    methods(Hidden)
        function UpdatePartData(~)


        end
    end

    methods(Static,Hidden)
        function wasCancelled=UpdateWaitBar(hwait)
            wasCancelled=false;
            if~isempty(hwait)

                if getappdata(hwait,'canceling')
                    wasCancelled=true;
                else
                    partInd=getappdata(hwait,'partInd');
                    numParts=getappdata(hwait,'numParts');
                    msg=sprintf(['Populating matrices for %d/%d '...
                    ,'wire parts'],partInd,numParts);
                    waitbar(partInd/numParts,hwait,msg);
                    setappdata(hwait,'partInd',partInd+1);
                end
            end

        end

    end

end