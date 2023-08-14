classdef Vic<rf.internal.rfengine.elements.Elements


    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Enabled=true
        Voltage=[]
    end

    methods(Access=private)
        function self=Vic(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,val)
            if isempty(ckt.Vic)
                ckt.Vic=rf.internal.rfengine.elements.Vic(ckt,label,n1,n2);
            else
                addElement(ckt.Vic,ckt,label,n1,n2)
            end
            if strncmpi(val,'dc=',3)
                val=val(4:end);
            end
            ckt.Vic.Voltage(end+1)=rf.internal.rfengine.Circuit.spice2double(val);
        end
    end

    methods
        function evalConstitutiveJandF(self,analysis)
            analysis.Ji(self.IndicesJi)=1-self.Enabled;
            analysis.Jv(self.IndicesJv(1,:))=self.Enabled;
            analysis.Jv(self.IndicesJv(2,:))=-self.Enabled;
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            analysis.Fiv(self.Branches)=...
            (1-self.Enabled)*analysis.I(self.Branches)+...
            self.Enabled*(analysis.V(self.BranchNodes(1,:))...
            -analysis.V(self.BranchNodes(2,:)));
            analysis.Uiv(self.Branches)=self.Enabled*self.Voltage.';
        end
    end
end
