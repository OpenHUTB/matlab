classdef C<rf.internal.rfengine.elements.Elements



    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Capacitance=[]
        IC={}
    end

    methods(Access=private)
        function self=C(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,val,varargin)
            if isempty(ckt.C)
                ckt.C=rf.internal.rfengine.elements.C(ckt,label,n1,n2);
            else
                addElement(ckt.C,ckt,label,n1,n2)
            end
            ckt.C.Capacitance(end+1)=rf.internal.rfengine.Circuit.spice2double(val);
            if~isempty(varargin)
                tok=varargin{1};
                i=strfind(tok,'=');
                ckt.C.IC{end+1}=tok(i+1:end);

                rf.internal.rfengine.elements.Vic.add(ckt,...
                sprintf('v_%s_IC',ckt.C.Label{end}),...
                ckt.C.NodeNames{1,end},...
                ckt.C.NodeNames{2,end},...
                ckt.C.IC{end})
            else
                ckt.C.IC{end+1}='0';
            end
        end
    end

    methods
        function initializeIndices(self,ckt)
            initializeIndices@rf.internal.rfengine.elements.Elements(self,ckt)
            self.IndicesJqv=self.IndicesJv;
            self.IndicesJv=[];
        end

        function evalConstitutiveJandF(self,analysis)
            if analysis.EvaluateCharge
                analysis.Jqv(self.IndicesJqv(1,:))=-self.Capacitance;
                analysis.Jqv(self.IndicesJqv(2,:))=self.Capacitance;
            end
            analysis.Ji(self.IndicesJi)=1;
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            if analysis.EvaluateCharge
                analysis.Qiv(self.Branches)=self.Capacitance.'.*...
                (analysis.V(self.BranchNodes(2,:))...
                -analysis.V(self.BranchNodes(1,:)));
            end
            analysis.Fiv(self.Branches)=analysis.I(self.Branches);
        end
    end
end
