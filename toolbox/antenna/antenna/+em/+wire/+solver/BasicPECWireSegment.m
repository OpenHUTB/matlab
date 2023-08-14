classdef BasicPECWireSegment<em.wire.solver.BasicWirePart

    properties(Constant)
        MinRelDist=0.001;
    end

    properties
SegmentEdges
SegmentMid
SegmentRadius
SegmentLength
SegmentUnitVec

PrevParts
NextParts
AffectedByOtherPartsZ
AffectingOtherPartsZ
Medium
MatchingPoints
PolyDegree
PolyCoeffs
Freqs
Dirty
    end

    methods
        function obj=BasicPECWireSegment(segmentInitEdge,...
            segmentEndEdge,segmentRadius,medium,freqs,varargin)
            narginchk(5,9);
            validateattributes(segmentInitEdge,{'numeric'},...
            {'nonempty','real','numel',3},mfilename,...
            'segment initial edge position');
            segmentInitEdge=segmentInitEdge(:).';
            validateattributes(segmentEndEdge,{'numeric'},...
            {'nonempty','real','numel',3},mfilename,...
            'segment end edge position');
            segmentEndEdge=segmentEndEdge(:).';
            validateattributes(segmentRadius,{'numeric'},...
            {'nonempty','scalar','real','positive'},mfilename,...
            'segment radius');
            validateattributes(freqs,{'numeric'},...
            {'nonempty','real','positive','increasing','size',...
            [1,1,nan]},mfilename,'frequencies');

            obj.SegmentEdges=[segmentInitEdge;segmentEndEdge];
            obj.SegmentRadius=segmentRadius;
            obj.SegmentLength=...
            sqrt(sum((segmentEndEdge-segmentInitEdge).^2));
            obj.SegmentUnitVec=...
            (segmentEndEdge-segmentInitEdge)/obj.SegmentLength;

            obj.PrevParts=[];
            obj.NextParts=[];

            obj.AffectedByOtherPartsZ=true;

            obj.AffectingOtherPartsZ=true;


            obj.Medium=medium;
            if nargin==5
                MatPDelta=(2*pi/obj.Medium.WaveNumber(freqs(end)))/8;
                MatPNum=max(1,ceil(obj.SegmentLength/MatPDelta));
            else
                if isempty(varargin{1})
                    MatPDelta=(2*pi/obj.Medium.WaveNumber(freqs(end)))/8;
                else
                    MatPDelta=varargin{1};
                end
                if nargin>6
                    if isscalar(varargin{2})
                        MatPNum=varargin{2};
                    else
                        if~isempty(varargin{2})
                            MatPNum=max(varargin{2}(1),...
                            ceil(obj.SegmentLength/MatPDelta));
                            MatPNum=min(varargin{2}(2),MatPNum);
                        else
                            MatPNum=max(1,...
                            ceil(obj.SegmentLength/MatPDelta));
                        end
                    end
                    if nargin>7&&~isempty(varargin{3})
                        segmentInitEdge=varargin{3}(:,1).';
                        segmentEndEdge=varargin{3}(:,2).';
                    end
                end
            end
            MatPDeltaVec=(segmentEndEdge-segmentInitEdge)/MatPNum;



            obj.MatchingPoints=segmentInitEdge+...
            (((1:MatPNum)-0.5).').*MatPDeltaVec;
            obj.SegmentMid=(segmentInitEdge+segmentEndEdge)/2;
            obj.PolyDegree=(MatPNum+2)-1;

            obj.PolyCoeffs=zeros(obj.PolyDegree,1,length(freqs));
            obj.Freqs=freqs;
            obj.Dirty=true(length(freqs),1);
            if nargin<=8||~strcmp(varargin{4},'BuildOnly')
                obj.PopulateEMSolution(freqs);
            else
                obj.PopulateEMSolution(freqs,[],'BuildOnly');
            end
        end

        function ICoeffs=CalcSegICoeffs(obj,Sm_,varargin)
            if nargin<3
                om=0:obj.PolyDegree;
            else
                om=varargin{1};
            end
            if numel(Sm_)==1
                ICoeffs=((Sm_-obj.SegmentLength/2)/obj.SegmentLength).^om;
            else
                [omMat,Sm_Mat]=meshgrid(om,Sm_);
                ICoeffs=((Sm_Mat-obj.SegmentLength/2)/obj.SegmentLength).^omMat;
            end
        end

        function IVals=CalcSegIs(obj,Sm_,varargin)
            if nargin<3||isempty(varargin{1})
                if any(obj.Dirty)
                    obj.Medium.Solve;
                end
                polyCoeffs=obj.PolyCoeffs;
            else
                polyCoeffs=varargin{1};
            end
            if nargin<4
                ExInd=1:size(obj.PolyCoeffs,2);
            else
                ExInd=varargin{2};
            end
            IVals=zeros([size(Sm_,2),size(polyCoeffs,[2,3])]);
            for freqInd=1:size(polyCoeffs,3)
                IVals(:,:,freqInd)=obj.CalcSegICoeffs(Sm_)*...
                polyCoeffs(:,ExInd,freqInd);
            end
        end

        function dIdlCoeffs=CalcSegdIdlCoeffs(obj,Sm_,varargin)
            if nargin<3
                om=1:obj.PolyDegree;
            else
                om=varargin{1};
                om=om(om>0);
            end
            if numel(Sm_)==1

                dIdlCoeffs=om.*((Sm_-obj.SegmentLength/2)/obj.SegmentLength).^(om-1)/obj.SegmentLength;
            else
                [omMat,Sm_Mat]=meshgrid(om,Sm_);
                dIdlCoeffs=omMat.*((Sm_Mat-obj.SegmentLength/2)/obj.SegmentLength).^(omMat-1)/obj.SegmentLength;
            end
        end

        function QtagVals=CalcSegQtags(obj,Sm_,varargin)
            if nargin<3||isempty(varargin{1})
                if any(obj.Dirty)
                    obj.Medium.Solve;
                end
                polyCoeffs=obj.PolyCoeffs;
            else
                polyCoeffs=varargin{1};
            end
            if nargin<4
                ExInd=1:size(obj.PolyCoeffs,2);
            else
                ExInd=varargin{2};
            end
            QtagVals=zeros([size(Sm_,2),size(polyCoeffs,[2,3])]);
            for freqInd=1:size(polyCoeffs,3)
                QtagVals(:,:,freqInd)=1j*obj.CalcSegdIdlCoeffs(Sm_)*...
                polyCoeffs(2:end,ExInd,freqInd)/...
                (2*pi*obj.Freqs(freqInd));
            end
        end

        function Fields_cart=CalcFields(obj,rp_,fieldType,varargin)
            if nargin<4||isempty(varargin{1})
                polyCoeffs=obj.PolyCoeffs(:,1,1);
            else
                polyCoeffs=varargin{1};
            end
            if nargin<5
                freq=obj.Medium.EMSolObj.Freqs;
            else
                freq=varargin{2};
            end
            if length(freq)>1
                error(['Calculation of fields for multiple '...
                ,'frequencies is not supported']);
            end
            d=sqrt(sum((obj.SegmentMid-rp_).^2,2));
            nR=2*d/obj.SegmentLength;
            switch fieldType
            case 'E'
                FieldCoeffs=obj.Medium.CalcSegEFullCoeffs(...
                rp_,...
                obj.SegmentEdges(1,:),...
                obj.SegmentUnitVec,...
                obj.SegmentLength,...
                0:obj.PolyDegree,...
                obj.SegmentRadius,...
                nR,...
                freq);
            case 'H'
                FieldCoeffs=obj.Medium.CalcSegHFullCoeffs(...
                rp_,...
                obj.SegmentEdges(1,:),...
                obj.SegmentUnitVec,...
                obj.SegmentLength,...
                0:obj.PolyDegree,...
                obj.SegmentRadius,...
                nR,...
                freq);
            end
            Fields=cell2mat(arrayfun(@(d)FieldCoeffs(:,:,d)*...
            polyCoeffs,[1,2,3],'UniformOutput',false));

            cosTetha=obj.SegmentUnitVec*[0,0,1].'/...
            norm(obj.SegmentUnitVec);
            sinTetha=sqrt(1-cosTetha^2);
            if abs(sinTetha)>0.0001
                Phi=atan2(obj.SegmentUnitVec*[0,1,0].',...
                obj.SegmentUnitVec*[1,0,0].');
            else


                Phi=pi/2;
            end
            Tr=[sinTetha*cos(Phi),cosTetha*cos(Phi),-sin(Phi);...
            sinTetha*sin(Phi),cosTetha*sin(Phi),cos(Phi);...
            cosTetha,-sinTetha,0].';
            Fields_cart=Fields*Tr;
        end

        function[isOnSeg,segPositions_]=isOnSegment(obj,locations)
            diffSeg=repmat(obj.SegmentEdges(1,:)-...
            obj.SegmentEdges(2,:),size(locations,1),1);
            diffLoc1=locations-obj.SegmentEdges(1,:);
            diffLoc2=locations-obj.SegmentEdges(2,:);
            locPerpDist=-dot(diffLoc2,diffSeg,2).*...
            (dot(diffLoc2,diffSeg,2)<0)+dot(diffLoc1,diffSeg,2).*...
            (dot(diffLoc1,diffSeg,2)>0);
            locNormDist=vecnorm(cross(diffSeg,diffLoc2,2),2,2)./...
            vecnorm(diffSeg,2,2);
            locTotDist=sqrt(locPerpDist.^2+locNormDist.^2);
            isOnSeg=em.wire.solver.BasicPECWireSegment.MinRelDist*...
            obj.SegmentRadius>=locTotDist;
            segPositions_=isOnSeg.*(-dot(diffLoc1,diffSeg,2)./...
            dot(diffSeg,diffSeg,2))-(~isOnSeg);
        end

    end

    methods(Access=protected)
        function PopulateEMSolution(obj,freqs,varargin)



            if nargin==2||...
                (nargin==4&&strcmp(varargin{2},'BuildOnly'))

                if all(obj.Medium.EMSolObj.Freqs==freqs)
                    [ZEnteries,exEnteries]=...
                    obj.Medium.EMSolObj.AddSegment(obj);
                else
                    error(['Frequecny of Imedance matrix in medium of '...
                    ,'segement is different than specified frequency']);
                end
                if(nargin==4&&strcmp(varargin{2},'BuildOnly'))
                    return
                end
            else
                [ZEnteries,exEnteries]=...
                obj.Medium.EMSolObj.GetSegmentEnteries(obj);
            end
            for OtherPartInd=1:length(ZEnteries)
                OtherPart=ZEnteries(OtherPartInd).OtherPart;
                switch class(OtherPart)
                case 'em.wire.solver.BasicPECWireSegment'





                    if(~ZEnteries(OtherPartInd).Reciprocal&&...
                        (numel(ZEnteries(OtherPartInd).Rows)~=...
                        size(OtherPart.MatchingPoints,1)))||...
                        (ZEnteries(OtherPartInd).Reciprocal&&...
                        (numel(ZEnteries(OtherPartInd).Cols)~=...
                        OtherPart.PolyDegree+1))
                        error(['Mismatch in number of rows allocated '...
                        ,'for segment in impedance matrix and '...
                        ,'number of segment matching points']);
                    end
                    if~ZEnteries(OtherPartInd).Reciprocal
                        sourceSeg=obj;
                        matchingSeg=OtherPart;
                    else
                        sourceSeg=OtherPart;
                        matchingSeg=obj;
                    end
                    d=norm(sourceSeg.SegmentMid-matchingSeg.SegmentMid);
                    nR=2*d/max(sourceSeg.SegmentLength,matchingSeg.SegmentLength);
                    ZEnteries(OtherPartInd).Vals=...
                    sourceSeg.Medium.CalcSegECoeffs(...
                    matchingSeg.MatchingPoints,...
                    matchingSeg.SegmentUnitVec,...
                    sourceSeg.SegmentEdges(1,:),...
                    sourceSeg.SegmentUnitVec,...
                    sourceSeg.SegmentLength,...
                    0:sourceSeg.PolyDegree,...
                    sourceSeg.SegmentRadius,...
                    nR,...
                    freqs);
                case{'em.wire.solver.BasicPECWireConnection',...
                    'em.wire.solver.DeltaGapPECWireConnection'}


                    if numel(ZEnteries(OtherPartInd).Rows)~=2
                        error(['Only one row should be allocated '...
                        ,'for connections per each ZEntery in '...
                        ,'the impedance matrix']);
                    end






                    ZEnteries(OtherPartInd).Vals(1:OtherPart.JpathsNum,...
                    1:obj.PolyDegree+1,1:length(freqs))=0;
                    d=norm(obj.SegmentMid-OtherPart.MatchingPoints);
                    nR=2*d/obj.SegmentLength;
                    for jpathInd=2:OtherPart.JpathsNum

                        matchingSeg=OtherPart.PrevParts;
                        ZEnteries(OtherPartInd).Vals(jpathInd,:,:)=...
                        ZEnteries(OtherPartInd).Vals(...
                        jpathInd,:,:)+...
                        sum(obj.Medium.CalcSegECoeffs(...
                        OtherPart.JPathMatP{1},...
                        matchingSeg.SegmentUnitVec,...
                        obj.SegmentEdges(1,:),...
                        obj.SegmentUnitVec,...
                        obj.SegmentLength,...
                        0:obj.PolyDegree,...
                        obj.SegmentRadius,...
                        nR,...
                        freqs),1)/OtherPart.JPathMatPNum{1};






                        matchingSeg=OtherPart.NextParts(jpathInd-1);
                        ZEnteries(OtherPartInd).Vals(...
                        jpathInd,:,:)=...
                        ZEnteries(OtherPartInd).Vals(...
                        jpathInd,:,:)+...
                        sum(obj.Medium.CalcSegECoeffs(...
                        OtherPart.JPathMatP{jpathInd},...
                        matchingSeg.SegmentUnitVec,...
                        obj.SegmentEdges(1,:),...
                        obj.SegmentUnitVec,...
                        obj.SegmentLength,...
                        0:obj.PolyDegree,...
                        obj.SegmentRadius,...
                        nR,...
                        freqs),1)/OtherPart.JPathMatPNum{jpathInd}*...
                        OtherPart.JPathLen{jpathInd}/...
                        OtherPart.JPathLen{1};





                    end
                otherwise

                    error(['interaction between '...
                    ,'em.wire.solver.BasicPECWireSegment '...
                    ,'currents and ',class(OtherPart)...
                    ,' is currently not supported.']);
                end
            end




            if numel(exEnteries.Indices)~=size(obj.MatchingPoints,1)
                error(['Mismatch in number of indices allocated '...
                ,'for segment in excitation vector and '...
                ,'number of segment matching points']);
            end


            Einc=obj.Medium.EMSolObj.EincFunc(obj.MatchingPoints,...
            obj.Medium,reshape(freqs,1,1,1,[]));
            exEnteries.Vals(1:size(obj.MatchingPoints,1),:,:)=...
            -dot(repmat(obj.SegmentUnitVec,...
            size(Einc,1),1,size(Einc,3),size(Einc,4)),Einc,2)./...
            (-1j*(2*pi*reshape(freqs,1,1,1,[]))*...
            (obj.Medium.mu_r*obj.Medium.mu0)/(4*pi));

            obj.Medium.EMSolObj.Fill(ZEnteries,exEnteries,varargin{:});
        end
    end

    methods(Hidden)
        function UpdatePartData(obj,vals,varargin)
            if nargin==2
                obj.PolyCoeffs=vals;
                obj.Dirty=false(length(obj.Freqs),1);
            else
                obj.PolyCoeffs(:,1,varargin{1})=vals;
                obj.Dirty(varargin{1})=false;
            end
        end

    end
end