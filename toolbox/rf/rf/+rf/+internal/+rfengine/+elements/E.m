classdef E<rf.internal.rfengine.elements.Elements


    properties(Constant)
        BranchNodeIndices=[1;2]
        ControlNodeIndices=[3;4]
    end

    properties
        Gain=[]
        ControlNodes=[]
    end

    methods(Access=private)
        function self=E(ckt,label,n1,n2,n3,n4)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2,n3,n4);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,n3,n4,gain)
            if isempty(ckt.E)
                ckt.E=rf.internal.rfengine.elements.E(ckt,label,n1,n2,n3,n4);
            else
                addElement(ckt.E,ckt,label,n1,n2,n3,n4)
            end
            ckt.E.Gain(end+1)=rf.internal.rfengine.Circuit.spice2double(gain);
        end
    end

    methods
        function initializeIndices(self,ckt)
            initializeIndices@rf.internal.rfengine.elements.Elements(self,ckt)
            self.IndicesJi=[];


            self.ControlNodes=self.Nodes(self.ControlNodeIndices,:);

            self.IndicesJv=[...
            self.IndicesJv
            self.Branches+(self.ControlNodes(1,:)-1)*ckt.NumBranches
            self.Branches+(self.ControlNodes(2,:)-1)*ckt.NumBranches
            ];
        end

        function evalConstitutiveJandF(self,analysis)
            analysis.Jv(self.IndicesJv(1,:))=1;
            analysis.Jv(self.IndicesJv(2,:))=-1;
            analysis.Jv(self.IndicesJv(3,:))=-self.Gain;
            analysis.Jv(self.IndicesJv(4,:))=self.Gain;
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            analysis.Fiv(self.Branches)=...
            analysis.V(self.BranchNodes(1,:))-...
            analysis.V(self.BranchNodes(2,:))-...
            self.Gain.'.*...
            (analysis.V(self.ControlNodes(1,:))-...
            analysis.V(self.ControlNodes(2,:)));
        end
    end
end
