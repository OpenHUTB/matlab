classdef DescriptionHelper < handle

    properties ( Constant, Access = private )
        DefaultLanguage = 'FOR-ALL';
    end

    methods ( Static )
        function m3iDesc = createOrUpdateM3IDescription( m3iModel, m3iDesc, slDesc )
            if ( ~isempty( slDesc ) || ~isempty( m3iDesc ) )
                if isempty( m3iDesc )

                    m3iDesc = Simulink.metamodel.arplatform.documentation.MultiLanguageOverviewParagraph( m3iModel );
                    m3iDescLine = Simulink.metamodel.arplatform.documentation.LOverviewParagraph( m3iModel );
                    m3iDescLine.body = slDesc;
                    m3iDescLine.language = autosar.mm.util.DescriptionHelper.DefaultLanguage;
                    m3iDesc.L2.append( m3iDescLine );
                else
                    if ( m3iDesc.L2.isEmpty(  ) )


                        m3iDescLine = Simulink.metamodel.arplatform.documentation.LOverviewParagraph( m3iModel );
                        m3iDescLine.language = autosar.mm.util.DescriptionHelper.DefaultLanguage;
                        m3iDescLine.body = slDesc;
                        m3iDesc.L2.append( m3iDescLine );
                    elseif ( m3iDesc.L2.size(  ) == 1 )

                        m3iDesc.L2.at( 1 ).body = slDesc;
                    else

                        return ;
                    end
                end
            end
        end

        function createOrUpdateM3IDescriptionForM3iType( m3iType, slDesc )

            assert( ischar( slDesc ) || isStringScalar( slDesc ), 'description must be a string' );

            [ descAvailable, descString ] = autosar.mm.util.DescriptionHelper.getSLDescFromM3IType( m3iType );
            if ( descAvailable || ~isempty( slDesc ) )
                if ~descAvailable

                    descExternalToolInfo = sprintf( [  ...
                        '<?xml version="1.0"?>\n' ...
                        , '<ROOT>\n' ...
                        , '<DESC>\n' ...
                        , '<L-2 L="%s">%s</L-2>\n' ...
                        , '</DESC>\n' ...
                        , '</ROOT>\n' ],  ...
                        autosar.mm.util.DescriptionHelper.DefaultLanguage, slDesc );

                    autosar.mm.Model.setExternalToolInfo( m3iType, 'ARXML_IDENTIFIABLE_INFO', descExternalToolInfo );
                else

                    if ~isempty( slDesc )
                        existingDesc = m3iType.getExternalToolInfo( 'ARXML_IDENTIFIABLE_INFO' ).externalId;
                        descExternalToolInfo = regexprep( existingDesc, [ '>', descString, '<' ], [ '>', slDesc, '<' ], 'once' );

                        autosar.mm.Model.setExternalToolInfo( m3iType, 'ARXML_IDENTIFIABLE_INFO', descExternalToolInfo );
                    end
                end
            end
        end



        function slDesc = getSLDescFromM3IDesc( m3iDesc )
            slDesc = '';
            if ( ~isempty( m3iDesc ) && ( m3iDesc.L2.size(  ) == 1 ) )
                slDesc = m3iDesc.L2.at( 1 ).body;
            end
        end

        function [ descAvailable, slDesc ] = getSLDescFromM3IType( m3iType )

            descText = m3iType.getExternalToolInfo( 'ARXML_IDENTIFIABLE_INFO' ).externalId;
            slDesc = '';
            descAvailable = false;
            if ~isempty( descText )
                openL2 = strfind( descText, '<L-2' );
                closeL2 = strfind( descText, '</L-2>' );
                if ( length( openL2 ) == 1 ) && ( length( closeL2 ) == 1 )
                    descAvailable = true;
                    descText = descText( openL2:closeL2 - 1 );
                    slDesc = descText( strfind( descText, '>' ) + 1:end  );
                end
            end
        end

        function [ slDesc, descSupported ] = getSLDescForEmbeddedObj( modelName, embeddedObj, namedargs )
            arguments
                modelName
                embeddedObj
                namedargs.ObjName = ''
            end
            slDesc = '';
            descSupported = false;
            typeIdentifier = embeddedObj.Identifier;


            if isa( embeddedObj, 'coder.types.Enum' ) ||  ...
                    isa( embeddedObj, 'coder.descriptor.types.Enum' )

                mprops = Simulink.getMetaClassIfValidEnumDataType( typeIdentifier );
                if ~isempty( mprops )
                    slDesc = Simulink.data.getEnumTypeInfo( typeIdentifier, 'Description' );
                    descSupported = true;
                    return ;
                end
            end

            [ dtExists, slObj ] = autosar.utils.Workspace.objectExistsInModelScope( modelName, typeIdentifier );
            if dtExists
                slDesc = slObj.Description;
                descSupported = true;
            end

            if isempty( namedargs.ObjName )
                return ;
            end




            [ dtExists, slObj ] = autosar.utils.Workspace.objectExistsInModelScope( modelName, namedargs.ObjName );
            if dtExists
                slDesc = slObj.Description;
                descSupported = true;
            end
        end

        function isEquivalent = isDescriptionEquivalent( m3iType, slDesc )
            isEquivalent = true;
            if ~isempty( slDesc )
                [ existingDescAvailable, existingDesc ] =  ...
                    autosar.mm.util.DescriptionHelper.getSLDescFromM3IType( m3iType );
                if ( existingDescAvailable )
                    isEquivalent = strcmp( slDesc, existingDesc );
                end
            end
        end
    end
end


