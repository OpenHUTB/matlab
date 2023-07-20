classdef AI<rf.internal.rfengine.elements.SourceElements


    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Variance={}
    end

    methods(Access=private)
        function self=AI(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.SourceElements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,val)
            if isempty(ckt.AI)
                ckt.AI=rf.internal.rfengine.elements.AI(ckt,label,n1,n2);
            else
                addElement(ckt.AI,ckt,label,n1,n2)
            end
            if ischar(val)
                ckt.AI.Variance{end+1}=...
                rf.internal.rfengine.Circuit.spice2double(val);
            else
                ckt.AI.Variance{end+1}=val;
            end
        end
    end

    methods
        function initializeIndices(self,ckt)
            initializeIndices@rf.internal.rfengine.elements.Elements(self,ckt)
            self.IndicesJv=[];
        end

        function evalConstitutiveJandF(self,analysis)
            analysis.Ji(self.IndicesJi)=1;
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            analysis.Fiv(self.Branches)=...
            analysis.I(self.Branches);
            analysis.Uiv(self.Branches)=0;
        end
    end
end
