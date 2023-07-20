classdef(Sealed,Hidden)Layer<handle












    properties

        LayerID(1,1)double;


        LayerPosition(1,2)double;



        LayerSize(1,1)double;


        Nodes(1,:)Simulink.internal.variantlayout.Node;




        LayerWidthMin(1,1)double;


        LayerWidthMax(1,1)double=-inf;
    end

    methods

        function this=Layer(layerId,layerPos)
            if nargin==2
                this.LayerID=layerId;
                this.LayerPosition=layerPos;
            end
        end


        function appendNode(this,Node)
            this.Nodes(end+1)=Node;
        end

        function appendDummyNode(this,dummyLabel,srcPort,srcNode,dstPort,hierarchyIdx,posFactor)
            tmp=Simulink.internal.variantlayout.Node('dummy',dummyLabel,1);

            tmp.Indegree=1;
            tmp.Outdegree=1;






            srcportPos=srcPort.PortPosition;
            dstportPos=dstPort.PortPosition;
            layPos=this.LayerPosition;














            if hierarchyIdx==1
                tmp.Position=[layPos(1),(posFactor*srcportPos(2)+(1-posFactor)*dstportPos(2))];
            else
                tmp.Position=[(posFactor*srcportPos(1)+(1-posFactor)*dstportPos(1)),layPos(2)];
            end

            tmp.Orientation=get_param(srcNode,'Orientation');
            tmp.NodeLabel=dummyLabel;
            tmp.NodeLayer=this.LayerID;

            tmp.InPorts.PortPosition=tmp.Position;
            tmp.OutPorts.PortPosition=tmp.Position;
            if posFactor>0.5

                tmp.InPorts.PortOrientation=srcPort.PortOrientation;
                tmp.OutPorts.PortOrientation=srcPort.PortOrientation;
            else

                tmp.InPorts.PortOrientation=dstPort.PortOrientation;
                tmp.OutPorts.PortOrientation=dstPort.PortOrientation;
            end
            srcName=get_param(srcNode,'Name');
            tmp.NodeName=sprintf(['d_',srcName,'_%d'],dummyLabel);
            this.Nodes(end+1)=tmp;
        end
    end
end


