classdef R<rf.internal.rfengine.elements.Elements


    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Resistance=[]
    end

    properties(Access=private)
g
    end

    properties(Access=private)
nP
nM
    end

    methods(Access=private)
        function self=R(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2)
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,val)
            if isempty(ckt.R)
                ckt.R=rf.internal.rfengine.elements.R(ckt,label,n1,n2);
            else
                addElement(ckt.R,ckt,label,n1,n2)
            end
            ckt.R.Resistance(end+1)=rf.internal.rfengine.Circuit.spice2double(val);
        end
    end

    methods
        function evalConstitutiveJandF(self,evaluator)
            self.nP=self.BranchNodes(1,:);
            self.nM=self.BranchNodes(2,:);

            evaluator.Ji(self.IndicesJi)=1;
            self.g=1./self.Resistance.';
            evaluator.Jv(self.IndicesJv(1,:))=-self.g;
            evaluator.Jv(self.IndicesJv(2,:))=self.g;
            updateConstitutiveF(self,evaluator)
        end

        function updateConstitutiveJandF(self,evaluator)
            updateConstitutiveF(self,evaluator)
        end

        function updateConstitutiveF(self,evaluator)
            evaluator.Fiv(self.Branches)=evaluator.I(self.Branches)-...
            (evaluator.V(self.nP)-evaluator.V(self.nM)).*self.g;
        end
    end
end
