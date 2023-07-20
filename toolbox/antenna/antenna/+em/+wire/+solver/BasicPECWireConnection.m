classdef BasicPECWireConnection<em.wire.solver.BasicWirePart
    properties
        PathLenVsMaxRadius=3;
        nMatchPerMinPathLen=2;

PrevParts
PrevSegSides
NextParts
NextSegSides

JpathsNum

JPathLen
JPathMatPNum
JPathMatP
KirchoffSign

AffectedByOtherPartsZ
AffectingOtherPartsZ
AffectedByOtherPartsEx
AffectingOtherPartsEx
Medium
MatchingPoints
Freqs
    end
    methods
        function obj=BasicPECWireConnection(prevSeg,prevSegSide,...
            nextSeg,nextSegSide,medium,freqs,varargin)
            if nargin>0
                obj.PrevParts=prevSeg;
                obj.PrevSegSides=prevSegSide;
                obj.NextParts=nextSeg;
                obj.NextSegSides=nextSegSide;

                obj.AffectedByOtherPartsZ=true;


                obj.AffectingOtherPartsZ=false;


                obj.AffectedByOtherPartsEx=false;


                obj.AffectingOtherPartsEx=false;



                if nargin>4
                    if(numel(freqs)~=numel(obj.PrevParts(1).Freqs)||...
                        any(freqs~=obj.PrevParts(1).Freqs))||...
                        (numel(freqs)~=...
                        numel(obj.NextParts(1).Freqs)||...
                        any(freqs~=obj.NextParts(1).Freqs))
                        error(['Frequencies of connection must '...
                        ,'correspond to those of the connected '...
                        ,'segments']);
                    end

                    obj.ConnectSegs;

                    obj.Medium=medium;





                    obj.MatchingPoints=...
                    prevSeg.SegmentEdges(prevSegSide+1,:);
                    if nargin>6&&~isempty(varargin{1})
                        obj.PathLenVsMaxRadius=varargin{1};
                        obj.nMatchPerMinPathLen=varargin{2};
                    end
                    obj.SetPathData;

                    obj.Freqs=freqs;
                    if nargin<=8||~strcmp(varargin{3},'BuildOnly')
                        obj.PopulateEMSolution(freqs);
                    else
                        obj.PopulateEMSolution(freqs,[],'BuildOnly');
                    end
                end
            end
        end

        function Initialize(obj,medium,freqs,varargin)



            if(numel(freqs)~=numel(obj.PrevParts(1).Freqs)||...
                any(freqs~=obj.PrevParts(1).Freqs))||...
                (numel(freqs)~=...
                numel(obj.NextParts(1).Freqs)||...
                any(freqs~=obj.NextParts(1).Freqs))
                error(['Frequencies of connection must '...
                ,'correspond to those of the connected segments']);
            end
            if isempty(obj.Medium)

                obj.ConnectSegs;

                obj.Medium=medium;





                obj.MatchingPoints=...
                obj.PrevParts.SegmentEdges(obj.PrevSegSides+1,:);
                if nargin>3&&~isempty(varargin{1})
                    obj.PathLenVsMaxRadius=varargin{1};
                    obj.nMatchPerMinPathLen=varargin{2};
                end
                obj.SetPathData;

                if nargin<=5||~strcmp(varargin{3},'BuildOnly')
                    obj.PopulateEMSolution(freqs);
                else
                    obj.PopulateEMSolution(freqs,[],'BuildOnly');
                end
            else
                if obj.Medium~=medium
                    error(['Connection can only be placed in a '...
                    ,'single medium']);
                end
                if nargin>3&&~isempty(varargin{1})&&...
                    (obj.PathLenVsMaxRadius~=varargin{1}||...
                    obj.nMatchPerMinPathLen~=varargin{2})
                    error(['Changing ''r2NFSegLenRatio'' or '...
                    ,'''nMatchPtNFSeg'' of previously initialized '...
                    ,'wire is not supported']);
                end
                [freqsTot,ia]=sort(cat(3,obj.Freqs,...
                freqs(:,:,~squeeze(ismembertol(freqs,...
                obj.Freqs,eps(max(freqs)),...
                'DataScale',1)))));
                isNewFreqInd=squeeze(ia>length(obj.Freqs));
                if any(isNewFreqInd)
                    obj.Freqs=freqsTot;
                    obj.PopulateEMSolution(freqsTot(isNewFreqInd),...
                    isNewFreqInd);
                end
            end
        end

    end

    methods(Access=protected)
        function ConnectSegs(obj)
            prevSeg=obj.PrevParts;
            nextSeg=obj.NextParts;

            if obj.PrevSegSides==0
                obj.PrevParts=obj.ProcessPrevNextSeg(prevSeg,0);
                obj.KirchoffSign(1)=-1;
                if isempty(prevSeg.PrevParts)
                    prevSeg.PrevParts=obj;
                else
                    error(['Attempt to connect to a segment that is '...
                    ,'already connected to a different wire part']);
                end
            else
                obj.PrevParts=obj.ProcessPrevNextSeg(prevSeg,1);
                obj.KirchoffSign(1)=1;
                if isempty(prevSeg.NextParts)
                    prevSeg.NextParts=obj;
                else
                    error(['Attempt to connect to a segment that is '...
                    ,'already connected to a different wire part']);
                end
            end

            if length(obj.NextSegSides)~=length(nextSeg)
                error(['The length of the vector of the next segement '...
                ,'sides must equal the number of next segments']);
            end
            for nextSegInd=1:length(obj.NextSegSides)
                if obj.NextSegSides(nextSegInd)==0
                    obj.NextParts(nextSegInd)=...
                    obj.ProcessPrevNextSeg(nextSeg,0);
                    obj.KirchoffSign(1+nextSegInd)=-1;
                    if isempty(nextSeg(nextSegInd).PrevParts)
                        nextSeg(nextSegInd).PrevParts=obj;
                    else
                        error(['Attempt to connect to a segment that is '...
                        ,'already connected to a different wire part']);
                    end
                else
                    obj.NextParts(nextSegInd)=...
                    obj.ProcessPrevNextSeg(nextSeg,1);
                    obj.KirchoffSign(1+nextSegInd)=1;
                    if isempty(nextSeg(nextSegInd).NextParts)
                        nextSeg(nextSegInd).NextParts=obj;
                    else
                        error(['Attempt to connect to a segment that is '...
                        ,'already connected to a different wire part']);
                    end
                end
            end
        end

        function SetPathData(obj)
            prevSeg=obj.PrevParts;
            nextSeg=obj.NextParts;

            obj.JpathsNum=1+length(nextSeg);
            maxRadius=max([prevSeg.SegmentRadius,...
            [nextSeg.SegmentRadius]]);
            obj.JPathLen{1}=obj.PathLenVsMaxRadius*maxRadius;
            minRadius=min([prevSeg.SegmentRadius,...
            [nextSeg.SegmentRadius]]);
            obj.JPathMatPNum{1}=...
            obj.nMatchPerMinPathLen*prevSeg.SegmentRadius/minRadius;
            obj.JPathMatP{1}=...
            em.wire.solver.BasicPECWireConnection.CalcMatchPts(...
            prevSeg,obj.PrevSegSides,obj.JPathLen{1},...
            obj.JPathMatPNum{1});
            for nextSegInd=1:length(nextSeg)
                obj.JPathLen{nextSegInd+1}=obj.PathLenVsMaxRadius*...
                maxRadius;
                obj.JPathMatPNum{nextSegInd+1}=...
                obj.nMatchPerMinPathLen*...
                nextSeg(nextSegInd).SegmentRadius/minRadius;
                obj.JPathMatP{nextSegInd+1}=...
                em.wire.solver.BasicPECWireConnection.CalcMatchPts(...
                nextSeg(nextSegInd),obj.NextSegSides(nextSegInd),...
                obj.JPathLen{nextSegInd+1},...
                obj.JPathMatPNum{nextSegInd+1});
            end
        end

        function PopulateEMSolution(obj,freqs,varargin)



            if nargin==2||...
                (nargin==4&&strcmp(varargin{2},'BuildOnly'))

                if all(obj.Medium.EMSolObj.Freqs==freqs)
                    [ZEnteries,exEnteries]=...
                    obj.Medium.EMSolObj.AddConnection(obj);
                else
                    error(['Frequecny of Imedance matrix in medium of '...
                    ,'segement is different than specified frequency']);
                end
                if(nargin==4&&strcmp(varargin{2},'BuildOnly'))
                    return
                end
            else
                [ZEnteries,exEnteries]=...
                obj.Medium.EMSolObj.GetConnectionEnteries(obj);
            end
            ZEnteries=obj.CalcZEnteries(ZEnteries,freqs);
            exEnteries=obj.CalcexEnteries(exEnteries,freqs);
            obj.Medium.EMSolObj.Fill(ZEnteries,exEnteries,varargin{:});
        end

        function ZEnteries=CalcZEnteries(obj,ZEnteries,freqs)



            if any(cellfun(@(x)numel(x),...
                {ZEnteries(1:1+length(obj.NextParts)).Rows})~=1)&&...
                any(cellfun(@(x)numel(x),...
                {ZEnteries(2+length(obj.NextParts):end).Rows})~=...
                length(obj.NextParts))
                error(['only one row should be allocated '...
                ,'for connections per each ZEntery in the '...
                ,'impedance matrix']);
            end


            Prevseg=obj.PrevParts;
            if obj.PrevSegSides==0
                Sm=0;
            else
                Sm=Prevseg.SegmentLength;
            end




            Zmat=obj.Medium.EMSolObj.ZmatObj;
            segInd=find(ismember([Zmat.PartsMap(:).Part],...
            Prevseg),1);
            PmVals=Zmat.Matrix(Zmat.PartsMap(segInd).Rows,...
            Zmat.PartsMap(segInd).Cols);
            maxPm=max(max(abs(PmVals)));

            for polyDegreeInd=0:Prevseg.PolyDegree
                ZEnteries(1).Vals(1,polyDegreeInd+1,:)=repmat(...
                obj.KirchoffSign(1)*Prevseg.CalcSegICoeffs(...
                Sm,...
                polyDegreeInd)*maxPm,1,1,length(freqs));
            end


            for nextSegInd=1:length(obj.NextParts)
                Nextseg=obj.NextParts(nextSegInd);
                if obj.NextSegSides(nextSegInd)==0
                    Sm=0;
                else
                    Sm=Nextseg.SegmentLength;
                end
                for polyDegreeInd=0:Nextseg.PolyDegree
                    ZEnteries(nextSegInd+1).Vals(1,polyDegreeInd+1,:)=...
                    repmat(obj.KirchoffSign(1+nextSegInd)*...
                    Nextseg.CalcSegICoeffs(Sm,polyDegreeInd)*maxPm,...
                    1,1,length(freqs));
                end
            end







            for OtherPartInd=nextSegInd+2:length(ZEnteries)
                OtherPart=ZEnteries(OtherPartInd).OtherPart;
                switch class(OtherPart)
                case 'em.wire.solver.BasicPECWireSegment'

                    if numel(ZEnteries(OtherPartInd).Rows)~=...
                        (obj.JpathsNum-1)
                        error(['Only one row should be allocated '...
                        ,'for connections per each ZEntery in the '...
                        ,'impedance matrix']);
                    end
                    ZEnteries(OtherPartInd).Vals(1:obj.JpathsNum-1,...
                    1:OtherPart.PolyDegree+1,1:length(freqs))=0;
                    d=norm(obj.MatchingPoints-OtherPart.SegmentMid);
                    nR=2*d/OtherPart.SegmentLength;
                    for jpathInd=2:obj.JpathsNum

                        matchingSeg=obj.PrevParts;
                        SumFieldsPrev=zeros(1,OtherPart.PolyDegree+1);
                        SumFieldsPrev=SumFieldsPrev+...
                        sum(OtherPart.Medium.CalcSegECoeffs(...
                        obj.JPathMatP{1},...
                        matchingSeg.SegmentUnitVec,...
                        OtherPart.SegmentEdges(1,:),...
                        OtherPart.SegmentUnitVec,...
                        OtherPart.SegmentLength,...
                        0:OtherPart.PolyDegree,...
                        OtherPart.SegmentRadius,...
                        nR,...
                        freqs),1)/obj.JPathMatPNum{1};






                        matchingSeg=obj.NextParts(jpathInd-1);
                        SumFieldsNext=zeros(1,OtherPart.PolyDegree+1);
                        SumFieldsNext=SumFieldsNext+...
                        sum(OtherPart.Medium.CalcSegECoeffs(...
                        obj.JPathMatP{jpathInd},...
                        matchingSeg.SegmentUnitVec,...
                        OtherPart.SegmentEdges(1,:),...
                        OtherPart.SegmentUnitVec,...
                        OtherPart.SegmentLength,...
                        0:OtherPart.PolyDegree,...
                        OtherPart.SegmentRadius,...
                        nR,...
                        freqs),1)/obj.JPathMatPNum{jpathInd}*...
                        obj.JPathLen{jpathInd}/...
                        obj.JPathLen{1};





                        ZEnteries(OtherPartInd).Vals(jpathInd-1,:,:)=...
                        obj.KirchoffSign(1)*SumFieldsPrev-...
                        obj.KirchoffSign(jpathInd)*SumFieldsNext;
                    end
                otherwise

                    error(['interaction between '...
                    ,'em.wire.solver.BasicPECWireConnection '...
                    ,'currents and ',class(OtherPart)...
                    ,'is currently not supported.']);
                end
            end
        end

        function exEnteries=CalcexEnteries(obj,exEnteries,freqs)


            if numel(exEnteries(1).Indices)~=obj.JpathsNum-1

                error(['Exactly two indices should be allocated '...
                ,'for connection in excitation vector']);
            end
            for jpathInd=2:obj.JpathsNum

                matchingSeg=obj.PrevParts;
                exEnteries(1).Vals(jpathInd-1,:,1:length(freqs))=0;
                SumFieldsPrev=0;
                for matPtInd=1:obj.JPathMatPNum{1}
                    Einc=obj.Medium.EMSolObj.EincFunc(...
                    obj.JPathMatP{1}(matPtInd,:),...
                    obj.Medium,freqs);
                    SumFieldsPrev=SumFieldsPrev+...
                    -(dot(repmat(...
                    matchingSeg.SegmentUnitVec,size(Einc,1),1,...
                    size(Einc,3),size(Einc,4)),Einc,2))/...
                    obj.JPathMatPNum{1};




                end

                matchingSeg=obj.NextParts(jpathInd-1);
                SumFieldsNext=0;
                for matPtInd=1:obj.JPathMatPNum{jpathInd}
                    Einc=obj.Medium.EMSolObj.EincFunc(...
                    obj.JPathMatP{jpathInd}(matPtInd,:),...
                    obj.Medium,freqs);
                    SumFieldsNext=SumFieldsNext+...
                    -(dot(repmat(...
                    matchingSeg.SegmentUnitVec,size(Einc,1),1,...
                    size(Einc,3),size(Einc,4)),Einc,2))/...
                    obj.JPathMatPNum{jpathInd}*...
                    obj.JPathLen{jpathInd}/obj.JPathLen{1};




                end
                exEnteries(1).Vals(jpathInd-1,:,:)=...
                obj.KirchoffSign(1)*SumFieldsPrev-...
                obj.KirchoffSign(jpathInd)*SumFieldsNext;
            end


            exEnteries(1).Vals=exEnteries(1).Vals./...
            (-1j*(2*pi*freqs)*(obj.Medium.mu_r*obj.Medium.mu0)/(4*pi));
        end
    end

    methods(Hidden)
        function UpdatePartData(~,~,varargin)


        end
    end

    methods(Static)
        function matchPts=...
            CalcMatchPts(seg,side,integPathLen,nMatchPerPathLen)
            MatPRatio=...
            seg.SegmentLength/integPathLen*(nMatchPerPathLen);
            MatPDeltaVec=(seg.SegmentEdges(2,:)-seg.SegmentEdges(1,:))...
            /MatPRatio;

            matchPts=seg.SegmentEdges(side+1,:)+...
            (-1)^(side)*(((1:nMatchPerPathLen)-0.5).').*MatPDeltaVec;
        end

        function SegOut=ProcessPrevNextSeg(wirePartIn,side)
            if isa(wirePartIn,'em.wire.solver.BasicPECWire')


                if~isempty(wirePartIn.Segments)
                    if side==0
                        SegOut=wirePartIn.Segments(1);
                    else
                        SegOut=wirePartIn.Segments(end);
                    end
                else
                    error(['BasicPECWire elements must be already '...
                    ,'initialized when connected']);
                end
            elseif isa(wirePartIn,'em.wire.solver.BasicPECWireSegment')
                SegOut=wirePartIn;
            else
                error(['conncetors can only be connected to '...
                ,'segments or wires']);

            end
        end

    end

end