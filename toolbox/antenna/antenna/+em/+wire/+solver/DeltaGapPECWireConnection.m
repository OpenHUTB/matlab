classdef DeltaGapPECWireConnection<em.wire.solver.BasicPECWireConnection
    properties
Voltage
ExFieldFun
GapUnitVec
    end
    methods
        function obj=DeltaGapPECWireConnection(prevSeg,...
            prevSegSide,nextSeg,nextSegSide,medium,V,freqs,varargin)

            obj.PrevParts=prevSeg;
            obj.PrevSegSides=prevSegSide;
            obj.NextParts=nextSeg;
            obj.NextSegSides=nextSegSide;

            obj.ConnectSegs;

            obj.AffectedByOtherPartsZ=true;

            obj.AffectingOtherPartsZ=false;

            obj.AffectedByOtherPartsEx=false;


            obj.AffectingOtherPartsEx=true;



            obj.Medium=medium;












            obj.GapUnitVec=prevSeg.SegmentUnitVec;

            obj.MatchingPoints=prevSeg.SegmentEdges(prevSegSide+1,:);
            if nargin>7&&~isempty(varargin{1})
                obj.PathLenVsMaxRadius=varargin{1};
                obj.nMatchPerMinPathLen=varargin{2};
            else
                obj.PathLenVsMaxRadius=3.5;
                obj.nMatchPerMinPathLen=10;
            end
            obj.SetPathData;

            obj.Voltage=V;




            obj.ExFieldFun=@(pos,medium,freqs)...
            repmat(obj.DeltaGapFieldFun(pos,medium).*...
            (((sum((pos-obj.MatchingPoints).^2,2))-...
            ((pos-obj.MatchingPoints)*obj.GapUnitVec.').^2)<=...
            (obj.PrevParts.SegmentRadius)^2),1,1,length(freqs));

            if nargin<=9||~strcmp(varargin{3},'BuildOnly')
                obj.PopulateEMSolution(freqs);
            else
                obj.PopulateEMSolution(freqs,[],'BuildOnly');
            end
        end
        function IGap=CalcIGap(obj,varargin)
            currentNext=obj.NextParts(1).CalcSegIs(obj.PathLenVsMaxRadius*...
            obj.NextParts(1).SegmentRadius/obj.nMatchPerMinPathLen,...
            [],varargin{:});
            currentPrev=...
            obj.PrevParts(1).CalcSegIs(obj.PrevParts(1).SegmentLength-...
            obj.PathLenVsMaxRadius*obj.PrevParts(1).SegmentRadius/...
            obj.nMatchPerMinPathLen,[],varargin{:});
            IGap=(currentPrev+currentNext)/2;
        end

        function Zin=CalcZin(obj,ExInd)



            if nargin==1
                ExInd=1;
            end
            Zin=obj.Voltage(ExInd)./obj.CalcIGap(ExInd);
        end

        function ExVec=CreateExVecReplica(obj,freqs,varargin)


            [~,exEnteries]=...
            obj.Medium.EMSolObj.GetConnectionEnteries(obj,varargin{1});
            newArgs={};
            if nargin>3
                newArgs=varargin(1:2);
            elseif nargin>2
                newArgs=varargin(1);
            end
            if nargin>4
                exEnteries=obj.CalcDeltaGapexEnteries(exEnteries,...
                freqs,varargin{3});
            else
                exEnteries=obj.CalcDeltaGapexEnteries(exEnteries,freqs);
            end
            ExVec=obj.Medium.EMSolObj.ExVecObj.FillReplica(exEnteries,...
            newArgs{:});
        end

    end

    methods(Access=protected)
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
                newVararg={};
            else
                newVararg=varargin(1);
                [ZEnteries,exEnteries]=...
                obj.Medium.EMSolObj.GetConnectionEnteries(obj,...
                newVararg{:});
            end
            if nargin<=3
                ZEnteries=obj.CalcZEnteries(ZEnteries,freqs);
                exEnteries=obj.CalcDeltaGapexEnteries(exEnteries,freqs);
            else
                obj.Voltage=varargin{2};
                ZEnteries=[];
                exEnteries=obj.CalcDeltaGapexEnteries(exEnteries,...
                freqs,varargin{2});
            end
            obj.Medium.EMSolObj.Fill(ZEnteries,exEnteries,newVararg{:});
        end

        function exEnteries=CalcDeltaGapexEnteries(obj,exEnteries,freqs,varargin)


            if(numel(exEnteries(1).Indices)~=1)||...
                (numel(exEnteries(2).Indices)~=...
                size(obj.PrevParts.MatchingPoints,1))||...
                (numel(exEnteries(3).Indices)~=...
                size(obj.NextParts.MatchingPoints,1))
                error(['Exactly two indices should be allocated '...
                ,'for connection in excitation vector']);
            end
            for jpathInd=2:obj.JpathsNum

                matchingSeg=obj.PrevParts;
                exEnteries(1).Vals(jpathInd-1,:,:)=0;
                for matPtInd=1:obj.JPathMatPNum{1}
                    deltaGapField=obj.DeltaGapFieldFun(...
                    obj.JPathMatP{1}(matPtInd,:),...
                    obj.Medium,varargin{:});
                    exEnteries(1).Vals(jpathInd-1,:,:)=...
                    exEnteries(1).Vals(jpathInd-1,:,:)+...
                    -repmat(reshape(dot(...
                    repmat(matchingSeg.SegmentUnitVec,...
                    size(deltaGapField,1),1,...
                    size(deltaGapField,3)),deltaGapField,2),[],...
                    size(deltaGapField,3)),1,1,length(freqs))/...
                    obj.JPathMatPNum{1};




                end

                matchingSeg=obj.NextParts(jpathInd-1);
                for matPtInd=1:obj.JPathMatPNum{jpathInd}
                    deltaGapField=obj.DeltaGapFieldFun(...
                    obj.JPathMatP{jpathInd}(matPtInd,:),...
                    obj.Medium,varargin{:});
                    exEnteries(1).Vals(jpathInd-1,:,:)=...
                    exEnteries(1).Vals(jpathInd-1,:,:)+...
                    -repmat(reshape(dot(...
                    repmat(matchingSeg.SegmentUnitVec,...
                    size(deltaGapField,1),1,...
                    size(deltaGapField,3)),deltaGapField,2),[],...
                    size(deltaGapField,3)),1,1,length(freqs))/...
                    obj.JPathMatPNum{jpathInd}*...
                    obj.JPathLen{jpathInd}/obj.JPathLen{1};




                end
            end


            exEnteries(1).Vals=exEnteries(1).Vals./...
            (-1j*(2*pi*repmat(freqs,1,length(obj.Voltage),1))*...
            (obj.Medium.mu_r*obj.Medium.mu0)/...
            (4*pi));

            for matPtInd=1:size(obj.PrevParts.MatchingPoints,1)
                deltaGapField=obj.DeltaGapFieldFun(...
                obj.PrevParts.MatchingPoints(matPtInd,:),...
                obj.Medium,varargin{:});
                exEnteries(2).Vals(matPtInd,:,:)=...
                exEnteries(2).Vals(matPtInd,:,:)+...
                -repmat(reshape(dot(...
                repmat(obj.PrevParts.SegmentUnitVec,...
                size(deltaGapField,1),1,...
                size(deltaGapField,3)),deltaGapField,2),[],...
                size(deltaGapField,3)),1,1,length(freqs))./...
                (-1j*(2*pi*repmat(freqs,1,length(obj.Voltage),1))*...
                (obj.Medium.mu_r*obj.Medium.mu0)/...
                (4*pi));
            end
            for matPtInd=1:size(obj.NextParts.MatchingPoints,1)
                deltaGapField=obj.DeltaGapFieldFun(...
                obj.NextParts.MatchingPoints(matPtInd,:),...
                obj.Medium,varargin{:});
                exEnteries(3).Vals(matPtInd,:,:)=...
                exEnteries(3).Vals(matPtInd,:,:)+...
                -repmat(reshape(dot(...
                repmat(obj.NextParts.SegmentUnitVec,...
                size(deltaGapField,1),1,...
                size(deltaGapField,3)),deltaGapField,2),[],...
                size(deltaGapField,3)),1,1,length(freqs))./...
                (-1j*(2*pi*repmat(freqs,1,length(obj.Voltage),1))*...
                (obj.Medium.mu_r*obj.Medium.mu0)/...
                (4*pi));
            end
        end

        function res=DeltaGapFieldFun(obj,pos,~,varargin)

            if nargin>3
                v=reshape(varargin{1},1,1,[]);
            else
                v=reshape(obj.Voltage,1,1,[]);
            end
            res=obj.GapUnitVec.*(abs((pos-obj.MatchingPoints)*...
            obj.GapUnitVec.')<=(obj.PathLenVsMaxRadius*...
            obj.PrevParts.SegmentRadius/obj.nMatchPerMinPathLen)).*...
            v/(2*obj.PathLenVsMaxRadius*...
            obj.PrevParts.SegmentRadius/obj.nMatchPerMinPathLen);
        end

    end
end