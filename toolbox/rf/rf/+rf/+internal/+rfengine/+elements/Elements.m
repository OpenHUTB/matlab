classdef(Abstract)Elements<handle




    properties(Abstract,Constant)
BranchNodeIndices
    end

    properties
        Label={}
        NodeNames={}
        InternalNodeNames={}
        Nodes=[]

        BranchNodes=[]
        Branches=[]

        IndicesJk=[]
        IndicesJi=[]
        IndicesJv=[]
        IndicesJqi=[]
        IndicesJqv=[]
    end

    properties(Hidden)

        TimeDomain=true
    end

    methods(Abstract,Static)
        add(ckt,label,varargin)
    end

    methods(Abstract)
        evalConstitutiveJandF(self,evaluator)
        updateConstitutiveJandF(self,evaluator)
        updateConstitutiveF(self,evaluator)
    end

    methods(Access=protected)
        function addElement(self,ckt,label,varargin)
            self.Label{end+1}=label;
            self.NodeNames(:,end+1)=varargin';
            tallyNodes(ckt,self.NodeNames(:,end))
            if~isempty(self.InternalNodeNames)



                internalNames=strcat([label,'.'],self.InternalNodeNames);
                tallyNodes(ckt,internalNames)
            end
        end

        function self=Elements(ckt,label,varargin)
            addElement(self,ckt,label,varargin{:});
            ckt.Elements{end+1}=self;
        end
    end

    methods
        function initializeIndices(self,ckt)



            self.IndicesJk=...
            self.BranchNodes+(self.Branches-1)*ckt.NumNodes;






            self.IndicesJi=...
            self.Branches+(self.Branches-1)*ckt.NumBranches;





            self.IndicesJv=...
            self.Branches+(self.BranchNodes-1)*ckt.NumBranches;
        end

        function evalConservationJ(self,ckt)
            ckt.Jk(self.IndicesJk(1,:))=1;
            ckt.Jk(self.IndicesJk(2,:))=-1;
        end
    end
end
