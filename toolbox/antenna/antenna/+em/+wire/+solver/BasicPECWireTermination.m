classdef BasicPECWireTermination<em.wire.solver.BasicWirePart
    properties
Side

PrevParts
NextParts
AffectedByOtherPartsZ
AffectingOtherPartsZ
Medium
MatchingPoints
    end
    methods
        function obj=BasicPECWireTermination(segment,side,medium,...
            freqs,varargin)



            obj.Side=side;
            if side==0
                segment.PrevParts=obj;


                obj.PrevParts=[];
                obj.NextParts=segment;
            else
                segment.NextParts=obj;


                obj.PrevParts=segment;
                obj.NextParts=[];
            end

            obj.AffectedByOtherPartsZ=false;


            obj.AffectingOtherPartsZ=false;


            obj.Medium=medium;


            obj.MatchingPoints=segment.SegmentEdges(side+1,:);
            if nargin<=4||~strcmp(varargin{1},'BuildOnly')
                obj.PopulateEMSolution(freqs);
            else
                obj.PopulateEMSolution(freqs,[],'BuildOnly');
            end
        end
    end

    methods(Access=protected)
        function PopulateEMSolution(obj,freqs,varargin)



            if nargin==2||...
                (nargin==4&&strcmp(varargin{2},'BuildOnly'))

                if all(obj.Medium.EMSolObj.Freqs==freqs)
                    [ZEnteries,exEnteries]=...
                    obj.Medium.EMSolObj.AddTermination(obj);
                else
                    error(['Frequecny of Imedance matrix in medium of '...
                    ,'segement is different than specified frequency']);
                end
                if(nargin==4&&strcmp(varargin{2},'BuildOnly'))
                    return
                end
            else
                [ZEnteries,exEnteries]=...
                obj.Medium.EMSolObj.GetTerminationEnteries(obj);
            end


            if numel(ZEnteries(1).Rows)~=1
                error(['Only one row should be allocated '...
                ,'for temination in impedance matrix']);
            end
            if obj.Side==0
                segment=obj.NextParts;
                Sm=0;
            else
                segment=obj.PrevParts;
                Sm=segment.SegmentLength;
            end
            for polyDegreeInd=0:segment.PolyDegree
                ZEnteries(1).Vals(1,polyDegreeInd+1,:)=repmat(...
                segment.CalcSegICoeffs(...
                Sm,...
                polyDegreeInd),1,1,length(freqs));
            end




            Zmat=obj.Medium.EMSolObj.ZmatObj;
            segInd=find(ismember([Zmat.PartsMap(:).Part],...
            segment),1);
            PmVals=Zmat.Matrix(Zmat.PartsMap(segInd).Cols,...
            Zmat.PartsMap(segInd).Rows);
            maxPm=max(max(abs(PmVals)));
            ZEnteries(1).Vals=ZEnteries(1).Vals*maxPm;



            if numel(exEnteries.Indices)~=1
                error(['only one index should be allocated '...
                ,'for termination in excitation vector']);
            end
            exEnteries.Vals=0;

            obj.Medium.EMSolObj.Fill(ZEnteries,exEnteries,varargin{:});
        end
    end

    methods(Hidden)
        function UpdatePartData(~,~,varargin)


        end

    end
end