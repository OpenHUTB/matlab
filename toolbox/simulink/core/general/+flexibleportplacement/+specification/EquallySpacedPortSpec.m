classdef EquallySpacedPortSpec<flexibleportplacement.specification.PortPlacementSpecification





    properties(Constant)
        ConnectorPlacementType=?ConnectorPlacement.EquallySpacedConnector
    end

    properties(Constant,Access=private)
        EmptySideData=struct(...
        char(ConnectorPlacement.RectSide.LEFT),...
        flexibleportplacement.connector.Connector.empty(),...
        char(ConnectorPlacement.RectSide.RIGHT),...
        flexibleportplacement.connector.Connector.empty(),...
        char(ConnectorPlacement.RectSide.TOP),...
        flexibleportplacement.connector.Connector.empty(),...
        char(ConnectorPlacement.RectSide.BOTTOM),...
        flexibleportplacement.connector.Connector.empty());

        EmptySideOrderData=struct(...
        char(ConnectorPlacement.RectSide.LEFT),[],...
        char(ConnectorPlacement.RectSide.RIGHT),[],...
        char(ConnectorPlacement.RectSide.TOP),[],...
        char(ConnectorPlacement.RectSide.BOTTOM),[]);
    end

    properties(SetAccess=private)
        SideData=flexibleportplacement.specification.EquallySpacedPortSpec.EmptySideData;
    end

    methods
        function obj=EquallySpacedPortSpec(block)
            obj=obj@flexibleportplacement.specification.PortPlacementSpecification(block);
        end

        function revertToDefault(obj)


            connectorFactory=flexibleportplacement.connector.Factory(obj.Block);
            portObjects=connectorFactory.getAllPorts();


            newSideData=obj.EmptySideData;
            sideOrderData=obj.EmptySideOrderData;

            for portObj=portObjects
                side=portObj.DefaultBlockSide;
                portNum=portObj.PortNumber;

                newSideData.(char(side))(end+1)=portObj;
                sideOrderData.(char(side))(end+1)=portNum;
            end


            [~,I]=structfun(@sort,sideOrderData,'UniformOutput',false);

            sortedSideData=obj.EmptySideData;
            sides=fields(newSideData);
            for ii=1:numel(sides)
                field=sides{ii};
                sortedSideData.(field)=newSideData.(field)(I.(field));
            end


            obj.SideData=sortedSideData;

        end

        function increaseConnectorIndex(obj,connector)
            side=obj.getConnectorsSide(connector);


            if obj.SideData.(char(side))(end)==connector
                return
            end

            idx=find(obj.SideData.(char(side))==connector);


            obj.SideData.(char(side))([idx,idx+1])=...
            obj.SideData.(char(side))([idx+1,idx]);
        end

        function decreaseConnectorIndex(obj,connector)
            side=obj.getConnectorsSide(connector);


            if obj.SideData.(char(side))(1)==connector
                return
            end

            idx=find(obj.SideData.(char(side))==connector);


            obj.SideData.(char(side))([idx,idx-1])=...
            obj.SideData.(char(side))([idx-1,idx]);
        end

        function moveConnectorToSide(obj,connector,side)
            oldSide=obj.getConnectorsSide(connector);


            isThisConnector=obj.SideData.(char(oldSide))==connector;
            obj.SideData.(char(oldSide))(isThisConnector)=[];


            obj.SideData.(char(side))(end+1)=connector;
        end

        function addSpacer(obj,side)
            newSpacer=flexibleportplacement.connector.Spacer;
            obj.SideData.(char(side))(end+1)=newSpacer;
        end

        function removeSpacer(obj,spacer)
            if metaclass(spacer)~=?flexibleportplacement.connector.Spacer
                return;
            end

            sideNames=fields(obj.SideData);
            for ii=1:numel(sideNames)
                sideName=sideNames{ii};
                obj.SideData.(sideName)(obj.SideData.(sideName)==spacer)=[];
            end
        end
    end

    methods(Access=private)
        function side=getConnectorsSide(obj,connector)
            sideNames=fields(obj.SideData);
            for ii=1:numel(sideNames)
                sideName=sideNames{ii};
                connectors=obj.SideData.(sideName);
                for connectorToCheck=connectors
                    if connector==connectorToCheck
                        side=ConnectorPlacement.RectSide.(sideName);
                        return;
                    end
                end
            end
            error('Connector not in spec');
        end

    end

    methods
        function loadFromSchema(obj,schema)

            newSideData=obj.EmptySideData;

            connectorFactory=flexibleportplacement.connector.Factory(obj.Block);

            for sideEnum=schema.sides.keys
                side=schema.sides.getByKey(sideEnum);
                connectorIds=side.connectorIds.toArray;

                for cIdAsCell=connectorIds
                    cId=cIdAsCell{:};
                    connector=connectorFactory.getConnectorFromId(cId);

                    newSideData.(char(sideEnum))(end+1)=connector;
                end
            end

            obj.SideData=newSideData;
        end

    end

    methods(Access=protected)
        function schemaModel=getSchemaModel(obj)

            schemaModel=mf.zero.Model;
            schema=ConnectorPlacement.EquallySpacedConnector(schemaModel);

            sideNames=fields(obj.SideData);
            for ii=1:numel(sideNames)
                sideName=sideNames{ii};

                side=ConnectorPlacement.EquallySpacedRectSide(schemaModel);
                side.side=ConnectorPlacement.RectSide.(sideName);

                connectors=obj.SideData.(sideName);
                for connector=connectors
                    portId=connector.Identifier;
                    side.connectorIds.add(portId);
                end

                schema.sides.add(side);
            end
        end
    end

end

