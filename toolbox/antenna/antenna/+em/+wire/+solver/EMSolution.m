classdef EMSolution<matlab.mixin.SetGet

    properties
ZmatObj
ExVecObj
DefEincFunc
EincFunc
    end

    properties(SetAccess=private)
Freqs
Dirty
    end

    properties(Hidden)
DirtyEx
    end






    methods

        function obj=EMSolution()
            obj.ZmatObj=em.wire.solver.ImpedanceMatrix(obj);
            obj.ExVecObj=em.wire.solver.ExcitationVec(obj);
            obj.DefEincFunc=@obj.EincFuncDefault;
            obj.EincFunc=obj.DefEincFunc;
            obj.DirtyEx=false;
        end

        function set.Freqs(obj,val)
            if length(obj.Freqs)~=length(val)||any(obj.Freqs~=val)
                obj.Freqs=val;
            end
        end

        function AddFreqs(obj,addedFreqs,newFreqInds)
            if size(obj.ZmatObj.Matrix,3)<length(newFreqInds)
                newFreqs=zeros(1,1,length(newFreqInds));
                newFreqs(:,:,~newFreqInds)=obj.Freqs;
                newFreqs(newFreqInds)=addedFreqs;
                obj.Freqs=newFreqs;

                affectedParts=obj.allScWireParts;
                for partInd=1:length(affectedParts)
                    affectedParts(partInd).Freqs=newFreqs;
                    prevPolyCoeffs=affectedParts(partInd).PolyCoeffs;
                    affectedParts(partInd).PolyCoeffs=...
                    zeros(size(affectedParts(partInd).PolyCoeffs,1),...
                    size(affectedParts(partInd).PolyCoeffs,2),...
                    length(newFreqInds));
                    affectedParts(partInd).PolyCoeffs(:,:,...
                    ~newFreqInds)=prevPolyCoeffs;
                    affectedParts(partInd).Dirty=newFreqInds;
                end
                obj.Dirty=newFreqInds;
                PrevMat=obj.ZmatObj.Matrix;
                obj.ZmatObj.Matrix=zeros(size(PrevMat,1),...
                size(PrevMat,2),length(newFreqInds));
                obj.ZmatObj.Matrix(:,:,~newFreqInds)=PrevMat;
                obj.ZmatObj.NMats=length(newFreqInds);
                PrevVec=obj.ExVecObj.Vec;
                obj.ExVecObj.Vec=zeros(size(PrevVec,1),...
                size(PrevVec,2),length(newFreqInds));
                obj.ExVecObj.Vec(:,:,~newFreqInds)=PrevVec;
                obj.ExVecObj.NFreqVecs=length(newFreqInds);
            elseif size(obj.ZmatObj.Matrix,3)>length(newFreqInds)
                error(['Cannot update solution to a solution with '...
                ,'less frequency points']);
            end
        end

        function RemoveFreqs(obj,FreqIndsToRemove)
            if size(obj.ZmatObj.Matrix,3)==length(FreqIndsToRemove)
                newFreqs=obj.Freqs(~FreqIndsToRemove);
                obj.Freqs=newFreqs;

                affectedParts=obj.allScWireParts;
                for partInd=1:length(affectedParts)
                    affectedParts(partInd).Freqs=newFreqs;
                    affectedParts(partInd).PolyCoeffs=...
                    affectedParts(partInd).PolyCoeffs(:,:,~FreqIndsToRemove);
                    affectedParts(partInd).Dirty=false(size(newFreqs));
                end
                obj.Dirty=false(size(newFreqs));
                obj.ZmatObj.Matrix=obj.ZmatObj.Matrix(:,:,~FreqIndsToRemove);
                obj.ZmatObj.NMats=length(newFreqs);
                obj.ExVecObj.Vec=obj.ExVecObj.Vec(:,:,~FreqIndsToRemove);
                obj.ExVecObj.NFreqVecs=length(newFreqs);
            else
                error(['Index vector of frequencies to remove is '...
                ,'different than the number of internal frequencies']);
            end
        end

        function ResetExVec(obj,varargin)
            if nargin>=2
                if obj.ExVecObj.NExVecs~=varargin{1}
                    obj.ExVecObj.NExVecs=varargin{1};
                    obj.ExVecObj.Vec=zeros(obj.ExVecObj.N,...
                    obj.ExVecObj.NExVecs,obj.ExVecObj.NFreqVecs);
                end
            else
                obj.ExVecObj.Vec=zeros(obj.ExVecObj.N,...
                obj.ExVecObj.NExVecs,obj.ExVecObj.NFreqVecs);
            end
            obj.DirtyEx=true;
        end

        function set.EincFunc(obj,val)
            if~isequal(obj.EincFunc,val)





                if iscell(val)
                    obj.EincFunc=val{1};
                else
                    obj.EincFunc=val;
                    obj.ResetExVec;
                end
            end
        end

        function res=isEincFuncDefined(obj)



            res=~strcmp(func2str(obj.EincFunc),...
            func2str(obj.DefEincFunc));
        end

        function[ZEnteries,exEnteries]=AddTermination(obj,termination)

            ZEnteries=obj.ZmatObj.AddTermination(termination);
            exEnteries=obj.ExVecObj.AddTermination(termination);
        end

        function[ZEnteries,exEnteries]=GetTerminationEnteries(obj,...
            termination)


            ZEnteries=obj.ZmatObj.GetTerminationEnteries(termination);
            exEnteries=obj.ExVecObj.GetTerminationEnteries(termination);
        end

        function[ZEnteries,exEnteries]=AddConnection(obj,...
            connection,varargin)








            if nargin>2
                freqInd=varargin{1};
            else
                freqInd=obj.Dirty;
            end

            ZEnteries=obj.ZmatObj.AddConnection(connection);
            exEnteries=obj.ExVecObj.AddConnection(connection,freqInd);
        end

        function[ZEnteries,exEnteries]=GetConnectionEnteries(obj,...
            connection,varargin)








            if nargin>2
                if~isempty(varargin{1})
                    freqInd=varargin{1};
                else
                    freqInd=true(size(obj.Dirty));
                end
            else
                freqInd=obj.Dirty;
            end

            ZEnteries=obj.ZmatObj.GetConnectionEnteries(connection);
            exEnteries=obj.ExVecObj.GetConnectionEnteries(connection,...
            freqInd);
        end

        function[ZEnteries,exEnteries]=AddSegment(obj,segment)

            ZEnteries=obj.ZmatObj.AddSegment(segment);
            exEnteries=obj.ExVecObj.AddSegment(segment);
        end

        function[ZEnteries,exEnteries]=GetSegmentEnteries(obj,segment)

            ZEnteries=obj.ZmatObj.GetSegmentEnteries(segment);
            exEnteries=obj.ExVecObj.GetSegmentEnteries(segment);
        end

        function Fill(obj,ZEnteries,exEnteries,varargin)

            if~isempty(ZEnteries)
                obj.ZmatObj.Fill(ZEnteries,varargin{:});
            end
            if~isempty(exEnteries)
                obj.ExVecObj.Fill(exEnteries,varargin{:});
            end
        end

        function parts=allWireParts(obj)
            parts=[obj.ZmatObj.PartsMap.Part];
        end

        function parts=allScWireParts(obj)


            partsInd=arrayfun(@(p)isprop(p,'AffectingOtherPartsZ')&&...
            (p.AffectingOtherPartsZ),obj.allWireParts);
            parts=[obj.ZmatObj.PartsMap(partsInd).Part];
        end

        function parts=allExWireParts(obj)


            partsInd=arrayfun(@(p)isprop(p,'AffectingOtherPartsEx')&&...
            (p.AffectingOtherPartsEx),obj.allWireParts);
            parts=[obj.ZmatObj.PartsMap(partsInd).Part];
        end

        function parts=allAffectedWireParts(obj)


            partsInd=arrayfun(@(p)isprop(p,'AffectedByOtherPartsZ')&&...
            (p.AffectedByOtherPartsZ),obj.allWireParts);
            parts=[obj.ZmatObj.PartsMap(partsInd).Part];
        end


        function EsVals_cart=Es(obj,rp_,varargin)
            if nargin>2
                vararginNew=[{[]},varargin(1)];
            else
                vararginNew=varargin;
            end
            ScParts=obj.allScWireParts;
            EsVals_cart=ScParts(1).CalcFields(rp_,'E',vararginNew{:});
            for segInd=2:length(ScParts)
                EsVals_cart=EsVals_cart+...
                ScParts(segInd).CalcFields(rp_,'E',vararginNew{:});
            end
        end

        function EiVals_cart=Ei(obj,rp_,medium,varargin)
            if nargin>3
                freqs=varargin(1);
            end
            ExParts=obj.allExWireParts;
            if~isempty(ExParts)
                EiVals_cart=ExParts(1).ExFieldFun(rp_,medium,freqs);
                for segInd=2:length(ExParts)
                    EiVals_cart=EiVals_cart+...
                    ExParts(segInd).ExFieldFun(rp_,medium,freqs);
                end
                EiVals_cart=EiVals_cart+...
                obj.EincFunc(rp_,medium,freqs);
            else
                EiVals_cart=obj.EincFunc(rp_,medium,freqs);
            end
        end

        function EtVals_cart=Et(obj,rp_,medium,varargin)
            EtVals_cart=obj.Ei(rp_,medium,varargin{:})+...
            obj.Es(rp_,varargin{:});
        end

        function HsVals_cart=Hs(obj,rp_,varargin)
            if nargin>2
                vararginNew=[{[]},varargin(1)];
            else
                vararginNew=varargin;
            end
            ScParts=obj.allScWireParts;
            HsVals_cart=ScParts(1).CalcFields(rp_,'H',vararginNew{:});
            for segInd=2:length(ScParts)
                HsVals_cart=HsVals_cart+...
                ScParts(segInd).CalcFields(rp_,'H',vararginNew{:});
            end
        end

        function res=Solve(obj,varargin)
            hwait=[];
            if nargin>1
                hwait=varargin{1};
            end
            if all(obj.Dirty)||obj.DirtyEx
                numFreqs=obj.ExVecObj.NFreqVecs;
                numEqs=obj.ExVecObj.NExVecs;
                res=zeros(size(obj.ZmatObj.Matrix,2),numEqs,numFreqs);
                for freqInd=1:size(obj.ZmatObj.Matrix,3)
                    res(:,:,freqInd)=obj.ZmatObj.Matrix(:,:,freqInd)\...
                    obj.ExVecObj.Vec(:,:,freqInd);
                    if any(~isfinite(res(:,:,freqInd)))
                        res=[];
                        break
                    end
                    obj.Dirty(freqInd)=false;
                    if~isempty(hwait)

                        if getappdata(hwait,'canceling')
                            res=[];
                            break
                        end
                        msg=sprintf(['Calculating %d/%d frequency '...
                        ,'points'],freqInd,numFreqs);
                        waitbar(freqInd/numFreqs,hwait,msg);
                    end
                end
                if~isempty(res)
                    PartsVec=obj.allWireParts;
                    for PartsVecInd=1:length(PartsVec)
                        PartsVec(PartsVecInd).UpdatePartData(...
                        res(obj.ZmatObj.PartsMap(PartsVecInd).Cols,...
                        :,:));
                    end
                end
            else
                DirtyInds=find(obj.Dirty);
                numDirty=length(DirtyInds);
                res=zeros(size(obj.ZmatObj.Matrix,2),1,numDirty);
                for freqInd=1:numDirty
                    dirtyInd=DirtyInds(freqInd);
                    res(:,:,freqInd)=obj.ZmatObj.Matrix(:,:,dirtyInd)\...
                    obj.ExVecObj.Vec(:,:,dirtyInd);
                    if any(~isfinite(res(:,:,freqInd)))
                        res=[];
                        break
                    end
                    obj.Dirty(dirtyInd)=false;
                    if~isempty(hwait)

                        if getappdata(hwait,'canceling')
                            res=[];
                            break
                        end
                        msg=sprintf(['Calculating %d/%d '...
                        ,'frequency points'],freqInd,numDirty);
                        waitbar(freqInd/numDirty,hwait,msg);
                    end
                end
                if~isempty(res)
                    PartsVec=obj.allWireParts;
                    for PartsVecInd=1:length(PartsVec)
                        PartsVec(PartsVecInd).UpdatePartData(...
                        res(obj.ZmatObj.PartsMap(PartsVecInd).Cols,...
                        :,:),DirtyInds);
                    end
                end
            end
        end

        function copySolution(obj,otherSol)





            obj.ZmatObj.N=otherSol.ZmatObj.N;
            obj.ZmatObj.NMats=otherSol.ZmatObj.NMats;
            obj.ZmatObj.Matrix=otherSol.ZmatObj.Matrix;


            obj.ExVecObj.N=otherSol.ExVecObj.N;
            obj.ExVecObj.NExVecs=otherSol.ExVecObj.NExVecs;
            obj.ExVecObj.NFreqVecs=otherSol.ExVecObj.NFreqVecs;
            obj.ExVecObj.Vec=otherSol.ExVecObj.Vec;


            obj.Freqs=otherSol.Freqs;
            obj.Dirty=otherSol.Dirty;


            PartsVec=obj.allScWireParts;
            otherPartsVec=otherSol.allScWireParts;
            assert(length(PartsVec)==length(otherPartsVec),...
            ['number of scattering wire parts has to be identical '...
            ,'in both solutions']);
            for PartsVecInd=1:length(PartsVec)
                assert(PartsVec(PartsVecInd).PolyDegree==...
                otherPartsVec(PartsVecInd).PolyDegree,...
                ['Polynomial order of all scattering wire parts '...
                ,'has to be identical in both solutions']);
                PartsVec(PartsVecInd).PolyCoeffs=...
                otherPartsVec(PartsVecInd).PolyCoeffs;
                PartsVec(PartsVecInd).Freqs=...
                otherPartsVec(PartsVecInd).Freqs;
                PartsVec(PartsVecInd).Dirty=...
                otherPartsVec(PartsVecInd).Dirty;
            end

            AffectedPartsVec=obj.allAffectedWireParts;
            AffectedOtherPartsVec=otherSol.allAffectedWireParts;
            for PartsVecInd=1:length(AffectedPartsVec)
                AffectedPartsVec(PartsVecInd).Freqs=...
                AffectedOtherPartsVec(PartsVecInd).Freqs;
            end
        end

    end

    methods(Access=private)
        function EincVec=EincFuncDefault(obj,pos,~,freqs)
            EincVec=zeros([size(pos),obj.ExVecObj.NExVecs,length(freqs)]);

        end
    end
end