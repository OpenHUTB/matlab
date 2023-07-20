classdef AB<rf.internal.rfengine.elements.Elements





    properties(Constant)
        BranchNodeIndices=[1,3;2,4]
    end

    properties
        Z0=[]
    end

    properties(Access=private,Constant)
        DefaultZ0=50
    end

    properties(Access=private)
inB
outB
inP
inM
outP
outM
dInBdInP
dInBdInM
dInBdOutP
dInBdOutM
dOutBdInP
dOutBdInM
dOutBdOutP
dOutBdOutM

invZ0
    end

    methods(Access=private)
        function self=AB(ckt,label,n1,n2,n3,n4)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2,n3,n4);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,n3,n4,varargin)
            if isempty(ckt.AB)
                ckt.AB=rf.internal.rfengine.elements.AB(ckt,label,n1,n2,n3,n4);
            else
                addElement(ckt.AB,ckt,label,n1,n2,n3,n4)
            end
            ckt.AB.Z0(end+1)=ckt.AB.DefaultZ0;
            for k=1:length(varargin)
                i=strfind(varargin{k},'=');
                ckt.AB.(upper(varargin{k}(1:i-1)))(end)=...
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

            self.inB=self.Branches(1:2:end);
            self.outB=self.Branches(2:2:end);
            self.inP=self.BranchNodes(1,1:2:end);
            self.inM=self.BranchNodes(2,1:2:end);
            self.outP=self.BranchNodes(1,2:2:end);
            self.outM=self.BranchNodes(2,2:2:end);

            self.dInBdInP=self.inB+(self.inP-1)*ckt.NumBranches;
            self.dInBdInM=self.inB+(self.inM-1)*ckt.NumBranches;
            self.dInBdOutP=self.inB+(self.outP-1)*ckt.NumBranches;
            self.dInBdOutM=self.inB+(self.outM-1)*ckt.NumBranches;
            self.dOutBdInP=self.outB+(self.inP-1)*ckt.NumBranches;
            self.dOutBdInM=self.outB+(self.inM-1)*ckt.NumBranches;
            self.dOutBdOutP=self.outB+(self.outP-1)*ckt.NumBranches;
            self.dOutBdOutM=self.outB+(self.outM-1)*ckt.NumBranches;

            self.IndicesJv=[...
            self.dInBdInP
            self.dInBdInM
            self.dInBdOutP
            self.dInBdOutM
            self.dOutBdInP
            self.dOutBdInM
            self.dOutBdOutP
            self.dOutBdOutM
            ];
        end

        function evalConstitutiveJandF(self,evaluator)
            self.invZ0=1./self.Z0.';

            updateConstitutiveF(self,evaluator)

            evaluator.Ji(self.IndicesJi)=1;
            evaluator.Jv(self.dInBdInP)=self.invZ0;
            evaluator.Jv(self.dInBdInM)=-self.invZ0;
            evaluator.Jv(self.dInBdOutP)=-self.invZ0;
            evaluator.Jv(self.dInBdOutM)=self.invZ0;
            evaluator.Jv(self.dOutBdInP)=2;
            evaluator.Jv(self.dOutBdInM)=-2;
            evaluator.Jv(self.dOutBdOutP)=-1;
            evaluator.Jv(self.dOutBdOutM)=1;
        end

        function updateConstitutiveJandF(self,evaluator)
            updateConstitutiveF(self,evaluator)
        end

        function updateConstitutiveF(self,evaluator)
            vIn=evaluator.V(self.inP)-evaluator.V(self.inM);
            vOut=evaluator.V(self.outP)-evaluator.V(self.outM);

            evaluator.Fiv(self.inB)=...
            evaluator.I(self.inB)+self.invZ0.*(vIn-vOut);

            evaluator.Fiv(self.outB)=...
            evaluator.I(self.outB)+2*vIn-vOut;
        end
    end
end
