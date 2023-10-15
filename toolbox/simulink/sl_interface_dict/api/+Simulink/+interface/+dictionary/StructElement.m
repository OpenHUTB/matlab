classdef StructElement < Simulink.interface.dictionary.NamedElement &  ...
        matlab.mixin.CustomDisplay




    properties ( Access = private )
        Parent Simulink.interface.dictionary.StructType
    end

    properties ( Dependent = true )
        Type{ mustBeA( Type, [ "Simulink.interface.dictionary.DataType",  ...
            'char', 'string' ] ) }
        Description{ mustBeTextScalar }

        Dimensions{ mustBeTextScalar }

    end

    methods ( Hidden, Access = protected )
        function propgrp = getPropertyGroups( ~ )

            proplist = { 'Name', 'Type', 'Description', 'Dimensions', 'Owner' };
            propgrp = matlab.mixin.util.PropertyGroup( proplist );
        end
    end

    methods
        function this = StructElement( zcImpl, structType )


            arguments
                zcImpl
                structType Simulink.interface.dictionary.StructType
            end
            this@Simulink.interface.dictionary.NamedElement( zcImpl, structType.getDictionary(  ).DictImpl );
            this.Parent = structType;
        end

        function destroy( this )



            this.getOwner(  ).removeElement( this.Name );
            delete( this );
        end

        function type = get.Type( this )
            type = this.getStructElementType(  );
        end

        function set.Type( this, type )
            arguments
                this
                type{ mustBeA( type, [ "Simulink.interface.dictionary.DataType",  ...
                    'char', 'string' ] ) }
            end
            if isa( type, 'Simulink.interface.dictionary.DataType' )
                typeStr = type.getTypeString(  );
            else
                typeStr = type;
            end

            this.setBusElementProperty( 'Type', typeStr );
        end

        function value = get.Description( this )
            value = this.ZCImpl.p_Descriptor.p_Description;
        end

        function set.Description( this, value )
            this.setBusElementProperty( 'Description', value );
        end

        function value = get.Dimensions( this )
            value = this.ZCImpl.p_Descriptor.p_Dimensions;
        end

        function set.Dimensions( this, value )
            this.setBusElementProperty( 'Dimensions', value );
        end
    end

    methods ( Access = protected )
        function owner = getOwner( this )
            assert( this.Parent.isvalid(  ), 'Invalid or deleted object.' );
            owner = this.Parent;
        end

        function value = getName( this )
            value = this.ZCImpl.getName;
        end

        function setName( this, newName )
            systemcomposer.BusObjectManager.RenameInterfaceElement(  ...
                this.getSourceName, false, this.Parent.Name, this.Name, newName );
        end
    end

    methods ( Access = private )
        function setBusElementProperty( this, propName, propVal )
            Simulink.interface.dictionary.TypeUtils.setBusElementPropVal(  ...
                this.getSourceName, this.Parent.Name, this.Name,  ...
                propName, propVal );
        end

        function type = getStructElementType( this )
            idict = this.getDictionary(  );
            [ typeName, slDataType ] = this.getElementSLTypeName(  );
            if startsWith( slDataType, 'Bus:' ) || startsWith( slDataType, 'ValueType:' )
                type = idict.getDataType( typeName );
            else

                type = Simulink.interface.dictionary.ValueType( idict, this.ZCImpl.p_Descriptor );
            end
        end

        function [ typeName, dataType ] = getElementSLTypeName( this )
            dataType = this.ZCImpl.p_Descriptor.p_DataType;
            typeName = Simulink.interface.dictionary.TypeUtils.stripPrefix( dataType );
        end
    end
end

