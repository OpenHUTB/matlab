classdef ARClassicPlatformMapping < Simulink.interface.dictionary.internal.PlatformMapping

    properties ( Constant, Access = private )
        PlatformKind = sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic;
    end

    methods
        function this = ARClassicPlatformMapping( interfaceDictAPI )


            arguments
                interfaceDictAPI Simulink.interface.Dictionary
            end
            this@Simulink.interface.dictionary.internal.PlatformMapping( interfaceDictAPI );
        end

        function setPlatformProperty( this, stereotypeableObj, varargin )

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                [ propNames, propValues ] = autosar.dictionary.ARClassicPlatformMapping.parseInputParams( varargin{ : } );

                if isa( stereotypeableObj, 'Simulink.interface.dictionary.InterfaceElement' )



                    this.syncPlatformProperty( stereotypeableObj, propNames, propValues );
                else
                    this.setPlatformPropertyImpl( stereotypeableObj, propNames, propValues )
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function propValue = getPlatformProperty( this, stereotypeableObj, propName )
















            arguments
                this autosar.dictionary.ARClassicPlatformMapping
                stereotypeableObj Simulink.interface.dictionary.BaseElement
                propName{ mustBeTextScalar, mustBeNonzeroLengthText }
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                propValue = this.getPlatformPropertyImpl( stereotypeableObj, propName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function [ propNames, propValues ] = getPlatformProperties( this, stereotypeableObj )












            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.BaseElement
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                if isa( stereotypeableObj, 'Simulink.interface.dictionary.InterfaceElement' )


                    [ propNames, propValues ] = this.getInterfaceElementPlatformProperties( stereotypeableObj );
                else
                    [ propNames, propValues ] = this.getPlatformPropertiesImpl( stereotypeableObj );
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function exportedFolder = exportDictionary( this, namedargs )





            arguments
                this
                namedargs.IsArchModelUIContext = false;
                namedargs.IsInterfaceDictUIContext = false;
                namedargs.ConfigSetOfBuildContext = [  ];
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                exporter = autosar.dictionary.internal.DictionaryExporter( this.InterfaceDictAPI.filepath,  ...
                    IsArchModelUIContext = namedargs.IsArchModelUIContext,  ...
                    IsInterfaceDictUIContext = namedargs.IsInterfaceDictUIContext,  ...
                    ConfigSetOfBuildContext = namedargs.ConfigSetOfBuildContext );
                exportedFolder = exporter.exportToARXML(  );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end
    end

    methods ( Hidden )



        function removeUnreferencedAUTOSARProperties( this )







            autosar.mm.sl2mm.M3IGarbageCollector.removeUnreferencedDataTypes(  ...
                this.InterfaceDictAPI.filepath );
        end

        function platformKind = getPlatformKind( this )
            platformKind = char( this.PlatformKind );
        end

        function setConstantDeploymentMethod( this, constantObj, methodStr )
            arguments
                this
                constantObj Simulink.interface.dictionary.Constant
                methodStr{ mustBeMember( methodStr, [ "Auto", "SystemConstant" ] ) };
            end


            method = sl.interface.dict.mapping.ConstantDeploymentMethod( methodStr );
            slddEntry = this.InterfaceDictAPI.getDDEntryObject( constantObj.Name );
            dictionaryMapping = this.InterfaceDictAPI.DictImpl.MappingManager.getMappingFor( this.PlatformKind );
            constantMapping = dictionaryMapping.findMappingEntriesByUUID( { slddEntry.UUID } );
            constantMapping.DeploymentMethod = method;



            methodStr = string( method );
            dataObj = slddEntry.getValue(  );
            if strcmp( methodStr, "SystemConstant" )
                dataObj.CoderInfo.StorageClass = 'Custom';
                dataObj.CoderInfo.CustomStorageClass = 'SystemConstant';
            else
                dataObj.CoderInfo.StorageClass = 'Auto';
                assert( strcmp( methodStr, "Auto" ), "Unexpected constant deployment method: %s", methodStr );
            end
            slddEntry.setValue( dataObj );
        end

        function methodStr = getConstantDeploymentMethod( this, constantObj )
            arguments
                this
                constantObj Simulink.interface.dictionary.Constant
            end

            slddEntry = this.InterfaceDictAPI.getDDEntryObject( constantObj.Name );
            dictionaryMapping = this.InterfaceDictAPI.DictImpl.MappingManager.getMappingFor( this.PlatformKind );
            constantMapping = dictionaryMapping.findMappingEntriesByUUID( { slddEntry.UUID } );
            methodStr = char( constantMapping.DeploymentMethod );
        end

        function dataType = getPlatformPropertyDataType( this, stereotypeableObj, propName )




            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.BaseElement
                propName
            end

            assert( stereotypeableObj.getIsStereotypableElement(  ),  ...
                '%s does not have any platform properties.', stereotypeableObj.Name );

            if isa( stereotypeableObj, 'Simulink.interface.dictionary.InterfaceElement' )


                dataType = this.getInterfaceElementPlatformPropertyDataType(  ...
                    stereotypeableObj, propName );
            else

                dataType = getPlatformPropertyDataType@ ...
                    Simulink.interface.dictionary.internal.PlatformMapping(  ...
                    this, stereotypeableObj, propName );
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

            if isa( stereotypeableObj, 'Simulink.interface.dictionary.InterfaceElement' )


                allowedValues = this.getInterfaceElementPlatformPropertyAllowedValues(  ...
                    stereotypeableObj, propName );
            else

                allowedValues = getPlatformPropertyAllowedValues@ ...
                    Simulink.interface.dictionary.internal.PlatformMapping(  ...
                    this, stereotypeableObj, propName );
            end
        end

        function syncPlatformProperty( this, stereotypeableObj, propNames, propValues )
            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.BaseElement
                propNames
                propValues
            end

            assert( stereotypeableObj.getIsStereotypableElement(  ), '%s does not have any platform properties.', stereotypeableObj.Name );

            platformSyncer = this.InterfaceDictAPI.getPlatformMappingSyncer(  ...
                sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic );
            if isa( stereotypeableObj, 'Simulink.interface.dictionary.InterfaceElement' )
                platformSyncer.setInterfaceElementPlatformProps( stereotypeableObj, propNames, propValues );
            else
                platformSyncer.setInterfacePlatformProps( stereotypeableObj, propNames, propValues );
            end
        end

        function propValue = getInterfacePlatformPropValue( this, stereotypeableObj, propName )
            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.PortInterface
                propName
            end

            platformSyncer = this.InterfaceDictAPI.getPlatformMappingSyncer(  ...
                sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic );
            propValue = platformSyncer.getInterfacePlatformPropValue( stereotypeableObj, propName );
        end

        function hasDynamicAllowedValues = hasDynamicAllowedValues( ~, ~, propName )

            if strcmp( propName, 'SwAddrMethod' )

                hasDynamicAllowedValues = true;
            else
                hasDynamicAllowedValues = false;
            end
        end
    end

    methods ( Access = private )
        function [ propNames, propValues ] = getInterfaceElementPlatformProperties( this, stereotypeableObj )
            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.InterfaceElement
            end

            platformSyncer = this.InterfaceDictAPI.getPlatformMappingSyncer(  ...
                sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic );
            [ propNames, propValues ] = platformSyncer.getInterfaceElementPlatformProps( stereotypeableObj );
        end

        function dataType = getInterfaceElementPlatformPropertyDataType( this, stereotypeableObj, propName )
            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.InterfaceElement
                propName char
            end

            platformSyncer = this.InterfaceDictAPI.getPlatformMappingSyncer(  ...
                sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic );
            dataType = platformSyncer.getInterfaceElementPlatformPropertyDataType(  ...
                stereotypeableObj, propName );
        end

        function dataType = getInterfaceElementPlatformPropertyAllowedValues( this, stereotypeableObj, propName )
            arguments
                this
                stereotypeableObj Simulink.interface.dictionary.InterfaceElement
                propName char
            end

            platformSyncer = this.InterfaceDictAPI.getPlatformMappingSyncer(  ...
                sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic );
            dataType = platformSyncer.getInterfaceElementPlatformPropertyAllowedValues(  ...
                stereotypeableObj, propName );
        end
    end

    methods ( Static, Access = private )

        function [ propertyNames, propertyValues ] = parseInputParams( varargin )

            p = inputParser;
            p.KeepUnmatched = true;
            p.PartialMatching = false;
            p.parse( varargin{ : } );
            params = p.Unmatched;
            propertyNames = fieldnames( params );
            propertyValues = struct2cell( params );
        end
    end
end


