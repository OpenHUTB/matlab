classdef I<rf.internal.rfengine.elements.Elements


    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Current=[]
    end

    methods(Access=private)
        function self=I(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,val)
            if isempty(ckt.I)
                ckt.I=rf.internal.rfengine.elements.I(ckt,label,n1,n2);
            else
                addElement(ckt.I,ckt,label,n1,n2)
            end
            if strncmpi(val,'dc=',3)
                val=val(4:end);
            end
            ckt.I.Current(end+1)=rf.internal.rfengine.Circuit.spice2double(val);
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
            analysis.Uiv(self.Branches)=self.Current.';
        end
    end
end
