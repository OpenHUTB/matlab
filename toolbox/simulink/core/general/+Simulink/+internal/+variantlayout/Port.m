classdef(Sealed,Hidden)Port<handle











    properties



        PortType(1,:)char;


        PortPosition(1,2)double;


        ParentNode(1,:)char;


        PortOrientation(1,1);


        PortHandle(1,1)double;


        PortNumber(1,1)double;


        PortSide(1,1);
    end


    methods

        function obj=Port(PortHandle)
            if(nargin>0)
                obj.PortHandle=PortHandle;
                obj.PortPosition=get(PortHandle,'Position');

                obj.PortNumber=get(PortHandle,'PortNumber');
                obj.ParentNode=get(PortHandle,'Parent');
                obj.PortType=get(PortHandle,'PortType');

                angleRot=floor(get(PortHandle,'Rotation'));
                switch obj.PortType
                case{'inport','enable','trigger','ifaction','Reset'}

                    if angleRot==6||angleRot==0
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.LEFT;
                    elseif angleRot==7||angleRot==1
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.UP;
                    elseif angleRot==3
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.RIGHT;
                    elseif angleRot==4||angleRot==-2
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.DOWN;
                    end



                    obj.PortSide=Simulink.internal.variantlayout.Direction.LEFT;

                case{'outport','state'}

                    if angleRot==0
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.LEFT;
                    elseif angleRot==1
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.UP;
                    elseif angleRot==3
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.RIGHT;
                    elseif angleRot==4||angleRot==-2
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.DOWN;
                    end




                    obj.PortSide=Simulink.internal.variantlayout.Direction.RIGHT;

                case 'connection'




                    if angleRot==0
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.LEFT;
                    elseif angleRot==1
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.UP;
                    elseif angleRot==3
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.RIGHT;
                    elseif angleRot==4||angleRot==-2
                        obj.PortOrientation=Simulink.internal.variantlayout.Direction.DOWN;
                    end

                end
            end
        end


        function isConnected=getIfConnected(obj,portobj)
            pH1=obj.PortHandle;
            pH2=portobj.PortHandle;
            switch obj.PortType
            case 'connection'

                blk1=get(pH1,'Parent');
                portConn=get_param(blk1,'PortConnectivity');
                portHandles=get_param(blk1,'PortHandles');
                allPorts=[portHandles.Inport,portHandles.Enable,...
                portHandles.Trigger,portHandles.Ifaction,...
                portHandles.Reset,portHandles.Outport,...
                portHandles.State,portHandles.LConn,...
                portHandles.RConn];
                portIdx=allPorts==pH1;
                conPorts=portConn(portIdx).DstPort;

            case{'inport','enable','trigger','ifaction','Reset'}
                lH=get(pH1,'Line');
                if lH~=-1
                    conPorts=get(lH,'SrcPortHandle');
                else
                    conPorts=[];
                end

            case{'outport','state'}
                lH=get(pH1,'Line');
                if lH~=-1
                    conPorts=get(lH,'DstPortHandle');
                else
                    conPorts=[];
                end
            end
            isConnected=any(conPorts==pH2);
        end
    end
end


