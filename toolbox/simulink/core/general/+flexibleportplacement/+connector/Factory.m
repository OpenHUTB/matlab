classdef Factory<handle




    properties(GetAccess=private,SetAccess=immutable)
Block
PortsOnBlock
PortOnBlockIDs
    end

    methods
        function obj=Factory(block)
            assert(is_simulink_handle(block));
            assert(strcmp(get_param(block,'Type'),'block'));
            assert(any(strcmp(get_param(block,'BlockType'),{'SubSystem','ModelReference'})));

            obj.Block=block;
            obj.PortsOnBlock=obj.getAllPortsForBlock();
            obj.PortOnBlockIDs={obj.PortsOnBlock.Identifier};
        end

        function connectors=getAllPorts(obj)
            connectors=obj.PortsOnBlock;
        end

        function connector=getConnectorFromId(obj,id)
            matchingObjects=strcmp(obj.PortOnBlockIDs,id);
            connector=obj.PortsOnBlock(matchingObjects);

            if isempty(connector)&&flexibleportplacement.connector.Spacer.isIdForSpacer(id)
                connector=flexibleportplacement.connector.Spacer;
            end

            assert(isscalar(connector));
        end
    end

    methods(Access=private)
        function obj=getPort(obj,ph)


            blockPorts=get_param(obj.Block,'PortHandles');

            portTypes=fields(blockPorts);
            portsOfType=struct2cell(blockPorts);

            isPortOfType=cellfun(@(ports)any(ports==ph),portsOfType);
            portType=portTypes(isPortOfType);
            assert(isscalar(portType));
            portType=portType{:};


            ctor=@(p)flexibleportplacement.connector.(portType)(p);
            obj=ctor(ph);
        end

        function portObjs=getAllPortsForBlock(obj)

            ph=get_param(obj.Block,'PortHandles');
            allPortsInCells=struct2cell(ph);
            allPorts=[allPortsInCells{:}];

            portObjs=flexibleportplacement.connector.Port.empty();

            for port=allPorts
                portObjs(end+1)=obj.getPort(port);%#ok<AGROW>
            end
        end
    end
end


