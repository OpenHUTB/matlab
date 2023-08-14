classdef V<rf.internal.rfengine.elements.Elements


    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Voltage=[]
    end

    methods(Access=private)
        function self=V(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,val)
            if isempty(ckt.V)
                ckt.V=rf.internal.rfengine.elements.V(ckt,label,n1,n2);
            else
                addElement(ckt.V,ckt,label,n1,n2)
            end
            if strncmpi(val,'dc=',3)
                val=val(4:end);
            end
            ckt.V.Voltage(end+1)=rf.internal.rfengine.Circuit.spice2double(val);
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
            analysis.Uiv(self.Branches)=self.Voltage.';
        end
    end
end
