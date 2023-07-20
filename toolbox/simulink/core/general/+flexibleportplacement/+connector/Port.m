classdef Port<flexibleportplacement.connector.Connector




    properties
Handle
    end

    properties(Abstract,SetAccess=private)
DefaultBlockSide
    end

    properties(Dependent,SetAccess=private)
PortNumber
    end

    methods(Access=protected)
        function obj=Port(ph)


            obj.Handle=ph;
        end
    end

    methods
        function portNum=get.PortNumber(obj)
            portNum=obj.getPortNumberImpl();
        end
    end

    methods(Access=protected)

        function portNum=getPortNumberImpl(obj)
            portNum=get_param(obj.Handle,'PortNumber');
        end

        function label=getPortLabelBasedDisplayName(obj,isInport)
            blkPath=get_param(obj.Handle,'Parent');
            blkH=get_param(blkPath,'Handle');



            rawLabel=slInternal('getPortLabel',blkH,obj.PortNumber,isInport);

            label=[obj.Identifier,' (',rawLabel,')'];
        end
    end
end


