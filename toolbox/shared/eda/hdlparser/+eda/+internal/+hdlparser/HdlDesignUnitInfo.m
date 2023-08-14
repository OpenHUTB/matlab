


classdef HdlDesignUnitInfo<handle


    properties(Access=protected)
        Ports=[];
    end

    methods

        function obj=HdlDesignUnitInfo()
            obj.Ports=[];
        end

        function clear(obj)
            obj.Ports=[];
        end
        function numPort=getNumOfPorts(obj)

            numPort=length(obj.Ports);
        end
        function addPort(obj,name,direction,bitwidth,isdescending)



            newPort=struct('Name',name,'Direction',direction,...
            'Bitwidth',bitwidth,'Isdescending',isdescending);
            obj.Ports=[obj.Ports,newPort];
        end

        function name=getPortName(obj,indx)

            name=obj.Ports(indx).Name;
        end

        function setPortName(obj,indx,name)

            obj.Ports(indx).Name=name;
        end

        function mode=getPortDirection(obj,indx)

            mode=obj.Ports(indx).Direction;
        end
        function setPortDirection(obj,indx,direction)
            obj.Ports(indx).Direction=direction;
        end

        function bitwidth=getPortBitWidth(obj,indx)
            bitwidth=obj.Ports(indx).Bitwidth;
        end
        function setPortBitWidth(obj,indx,bitwidth)
            obj.Ports(indx).Bitwidth=bitwidth;
        end

        function isdescending=isRangeDescending(obj,indx)
            isdescending=obj.Ports(indx).Isdescending;
        end

        function setRangeDescending(obj,indx,isdescending)
            obj.Ports(indx).Isdescending=isdescending;
        end

        function indx=findPort(obj,name)


            if(isempty(obj.Ports))
                indx=0;
                return;
            end

            r=strcmp({obj.Ports.Name},name);
            indx=find(r,1,'first');
        end
    end
end

