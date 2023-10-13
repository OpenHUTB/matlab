classdef ( Sealed )DLCodegenCompatibilityLogger < coder.internal.DLCodegenErrorHandler

    properties ( SetAccess = private, GetAccess = public )

        LayerValidationLog table

        NetworkValidationLog table

        GenericValidationLog table
    end


    properties ( Dependent, SetAccess = private, GetAccess = public )

        FormattedLayerValidationLog

        FormattedNetworkValidationLog

        FormattedGenericValidationLog
    end


    methods

        function handleLayerError( logger, layer, msg )

            arguments
                logger( 1, 1 )
                layer( 1, : ){ mustBeA( layer, 'nnet.cnn.layer.Layer' ) }
                msg( 1, 1 )message{ mustBeNonempty }
            end

            structEntry.LayerName = string( layer.Name );
            structEntry.LayerType = string( class( layer ) );
            structEntry.Diagnostics = msg;

            logger.LayerValidationLog = [ logger.LayerValidationLog;struct2table( structEntry ) ];

        end


        function handleNetworkError( logger, msg )

            arguments
                logger( 1, 1 )
                msg( 1, 1 )message{ mustBeNonempty }
            end

            structEntry.Diagnostics = msg;

            logger.NetworkValidationLog = [ logger.NetworkValidationLog;struct2table( structEntry ) ];

        end


        function handleGenericError( logger, identifier, msgStr )
            arguments
                logger( 1, 1 )
                identifier{ mustBeText }
                msgStr{ mustBeText }
            end

            structEntry.Diagnostics = string( msgStr );
            structEntry.IssueId = string( identifier );

            logger.GenericValidationLog = [ logger.GenericValidationLog;struct2table( structEntry ) ];

        end


        function tf = isempty( logger )
            tf = isempty( logger.LayerValidationLog ) ...
                && isempty( logger.NetworkValidationLog ) ...
                && isempty( logger.GenericValidationLog );
        end


        function tbl = get.FormattedLayerValidationLog( obj )

            tbl = obj.LayerValidationLog;
            if ~isempty( tbl )
                messageArray = tbl.Diagnostics;
                idcategorical = categorical( { messageArray.Identifier } );

                tbl.Diagnostics = string( arrayfun( @( msg )[ getString( msg ), ' ', coder.internal.moreinfo( msg.Identifier ) ], tbl.Diagnostics, 'UniformOutput', false ) );
                tbl.IssueId = idcategorical';
                tbl = sortrows( tbl, "LayerType" );
                tbl = tbl( :, [ 1, 2, 4, 3 ] );
                tbl = iRemoveAdditionalDiagnosticsForUnsupportedLayerTypes( tbl );
            end
        end


        function tbl = get.FormattedNetworkValidationLog( obj )
            tbl = obj.NetworkValidationLog;
            if ~isempty( tbl )
                messageArray = tbl.Diagnostics;
                idcategorical = categorical( { messageArray.Identifier } );
                tbl.IssueId = idcategorical';

                tbl.Diagnostics = string( arrayfun( @( msg )[ getString( msg ), ' ', coder.internal.moreinfo( msg.Identifier ) ], tbl.Diagnostics, 'UniformOutput', false ) );
                tbl = tbl( :, [ 2, 1 ] );
            end
        end


        function tbl = get.FormattedGenericValidationLog( obj )
            tbl = obj.GenericValidationLog;

            if ~isempty( tbl )
                for i = 1:numel( tbl.Diagnostics )
                    tbl.Diagnostics( i ) = tbl.Diagnostics( i ) + " " + coder.internal.moreinfo( tbl.IssueId( i ) );
                end

                idcategorical = categorical( cellstr( tbl.IssueId ) );
                tbl.IssueId = idcategorical;


                tbl = tbl( :, [ 2, 1 ] );

            end

        end

    end

end


function tbl = iRemoveAdditionalDiagnosticsForUnsupportedLayerTypes( tbl )

unsupportedLayerMsgId = "dlcoder_spkg:cnncodegen:unsupported_layer";
unsupportedLayerTypeEntryIndices = tbl.IssueId == unsupportedLayerMsgId;
unsupportedLayerTypeEntriesTbl = tbl( unsupportedLayerTypeEntryIndices, : );
if ~isempty( unsupportedLayerTypeEntriesTbl )
    layerNamesWithUnsupportedTypeBool = ismember( tbl.LayerName, unsupportedLayerTypeEntriesTbl.LayerName );
    rowsThatCorrespondToUnsupportedLayerTypeIssue = layerNamesWithUnsupportedTypeBool & unsupportedLayerTypeEntryIndices;

    rowsToKeep = rowsThatCorrespondToUnsupportedLayerTypeIssue | ~layerNamesWithUnsupportedTypeBool;
    tbl = tbl( rowsToKeep, : );
end
end



