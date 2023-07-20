classdef Epoly<rf.internal.rfengine.elements.Elements




    properties(Constant)
        BranchNodeIndices=[1;2]
        ControlNodeIndices=[3;4]
    end

    properties
        P={}
        ControlNodes=[]
    end

    methods(Access=private)
        function self=Epoly(ckt,label,n1,n2,n3,n4)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2,n3,n4);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,~,n3,n4,varargin)
            if isempty(ckt.Epoly)
                ckt.Epoly=rf.internal.rfengine.elements.Epoly(ckt,label,n1,n2,n3,n4);
            else
                addElement(ckt.Epoly,ckt,label,n1,n2,n3,n4)
            end
            c=str2double(varargin);
            if isempty(c)
                c=0;
            end
            ckt.Epoly.P{end+1}=c.';
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
            for j=1:size(self.Nodes,2)
                c=self.P{j};
                n=length(c)-1;
                dv=analysis.V(self.ControlNodes(1,j))-...
                analysis.V(self.ControlNodes(2,j));
                d=dv.^(0:n-1)*((1:n)'.*c(2:end));

                analysis.Jv(self.IndicesJv(3,j))=-d;
                analysis.Jv(self.IndicesJv(4,j))=d;
            end
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            evalConstitutiveJandF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            for j=1:size(self.Nodes,2)
                c=self.P{j};
                n=length(c)-1;
                analysis.Fiv(self.Branches(j))=...
                analysis.V(self.BranchNodes(1,j))-...
                analysis.V(self.BranchNodes(2,j))-...
                (analysis.V(self.ControlNodes(1,j))-...
                analysis.V(self.ControlNodes(2,j))).^(0:n)*c;
            end
        end
    end
end
