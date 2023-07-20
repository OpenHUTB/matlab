classdef F<rf.internal.rfengine.elements.Elements


    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Vsense={}
        Gain=[]
        ControlBranches=[]
    end

    methods(Access=private)
        function self=F(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,vsense,gain)
            if isempty(ckt.F)
                ckt.F=rf.internal.rfengine.elements.F(ckt,label,n1,n2);
            else
                addElement(ckt.F,ckt,label,n1,n2)
            end
            ckt.F.Vsense{end+1}=vsense;
            ckt.F.Gain(end+1)=rf.internal.rfengine.Circuit.spice2double(gain);
        end
    end

    methods
        function initializeIndices(self,ckt)
            initializeIndices@rf.internal.rfengine.elements.Elements(self,ckt)
            self.IndicesJv=[];


            for k=1:size(self.Nodes,2)
                if~isempty(ckt.V)
                    idx=strcmp(self.Vsense{k},ckt.V.Label);
                    if any(idx)
                        self.ControlBranches(k)=ckt.V.Branches(idx);
                        continue
                    end
                end

                if~isempty(ckt.Vsin)
                    idx=strcmp(self.Vsense{k},ckt.Vsin.Label);
                    if any(idx)
                        self.ControlBranches(k)=ckt.Vsin.Branches(idx);
                        continue
                    end
                end
            end

            self.IndicesJi=[...
            self.IndicesJi
            self.Branches+(self.ControlBranches-1)*ckt.NumBranches
            ];
        end

        function evalConstitutiveJandF(self,analysis)
            analysis.Ji(self.IndicesJi(1,:))=1;
            analysis.Ji(self.IndicesJi(2,:))=-self.Gain;
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            analysis.Fiv(self.Branches)=analysis.I(self.Branches)-...
            self.Gain.'.*analysis.I(self.ControlBranches);
        end
    end
end
