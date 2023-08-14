classdef L<rf.internal.rfengine.elements.Elements



    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Inductance=[]
        IC={}
    end

    methods(Access=private)
        function self=L(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,val,varargin)
            if isempty(ckt.L)
                ckt.L=rf.internal.rfengine.elements.L(ckt,label,n1,n2);
            else
                addElement(ckt.L,ckt,label,n1,n2)
            end
            ckt.L.Inductance(end+1)=rf.internal.rfengine.Circuit.spice2double(val);
            if~isempty(varargin)
                tok=varargin{1};
                i=strfind(tok,'=');
                ckt.L.IC{end+1}=tok(i+1:end);

                newNode=...
                sprintf('%s_IC',ckt.L.NodeNames{1,end});
                rf.internal.rfengine.elements.Iic.add(ckt,...
                sprintf('i_%s_IC',ckt.L.Label{end}),...
                ckt.L.NodeNames{1,end},...
                newNode,...
                ckt.L.IC{end});
                ckt.NodeCountMap(newNode)=2;
                ckt.NodeCountMap(ckt.L.NodeNames{1,end})=...
                ckt.NodeCountMap(ckt.L.NodeNames{1,end})-1;
                ckt.L.NodeNames{1,end}=newNode;
            else
                ckt.L.IC{end+1}='0';
            end
        end
    end

    methods
        function initializeIndices(self,ckt)
            initializeIndices@rf.internal.rfengine.elements.Elements(self,ckt)
            self.IndicesJqi=self.IndicesJi;
            self.IndicesJi=[];
        end

        function evalConstitutiveJandF(self,analysis)
            if analysis.EvaluateCharge
                analysis.Jqi(self.IndicesJqi)=-self.Inductance;
            end
            analysis.Jv(self.IndicesJv(1,:))=1;
            analysis.Jv(self.IndicesJv(2,:))=-1;
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            if analysis.EvaluateCharge
                analysis.Qiv(self.Branches)=...
                -self.Inductance.'.*analysis.I(self.Branches);
            end
            analysis.Fiv(self.Branches)=...
            analysis.V(self.BranchNodes(1,:))...
            -analysis.V(self.BranchNodes(2,:));
        end
    end
end
