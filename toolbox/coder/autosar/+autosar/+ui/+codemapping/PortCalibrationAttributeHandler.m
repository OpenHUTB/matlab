classdef PortCalibrationAttributeHandler < handle

    properties ( Constant, Access = public )

        SupportedPortCalibrationAttributes =  ...
            { { DAStudio.message( 'RTW:autosar:ArLongNameProperty' ), 'string' } };
    end

    methods ( Static, Access = public )
        function validCalibrationAttributes = getValidCalibrationAttributesForPort( mdlName, portName, isInport )


            import autosar.ui.codemapping.PortCalibrationAttributeHandler;
            validCalibrationAttributes = {  };


            if slfeature( 'AUTOSARLongNameAuthoring' )
                [ ~, arDataElementName ] =  ...
                    PortCalibrationAttributeHandler.getAUTOSARPortMappingInfo( mdlName, portName, isInport );
                isPortMappedToDataElement = ~isempty( arDataElementName );
                if isPortMappedToDataElement
                    validCalibrationAttributes =  ...
                        autosar.ui.codemapping.PortCalibrationAttributeHandler.getSupportedPortCalibrationAttributes;
                end
            end
        end

        function value = getCalibrationAttributeValueForPropertyInspector( modelH, mappingObj, propName )
            import autosar.ui.codemapping.PortCalibrationAttributeHandler;


            modelName = get_param( modelH, 'Name' );
            m3iComp = autosar.api.Utils.m3iMappedComponent( modelName );
            arPortName = mappingObj.MappedTo.Port;
            m3iPort = autosar.ui.comspec.ComSpecUtils.findM3IPortByName( m3iComp, arPortName );
            if isempty( m3iPort )


                assert( autosar.composition.Utils.isCompositePortBlock( mappingObj.Block ), 'Only valid for bus port block' );
                value = '';
                return ;
            end

            arDataElementName = mappingObj.MappedTo.Element;
            m3iDataElement = PortCalibrationAttributeHandler.findM3iDataElementFromPort( m3iPort, arDataElementName );

            switch propName
                case 'LongName'
                    if isempty( m3iDataElement.longName )
                        value = '';
                    else
                        value = PortCalibrationAttributeHandler.getLongNameForGUIFromSequenceOfLLongName(  ...
                            m3iDataElement.longName.L4 );
                    end
                otherwise
                    assert( false, 'Unexpected property type for port calibration attribute.' );
            end
        end

        function setCalibrationAttributeValueForPropertyInspector( modelH, mappingObj, propName, propValue )


            import autosar.ui.codemapping.PortCalibrationAttributeHandler;

            modelName = get_param( modelH, 'Name' );
            m3iModel = autosar.api.Utils.m3iModel( modelName );
            m3iComp = autosar.api.Utils.m3iMappedComponent( modelName );
            arPortName = mappingObj.MappedTo.Port;
            m3iPort = autosar.ui.comspec.ComSpecUtils.findM3IPortByName( m3iComp, arPortName );
            if isempty( m3iPort )


                assert( autosar.composition.Utils.isCompositePortBlock( mappingObj.Block ), 'Only valid for bus port block' )


                m3iPort = autosar.simulink.bep.Mapping.syncBusPort( mappingObj.Block );
                assert( ~isempty( m3iPort ), 'm3iPort should not be empty' );
            end
            arDataElementName = mappingObj.MappedTo.Element;
            m3iDataElement = PortCalibrationAttributeHandler.findM3iDataElementFromPort( m3iPort, arDataElementName );

            switch propName
                case 'LongName'
                    transaction = M3I.Transaction( m3iModel );
                    autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3ILongName( m3iModel, m3iDataElement, propValue );
                    transaction.commit(  );
                otherwise
                    assert( false, 'Unexpected property type for port calibration attribute.' );
            end
        end

        function supportedPortCalibrationAttributes = getSupportedPortCalibrationAttributes(  )
            props = autosar.ui.codemapping.PortCalibrationAttributeHandler.SupportedPortCalibrationAttributes;
            supportedPortCalibrationAttributes = cell( 1, size( props, 2 ) );
            for i = 1:length( supportedPortCalibrationAttributes )
                supportedPortCalibrationAttributes{ i } = props{ i }{ 1 };
            end
        end

        function longNameBody = getLongNameValueFromMultiLanguageLongName( m3iMultiLanguageLongName )

            import autosar.ui.codemapping.PortCalibrationAttributeHandler;

            if isempty( m3iMultiLanguageLongName )
                longNameBody = '';
                return
            end
            assert( isa( m3iMultiLanguageLongName, autosar.ui.metamodel.PackageString.LongNameClass ),  ...
                'Unable to retrieve LongName from this m3iObject.' )

            longNameBody = PortCalibrationAttributeHandler.getLongNameForGUIFromSequenceOfLLongName(  ...
                m3iMultiLanguageLongName.L4 );
        end

        function parentM3iObj = getParentM3iObjFromLLongName( llongNameObj )

            arguments
                llongNameObj Simulink.metamodel.arplatform.documentation.LLongName;
            end

            m3iMultiLanguageLongNameObj = llongNameObj.owner;
            parentM3iObj = m3iMultiLanguageLongNameObj.owner;
        end
    end

    methods ( Static, Access = private )
        function [ arPortName, arDataElementName, arDataAccessMode ] = getAUTOSARPortMappingInfo( mdlName, portName, isInport )

            slMapObj = autosar.api.getSimulinkMapping( mdlName );
            if isInport
                [ arPortName, arDataElementName, arDataAccessMode ] =  ...
                    slMapObj.getInport( portName );
            else
                [ arPortName, arDataElementName, arDataAccessMode ] =  ...
                    slMapObj.getOutport( portName );
            end
        end

        function m3iDataElement = findM3iDataElementFromPort( m3iPort, arDataElementName )
            m3iDataElement = autosar.mm.Model.findElementInSequenceByName(  ...
                m3iPort.Interface.DataElements, arDataElementName );
        end

        function longNameBody = getLongNameForGUIFromSequenceOfLLongName( seqOfLLongName )

            arguments
                seqOfLLongName Simulink.metamodel.arplatform.documentation.SequenceOfLLongName
            end

            longNameBody = seqOfLLongName.at( 1 ).body;
            for i = seqOfLLongName.size
                if strcmp( seqOfLLongName.at( i ).language, 'FOR-ALL' )
                    longNameBody = seqOfLLongName.at( i ).body;
                end
            end
        end
    end
end



