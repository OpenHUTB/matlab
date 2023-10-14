classdef ( ConstructOnLoad = true, UseClassDefaultsOnLoad = true, Sealed )BubbleChart ...
        < matlab.graphics.chart.primitive.internal.AbstractScatter

    properties ( SetObservable, Dependent )
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor = 'flat';
        MarkerFaceAlpha matlab.internal.datatype.matlab.graphics.datatype.MarkerAlpha = 0.6;
    end
    properties ( Hidden )
        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
        MarkerFaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto';
    end
    properties ( AffectsObject, AffectsLegend, AbortSet, Hidden )
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor = 'flat';
        MarkerFaceAlpha_I matlab.internal.datatype.matlab.graphics.datatype.MarkerAlpha = 0.6;
    end
    properties ( SetAccess = private, Transient, Hidden )
        Marker_I = 'o';
    end
    properties ( Access = private, Transient )
        Padding( 1, 1 )double = 0
    end

    methods ( Access = 'protected', Hidden = true )
        function doSetup( hObj )
            hObj.Type = 'bubble';
            addDependencyConsumed( hObj, { 'figurecolormap', 'colorspace', 'colororder_linestyleorder', 'hintconsumer' } );
            addlistener( hObj, { 'XJitter', 'YJitter', 'ZJitter',  ...
                'XJitterWidth', 'YJitterWidth', 'ZJitterWidth' },  ...
                'PostSet', @( ~, ~ )hObj.setJitterDirty(  ) );

            internalModeStorage = true;
            hObj.linkDataPropertyToChannel( 'XData', 'X', internalModeStorage );
            hObj.linkDataPropertyToChannel( 'YData', 'Y', internalModeStorage );
            hObj.linkDataPropertyToChannel( 'ZData', 'Z', internalModeStorage );
            hObj.linkDataPropertyToChannel( 'SizeData', 'Size', internalModeStorage );
            hObj.linkDataPropertyToChannel( 'CData', 'Color', internalModeStorage );
            hObj.linkDataPropertyToChannel( 'AlphaData', 'Alpha', internalModeStorage );


            hObj.CurrentIconColorInfo = matlab.graphics.chart.primitive.internal.abstractscatter.IconColorInfoCache;


            hObj.MarkerHandle.Style = 'circle';
            hObj.MarkerHandleNaN.Style = 'circle';
        end

        function setJitterDirty( hObj )
            hObj.JitterDirty_I = true;
        end

        [ order, x, y, z, s, a, c ] = getCleanData( hObj, x, y, z, s, a, c, stripnanc )
    end


    methods ( Static, Hidden )
        function validateData( dataMap )
            arguments
                dataMap( 1, 1 )matlab.graphics.data.DataMap
            end

            channels = string( fieldnames( dataMap.Map ) );
            keep = ismember( channels, [ "X", "Y", "Z", "Size", "Color", "Alpha" ] );
            channels = channels( keep );
            for c = channels'
                subscript = dataMap.Map.( c );
                data = dataMap.DataSource.getData( subscript );
                for d = 1:numel( data )
                    matlab.graphics.chart.primitive.BubbleChart.validateDataPropertyValue( c, data{ d } );
                end
            end
        end
    end

    methods
        function val = get.MarkerFaceColor( hObj )
            val = hObj.MarkerFaceColor_I;
        end
        function set.MarkerFaceColor( hObj, val )
            hObj.MarkerFaceColorMode = 'manual';
            hObj.MarkerFaceColor_I = val;
        end
        function set.MarkerFaceColorMode( hObj, val )
            hObj.MarkerFaceColorMode = val;
        end
        function val = get.MarkerFaceAlpha( hObj )
            val = hObj.MarkerFaceAlpha_I;
        end
        function set.MarkerFaceAlpha( hObj, val )
            hObj.MarkerFaceAlphaMode = 'manual';
            hObj.MarkerFaceAlpha_I = val;
        end
        function set.MarkerFaceAlphaMode( hObj, val )
            hObj.MarkerFaceAlphaMode = val;
        end
        function val = get.Padding( hObj )

            hc = ancestor( hObj, 'matlab.graphics.axis.HintConsumer', 'node' );
            val = 0;
            if ~isempty( hc ) && numel( hc.BubbleSizeRange ) == 2

                val = hc.BubbleSizeRange( 2 ) / 2 + hObj.LineWidth / 2;


                ds = ancestor( hObj, 'matlab.graphics.axis.dataspace.DataSpace', 'node' );
                if val ~= hObj.Padding && ~isempty( ds )
                    MarkXYZLimitDependency( ds );
                end
            end
            hObj.Padding = val;
        end
    end


    methods ( Access = 'protected', Hidden = true )
        varargout = doGetDisplayAnchorPoint( hObj, index, ~ )
        varargout = doGetNearestPoint( hObj, position )
    end
    methods ( Access = 'public', Hidden = true )

        hintcell = getExtentsHints( hObj )
        hints = getHints( hObj )
        mcodeConstructor( this, code )
        varargout = mapSize( hObj, sz, us )
    end
    methods ( Static, Access = protected )
        function data = validateDataPropertyValue( channelName, data )
            if strcmp( channelName, 'Size' )
                try
                    hgcastvalue( 'matlab.graphics.datatype.NumericMatrix', data );
                catch
                    error( message( 'MATLAB:hg:shaped_arrays:NumericMatrixType' ) )
                end
            end
            data = validateDataPropertyValue@matlab.graphics.chart.primitive.internal.AbstractScatter( channelName, data );
        end
    end
end

