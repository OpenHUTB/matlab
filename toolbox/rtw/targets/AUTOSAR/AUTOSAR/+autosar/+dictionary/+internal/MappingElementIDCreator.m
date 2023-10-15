classdef MappingElementIDCreator

    methods ( Static )

        function elementID = getPortElementID( modelName, portName, elementName, namedargs )

            arguments
                modelName
                portName
                elementName
                namedargs.EncodeToJson = true;
            end

            import autosar.dictionary.internal.DictionaryLinkUtils
            elementID = '';

            if ~DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary( modelName )
                return ;
            end

            if isempty( portName ) || isempty( elementName )

                return ;
            end

            m3iComp = autosar.api.Utils.m3iMappedComponent( modelName );
            m3iPort = autosar.mm.Model.findM3IPortByName( m3iComp, portName );
            if isempty( m3iPort ) || ~m3iPort.Interface.isvalid
                return
            end

            m3iElements = autosar.mm.Model.findM3IPortContaineeElements( m3iPort );
            elementId = [  ];
            if ~isempty( m3iElements )
                if isa( m3iElements, 'Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement' )
                    m3iElement = m3iElements;
                    elementId = M3I.SerializeId( m3iElement );
                else
                    for i = 1:m3iElements.size
                        m3iElement = m3iElements.at( i );
                        if strcmp( elementName, m3iElement.Name )
                            elementId = M3I.SerializeId( m3iElement );
                            break ;
                        end
                    end
                end
            end

            sharedDictUUID = autosar.dictionary.Utils.getDictionaryUUID( m3iElement.rootModel );
            elementID = struct(  ...
                'ArchitectureDictionaryUUID', sharedDictUUID,  ...
                'ElementID', elementId );
            if namedargs.EncodeToJson
                elementID = jsonencode( elementID );
            end
        end
    end
end

