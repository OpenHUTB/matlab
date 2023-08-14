classdef AT<rf.internal.rfengine.elements.Elements






    properties(Constant)
        ControlNodeIndices=[1;2]
        BranchNodeIndices=[3,4;2,2]
    end

    properties
        SR=[]
        SI=[]
        ControlNodes=[]
    end

    properties(Access=private)
realB
imagB
ctrlP
ctrlM
imagP
imagM
dRealBdCtrlP
dRealBdCtrlM
dRealBdImagP
dRealBdImagM
dImagBdCtrlP
dImagBdCtrlM
dImagBdImagP
dImagBdImagM

sr
si
    end

    methods(Access=private)
        function self=AT(ckt,label,n1,n2,n3,n4)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2,n3,n4);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,n3,n4,varargin)
            if isempty(ckt.AT)
                ckt.AT=rf.internal.rfengine.elements.AT(ckt,label,n1,n2,n3,n4);
            else
                addElement(ckt.AT,ckt,label,n1,n2,n3,n4)
            end
            for k=1:length(varargin)
                i=strfind(varargin{k},'=');
                ckt.AT.(upper(varargin{k}(1:i-1)))(end)=...
                rf.internal.rfengine.Circuit.spice2double(varargin{k}(i+1:end));
            end
        end
    end

    methods
        function initializeIndices(self,ckt)
            self.IndicesJk=...
            self.BranchNodes+(self.Branches-1)*ckt.NumNodes;

            self.IndicesJi=...
            self.Branches+(self.Branches-1)*ckt.NumBranches;


            self.ControlNodes=self.Nodes(self.ControlNodeIndices,:);

            self.realB=self.Branches(1:2:end);
            self.imagB=self.Branches(2:2:end);
            self.imagP=self.BranchNodes(1,2:2:end);
            self.imagM=self.BranchNodes(2,2:2:end);
            self.ctrlP=self.ControlNodes(1,:);
            self.ctrlM=self.ControlNodes(2,:);

            self.dRealBdCtrlP=self.realB+(self.ctrlP-1)*ckt.NumBranches;
            self.dRealBdCtrlM=self.realB+(self.ctrlM-1)*ckt.NumBranches;
            self.dRealBdImagP=self.realB+(self.imagP-1)*ckt.NumBranches;
            self.dRealBdImagM=self.realB+(self.imagM-1)*ckt.NumBranches;
            self.dImagBdCtrlP=self.imagB+(self.ctrlP-1)*ckt.NumBranches;
            self.dImagBdCtrlM=self.imagB+(self.ctrlM-1)*ckt.NumBranches;
            self.dImagBdImagP=self.imagB+(self.imagP-1)*ckt.NumBranches;
            self.dImagBdImagM=self.imagB+(self.imagM-1)*ckt.NumBranches;

            self.IndicesJv=[...
            self.dRealBdCtrlP
            self.dRealBdCtrlM
            self.dRealBdImagP
            self.dRealBdImagM
            self.dImagBdCtrlP
            self.dImagBdCtrlM
            self.dImagBdImagP
            self.dImagBdImagM
            ];
        end

        function evalConstitutiveJandF(self,evaluator)
            updateConstitutiveJandF(self,evaluator)
            evaluator.Ji(self.IndicesJi)=1;
        end

        function updateConstitutiveJandF(self,evaluator)
            updateConstitutiveF(self,evaluator);



            evaluator.Jv(self.dRealBdCtrlP)=-self.sr;
            evaluator.Jv(self.dRealBdCtrlM)=self.sr;
            evaluator.Jv(self.dRealBdImagP)=self.si;
            evaluator.Jv(self.dRealBdImagM)=-self.si;



            evaluator.Jv(self.dImagBdCtrlP)=-self.si;
            evaluator.Jv(self.dImagBdCtrlM)=self.si;
            evaluator.Jv(self.dImagBdImagP)=-self.sr;
            evaluator.Jv(self.dImagBdImagM)=self.sr;
        end

        function updateConstitutiveF(self,evaluator)
            uniqueFreqs=evaluator.Analysis.UniqueFreqs;
            j=(abs(evaluator.Time-uniqueFreqs)<=max(eps(uniqueFreqs)));


            self.sr=self.SR(:,j);
            self.si=self.SI(:,j);



            evaluator.Fiv(self.realB)=evaluator.I(self.realB)-...
            self.sr.*(evaluator.V(self.ctrlP)-evaluator.V(self.ctrlM))+...
            self.si.*(evaluator.V(self.imagP)-evaluator.V(self.imagM));



            evaluator.Fiv(self.imagB)=-evaluator.I(self.imagB)-...
            self.si.*(evaluator.V(self.ctrlP)-evaluator.V(self.ctrlM))-...
            self.sr.*(evaluator.V(self.imagP)-evaluator.V(self.imagM));
        end
    end
end
