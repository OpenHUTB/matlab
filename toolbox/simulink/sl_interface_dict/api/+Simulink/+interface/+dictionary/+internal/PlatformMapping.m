classdef ( Abstract )PlatformMapping < handle






    methods ( Abstract )
        setPlatformProperty( this, stereotypeableObj, varargin );
        propVal = getPlatformProperty( this, stereotypeableObj, propName );
        [ propNames, propValues ] = getPlatformProperties( this, stereotypeableObj );
        platformKind = getPlatformKind( this );
    end

    properties ( Access = protected )
        InterfaceDictAPI Simulink.interface.Dictionary
    end

    methods
        function this = PlatformMapping( interfaceDictAPI )
            this.InterfaceDictAPI = interfaceDictAPI;
        end
    end

    methods ( Hidden, Access = public )
        function dataType = getPlatformPropertyDataType( this, stereotypeableObj, propName )





            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.BaseElement
                propName
            end

            assert( stereotypeableObj.getIsStereotypableElement(  ),  ...
                '%s does not have any platform properties.', stereotypeableObj.Name );

            stereotype = this.getPlatformStereotype( stereotypeableObj );
            zcWrapper = stereotypeableObj.getZCWrapper(  );
            propUsage = zcWrapper.getPropertyUsage( stereotype, propName );


            propertyType = propUsage.propertyDef.type;
            if isa( propertyType, 'systemcomposer.property.Enumeration' )
                dataType = 'enum';
            elseif isa( propertyType, 'systemcomposer.property.BooleanType' )
                dataType = 'bool';
            else
                dataType = 'string';
            end
        end

        function allowedValues = getPlatformPropertyAllowedValues( this, stereotypeableObj, propName )





            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.BaseElement
                propName
            end

            assert( stereotypeableObj.getIsStereotypableElement(  ),  ...
                '%s does not have any platform properties.', stereotypeableObj.Name );

            stereotype = this.getPlatformStereotype( stereotypeableObj );
            zcWrapper = stereotypeableObj.getZCWrapper(  );
            propUsage = zcWrapper.getPropertyUsage( stereotype, propName );

            propertyType = propUsage.propertyDef.type;
            if isa( propertyType, 'systemcomposer.property.Enumeration' )
                allowedValues = propertyType.getLiteralsAsStrings(  );
            else
                allowedValues = {  };
            end
        end

        function hasDynamicAllowedValues = hasDynamicAllowedValues( ~, ~, ~ )







            hasDynamicAllowedValues = true;
        end
    end

    methods ( Hidden, Static )
        function platformMapping = getPlatformMapping( platformName, interfaceDictAPI )

            switch ( platformName )
                case 'AUTOSARClassic'
                    platformMapping = autosar.dictionary.ARClassicPlatformMapping( interfaceDictAPI );
                case interfaceDictAPI.getFunctionPlatformNames(  )
                    platformMapping = Simulink.interface.dictionary.internal.FunctionPlaformMapping( platformName, interfaceDictAPI );
                otherwise
                    assert( false, 'Only AUTOSARClassic is supported for platform mapping' );
            end
        end
    end

    methods ( Access = protected )
        function propValue = getPlatformPropertyImpl( this, stereotypeableObj, propName )





            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.BaseElement
                propName
            end

            assert( stereotypeableObj.getIsStereotypableElement(  ),  ...
                '%s does not have any platform properties.', stereotypeableObj.Name );

            propName = convertStringsToChars( propName );

            if isa( stereotypeableObj, 'Simulink.interface.dictionary.InterfaceElement' )
                [ propNames, propValues ] = this.getPlatformProperties( stereotypeableObj );
                propValue = propValues( strcmp( propNames, propName ) );
                assert( ~isempty( propValue ), 'invalid property name: %s', propName );
                propValue = propValue{ : };
            else
                stereotypeQName = this.getPlatformStereotype( stereotypeableObj );
                if ~startsWith( propName, stereotypeQName )
                    propQName = [ stereotypeQName, '.', propName ];
                else
                    propQName = propName;
                end
                zcWrapper = stereotypeableObj.getZCWrapper(  );
                propValue = zcWrapper.getEvaluatedPropertyValue( propQName );
                if isenum( propValue )

                    propValue = char( propValue );
                end
            end
        end

        function setPlatformPropertyImpl( this, stereotypeableObj, propNames, propValues )





            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.BaseElement
                propNames
                propValues
            end

            import Simulink.interface.dictionary.internal.PlatformMapping

            assert( stereotypeableObj.getIsStereotypableElement(  ),  ...
                '%s does not have any platform properties.', stereotypeableObj.Name );

            propNames = convertStringsToChars( propNames );

            stereotype = this.getPlatformStereotype( stereotypeableObj );
            zcWrapper = stereotypeableObj.getZCWrapper(  );
            for i = 1:length( propNames )
                propName = propNames{ i };
                propValue = PlatformMapping.convertValueToExpression( propValues{ i } );
                try
                    zcWrapper.setProperty( [ stereotype, '.', propName ], propValue );
                catch ME
                    if strcmp( ME.identifier, 'SystemArchitecture:Property:ErrorSettingPropertyValue' ) &&  ...
                            ~isempty( ME.cause )


                        newME = ME.cause{ 1 };
                    else
                        newME = ME;
                    end
                    throw( newME );
                end
            end
        end

        function [ propNames, propValues ] = getPlatformPropertiesImpl( this, stereotypeableObj )




            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.BaseElement
            end

            import Simulink.interface.dictionary.internal.PlatformMapping

            assert( stereotypeableObj.getIsStereotypableElement(  ),  ...
                '%s does not have any platform properties.', stereotypeableObj.Name );

            stereotype = this.getPlatformStereotype( stereotypeableObj );
            zcWrapper = stereotypeableObj.getZCWrapper(  );
            propNames = cellstr( zcWrapper.getStereotypeProperties(  ) );
            propValues = cell( 1, length( propNames ) );
            for i = 1:length( propNames )
                propValues{ i } = this.getPlatformProperty( stereotypeableObj, propNames{ i } );
            end
            propNames = strrep( propNames, [ stereotype, '.' ], '' );
        end
    end

    methods ( Access = private )
        function stereotype = getPlatformStereotype( this, stereotypeableObj )
            import Simulink.interface.dictionary.internal.PlatformMapping

            profileName = this.getProfileName(  );
            zcWrapper = stereotypeableObj.getZCWrapper(  );
            stereotypes = zcWrapper.getStereotypes(  );

            stereotype = [  ];
            for i = 1:length( stereotypes )
                stereotype = stereotypes{ i };
                if startsWith( stereotype, profileName )
                    break ;
                end
            end
            assert( ~isempty( stereotype ), [ '%s has no platform properties. ' ...
                , 'Ensure dictionary has mapping for %s platform.' ], stereotypeableObj.Name, profileName );
        end

        function profileName = getProfileName( this )
            profileManager = Simulink.interface.dictionary.internal.ProfileManager.getManager( this.getPlatformKind(  ) );
            profileName = profileManager.getProfileName(  );
        end
    end

    methods ( Hidden, Static )
        function expr = convertValueToExpression( val )
            if ischar( val ) || isstring( val )
                val = char( val );
                expr = [ '''', val, '''' ];
            else

                expr = string( val );
            end
        end
    end
end

