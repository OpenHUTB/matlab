classdef(Sealed,Hidden)Node<handle














    properties


        Indegree(1,1)double=0;


        Outdegree(1,1)double=0;


        InPorts(1,:)Simulink.internal.variantlayout.Port;


        OutPorts(1,:)Simulink.internal.variantlayout.Port;


        Position(1,2)double;


        Size(1,2)double=[1,1];


        NodeHandle(1,1)double;



        NodeLabel(1,1)double;



        NodeLayer(1,1)double;




        NodeRank(1,1)double;


        IsDummy(1,1)logical=0;


        NodeName(1,:)char;



        Deltav(1,1)double=0;


        Orientation(1,:)char='right';
    end

    methods

        function obj=Node(blkPath,label,dummy)

            if nargin>2

                obj.IsDummy=dummy;
                obj.InPorts=Simulink.internal.variantlayout.Port;
                obj.OutPorts=Simulink.internal.variantlayout.Port;
                obj.InPorts.PortType='inport';
                obj.OutPorts.PortType='outport';
                obj.InPorts.ParentNode='dummy';
                obj.OutPorts.ParentNode='dummy';
                obj.InPorts.PortNumber=1;
                obj.OutPorts.PortNumber=1;

            elseif nargin>1

                obj.NodeHandle=get_param(blkPath,'Handle');
                pos=get_param(blkPath,'Position');
                obj.Position=[pos(1),pos(2)];
                obj.NodeLabel=label;
                obj.NodeName=get(obj.NodeHandle,'Name');
                obj.Orientation=get_param(blkPath,'Orientation');







                obj.Size=[pos(3)-pos(1),pos(4)-pos(2)];

                portHandles=get_param(blkPath,'PortHandles');

                obj.Indegree=numel(portHandles.Inport)+...
                numel(portHandles.LConn)+numel(portHandles.RConn)...
                +numel(portHandles.Enable)+numel(portHandles.Trigger)...
                +numel(portHandles.Ifaction)+numel(portHandles.Reset);
                obj.Outdegree=numel(portHandles.Outport)+...
                numel(portHandles.LConn)+numel(portHandles.RConn)...
                +numel(portHandles.State);


                if obj.Indegree~=0
                    obj.InPorts(1,obj.Indegree)=Simulink.internal.variantlayout.Port;
                end

                if obj.Outdegree~=0
                    obj.OutPorts(1,obj.Outdegree)=Simulink.internal.variantlayout.Port;
                end

                for inP=1:numel(portHandles.Inport)
                    obj.InPorts(inP)=Simulink.internal.variantlayout.Port(portHandles.Inport(inP));
                end
                inPortFilledIdx=numel(portHandles.Inport);

                for ouP=1:numel(portHandles.Outport)
                    obj.OutPorts(ouP)=Simulink.internal.variantlayout.Port(portHandles.Outport(ouP));
                end
                outPortFilledIdx=numel(portHandles.Outport);

                for lCon=1:numel(portHandles.LConn)
                    obj.InPorts(inPortFilledIdx+lCon)=...
                    Simulink.internal.variantlayout.Port(portHandles.LConn(lCon));
                    obj.OutPorts(outPortFilledIdx+lCon)=...
                    Simulink.internal.variantlayout.Port(portHandles.LConn(lCon));

                    obj.InPorts(inPortFilledIdx+lCon).PortSide=...
                    Simulink.internal.variantlayout.Direction.LEFT;
                    obj.OutPorts(outPortFilledIdx+lCon).PortSide=...
                    Simulink.internal.variantlayout.Direction.LEFT;





                    angleRot=floor(get(portHandles.LConn(lCon),'Rotation'));
                    if angleRot==0
                        obj.InPorts(inPortFilledIdx+lCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.LEFT;
                        obj.OutPorts(outPortFilledIdx+lCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.RIGHT;
                    elseif angleRot==1
                        obj.InPorts(inPortFilledIdx+lCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.UP;
                        obj.OutPorts(outPortFilledIdx+lCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.DOWN;
                    elseif angleRot==3
                        obj.InPorts(inPortFilledIdx+lCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.RIGHT;
                        obj.OutPorts(outPortFilledIdx+lCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.LEFT;
                    elseif angleRot==4||angleRot==-2
                        obj.InPorts(inPortFilledIdx+lCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.DOWN;
                        obj.OutPorts(outPortFilledIdx+lCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.UP;
                    end
                end
                inPortFilledIdx=inPortFilledIdx+numel(portHandles.LConn);
                outPortFilledIdx=outPortFilledIdx+numel(portHandles.LConn);

                for RCon=1:numel(portHandles.RConn)
                    obj.InPorts(inPortFilledIdx+RCon)=...
                    Simulink.internal.variantlayout.Port(portHandles.RConn(RCon));
                    obj.OutPorts(outPortFilledIdx+RCon)=...
                    Simulink.internal.variantlayout.Port(portHandles.RConn(RCon));

                    obj.InPorts(inPortFilledIdx+RCon).PortSide=...
                    Simulink.internal.variantlayout.Direction.RIGHT;
                    obj.OutPorts(outPortFilledIdx+RCon).PortSide=...
                    Simulink.internal.variantlayout.Direction.RIGHT;





                    angleRot=floor(get(portHandles.RConn(RCon),'Rotation'));
                    if angleRot==0
                        obj.InPorts(inPortFilledIdx+RCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.RIGHT;
                        obj.OutPorts(outPortFilledIdx+RCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.LEFT;
                    elseif angleRot==1
                        obj.InPorts(inPortFilledIdx+RCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.DOWN;
                        obj.OutPorts(outPortFilledIdx+RCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.UP;
                    elseif angleRot==3
                        obj.InPorts(inPortFilledIdx+RCon).PortOrientation=Simulink.internal.variantlayout.Direction.LEFT;
                        obj.OutPorts(outPortFilledIdx+RCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.RIGHT;
                    elseif angleRot==4||angleRot==-2
                        obj.InPorts(inPortFilledIdx+RCon).PortOrientation=Simulink.internal.variantlayout.Direction.UP;
                        obj.OutPorts(outPortFilledIdx+RCon).PortOrientation=...
                        Simulink.internal.variantlayout.Direction.DOWN;
                    end
                end
                inPortFilledIdx=inPortFilledIdx+numel(portHandles.RConn);
                outPortFilledIdx=outPortFilledIdx+numel(portHandles.RConn);

                for enP=1:numel(portHandles.Enable)
                    obj.InPorts(inPortFilledIdx+enP)=...
                    Simulink.internal.variantlayout.Port(portHandles.Enable(enP));
                end
                inPortFilledIdx=inPortFilledIdx+numel(portHandles.Enable);

                for trP=1:numel(portHandles.Trigger)
                    obj.InPorts(inPortFilledIdx+trP)=...
                    Simulink.internal.variantlayout.Port(portHandles.Trigger(trP));
                end
                inPortFilledIdx=inPortFilledIdx+numel(portHandles.Trigger);

                for stP=1:numel(portHandles.State)
                    obj.OutPorts(outPortFilledIdx+stP)=...
                    Simulink.internal.variantlayout.Port(portHandles.State(stP));
                end


                for acP=1:numel(portHandles.Ifaction)
                    obj.InPorts(inPortFilledIdx+acP)=...
                    Simulink.internal.variantlayout.Port(portHandles.Ifaction(acP));
                end
                inPortFilledIdx=inPortFilledIdx+numel(portHandles.Ifaction);

                for rsP=1:numel(portHandles.Reset)
                    obj.InPorts(inPortFilledIdx+rsP)=...
                    Simulink.internal.variantlayout.Port(portHandles.Reset(rsP));
                end


            elseif nargin>0


                anotHandle=blkPath;
                obj.NodeHandle=anotHandle;
                pos=get(anotHandle,'Position');
                obj.Position=[pos(1),pos(2)];
                obj.Size=[pos(3),pos(4)]-[pos(1),pos(2)];
                obj.NodeName='annot';
            end
        end
    end
end


