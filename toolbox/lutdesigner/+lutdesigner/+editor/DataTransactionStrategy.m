classdef ( Abstract )DataTransactionStrategy < handle

    methods
        function dataModel = createDataModelFor( this, dataProxy )
            arguments
                this( 1, 1 )lutdesigner.editor.DataTransactionStrategy
                dataProxy( 1, 1 )lutdesigner.data.proxy.DataProxy
            end

            dataModel = lutdesigner.editor.model.LookupTableModel;
            this.readFromDataSource( dataProxy, dataModel );
        end

        function features = getDisablePropertyEditFeaturesForDataSource( this, dataProxy )
            arguments
                this( 1, 1 )lutdesigner.editor.DataTransactionStrategy
                dataProxy( 1, 1 )lutdesigner.data.proxy.DataProxy
            end




            dataUsage = dataProxy.listDataUsage(  );
            m = containers.Map;
            for i = 1:numel( dataUsage )
                dataSource = dataUsage( i ).DataSource;
                key = sprintf( "%s/%s/%s", dataSource.SourceType, dataSource.Source, dataSource.Name );
                if m.isKey( key ) || dataSource.isPeerLocked(  )
                    features = { LUTWidget.DisableAxesEdit, LUTWidget.DisableTableEdit };
                    return ;
                end
                m( key ) = true;
            end

            features = this.getDisablePropertyEditFeaturesForDataSourceImpl( dataProxy );
        end

        function readFromDataSource( this, dataProxy, dataModel )
            arguments
                this( 1, 1 )lutdesigner.editor.DataTransactionStrategy
                dataProxy( 1, 1 )lutdesigner.data.proxy.DataProxy
                dataModel( 1, 1 )lutdesigner.editor.model.LookupTableModel
            end

            this.readFromDataSourceImpl( dataProxy, dataModel );

            features = this.getDisablePropertyEditFeaturesForDataSource( dataProxy );
            dataModel.updateDisablePropertyEditFeatures( features );
        end

        function writeToDataSource( this, dataProxy, dataModel )
            arguments
                this( 1, 1 )lutdesigner.editor.DataTransactionStrategy
                dataProxy( 1, 1 )lutdesigner.data.proxy.DataProxy
                dataModel( 1, 1 )lutdesigner.editor.model.LookupTableModel
            end

            this.writeToDataSourceImpl( dataProxy, dataModel );
        end
    end

    methods ( Abstract, Access = protected )
        features = getDisablePropertyEditFeaturesForDataSourceImpl( this, dataProxy );

        readFromDataSourceImpl( this, dataProxy, dataModel );

        writeToDataSourceImpl( this, dataProxy, dataModel );
    end

    methods ( Static )
        function strategy = create( dataProxy )
            if isa( dataProxy, 'lutdesigner.data.proxy.LookupTableProxy' )
                strategy = lutdesigner.editor.LookupTableTransactionStrategy;
            else
                assert( isa( dataProxy, 'lutdesigner.data.proxy.MatrixParameterProxy' ) )
                strategy = lutdesigner.editor.MatrixTransactionStrategy;
            end
        end
    end
end



