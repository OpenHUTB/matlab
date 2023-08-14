classdef AV<rf.internal.rfengine.elements.SourceElements


    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Variance={}
    end

    methods(Access=private)
        function self=AV(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.SourceElements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,val)
            if isempty(ckt.AV)
                ckt.AV=rf.internal.rfengine.elements.AV(ckt,label,n1,n2);
            else
                addElement(ckt.AV,ckt,label,n1,n2)
            end
            if ischar(val)
                ckt.AV.Variance{end+1}=...
                rf.internal.rfengine.Circuit.spice2double(val);
            else
                ckt.AV.Variance{end+1}=val;
            end
        end
    end

    methods
        function initializeIndices(self,ckt)
            initializeIndices@rf.internal.rfengine.elements.Elements(self,ckt)
            self.IndicesJi=[];
        end

        function evalConstitutiveJandF(self,analysis)
            analysis.Jv(self.IndicesJv(1,:))=1;
            analysis.Jv(self.IndicesJv(2,:))=-1;
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            analysis.Fiv(self.Branches)=...
            analysis.V(self.BranchNodes(1,:))...
            -analysis.V(self.BranchNodes(2,:));
            analysis.Uiv(self.Branches)=0;
        end
    end
end
