classdef SBioPercentilePlot < SimBiology.internal.plotting.sbioplot.SBioCategoricalPlot





    properties ( Constant )
        MIN_INDEX = 1;
        MAX_INDEX = 2;
        LOWER_INDEX = 1;
        UPPER_INDEX = 2;
        MAX_NUM_TIMEPOINT_BINS = 50;
    end




    properties ( Access = protected )
        dataSourceToDataOptionsDictionary = dictionary;
    end

    methods ( Access = public )
        function flag = supportsResponseDisplayType( obj )
            flag = true;
        end

        function flag = supportsGroupCategory( obj )
            flag = false;
        end

        function flag = supportsCategoryStyle( obj, style )
            switch style
                case { SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR,  ...
                        SimBiology.internal.plotting.categorization.CategoryDefinition.GRID,  ...
                        SimBiology.internal.plotting.categorization.CategoryDefinition.HORIZONTAL,  ...
                        SimBiology.internal.plotting.categorization.CategoryDefinition.VERTICAL }
                    flag = true;
                otherwise
                    flag = false;
            end
        end

        function primaryPlotArguments = getPrimaryPlotArguments( obj )
            primaryPlotArguments = obj.getPlotArguments(  );
        end

        function flag = hasMultiplePrimaryPlotArguments( obj )
            flag = obj.hasMultipleDataSources(  );
        end

        function flag = hasOneToOneGroupMatchingOnly( obj )
            flag = false;
        end


        function percentiles = getPercentiles( obj )
            percentiles = obj.getProps(  ).PercentilesOptions.Percentiles;
        end

        function flag = showMedian( obj )
            flag = obj.getProps(  ).PercentilesOptions.Median;
        end

        function flag = usePercentileLines( obj )
            flag = obj.getProps(  ).PercentilesOptions.Lines;
        end

        function flag = usePercentileShading( obj )
            flag = obj.getProps(  ).PercentilesOptions.Shading;
        end


        function flag = showMean( obj )
            flag = obj.getProps(  ).MeanOptions.Mean;
        end

        function flag = showStandardDeviation( obj )
            flag = obj.getProps(  ).MeanOptions.StandardDeviation;
        end

        function flag = showMinMax( obj )
            flag = obj.getProps(  ).MeanOptions.MinMax;
        end

        function flag = useMeanLines( obj )
            flag = obj.getProps(  ).MeanOptions.Lines;
        end

        function flag = useMeanMarkers( obj )
            flag = obj.getProps(  ).MeanOptions.Markers;
        end


        function dataOptions = getDataOptionsForCompoundBin( obj, compoundBin )
            dataOptions = obj.getDataOptionsForDataSource( compoundBin.getResponseBinValue(  ).dataSource );
        end

        function dataOptions = getDataOptionsForDataSource( obj, dataSource )
            dataOptions = obj.dataSourceToDataOptionsDictionary( dataSource.key );
        end

        function idx = getDataOptionsIndexForDataSource( obj, allDataOptions, dataSource )

            idx = isEqualByKey( [ allDataOptions.DataSource ], dataSource );
            assert( sum( idx ) == 1 );
        end

        function flag = isInterpolation( ~, dataOptions )
            flag = strcmp( dataOptions.TimecourseHandling,  ...
                SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.TIMECOURSE_HANDLING_INTERPOLATION );
        end

        function timepoints = getTimepoints( ~, dataOptions )
            timepoints = dataOptions.InterpolationSettings.Timepoints;
        end

        function interpolationMethod = getInterpolationMethod( ~, dataOptions )
            interpolationMethod = dataOptions.InterpolationSettings.InterpolationMethod;
        end

        function binningMethod = getBinningMethod( ~, dataOptions )
            binningMethod = dataOptions.BinningSettings.BinningMethod;
        end

        function numBins = getNumTimepointBins( ~, dataOptions )
            numBins = dataOptions.BinningSettings.NumTimepointBins;
        end

        function binEdges = getTimepointBinEdges( ~, dataOptions )
            binEdges = dataOptions.BinningSettings.TimepointBinEdges;
        end

        function showBinEdges = getShowBinEdges( ~, dataOptions )
            showBinEdges = dataOptions.BinningSettings.ShowBinEdges;
        end

        function updateBinningSettings( obj, dataSource, numTimepointBins, timepointBinEdges )
            allDataOptions = obj.getProps(  ).DataOptions;
            idx = obj.getDataOptionsIndexForDataSource( allDataOptions, dataSource );

            dataOptions = allDataOptions( idx );

            if isempty( dataOptions.BinningSettings.NumTimepointBins )
                dataOptions.BinningSettings.NumTimepointBins = numTimepointBins;
            else




                dataOptions.BinningSettings.NumTimepointBins = max( dataOptions.BinningSettings.NumTimepointBins, numTimepointBins );
            end





            if ~ischar( dataOptions.BinningSettings.TimepointBinEdges )







                if obj.usesVariableCategory(  ) && ~isempty( dataOptions.BinningSettings.TimepointBinEdges )
                    timepointBinEdges( 1 ) = min( timepointBinEdges( 1 ), dataOptions.BinningSettings.TimepointBinEdges( 1 ) );
                    timepointBinEdges( end  ) = max( timepointBinEdges( end  ), dataOptions.BinningSettings.TimepointBinEdges( end  ) );
                end

                dataOptions.BinningSettings.TimepointBinEdges = timepointBinEdges;
            end

            allDataOptions( idx ) = dataOptions;
            obj.setDefinitionProperty( 'DataOptions', allDataOptions );
        end

        function updateDataOptions( obj )



            plotArguments = obj.getPlotArguments(  );
            allDataOptions = obj.getProps(  ).DataOptions;



            plotArgumentsKeys = { plotArguments.getDataSources(  ).key };
            existingDataOptionsKeys = { allDataOptions.getDataSources(  ).key };


            newIdx = ~ismember( plotArgumentsKeys, existingDataOptionsKeys );
            newDataOptions = SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions( plotArguments( newIdx ) );



            keepIdx = ismember( existingDataOptionsKeys, plotArgumentsKeys );



            dataOptions = vertcat( allDataOptions( keepIdx ), newDataOptions );



            responseCategory = obj.getCategoryForCategoryVariable( SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE );
            allResponseBins = [ responseCategory.binSettings.value ];

            dataSourceToResponseBinsDict = allResponseBins.mapBinsToDataSources( plotArgumentsKeys );

            for d = 1:numel( dataOptions )
                responseBins = dataSourceToResponseBinsDict( dataOptions( d ).DataSource.key );
                responseBins = responseBins{ 1 };
                if dataOptions( d ).RawDataPercentage == 0 &&  ...
                        any( matches( { responseBins.displayType }, SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.RAWDATA ) )
                    dataOptions( d ).RawDataPercentage = 100;
                end
            end



            obj.dataSourceToDataOptionsDictionary = dictionary( string( { dataOptions.getDataSources(  ).key } )', dataOptions );


            obj.setDefinitionProperty( 'DataOptions', dataOptions );
        end

        function flag = isShowingRawData( obj )

            flag = any( str2double( { obj.getProps(  ).DataOptions.RawDataPercentage } ) );
        end
    end




    methods ( Access = protected )
        function processAdditionalArguments( obj, definitionProps )

            processAdditionalArguments@SimBiology.internal.plotting.sbioplot.SBioCategoricalPlot( obj, definitionProps );


            obj.updateDataOptions(  );
        end

        function plotBin( obj, compoundBin )
            ax = obj.getAxesForSubplot( compoundBin.style.row, compoundBin.style.column );

            displayType = compoundBin.getResponseBinValue(  ).displayType;
            switch displayType
                case SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.PERCENTILE
                    obj.plotPercentile( ax, compoundBin );
                case SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.MEAN
                    obj.plotMean( ax, compoundBin );
            end


            obj.plotRawData( ax, compoundBin, displayType );
        end
    end

    methods ( Abstract, Access = protected )

        [ resampledDataX, resampledDataY ] = resample( obj, timeVector, compoundBin, isSimulation, interpolationMethod )





        cleanedDataSeries = cleanDataSeries( obj, dataSeries )





        [ T, X, Y ] = getRawDataVectors( obj, cleanedDataSeries )


        [ medianX, medianY ] = getMedianForResampledData( obj, resampledData )
        [ percentileVectorsX, percentileVectorsY ] = getPercentileVectorsForResampledData( obj, resampledData, percentiles )

        [ medianX, medianY ] = getMedianForBinnedData( obj, binnedData )
        [ percentileVectorsX, percentileVectorsY ] = getPercentileVectorsForBinnedData( obj, resampledData, percentiles )


        [ meanX, meanY ] = getMeanForResampledData( obj, resampledData )
        [ stdDevX, stdDevY ] = getStdDevForResampledData( obj, resampledData )
        [ minMaxX, minMaxY ] = getMinMaxForResampledData( obj, resampledData )

        [ meanX, meanY ] = getMeanForBinnedData( obj, binnedData )
        [ stdDevX, stdDevY ] = getStdDevForBinnedData( obj, binnedData )
        [ minMaxX, minMaxY ] = getMinMaxForBinnedData( obj, binnedData )
    end




    methods ( Access = protected )
        function plotPercentile( obj, ax, compoundBin )

            [ percentileData, binEdgeValues ] = obj.getPercentileData( compoundBin );

            color = compoundBin.getColor(  );
            visibility = compoundBin.getVisibility(  );
            bins = compoundBin.getAllBins(  );

            obj.plotPercentileShading( ax, percentileData, color, visibility, bins );
            obj.plotPercentileLines( ax, percentileData, color, visibility, bins );
            obj.plotMedianLine( ax, percentileData, color, visibility, bins );
            obj.showBinEdges( ax, compoundBin, binEdgeValues, color, visibility, bins );
        end

        function plotMedianLine( obj, ax, percentileData, color, visibility, bins )
            if obj.showMedian
                medianFormats = obj.getMedianLineFormats( percentileData );
                lineHandles = plot( ax.handle, obj.getXForMedian( percentileData ), obj.getYForMedian( percentileData ), 'Color', color, 'Visible', visibility, medianFormats{ : } );


                displayInfo = obj.createDisplayInfoStruct( 'Description', 'Median' );
                set( lineHandles, 'UserData', struct( 'CategoryBinValues', { bins },  ...
                    'DisplayInfo', { displayInfo } ) );
            end
        end

        function plotPercentileLines( obj, ax, percentileData, color, visibility, bins )
            if obj.usePercentileLines
                percentileFormats = obj.getPercentileLineFormats( percentileData );

                lineHandles = plot( ax.handle, obj.getXForPercentiles( percentileData ), obj.getYForPercentiles( percentileData ), 'Color', color, 'Visible', visibility, percentileFormats{ : } );


                for i = 1:numel( lineHandles )
                    displayInfo = obj.createDisplayInfoStruct( 'Percentile', num2str( percentileData.percentiles( i ) ) );
                    set( lineHandles( i ), 'UserData', struct( 'CategoryBinValues', { bins },  ...
                        'DisplayInfo', { displayInfo } ) );
                end
            end
        end

        function plotPercentileShading( obj, ax, percentileData, color, visibility, bins )
            if obj.usePercentileShading
                plotPercentileShadingHalf( obj, true, ax, percentileData, color, visibility, bins );
                plotPercentileShadingHalf( obj, false, ax, percentileData, color, visibility, bins );
            end
        end

        function plotPercentileShadingHalf( obj, isLowerHalf, ax, percentileData, color, visibility, bins )

            percentiles = percentileData.percentiles;
            percentileVectors = percentileData.percentilesY;

            if isLowerHalf
                idx = percentiles < 50;
                percentiles = percentiles( idx );
                percentileVectors = percentileVectors( :, idx );
            else
                idx = percentiles > 50;
                percentiles = fliplr( percentiles( idx ) );
                percentileVectors = fliplr( percentileVectors( :, idx ) );
            end
            n = size( percentiles, 2 );

            if n > 0

                alphaValues = obj.getPercentileShadingAlphas( n );


                x = vertcat( percentileData.timeVector, flipud( percentileData.timeVector ) );
                flippedMedian = flipud( percentileData.medianY );


                for i = 1:n
                    y = vertcat( percentileVectors( :, i ), flippedMedian );


                    idx = ~isnan( y );
                    p = patch( ax.handle, x( idx ), y( idx ), color, 'EdgeColor', color, 'FaceAlpha', alphaValues( i ), 'LineStyle', 'none', 'Visible', visibility );


                    displayInfo = obj.createDisplayInfoStruct( 'Percentile', num2str( percentiles( i ) ) );
                    set( p, 'UserData', struct( 'CategoryBinValues', { bins },  ...
                        'DisplayInfo', { displayInfo } ) );
                end
            end
        end

        function [ percentileData, binEdgeValues ] = getPercentileData( obj, compoundBin )
            percentileData = struct( 'timeVector', { [  ] },  ...
                'medianX', { [  ] },  ...
                'medianY', { [  ] },  ...
                'percentilesX', { [  ] },  ...
                'percentilesY', { [  ] },  ...
                'percentiles', obj.getPercentileValues(  ) );

            dataOptions = obj.getDataOptionsForCompoundBin( compoundBin );

            if obj.isInterpolation( dataOptions )

                aggregationFcn = @getResampledData;
                medianFcn = @getMedianForResampledData;
                percentileFcn = @getPercentileVectorsForResampledData;
            else

                aggregationFcn = @getBinnedData;
                medianFcn = @getMedianForBinnedData;
                percentileFcn = @getPercentileVectorsForBinnedData;
            end

            [ percentileData.timeVector, aggregatedData ] = aggregationFcn( obj, compoundBin, dataOptions );

            [ percentileData.medianX, percentileData.medianY ] = medianFcn( obj, aggregatedData );

            if ~isempty( percentileData.percentiles )
                [ percentileData.percentilesX, percentileData.percentilesY ] = percentileFcn( obj, aggregatedData, percentileData.percentiles );
            end

            binEdgeValues = obj.getBinEdgeValuesFromAggregatedData( aggregatedData );
        end

        function percentiles = getPercentileValues( obj )

            percentiles = eval( horzcat( '[', obj.getPercentiles(  ), ']' ) );

            if obj.showMedian
                idx = ( percentiles == 50 );
                percentiles = percentiles( ~idx );
            end
        end

        function vector = getXForMedian( obj, percentileData )
            if isempty( percentileData.medianX )
                vector = percentileData.timeVector;
            else
                vector = percentileData.medianX;
            end
        end

        function vector = getYForMedian( obj, percentileData )
            vector = percentileData.medianY;
        end

        function vector = getXForPercentiles( obj, percentileData )
            if isempty( percentileData.percentilesX )
                vector = percentileData.timeVector;
            else
                vector = percentileData.percentilesX;
            end
        end

        function vector = getYForPercentiles( obj, percentileData )
            vector = percentileData.percentilesY;
        end

        function formats = getMedianLineFormats( obj, percentileData )
            arguments
                obj
                percentileData struct = [  ]
            end
            formats = obj.getPercentileLineFormatsHelper( percentileData, 2.5 );
        end

        function formats = getPercentileLineFormats( obj, percentileData )
            arguments
                obj
                percentileData struct = [  ]
            end
            formats = obj.getPercentileLineFormatsHelper( percentileData, 1.0 );
        end

        function formats = getPercentileLineFormatsHelper( ~, percentileData, lineWidth )
            arguments
                ~
                percentileData struct
                lineWidth double
            end
            if isempty( percentileData ) || numel( percentileData.timeVector ) > 1
                marker = 'none';
            else
                marker = '_';
            end
            formats = { 'linestyle', '-',  ...
                'linewidth', lineWidth ...
                , 'marker', marker };
        end
    end




    methods ( Access = protected )
        function plotMean( obj, ax, compoundBin )
            if obj.useMeanLines || obj.useMeanMarkers

                [ meanData, binEdgeValues ] = obj.getMeanData( compoundBin );

                color = compoundBin.getColor(  );
                visibility = compoundBin.getVisibility(  );
                bins = compoundBin.getAllBins(  );

                obj.plotMeanLine( ax, meanData, color, visibility, bins );
                obj.plotStandardDeviation( ax, meanData, color, visibility, bins );
                obj.plotMinMax( ax, meanData, color, visibility, bins );
                obj.showBinEdges( ax, compoundBin, binEdgeValues, color, visibility, bins );
            end
        end

        function plotMeanLine( obj, ax, meanData, color, visibility, bins )


            if obj.showMean && ~( obj.showStandardDeviation && obj.useMeanMarkers )
                formats = obj.getMeanFormats(  );

                lineHandle = plot( ax.handle, obj.getXForMean( meanData ), obj.getYForMean( meanData ), 'color', color, 'visible', visibility, formats{ : } );

                displayInfo = obj.createDisplayInfoStruct( 'Description', 'Mean' );
                if obj.useMeanMarkers && obj.showStandardDeviation
                    displayInfo = obj.createDisplayInfoStruct( 'Description', 'Mean +/- 1 Standard Deviation' );
                    set( lineHandle, 'UserData', struct( 'CategoryBinValues', { bins },  ...
                        'DisplayInfo', { displayInfo } ) );
                else
                    set( lineHandle, 'UserData', struct( 'CategoryBinValues', { bins },  ...
                        'DisplayInfo', { displayInfo } ) );
                end
            end
        end

        function plotStandardDeviation( obj, ax, meanData, color, visibility, bins )
            if obj.showStandardDeviation
                formats = obj.getStdDevFormats(  );

                if obj.useMeanMarkers
                    errorBarHandle = errorbar( ax.handle, obj.getXForMean( meanData ), obj.getYForMean( meanData ),  ...
                        meanData.stdDevY, meanData.stdDevY, meanData.stdDevX, meanData.stdDevX,  ...
                        'color', color, 'visible', visibility, formats{ : } );

                    set( errorBarHandle, 'UserData', struct( 'CategoryBinValues', bins ) );
                    displayInfo = obj.createDisplayInfoStruct( 'Description', 'Mean +/- 1 Standard Deviation' );
                    set( errorBarHandle, 'UserData', struct( 'CategoryBinValues', { bins },  ...
                        'DisplayInfo', { displayInfo } ) );
                else
                    lineHandles = plot( ax.handle, obj.getXForStdDev( meanData ), obj.getYForStdDev( meanData ), 'color', color, 'visible', visibility, formats{ : } );

                    displayInfo = obj.createDisplayInfoStruct( 'Description', 'Mean - 1 Standard Deviation' );
                    set( lineHandles( 1 ), 'UserData', struct( 'CategoryBinValues', { bins },  ...
                        'DisplayInfo', { displayInfo } ) );
                    displayInfo = obj.createDisplayInfoStruct( 'Description', 'Mean + 1 Standard Deviation' );
                    set( lineHandles( 2 ), 'UserData', struct( 'CategoryBinValues', { bins },  ...
                        'DisplayInfo', { displayInfo } ) );
                end
            end
        end

        function plotMinMax( obj, ax, meanData, color, visibility, bins )
            if obj.showMinMax
                formats = obj.getMinMaxFormats(  );

                lineHandles = plot( ax.handle, obj.getXForMinMax( meanData ), obj.getYForMinMax( meanData ), 'color', color, 'visible', visibility, formats{ : } );

                set( lineHandles, 'UserData', struct( 'CategoryBinValues', bins ) );

                displayInfo = obj.createDisplayInfoStruct( 'Description', 'Minimum' );
                set( lineHandles( 1 ), 'UserData', struct( 'CategoryBinValues', { bins },  ...
                    'DisplayInfo', { displayInfo } ) );
                displayInfo = obj.createDisplayInfoStruct( 'Description', 'Maximum' );
                set( lineHandles( 2 ), 'UserData', struct( 'CategoryBinValues', { bins },  ...
                    'DisplayInfo', { displayInfo } ) );
            end
        end

        function [ meanData, binEdgeValues ] = getMeanData( obj, compoundBin )
            meanData = struct( 'timeVector', { [  ] },  ...
                'meanX', { [  ] },  ...
                'meanY', { [  ] },  ...
                'stdDevX', { [  ] },  ...
                'stdDevY', { [  ] },  ...
                'minMaxX', { [  ] },  ...
                'minMaxY', { [  ] } );

            dataOptions = obj.getDataOptionsForCompoundBin( compoundBin );

            if obj.isInterpolation( dataOptions )

                aggregationFcn = @getResampledData;
                meanFcn = @getMeanForResampledData;
                stdDevFcn = @getStdDevForResampledData;
                minMaxFcn = @getMinMaxForResampledData;
            else

                aggregationFcn = @getBinnedData;
                meanFcn = @getMeanForBinnedData;
                stdDevFcn = @getStdDevForBinnedData;
                minMaxFcn = @getMinMaxForBinnedData;
            end

            [ meanData.timeVector, aggregatedData ] = aggregationFcn( obj, compoundBin, dataOptions );

            if ( obj.showMean || obj.showStandardDeviation )
                [ meanData.meanX, meanData.meanY ] = meanFcn( obj, aggregatedData );
            end

            if ( obj.showStandardDeviation )
                [ meanData.stdDevX, meanData.stdDevY ] = stdDevFcn( obj, aggregatedData );
            end

            if ( obj.showMinMax )
                [ meanData.minMaxX, meanData.minMaxY ] = minMaxFcn( obj, aggregatedData );
            end

            binEdgeValues = obj.getBinEdgeValuesFromAggregatedData( aggregatedData );
        end

        function vector = getXForMean( obj, meanData )
            if isempty( meanData.meanX )
                vector = meanData.timeVector;
            else
                vector = meanData.meanX;
            end
        end

        function vector = getYForMean( obj, meanData )
            vector = meanData.meanY;
        end

        function vectors = getXForStdDev( obj, meanData )
            if isempty( meanData.meanX )
                vectors = meanData.timeVector;
            else
                vectors( :, obj.UPPER_INDEX ) = meanData.meanX + meanData.stdDevX;
                vectors( :, obj.LOWER_INDEX ) = meanData.meanX - meanData.stdDevX;
            end
        end

        function vectors = getYForStdDev( obj, meanData )
            vectors( :, obj.UPPER_INDEX ) = meanData.meanY + meanData.stdDevY;
            vectors( :, obj.LOWER_INDEX ) = meanData.meanY - meanData.stdDevY;
        end

        function vectors = getXForMinMax( obj, meanData )
            if isempty( meanData.minMaxX )
                vectors = meanData.timeVector;
            else
                vectors = meanData.minMaxX;
            end
        end

        function vectors = getYForMinMax( obj, meanData )
            vectors = meanData.minMaxY;
        end

        function meanFormats = getMeanFormats( obj )



            defaultLineWidth = get( groot, 'DefaultLineLineWidth' );
            if obj.useMeanMarkers && obj.useMeanLines
                meanFormats = { 'linestyle', ':',  ...
                    'linewidth', defaultLineWidth + 1,  ...
                    'marker', 'o' };

            elseif obj.useMeanMarkers
                meanFormats = { 'linestyle', 'none',  ...
                    'linewidth', defaultLineWidth + 1,  ...
                    'marker', 'o' };

            else
                meanFormats = { 'linestyle', '-',  ...
                    'linewidth', defaultLineWidth + 2,  ...
                    'marker', 'none' };
            end
        end

        function stdDevFormats = getStdDevFormats( obj )



            defaultLineWidth = get( groot, 'DefaultLineLineWidth' );
            if obj.useMeanMarkers && obj.showMean
                marker = 'o';
            else
                marker = 'none';
            end

            if obj.useMeanMarkers && obj.useMeanLines
                stdDevFormats = { 'linestyle', ':',  ...
                    'linewidth', defaultLineWidth + 1,  ...
                    'marker', marker };

            elseif obj.useMeanMarkers

                stdDevFormats = { 'linestyle', 'none',  ...
                    'linewidth', defaultLineWidth + 1,  ...
                    'marker', marker };

            else
                stdDevFormats = { 'linestyle', '-.',  ...
                    'linewidth', defaultLineWidth + 1.5,  ...
                    'marker', marker };
            end
        end

        function minMaxFormats = getMinMaxFormats( obj )


            defaultLineWidth = get( groot, 'DefaultLineLineWidth' );
            if obj.useMeanMarkers && obj.useMeanLines
                minMaxFormats = { 'linestyle', ':',  ...
                    'linewidth', defaultLineWidth + 1,  ...
                    'marker', '*' };

            elseif obj.useMeanMarkers
                minMaxFormats = { 'linestyle', 'none',  ...
                    'linewidth', defaultLineWidth + 1,  ...
                    'marker', '*' };

            else
                minMaxFormats = { 'linestyle', ':',  ...
                    'linewidth', defaultLineWidth + 1.5,  ...
                    'marker', 'none' };
            end
        end
    end




    methods ( Access = protected )

        function plotRawData( obj, ax, compoundBin, displayStyle )
            dataOptions = obj.getDataOptionsForCompoundBin( compoundBin );
            rawDataPercentage = dataOptions.RawDataPercentage;

            if rawDataPercentage == 0
                return ;
            end

            isSimulation = compoundBin.getResponseBinValue(  ).isSimulation;

            color = [ compoundBin.getColor(  ) ];


            if strcmp( displayStyle, SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.MEAN )
                color = [ color, 0.5 ];
            end
            visibility = compoundBin.getVisibility(  );
            bins = compoundBin.getAllBins(  );
            rawDataFormats = obj.getRawDataLineFormats( isSimulation );

            dataSeries = compoundBin.dataSeries;
            if rawDataPercentage < 100
                numRawData = numel( dataSeries );
                delta = 100 / rawDataPercentage;
                idx = unique( round( 1:delta:numRawData ) );
                dataSeries = dataSeries( idx );
            end

            for i = 1:numel( dataSeries )

                lineHandles = plot( ax.handle, dataSeries( i ).independentVariableData, dataSeries( i ).dependentVariableData,  ...
                    'color', color, 'visible', visibility, rawDataFormats{ : } );

                displayInfo = obj.createDisplayInfoStruct( 'Group', dataSeries( i ).groupBinValue.getDisplayNameHelper( obj ) );
                set( lineHandles, 'UserData', struct( 'CategoryBinValues', { bins },  ...
                    'DisplayInfo', { displayInfo } ) );
            end
        end

        function formats = getRawDataLineFormats( obj, isSimulation )
            defaultLineWidth = get( groot, 'DefaultLineLineWidth' );

            if isSimulation
                formats = { 'linestyle', ':',  ...
                    'linewidth', defaultLineWidth,  ...
                    'marker', 'none' };
            else
                formats = { 'linestyle', 'none',  ...
                    'linewidth', defaultLineWidth,  ...
                    'marker', '.' };
            end
        end
    end






    methods ( Access = protected )
        function showBinEdges( obj, ax, compoundBin, binEdgeValues, color, visibility, bins )
            dataOptions = obj.getDataOptionsForCompoundBin( compoundBin );


            if isempty( binEdgeValues ) || ~obj.getShowBinEdges( dataOptions )
                return ;
            end


            keepIdx = isfinite( binEdgeValues );
            binEdgeValues = binEdgeValues( keepIdx );
            if ~isempty( binEdgeValues )
                h = xline( ax.handle, binEdgeValues, 'Color', color, 'LineStyle', '-.', 'LineWidth', 1.0, 'Visible', visibility );
                set( h, 'Tag', obj.BIN_EDGE_TAG, 'UserData', struct( 'CategoryBinValues', { bins } ) );
            end
        end
    end




    methods ( Access = protected )
        function flag = isObjectSupportedForDataTip( obj, h )
            flag = isa( h, 'matlab.graphics.chart.primitive.Line' ) ||  ...
                isa( h, 'matlab.graphics.chart.primitive.ErrorBar' );
        end

        function isAdded = setDataTemplateForHandle( obj, h )
            isAdded = setDataTemplateForHandle@SimBiology.internal.plotting.sbioplot.SBioCategoricalPlot( obj, h );

            if isAdded && isfield( h.UserData, 'DisplayInfo' )
                displayInfo = h.UserData.DisplayInfo;
                for i = numel( displayInfo ): - 1:1
                    if strcmp( displayInfo( i ).fieldname, 'Percentile' )
                        dataTipRows( i ) = dataTipTextRow( [ displayInfo( i ).value, 'th percentile' ], @( x )[  ] );
                    elseif strcmp( displayInfo( i ).fieldname, 'Description' )
                        dataTipRows( i ) = dataTipTextRow( displayInfo( i ).value, @( x )[  ] );
                    else
                        dataTipRows( i ) = dataTipTextRow( [ displayInfo( i ).fieldname, ': ', displayInfo( i ).value ], @( x )[  ] );
                    end
                end

                h.DataTipTemplate.DataTipRows = horzcat( h.DataTipTemplate.DataTipRows, dataTipRows );
            end
        end
    end

    methods ( Static, Access = protected )
        function displayInfo = createDisplayInfoStruct( fieldname, value )
            displayInfo = struct( 'fieldname', { fieldname }, 'value', { value } );
        end
    end




    methods ( Access = protected )
        function [ timeVector, resampledData ] = getResampledData( obj, compoundBin, dataOptions )








            isSimulation = compoundBin.getResponseBinValue(  ).isSimulation;


            timepoints = obj.getTimepoints( dataOptions );
            interpolationMethod = obj.getInterpolationMethod( dataOptions );

            timeVector = getTimeVector( obj, timepoints, compoundBin, isSimulation );
            [ resampledData.resampledDataX, resampledData.resampledDataY ] = resample( obj, timeVector, compoundBin, isSimulation, interpolationMethod );
        end

        function timeVector = getTimeVector( obj, timepoints, compoundBin, isSimulation )
            if strcmp( timepoints, SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.AUTO_TIMEPOINTS )
                numTimepoints = 1001;
                timeVector = obj.computeTimeVector( compoundBin, isSimulation, numTimepoints );
            else
                timeVector = obj.getTimepointValues( timepoints );
            end
        end

        function timeVector = getTimepointValues( obj, timepoints )

            timeVector = eval( horzcat( '[', timepoints, ']' ) );

            if size( timeVector, 2 ) > 1
                timeVector = timeVector';
            end
        end

        function timeVector = computeTimeVector( obj, compoundBin, isSimulation, numTimepoints )
            if isSimulation
                timeVector = SimBiology.internal.plotting.data.SBioDataInterfaceForSimData.computeUniformTimeVector( compoundBin.dataSeries, numTimepoints, ~obj.isTimePlot(  ) );
            else
                timeVector = SimBiology.internal.plotting.data.SBioDataInterfaceForExperimentalData.computeUniformTimeVector( compoundBin.dataSeries, numTimepoints, ~obj.isTimePlot(  ) );
            end
        end
    end




    methods ( Access = protected )
        function [ meanTimeVector, binnedData ] = getBinnedData( obj, compoundBin, dataOptions )







            binningMethod = obj.getBinningMethod( dataOptions );

            [ T, X, Y, cleanedDataSeries ] = obj.getRawDataForBinning( compoundBin.dataSeries );







            switch binningMethod
                case SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.BINNING_AUTO
                    [ meanTimeVector, binClassifications, numBins, binEdgeValues ] = obj.getTimepointBinsAuto( T, cleanedDataSeries, dataOptions );
                case SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.BINNING_NUM_BINS
                    [ meanTimeVector, binClassifications, numBins, binEdgeValues ] = obj.getTimepointBinsUsingNumBins( T, cleanedDataSeries, dataOptions );
                otherwise
                    [ meanTimeVector, binClassifications, numBins, binEdgeValues ] = obj.getTimepointBinsUsingBinEdges( T, cleanedDataSeries, dataOptions );
            end

            binnedData = struct( 'allDataX', X, 'allDataY', Y, 'dataClassifications', binClassifications, 'binEdgeValues', binEdgeValues );



            obj.updateBinningSettings( dataOptions.DataSource, numBins, binEdgeValues );
        end

        function [ T, X, Y, cleanedDataSeries ] = getRawDataForBinning( obj, dataSeries )
            cleanedDataSeries = obj.cleanDataSeries( dataSeries );
            [ T, X, Y ] = obj.getRawDataVectors( cleanedDataSeries );
        end

        function [ meanTimeVector, binClassifications, numBins, binEdges ] = getTimepointBinsAuto( obj, T, cleanedDataSeries, ~ )
            minMaxNumBins = obj.computeMinMaxNumberOfBins( cleanedDataSeries );
            [ meanTimeVector, binClassifications, numBins, binEdges ] = SimBiology.internal.binData( T, minMaxNumBins = minMaxNumBins );
        end

        function [ meanTimeVector, binClassifications, numBins, binEdges ] = getTimepointBinsUsingNumBins( obj, T, ~, dataOptions )
            numBins = obj.getNumTimepointBins( dataOptions );
            [ meanTimeVector, binClassifications, numBins, binEdges ] = SimBiology.internal.binData( T, numBins = numBins );
        end

        function [ meanTimeVector, binClassifications, numBins, binEdges ] = getTimepointBinsUsingBinEdges( obj, T, ~, dataOptions )



            binEdges = obj.getTimepointBinEdgeValues( dataOptions );
            [ meanTimeVector, binClassifications, numBins ] = SimBiology.internal.binData( T, binEdges = binEdges );



            nanIdx = isnan( meanTimeVector );

            oldBinIdx = 1:numBins;
            newBinIdx = 1:sum( ~nanIdx );

            oldToNewBinIdx = nan( numel( oldBinIdx ), 1 );
            oldToNewBinIdx( ~nanIdx ) = newBinIdx;

            meanTimeVector = meanTimeVector( ~nanIdx );
            binClassifications = oldToNewBinIdx( binClassifications );
        end

        function minMaxNumBins = computeMinMaxNumberOfBins( obj, cleanedDataSeries )
            numTimepointsPerGroup = arrayfun( @( ds )numel( ds.independentVariableData ), cleanedDataSeries );


            numGroupsMin = min( max( 1, floor( 0.75 * min( numTimepointsPerGroup ) ) ), obj.MAX_NUM_TIMEPOINT_BINS );
            numGroupsMax = min( ceil( 1.25 * max( numTimepointsPerGroup ) ), obj.MAX_NUM_TIMEPOINT_BINS );
            minMaxNumBins = [ numGroupsMin, numGroupsMax ];
        end

        function binEdges = getTimepointBinEdgeValues( obj, dataOptions )

            binEdges = obj.getTimepointBinEdges( dataOptions );



            if ischar( binEdges )
                binEdges = eval( horzcat( '[', binEdges, ']' ) );

                if size( binEdges, 1 ) > 1
                    binEdges = binEdges';
                end
            end
        end

        function binEdgeValues = getBinEdgeValuesFromAggregatedData( obj, aggregatedData )
            if isfield( aggregatedData, 'binEdgeValues' )
                binEdgeValues = aggregatedData.binEdgeValues;
            else
                binEdgeValues = [  ];
            end
        end
    end




    methods ( Access = protected )
        function plotElementHandles = getAllPlotElementHandles( obj )
            plotElementHandles = findobj( obj.figure.handle, '-depth', 2,  ...
                'type', 'line', '-or', 'type', 'patch', '-or', 'type', 'errorbar' );
        end
    end




    methods ( Access = protected )
        function [ legendArray, dummyAxes ] = getLegendArrayForExport( obj, destinationFigure )

            [ legendArray, dummyAxes ] = getLegendArrayForExport@SimBiology.internal.plotting.sbioplot.SBioCategoricalPlot( obj, destinationFigure );

            responseCategory = obj.getCategoryForCategoryVariable( SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE );

            [ percentileLegend, percentileDummyAxes ] = obj.getPercentileLegendForExport( destinationFigure, responseCategory );
            [ meanLegend, meanDummyAxes ] = obj.getMeanLegendForExport( destinationFigure, responseCategory );
            [ rawDataLegend, rawDataDummyAxes ] = obj.getRawDataLegendForExport( destinationFigure, responseCategory );

            if ~isempty( percentileLegend )
                legendArray( end  + 1 ) = percentileLegend;
                dummyAxes( end  + 1 ) = percentileDummyAxes;
            end
            if ~isempty( meanLegend )
                legendArray( end  + 1 ) = meanLegend;
                dummyAxes( end  + 1 ) = meanDummyAxes;
            end
            if ~isempty( rawDataLegend )
                legendArray( end  + 1 ) = rawDataLegend;
                dummyAxes( end  + 1 ) = rawDataDummyAxes;
            end
        end

        function [ percentileLegend, dummyAxes ] = getPercentileLegendForExport( obj, destinationFigure, responseCategory )
            if any( arrayfun( @( b )strcmp( b.value.displayType, SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.PERCENTILE ),  ...
                    responseCategory.binSettings ) )

                dummyAxes = axes( destinationFigure, 'Visible', 'off', 'Position', [ .1, .1, .01, .01 ], 'tag', 'dummyAxesForLegend' );%#ok<CPROP,CPROPLC>
                dummyAxes.Toolbar.Visible = 'off';

                percentiles = obj.getPercentileValues(  );
                if obj.usePercentileLines || isempty( percentiles )
                    dummyHandles = matlab.graphics.chart.primitive.Line.empty;


                    if obj.showMedian
                        props = obj.getMedianLineFormats(  );
                        dummyHandles( end  + 1 ) = line( dummyAxes, 1, 1, 'Visible', 'on', 'tag', 'dummyLineForLegend', 'Color', [ 0, 0, 0 ], props{ : }, 'DisplayName', 'Median' );
                    end


                    props = obj.getPercentileLineFormats(  );
                    for i = 1:numel( percentiles )
                        dummyHandles( end  + 1 ) = line( dummyAxes, 1, 1, 'Visible', 'on', 'tag', 'dummyLineForLegend', 'Color', [ 0, 0, 0 ], props{ : }, 'DisplayName', [ num2str( percentiles( i ) ), 'th percentile' ] );%#ok<AGROW>
                    end
                else
                    idx = percentiles < 50;
                    color = [ 0, 0, 0 ];

                    dummyHandles = matlab.graphics.primitive.Patch.empty;


                    n = sum( idx );
                    if n > 0
                        bounds = percentiles( idx );
                        alphas = obj.getPercentileShadingAlphas( n );
                        for i = 1:( n - 1 )
                            dummyHandles( end  + 1 ) = patch( dummyAxes, 1, 1, color, 'FaceAlpha', alphas( i ), 'LineStyle', 'none', 'Visible', 'on', 'tag', 'dummyLineForLegend', 'DisplayName', [ num2str( bounds( i ) ), ' to ', num2str( bounds( i + 1 ) ), 'th percentile' ] );%#ok<AGROW>
                        end
                        dummyHandles( end  + 1 ) = patch( dummyAxes, 1, 1, color, 'FaceAlpha', alphas( n ), 'LineStyle', 'none', 'Visible', 'on', 'tag', 'dummyLineForLegend', 'DisplayName', [ num2str( bounds( n ) ), 'th percentile to median' ] );%#ok<AGROW>
                    end

                    n = sum( ~idx );
                    if n > 0
                        bounds = percentiles( ~idx );
                        alphas = flip( obj.getPercentileShadingAlphas( n ) );
                        dummyHandles( end  + 1 ) = patch( dummyAxes, 1, 1, color, 'FaceAlpha', alphas( 1 ), 'LineStyle', 'none', 'Visible', 'on', 'tag', 'dummyLineForLegend', 'DisplayName', [ 'median to ', num2str( bounds( 1 ) ), 'th percentile' ] );%#ok<AGROW>
                        for i = 2:n
                            dummyHandles( end  + 1 ) = patch( dummyAxes, 1, 1, color, 'FaceAlpha', alphas( i ), 'LineStyle', 'none', 'Visible', 'on', 'tag', 'dummyLineForLegend', 'DisplayName', [ num2str( bounds( i - 1 ) ), ' to ', num2str( bounds( i ) ), 'th percentile' ] );%#ok<AGROW>
                        end
                    end
                end


                percentileLegend = legend( dummyHandles, 'tag', 'percentilePlotLegend' );
                percentileLegend.Title.String = 'Percentiles';
                percentileLegend.Interpreter = 'none';
            else
                percentileLegend = [  ];
                dummyAxes = matlab.graphics.axis.Axes.empty;
            end
        end

        function [ meanLegend, dummyAxes ] = getMeanLegendForExport( obj, destinationFigure, responseCategory )
            if any( arrayfun( @( b )strcmp( b.value.displayType, SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.MEAN ),  ...
                    responseCategory.binSettings ) )

                dummyAxes = axes( destinationFigure, 'Visible', 'off', 'Position', [ .1, .1, .01, .01 ], 'tag', 'dummyAxesForLegend' );%#ok<CPROP,CPROPLC>
                dummyAxes.Toolbar.Visible = 'off';


                props = obj.getMeanFormats(  );
                dummyLines = line( dummyAxes, 1, 1, 'Visible', 'on', 'tag', 'dummyLineForLegend', 'Color', [ 0, 0, 0 ], props{ : }, 'DisplayName', 'Mean' );


                if obj.showStandardDeviation && obj.useMeanLines && ~obj.useMeanMarkers
                    props = obj.getStdDevFormats(  );
                    dummyLines( end  + 1 ) = line( dummyAxes, 1, 1, 'Visible', 'on', 'tag', 'dummyLineForLegend', 'Color', [ 0, 0, 0 ], props{ : }, 'DisplayName', 'Mean +/- 1 Standard Deviation' );
                end


                if obj.showMinMax
                    props = obj.getMinMaxFormats(  );
                    dummyLines( end  + 1 ) = line( dummyAxes, 1, 1, 'Visible', 'on', 'tag', 'dummyLineForLegend', 'Color', [ 0, 0, 0 ], props{ : }, 'DisplayName', 'Min/Max' );
                end


                meanLegend = legend( dummyLines, 'tag', 'percentilePlotLegend' );
                meanLegend.Title.String = 'Mean';
                meanLegend.Interpreter = 'none';
            else
                meanLegend = [  ];
                dummyAxes = matlab.graphics.axis.Axes.empty;
            end
        end

        function [ rawDataLegend, dummyAxes ] = getRawDataLegendForExport( obj, destinationFigure, responseCategory )
            if obj.isShowingRawData(  )
                dummyAxes = axes( destinationFigure, 'Visible', 'off', 'Position', [ .1, .1, .01, .01 ], 'tag', 'dummyAxesForLegend' );%#ok<CPROP,CPROPLC>
                dummyAxes.Toolbar.Visible = 'off';


                isSimulationArray = arrayfun( @( b )b.value.isSimulation, responseCategory.binSettings );
                hasSimulation = any( isSimulationArray );
                hasExperimentalData = ~all( isSimulationArray );

                dummyLines = matlab.graphics.chart.primitive.Line.empty;
                if ( hasSimulation )
                    props = obj.getRawDataLineFormats( true );
                    dummyLines( end  + 1 ) = line( dummyAxes, 1, 1, 'Visible', 'on', 'tag', 'dummyLineForLegend', 'Color', [ 0, 0, 0 ], props{ : }, 'DisplayName', 'Simulation Timecourses' );
                end
                if ( hasExperimentalData )
                    props = obj.getRawDataLineFormats( false );
                    dummyLines( end  + 1 ) = line( dummyAxes, 1, 1, 'Visible', 'on', 'tag', 'dummyLineForLegend', 'Color', [ 0, 0, 0 ], props{ : }, 'DisplayName', 'Experimental Timecourses' );
                end


                rawDataLegend = legend( dummyLines, 'tag', 'percentilePlotLegend' );
                rawDataLegend.Title.String = 'Raw Timecourse Data';
                rawDataLegend.Interpreter = 'none';
            else
                rawDataLegend = [  ];
                dummyAxes = matlab.graphics.axis.Axes.empty;
            end
        end
    end




    methods ( Static, Access = public )
        function errorMessage = verifyPercentiles( value )
            errorMessage = message.empty;
            try

                percentiles = eval( horzcat( '[', value, ']' ) );


                if ~isnumeric( percentiles ) || ~all( percentiles >= 0 & percentiles <= 100 )
                    errorMessage = message( 'SimBiology:Plotting:PERCENTILES_NOT_NUMERIC' );
                elseif ( size( percentiles, 1 ) > 1 && size( percentiles, 2 ) > 1 )
                    errorMessage = message( 'SimBiology:Plotting:PERCENTILES_NOT_1D' );
                else

                    idx = ( percentiles == 50 );
                    percentiles = percentiles( ~idx );

                    for i = 2:numel( percentiles )
                        if percentiles( i ) <= percentiles( i - 1 )
                            errorMessage = message( 'SimBiology:Plotting:PERCENTILES_NOT_ORDERED' );
                            break ;
                        end
                    end
                end
                if ~isempty( errorMessage )
                    errorMessage = message( 'SimBiology:Plotting:INVALID_PERCENTILE_EXPRESSION', errorMessage.getString(  ) );
                end
            catch ex
                errorMessage = message( 'SimBiology:Plotting:INVALID_PERCENTILE_EXPRESSION', ex.message );
            end
        end

        function errorMessage = verifyTimepoints( value )
            errorMessage = message.empty;
            if ~strcmp( value, SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.AUTO_TIMEPOINTS )
                try

                    timeVector = eval( horzcat( '[', value, ']' ) );


                    if ~isnumeric( timeVector ) || ~all( timeVector >= 0 ) || any( isinf( timeVector ) )
                        errorMessage = message( 'SimBiology:Plotting:TIMEPOINTS_NOT_NUMERIC' );
                    elseif ( size( timeVector, 1 ) > 1 && size( timeVector, 2 ) > 1 ) || isempty( timeVector )
                        errorMessage = message( 'SimBiology:Plotting:TIMEPOINTS_NOT_1D' );

                    else
                        for i = 2:numel( timeVector )
                            if timeVector( i ) <= timeVector( i - 1 )
                                errorMessage = message( 'SimBiology:Plotting:TIMEPOINTS_NOT_ORDERED' );
                                break ;
                            end
                        end
                    end
                    if ~isempty( errorMessage )
                        errorMessage = message( 'SimBiology:Plotting:INVALID_TIMEPOINTS_EXPRESSION', errorMessage.getString(  ) );
                    end
                catch ex
                    errorMessage = message( 'SimBiology:Plotting:INVALID_TIMEPOINTS_EXPRESSION', ex.message );
                end
            end
        end

        function alphaValues = getPercentileShadingAlphas( n )
            alphaMax = 0.25;
            alphaMin = max( alphaMax - n * .1, 0.1 );
            if n == 1
                delta = 0;
            else
                delta = ( alphaMax - alphaMin ) / ( n - 1 );
            end
            for i = n: - 1:1
                alphaValues( i ) = alphaMin + delta * ( i - 1 );
            end
        end
    end
end

