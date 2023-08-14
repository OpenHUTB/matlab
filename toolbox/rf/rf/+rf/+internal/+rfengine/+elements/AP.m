classdef AP<rf.internal.rfengine.elements.Elements



    properties(Constant)
        BranchNodeIndices=[5;6]
        ControlNodeIndices=[1,3;2,4]
    end

    properties
        ControlNodes=[]
    end

    properties
outB
inP
inM
loP
loM
outP
outM
dOutBdOutP
dOutBdOutM
dOutBdInP
dOutBdInM
dOutBdLoP
dOutBdLoM
    end

    methods(Access=private)
        function self=AP(ckt,label,n1,n2,n3,n4,n5,n6)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2,n3,n4,n5,n6);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,n3,n4,n5,n6)
            if isempty(ckt.AP)
                ckt.AP=rf.internal.rfengine.elements.AP(ckt,label,n1,n2,n3,n4,n5,n6);
            else
                addElement(ckt.AP,ckt,label,n1,n2,n3,n4,n5,n6)
            end
        end
    end

    methods
        function initializeIndices(self,ckt)
            self.IndicesJk=...
            self.BranchNodes+(self.Branches-1)*ckt.NumNodes;

            self.IndicesJi=[];

            self.ControlNodes=self.Nodes(self.ControlNodeIndices,:);

            self.outB=self.Branches;
            self.inP=self.ControlNodes(1,:);
            self.inM=self.ControlNodes(2,:);
            self.loP=self.ControlNodes(3,:);
            self.loM=self.ControlNodes(4,:);
            self.outP=self.BranchNodes(1,:);
            self.outM=self.BranchNodes(2,:);

            self.dOutBdOutP=self.outB+(self.outP-1)*ckt.NumBranches;
            self.dOutBdOutM=self.outB+(self.outM-1)*ckt.NumBranches;
            self.dOutBdInP=self.outB+(self.inP-1)*ckt.NumBranches;
            self.dOutBdInM=self.outB+(self.inM-1)*ckt.NumBranches;
            self.dOutBdLoP=self.outB+(self.loP-1)*ckt.NumBranches;
            self.dOutBdLoM=self.outB+(self.loM-1)*ckt.NumBranches;

            self.IndicesJv=[...
            self.dOutBdOutP
            self.dOutBdOutM
            self.dOutBdInP
            self.dOutBdInM
            self.dOutBdLoP
            self.dOutBdLoM
            ];
        end

        function evalConstitutiveJandF(self,evaluator)
            updateConstitutiveJandF(self,evaluator)

            evaluator.Jv(self.dOutBdOutP)=1;
            evaluator.Jv(self.dOutBdOutM)=-1;
        end

        function updateConstitutiveJandF(self,evaluator)
            updateConstitutiveF(self,evaluator);

            vIn=evaluator.V(self.inP)-evaluator.V(self.inM);
            vLo=evaluator.V(self.loP)-evaluator.V(self.loM);

            evaluator.Jv(self.dOutBdInP)=-vLo;
            evaluator.Jv(self.dOutBdInM)=vLo;
            evaluator.Jv(self.dOutBdLoP)=-vIn;
            evaluator.Jv(self.dOutBdLoM)=vIn;
        end

        function updateConstitutiveF(self,evaluator)


            vIn=evaluator.V(self.inP)-evaluator.V(self.inM);
            vLo=evaluator.V(self.loP)-evaluator.V(self.loM);

            evaluator.Fiv(self.Branches)=...
            evaluator.V(self.outP)-evaluator.V(self.outM)-vIn.*vLo;
        end
    end
end
