classdef StateflowMDLMatch<handle




    properties(GetAccess=public,SetAccess=immutable)
        Value(1,1)string
        SSID(1,1)string
        Node(1,1)
    end

    properties(Dependent)
ChartID
Path
ParentID
    end

    properties(GetAccess=public,SetAccess=immutable)
        ID(1,1)string
    end

    properties(GetAccess=private,SetAccess=immutable)
Handler
    end

    methods
        function this=StateflowMDLMatch(value,ssid,id,handler,node)
            this.Value=value;
            this.SSID=ssid;
            this.ID=id;
            this.Handler=handler;
            this.Node=node;
        end

        function id=get.ChartID(this)
            next=this.ID;
            while strlength(next)>0
                id=next;
                next=this.Handler.getStateflowParent(id);
            end
        end

        function path=get.Path(this)
            path=this.Handler.getStateflowChartName(this.ChartID)+":"+this.SSID;
        end

        function id=get.ParentID(this)
            id=this.Handler.getStateflowParent(this.ID);
        end

        function comp=createComponent(this)
            chartName=this.Handler.getStateflowChartName(this.ChartID);
            sid=this.Handler.getSID(chartName);
            stateflowType=dependencies.internal.graph.Type("Stateflow");
            comp=dependencies.internal.graph.Component(this.Node,this.Path,stateflowType,0,"",chartName,sid+":"+this.SSID);
        end
    end
end
