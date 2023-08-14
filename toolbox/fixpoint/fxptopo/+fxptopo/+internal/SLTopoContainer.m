classdef(Sealed)SLTopoContainer<fxptopo.internal.TopologyContainer





    properties(Access=private)
        RemoveTopNode(1,1)logical=true
    end

    methods(Access=protected)
        function createGraph(this)
            g=Simulink.internal.extractBDTopoGraph(this.ModelName);
            if(this.RemoveTopNode)
                g=rmnode(g,1);
            end
            g=fxptopo.internal.topoGraphToFxpTopoGraph(g);

            this.ModelGraph=g;

            removeNodes=false(numel(g.Nodes.SID),1);
            for k=1:numel(removeNodes)
                if~isequal(g.Nodes.SID(k),"")
                    currentPath=Simulink.ID.getFullName(g.Nodes.SID(k));
                    if~strcmp(currentPath,this.CurrentSystem)
                        removeNodes(k)=~contains(currentPath,[this.CurrentSystem,'/']);
                    end
                end
            end
            g=g.rmnode(find(removeNodes));%#ok<FNDSB>

            this.Graph=g;
        end
    end

    methods
        function setRemoveTopNode(this,aVal)
            this.RemoveTopNode=aVal;
        end
    end
end
