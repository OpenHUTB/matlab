classdef AliasType < Simulink.interface.dictionary.DataType &  ...
        matlab.mixin.CustomDisplay

    properties ( Dependent = true )
        BaseType{ mustBeA( BaseType, { 'char', 'string',  ...
            'Simulink.interface.dictionary.DataType' } ) }
        Description{ mustBeTextScalar }
    end

    methods ( Hidden, Access = protected )
        function propgrp = getPropertyGroups( ~ )

            proplist = { 'Name', 'BaseType', 'Description', 'Owner' };
            propgrp = matlab.mixin.util.PropertyGroup( proplist );
        end
    end

    methods ( Hidden )
        function this = AliasType( interfaceDictAPI, zcImpl )


            this@Simulink.interface.dictionary.DataType( interfaceDictAPI, zcImpl );
        end
    end

    methods
        function set.BaseType( this, type )
            arguments
                this
                type{ mustBeA( type, { 'char', 'string',  ...
                    'Simulink.interface.dictionary.DataType' } ) }
            end
            if isa( type, 'Simulink.interface.dictionary.DataType' )
                typeStr = type.getTypeString(  );
            else
                typeStr = type;
            end


            this.setDDEntryPropValue( 'BaseType', typeStr );
        end

        function value = get.BaseType( this )
            value = this.ZCImpl.p_BaseType;
        end

        function desc = get.Description( this )
            desc = this.ZCImpl.p_Description;
        end

        function set.Description( this, newDesc )
            this.setDDEntryPropValue( 'Description', newDesc );
        end
    end

    methods ( Hidden )
        function str = getTypeString( this )
            str = this.Name;
        end
    end
end



