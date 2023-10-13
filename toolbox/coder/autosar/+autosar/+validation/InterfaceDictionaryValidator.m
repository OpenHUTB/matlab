classdef InterfaceDictionaryValidator < autosar.validation.PhasedValidator

    methods ( Access = protected )

        function verifyInitial( this, hModel )%#ok<INUSD>
            autosar.validation.InterfaceDictionaryValidator.runChecks( hModel );
        end
    end

    methods ( Static )
        function runChecks( modelName )
            import autosar.validation.InterfaceDictionaryValidator

            modelName = get_param( modelName, 'Name' );

            interfaceDicts = SLDictAPI.getTransitiveInterfaceDictsForModel( modelName );
            if isempty( interfaceDicts )



                InterfaceDictionaryValidator.runNoInterfaceDictionaryChecks( modelName );
                return ;
            end


            InterfaceDictionaryValidator.checkSingleInterfaceDict( modelName, interfaceDicts );
            assert( numel( interfaceDicts ) == 1, 'expect 1 interface dict in model closure' );
            interfaceDict = autosar.utils.File.dropPath( interfaceDicts{ 1 } );


            InterfaceDictionaryValidator.checkNoAdaptiveComponent( modelName, interfaceDict );


            InterfaceDictionaryValidator.checkDictPlatformMapping( modelName, interfaceDict,  ...
                MappingKind = sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic );


            InterfaceDictionaryValidator.checkM3IModelsAreLinked( modelName, interfaceDict );


            InterfaceDictionaryValidator.checkNoInterfacesOutsideInterfaceDict( modelName, interfaceDict );
        end

        function checkSingleInterfaceDict( modelName, interfaceDicts )
            if numel( interfaceDicts ) > 1
                interfaceDictsStr = autosar.api.Utils.cell2str(  ...
                    autosar.utils.File.dropPath( interfaceDicts ) );
                autosar.validation.AutosarUtils.reportErrorWithFixit(  ...
                    'autosarstandard:dictionary:MultipleInterfaceDictsInModelClosure',  ...
                    modelName, interfaceDictsStr );
            end
        end

        function checkNoAdaptiveComponent( modelName, interfaceDict )



            if autosar.api.Utils.isMappedToAdaptiveApplication( modelName ) ||  ...
                    Simulink.CodeMapping.isAutosarAdaptiveSTF( modelName )
                autosar.validation.Validator.logErrorAndFlush(  ...
                    'autosarstandard:dictionary:InterfaceDictNoSupportedForAdaptiveComponent',  ...
                    interfaceDict, modelName );
            end
        end

        function runNoInterfaceDictionaryChecks( modelName )
            if autosar.api.Utils.isMapped( modelName )



                hasCrossM3IModelAssociations = ~isempty(  ...
                    autosarcore.ModelUtils.getMappingSharedDictUUID( modelName ) );
                if hasCrossM3IModelAssociations





                    dataDict = get_param( modelName, 'DataDictionary' );
                    autosar.validation.InterfaceDictionaryValidator.checkM3IModelsAreLinked(  ...
                        modelName, dataDict );
                end
            end
        end

        function checkDictPlatformMapping( modelName, interfaceDict, namedargs )


            arguments
                modelName
                interfaceDict
                namedargs.MappingKind sl.interface.dict.mapping.PlatformMappingKind
            end

            if isempty( namedargs.MappingKind )
                assert( autosar.api.Utils.isMappedToComponent( modelName ),  ...
                    '%s is expected to have classic AUTOSAR mapping', modelName );
                platformName = 'AUTOSARClassic';
            else
                platformName = char( namedargs.MappingKind );
            end

            dictAPI = Simulink.interface.dictionary.open( interfaceDict );
            if ~dictAPI.hasPlatformMapping( platformName )
                autosar.validation.Validator.logErrorAndFlush(  ...
                    'autosarstandard:dictionary:ModelUsingInterfaceDictNoARMapping',  ...
                    modelName, interfaceDict );
            end
        end

        function checkM3IModelsAreLinked( modelName, interfaceDictFile )
            if ~autosar.api.Utils.isMapped( modelName )
                return ;
            end

            interfaceDictName = autosar.utils.File.dropPath( interfaceDictFile );
            autosarcore.M3IModelLoader.runSharedAUTOSARDictChecks( modelName, interfaceDictName );






            if isempty( autosarcore.ModelUtils.getMappingSharedDictUUID( modelName ) )
                autosar.validation.Validator.logErrorAndFlush(  ...
                    'autosarstandard:dictionary:InterfaceDictNotProperlyLinkedToModel',  ...
                    modelName, interfaceDictName );
            end
        end

        function checkNoInterfacesOutsideInterfaceDict( modelName, interfaceDictFile )

            import autosar.validation.InterfaceDictionaryValidator

            if autosar.dictionary.internal.DictionaryExporter.isTempHiddenModelForDictExport( modelName )
                return ;
            end

            interfaceDictName = autosar.utils.File.dropPath( interfaceDictFile );
            bepBlks = InterfaceDictionaryValidator.findRootLevelBEPsUsingNonInterfaceDictInterfaces(  ...
                modelName, interfaceDictName );
            for ii = 1:numel( bepBlks )
                bepBlk = bepBlks{ ii };
                autosar.validation.Validator.logError(  ...
                    'autosarstandard:dictionary:UsedInterfaceDefinitionNotInInterfaceDict',  ...
                    modelName, getfullname( bepBlk ), get_param( bepBlk, 'PortName' ), interfaceDictName );
            end
        end

        function portBlocks = findRootLevelBEPsUsingNonInterfaceDictInterfaces(  ...
                subsysOrModel, interfaceDicts, namedargs )

            arguments
                subsysOrModel
                interfaceDicts
                namedargs.IncludeInlinedInterfaces = true;
            end

            portBlocks = {  };

            if ~iscell( interfaceDicts )
                interfaceDicts = { interfaceDicts };
            end

            dictInteraceNames = [  ];
            for dictIdx = 1:length( interfaceDicts )
                interfaceDictAPI = Simulink.interface.dictionary.open( interfaceDicts{ dictIdx } );
                dictInteraceNames = [ dictInteraceNames, interfaceDictAPI.getInterfaceNames(  ) ];%#ok<AGROW>
            end

            busElementPortsAtRoot = autosar.simulink.bep.Utils.findBusElementPortsAtRoot( subsysOrModel );
            for ii = 1:numel( busElementPortsAtRoot )
                bepBlk = busElementPortsAtRoot( ii );
                [ isUsingBusObj, busObjName ] = autosar.simulink.bep.Utils.isBEPUsingBusObject( bepBlk );
                if ~isUsingBusObj
                    if namedargs.IncludeInlinedInterfaces

                        portBlocks{ end  + 1 } = getfullname( bepBlk );%#ok<AGROW>
                    end
                else


                    interfaceName = autosar.utils.StripPrefix( busObjName );
                    if ~any( strcmp( interfaceName, dictInteraceNames ) )
                        portBlocks{ end  + 1 } = getfullname( bepBlk );%#ok<AGROW>
                    end
                end
            end
        end
    end
end



