classdef DeltaGapPECWire<em.wire.solver.BasicPECWire





    properties
Voltages
GapPositions_
GapNodes
    end
    methods
        function obj=DeltaGapPECWire(wireNodesOrig,segmentRadius,...
            edgeType,GapPositions_,medium,V,freqs,varargin)










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
                obj.GapPositions_=GapPositions_;
                if nargin>4
                    obj.Medium=medium;
                    if nargin>7&&~isempty(varargin{1})
                        obj.r2NFSegLenRatio=varargin{1};
                        obj.nMatchPtNFSeg=varargin{2};
                    end
                    if nargin>9&&~isempty(varargin{3})
                        obj.maxEdgeLength=varargin{3};
                    else
                        obj.maxEdgeLength=obj.Medium.Lambda(freqs(end))/8;
                    end
                    if nargin>10&&~isempty(varargin{4})
                        obj.growthRate=varargin{4};
                    else
                        obj.growthRate=2.0;
                    end
                    if nargin>11&&~isempty(varargin{5})
                        obj.maxMatchPtDist=varargin{5};
                    else
                        obj.maxMatchPtDist=...
                        obj.Medium.Lambda(freqs(end))/8;
                    end
                    if nargin>12&&~isempty(varargin{6})
                        obj.maxnMatchPt=varargin{6};
                    else
                        obj.maxnMatchPt=6;
                    end
                    obj.nMatchPtNFSeg=min(obj.maxnMatchPt,...
                    obj.nMatchPtNFSeg);
                    if size(V,1)~=length(obj.GapPositions_)
                        if size(V,1)==1&&...
                            size(V,2)==length(obj.GapPositions_)
                            V=V.';
                        else
                            error(['column size of voltages matrix '...
                            ,'must be eqaul to the length of '...
                            ,'GapPositions_ vector']);
                        end
                    end
                    obj.Medium.EMSolObj.ResetExVec(size(V,2));
                    obj.Voltages=V;

                    [obj.wireNodes,obj.GapNodes,obj.isNFSeg]=...
                    obj.FindWireNodes(wireNodesOrig,...
                    edgeType,GapPositions_);
                    [obj.MatchingPoints,obj.MatchingPointsSegInd]=...
                    obj.FindMatchPts;


                    if nargin<=13||~varargin{7}
                        obj.Freqs=freqs;
                        obj.Medium.EMSolObj.AddFreqs(freqs,...
                        true(length(freqs),1));
                        obj.ConnectSegments;
                    end
                end
            end
        end

        function Initialize(obj,medium,V,freqs,varargin)



            if isempty(obj.Medium)
                obj.Medium=medium;
                if~isempty(V)
                    if size(V,1)~=length(obj.GapPositions_)
                        if size(V,1)==1&&...
                            size(V,2)==length(obj.GapPositions_)
                            V=V.';
                        else
                            error(['column size of voltages matrix '...
                            ,'must be eqaul to the length of '...
                            ,'GapPositions_ vector']);
                        end
                    end
                    obj.Medium.EMSolObj.ResetExVec(size(V,2));
                    obj.Voltages=V;
                end
                if nargin>4&&~isempty(varargin{1})
                    obj.r2NFSegLenRatio=varargin{1};
                    obj.nMatchPtNFSeg=varargin{2};
                end
                if nargin>6&&~isempty(varargin{3})
                    obj.maxEdgeLength=varargin{3};
                else
                    obj.maxEdgeLength=obj.Medium.Lambda(freqs(end))/8;
                end
                if nargin>7&&~isempty(varargin{4})
                    obj.growthRate=varargin{4};
                else
                    obj.growthRate=2.0;
                end
                if nargin>8&&~isempty(varargin{5})
                    obj.maxMatchPtDist=varargin{5};
                else
                    obj.maxMatchPtDist=obj.Medium.Lambda(freqs(end))/8;
                end
                if nargin>9&&~isempty(varargin{6})
                    obj.maxnMatchPt=varargin{6};
                else
                    obj.maxnMatchPt=6;
                end
                obj.nMatchPtNFSeg=min(obj.maxnMatchPt,obj.nMatchPtNFSeg);

                [obj.wireNodes,obj.GapNodes,obj.isNFSeg]=...
                obj.FindWireNodes(obj.wireNodesOrig,obj.EdgeType,...
                obj.GapPositions_);
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
                    if nargin<=10||~varargin{7}
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
                if nargin>5&&(~isempty(varargin{1})&&...
                    (obj.r2NFSegLenRatio~=varargin{1})||...
                    (~isempty(varargin{2})&&...
                    obj.nMatchPtNFSeg~=varargin{2}))
                    error(['Changing ''r2NFSegLenRatio'' or '...
                    ,'''nMatchPtNFSeg'' of previously initialized '...
                    ,'wire is not supported']);
                end
                if~isempty(V)
                    if size(V,1)~=length(obj.GapPositions_)
                        if size(V,1)==1&&...
                            size(V,2)==length(obj.GapPositions_)
                            V=V.';
                        else
                            error(['column size of voltages matrix '...
                            ,'must be eqaul to the length of '...
                            ,'GapPositions_ vector']);
                        end
                    end
                    obj.Medium.EMSolObj.ResetExVec(size(V,2));
                end
                ExistingWireFreq=obj.Freqs;
                [freqsTotChk,iaWireFreq]=sort(cat(3,ExistingWireFreq,...
                freqs(:,:,~squeeze(ismembertol(freqs,...
                ExistingWireFreq,eps(max(freqs)),...
                'DataScale',1)))));%#ok<*ASGLU>
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
                if~isempty(V)
                    obj.Voltages=V;
                    gapConns=obj.Connections(obj.GapNodes(2:end-1));
                    for connInd=1:length(gapConns)
                        gapConns(connInd).PopulateEMSolution(...
                        obj.Medium.EMSolObj.Freqs,[],V);
                    end

                end
            end
        end

        function GapPos=GapLocations(obj)
            wireNodesDiff=diff(obj.wireNodesOrig,[],2);
            WireSegLens=sqrt(sum(wireNodesDiff.^2));
            WireLens=[0,squeeze(cumsum(WireSegLens))];
            WireLens_=WireLens/WireLens(end);
            for GapPosInd=1:length(obj.GapPositions_)
                GapSeg_curr=find(obj.GapPositions_(GapPosInd)<...
                WireLens_,1)-1;
                GapPos_=obj.GapPositions_(GapPosInd)-...
                WireLens_(GapSeg_curr);
                GapSegDiff=(obj.wireNodesOrig(:,GapSeg_curr+1)-...
                obj.wireNodesOrig(:,GapSeg_curr))/...
                sqrt(sum(wireNodesDiff(:,GapSeg_curr).^2));
                GapPos(:,GapPosInd)=obj.wireNodesOrig(:,GapSeg_curr)+...
                GapPos_*WireLens(end)*GapSegDiff;%#ok<AGROW>
            end
        end

        function IGap=CalcIGap(obj)
            gapConns=obj.Connections(obj.GapNodes(2:end-1));
            if~isempty(gapConns)
                IGap=gapConns(1).CalcIGap;
                if length(gapConns)>1
                    IGap=[IGap;zeros(length(gapConns)-1,1,...
                    size(IGap,3))];
                    for gapInd=2:length(gapConns)
                        IGap(gapInd,:,:)=gapConns(gapInd).CalcIGap;
                    end
                end
            else
                IGap=[];
            end
        end

        function Zin=CalcZin(obj)
            gapConns=obj.Connections(obj.GapNodes(2:end-1));
            if~isempty(gapConns)
                Zin=gapConns(1).CalcZin;
                if length(gapConns)>1
                    Zin=[Zin;zeros(length(gapConns)-1,1,size(Zin,3))];
                    for gapInd=2:length(gapConns)
                        Zin(gapInd,:,:)=gapConns(gapInd).CalcZin;
                    end
                end
            else
                Zin=[];
            end
        end

        function ExMat=CreateExMat(obj,freqs,ExVecOrig)
            gapConns=obj.Connections(obj.GapNodes(2:end-1));
            ExMat(:,1,:)=gapConns(1).CreateExVecReplica(freqs,...
            true(length(freqs),1),ExVecOrig,1);
            for gapInd=2:length(gapConns)
                ExMat(:,1,:)=gapConns(1).CreateExVecReplica(freqs,[],...
                ExMat(:,1,:),1);
            end
        end
    end

    methods(Access=protected)
        function[wireNodes,GapNodes,isNFSeg]=FindWireNodes(obj,...
            wireNodes,edgeType,GapPositions_)


            isNFSeg=zeros(size(wireNodes,2)-1,1);
            GapNodesOrig=false(1,size(wireNodes,2));
            GapSeg=zeros(size(GapPositions_));
            for GapPosInd=1:length(GapPositions_)
                wireNodesDiff=diff(wireNodes,[],2);
                WireSegLens=sqrt(sum(wireNodesDiff.^2));
                WireLens=[0,squeeze(cumsum(WireSegLens))];
                WireLens_=WireLens/WireLens(end);
                GapSeg(GapPosInd)=...
                find((GapPositions_(GapPosInd)+sqrt(eps))<WireLens_,1)-1;
                GapSeg_curr=GapSeg(GapPosInd);
                NFSegLen_=obj.r2NFSegLenRatio*obj.SegmentRadius/...
                WireLens(end);

                GapPos_=GapPositions_(GapPosInd)-WireLens_(GapSeg_curr);
                GapNFSegEdge0_=GapPos_-NFSegLen_;
                GapNFSegEdge1_=GapPos_+NFSegLen_;
                if WireLens_(GapSeg_curr)<GapPositions_(GapPosInd)-sqrt(eps)




                    if~isNFSeg(GapSeg_curr)
                        GapSegDiff=(wireNodes(:,GapSeg_curr+1)-...
                        wireNodes(:,GapSeg_curr))/...
                        sqrt(sum(wireNodesDiff(:,GapSeg_curr).^2));




                        if((GapNFSegEdge0_-NFSegLen_)<0)
                            GapNFSegEdge0=zeros(3,0);
                            added1StSeg=0;
                            isNFSeg(GapSeg_curr)=1;
                        else
                            GapNFSegEdge0=wireNodes(:,GapSeg_curr)+...
                            GapNFSegEdge0_*WireLens(end)*GapSegDiff;
                            added1StSeg=1;
                            isNFSeg=[isNFSeg(1:GapSeg_curr);1;...
                            isNFSeg(GapSeg_curr:end)];
                            GapNodesOrig=[GapNodesOrig(1:GapSeg_curr)...
                            ,false,GapNodesOrig(GapSeg_curr+1:end)];
                        end





                        if((GapNFSegEdge1_+NFSegLen_)>...
                            (WireLens_(GapSeg_curr+1)-...
                            WireLens_(GapSeg_curr)))
                            GapNFSegEdge1=zeros(3,0);
                            isNFSeg=[isNFSeg(1:GapSeg_curr+...
                            added1StSeg);isNFSeg(GapSeg_curr+...
                            added1StSeg:end)];
                            GapNodesOrig=[GapNodesOrig(1:GapSeg_curr+...
                            added1StSeg),true,GapNodesOrig(...
                            GapSeg_curr+added1StSeg+1:end)];
                        else
                            GapNFSegEdge1=wireNodes(:,GapSeg_curr)+...
                            GapNFSegEdge1_*WireLens(end)*GapSegDiff;
                            isNFSeg=[isNFSeg(1:GapSeg_curr+...
                            added1StSeg);1;isNFSeg(GapSeg_curr+...
                            added1StSeg+1:end)];
                            GapNodesOrig=[GapNodesOrig(1:GapSeg_curr+...
                            added1StSeg),true,false,GapNodesOrig(...
                            GapSeg_curr+added1StSeg+1:end)];
                        end
                        GapPos=wireNodes(:,GapSeg_curr)+GapPos_*...
                        WireLens(end)*GapSegDiff;
                        wireNodes=[wireNodes(:,1:GapSeg_curr)...
                        ,GapNFSegEdge0,GapPos,GapNFSegEdge1...
                        ,wireNodes(:,GapSeg_curr+1:end)];
                    else
                        error(['Cannot place Delta Gap source within a '...
                        ,'wire segment that is designated as near-'...
                        ,'field (a segment neighboring an edge or '...
                        ,'another source)']);
                    end
                else

                    if~isNFSeg(GapSeg_curr)&&~isNFSeg(GapSeg_curr-1)




                        GapSegDiff=(wireNodes(:,GapSeg_curr+1)-...
                        wireNodes(:,GapSeg_curr))/...
                        sqrt(sum(wireNodesDiff(:,GapSeg_curr).^2));
                        if((GapNFSegEdge0_-NFSegLen_)<...
                            (WireLens_(GapSeg_curr-1)-...
                            WireLens_(GapSeg_curr)))
                            GapNFSegEdge0=zeros(3,0);
                            added1StSeg=0;
                            isNFSeg(GapSeg_curr-1)=1;
                        else
                            GapNFSegEdge0=wireNodes(:,GapSeg_curr)+...
                            GapNFSegEdge0_*WireLens(end)*GapSegDiff;
                            added1StSeg=1;
                            isNFSeg=[isNFSeg(1:GapSeg_curr-1);1;...
                            isNFSeg(GapSeg_curr:end)];
                            GapNodesOrig=[GapNodesOrig(1:GapSeg_curr-1)...
                            ,false,GapNodesOrig(GapSeg_curr+1:end)];
                        end





                        if((GapNFSegEdge1_+NFSegLen_)>...
                            (WireLens_(GapSeg_curr+1)-...
                            WireLens_(GapSeg_curr)))
                            GapNFSegEdge1=zeros(3,0);
                            isNFSeg=[isNFSeg(1:GapSeg_curr-1+...
                            added1StSeg);isNFSeg(GapSeg_curr-1+...
                            added1StSeg:end)];
                            GapNodesOrig=[GapNodesOrig(...
                            1:GapSeg_curr-1+added1StSeg),true...
                            ,GapNodesOrig((GapSeg_curr+...
                            added1StSeg+1):end)];
                        else
                            GapNFSegEdge1=wireNodes(:,GapSeg_curr)+...
                            GapNFSegEdge1_*WireLens(end)*GapSegDiff;
                            isNFSeg=[isNFSeg(1:GapSeg_curr-1+...
                            added1StSeg);1;isNFSeg(GapSeg_curr+...
                            added1StSeg:end)];
                            GapNodesOrig=[GapNodesOrig(...
                            1:GapSeg_curr-1+added1StSeg),true...
                            ,false,GapNodesOrig((GapSeg_curr+...
                            added1StSeg):end)];
                        end
                        GapPos=wireNodes(:,GapSeg_curr)+GapPos_*...
                        WireLens(end)*GapSegDiff;
                        wireNodes=[wireNodes(:,1:GapSeg_curr-1)...
                        ,GapNFSegEdge0,GapPos,GapNFSegEdge1...
                        ,wireNodes(:,GapSeg_curr+1:end)];
                    else
                        error(['Cannot place Delta Gap source on a node'...
                        ,' neighboring a wire segment that is '...
                        ,'designated as near-field (a segment '...
                        ,'neighboring an edge or another source)']);
                    end
                end

            end
            [wireNodes,isNFSeg,isOrigNodes]=...
            FindWireNodes@em.wire.solver.BasicPECWire(obj,...
            wireNodes,isNFSeg,edgeType);
            GapNodes=false(size(isOrigNodes));
            GapNodes(isOrigNodes)=GapNodesOrig;
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
                    MatchPtsInitEdge=obj.wireNodes(:,nodeIdx);
                    MatchPtsEndEdge=obj.wireNodes(:,nodeIdx+1);
                    if obj.isNFSeg(nodeIdx)
                        if obj.GapNodes(nodeIdx)
                            MatchPtsEdgeDiff=MatchPtsEndEdge-...
                            MatchPtsInitEdge;
                            MatchPtsInitEdge=MatchPtsInitEdge+...
                            MatchPtsEdgeDiff/2;
                            MatPNum=ceil(obj.nMatchPtNFSeg/2);
                        elseif obj.GapNodes(nodeIdx+1)
                            MatchPtsEdgeDiff=MatchPtsEndEdge-...
                            MatchPtsInitEdge;
                            MatchPtsEndEdge=MatchPtsEndEdge-...
                            MatchPtsEdgeDiff/2;
                            MatPNum=ceil(obj.nMatchPtNFSeg/2);
                        else
                            MatPNum=obj.nMatchPtNFSeg;
                        end
                    else
                        segmentLen=sqrt(sum((MatchPtsEndEdge-...
                        MatchPtsInitEdge).^2));
                        MatPNum=max(1,...
                        ceil(segmentLen/obj.maxMatchPtDist));
                        MatPNum=min(obj.maxnMatchPt,MatPNum);
                    end
                    MatPDeltaVec=(MatchPtsEndEdge-MatchPtsInitEdge)/...
                    MatPNum;
                    mPts=[mPts,MatchPtsInitEdge+...
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
                    MatchPtsInitEdge=obj.wireNodes(:,nodeIdx);
                    MatchPtsEndEdge=obj.wireNodes(:,nodeIdx+1);
                    if obj.GapNodes(nodeIdx)
                        MatchPtsEdgeDiff=MatchPtsEndEdge-MatchPtsInitEdge;
                        MatchPtsInitEdge=MatchPtsInitEdge+...
                        MatchPtsEdgeDiff/2;
                        nMatchPts=ceil(obj.nMatchPtNFSeg/2);
                    elseif obj.GapNodes(nodeIdx+1)
                        MatchPtsEdgeDiff=MatchPtsEndEdge-MatchPtsInitEdge;
                        MatchPtsEndEdge=MatchPtsEndEdge-...
                        MatchPtsEdgeDiff/2;
                        nMatchPts=ceil(obj.nMatchPtNFSeg/2);
                    else
                        nMatchPts=obj.nMatchPtNFSeg;
                    end
                    obj.Segments(nodeIdx)=...
                    em.wire.solver.BasicPECWireSegment(...
                    obj.wireNodes(:,nodeIdx),...
                    obj.wireNodes(:,nodeIdx+1),...
                    obj.SegmentRadius,obj.Medium,obj.Freqs,[],...
                    nMatchPts,[MatchPtsInitEdge,MatchPtsEndEdge],...
                    extraArgs{:});
                else
                    obj.Segments(nodeIdx)=...
                    em.wire.solver.BasicPECWireSegment(...
                    obj.wireNodes(:,nodeIdx),...
                    obj.wireNodes(:,nodeIdx+1),...
                    obj.SegmentRadius,obj.Medium,obj.Freqs,...
                    obj.maxMatchPtDist,[1,obj.maxnMatchPt],[],...
                    extraArgs{:});
                end
            end



            voltages=zeros(length(obj.GapNodes),size(obj.Voltages,2));
            voltages(obj.GapNodes,:)=obj.Voltages;
            for nodeIdx=2:nodes-1
                if obj.UpdateWaitBar(hwait)
                    return;
                end
                if nodeIdx==2
                    if obj.GapNodes(nodeIdx)
                        obj.Connections=...
                        em.wire.solver.DeltaGapPECWireConnection(...
                        obj.Segments(nodeIdx-1),1,...
                        obj.Segments(nodeIdx),0,...
                        obj.Medium,voltages(nodeIdx,:),obj.Freqs,...
                        obj.r2NFSegLenRatio/2,10,extraArgs{:});






                    else
                        obj.Connections=...
                        em.wire.solver.BasicPECWireConnection(...
                        obj.Segments(nodeIdx-1),1,...
                        obj.Segments(nodeIdx),0,obj.Medium,...
                        obj.Freqs,[],[],extraArgs{:});
                    end
                else
                    if obj.GapNodes(nodeIdx)
                        obj.Connections(nodeIdx-1)=...
                        em.wire.solver.DeltaGapPECWireConnection(...
                        obj.Segments(nodeIdx-1),1,...
                        obj.Segments(nodeIdx),0,...
                        obj.Medium,voltages(nodeIdx,:),obj.Freqs,...
                        obj.r2NFSegLenRatio/2,10,extraArgs{:});
                    else
                        obj.Connections(nodeIdx-1)=...
                        em.wire.solver.BasicPECWireConnection(...
                        obj.Segments(nodeIdx-1),1,...
                        obj.Segments(nodeIdx),0,obj.Medium,...
                        obj.Freqs,[],[],extraArgs{:});
                    end
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
    end

    methods(Hidden)
        function UpdatePartData(~)


        end
    end

end