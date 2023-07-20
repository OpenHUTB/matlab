classdef Factory




    methods(Access=private)
        function obj=Factory()
        end
    end


    properties(Access=private,Constant)
        DefaultType='';
        ConcreteTypes={'flexibleportplacement.specification.EquallySpacedPortSpec'};
    end

    methods(Static)
        function spec=getSpecifiction(block)
            assert(slfeature('FlexiblePortPlacementInfrastructure')>=1)
            assert(slfeature('SubsystemFlexiblePortPlacement')>=1)

            assert(is_simulink_handle(block));
            assert(strcmp(get_param(block,'Type'),'block'));
            assert(any(strcmp(get_param(block,'BlockType'),{'SubSystem','ModelReference'})));

            spec=flexibleportplacement.specification.EquallySpacedPortSpec(block);

            try



                [schema,m]=flexibleportplacement.specification.Factory.getSchemaFromBlock(block);%#ok<ASGLU> variable "m" needs to stay alive since it "owns" the schema.

                isSchemaCorrectType=metaclass(schema)==flexibleportplacement.specification.EquallySpacedPortSpec.ConnectorPlacementType;

                if~isSchemaCorrectType&&~isempty(schema)
                    warning(['There is no specification defined for this schema,',...
                    ' reverting to the EquallySpacedPortSpec']);
                end

                if isempty(schema)||~isSchemaCorrectType
                    spec.revertToDefault();
                else
                    spec.loadFromSchema(schema);
                end
            catch ME
                warning('FlexiblePortPlacement:specificationFactory:internalError',...
                ['An error occurred when attempting to load the existing '...
                ,'port placement schema and display it in a dialog. '...
                ,'Reverting to default EquallySpacedPortSpec port positions.'...
                ,newline,newline,...
                'The error was: ',newline,newline,...
                ME.getReport()])
                spec.revertToDefault();
            end

        end
    end

    methods(Static,Access=private)
        function[schema,m]=getSchemaFromBlock(block)
            connectorPlacementJsonSpec=get_param(block,'PortSchema');

            if isempty(connectorPlacementJsonSpec)
                schema=ConnectorPlacement.PlacementSchema.empty();
                m=mf.zero.Model.empty();
                return;
            end

            parser=mf.zero.io.JSONParser;
            schema=parser.parseString(connectorPlacementJsonSpec);
            m=parser.Model;
        end
    end
end


