classdef Widget < metric.dashboard.widgets.WidgetBase

    properties ( Dependent )
        Title
        Height
        MetricIDs
        Labels
        Groups
        ItemLabels
        DataIndex
        DataOrder
        WidgetActions
        Unit
    end

    properties ( SetAccess = private )
        Tooltip
    end


    properties ( Constant, Hidden, Abstract )
        HeightLimit
        TooltipLocations
    end


    methods ( Access = { ?metric.dashboard.WidgetFactory, ?metric.dashboard.widgets.Widget } )
        function obj = Widget( element, ~ )
            obj = obj@metric.dashboard.widgets.WidgetBase( element );
            if obj.MF0Widget.Height == 0
                obj.MF0Widget.Height = obj.HeightLimit;
            end
        end
    end

    methods


        function title = get.Title( this )
            title = this.MF0Widget.WidgetTitle;
        end

        function set.Title( this, title )
            metric.dashboard.Verify.ScalarCharOrString( title );
            this.MF0Widget.WidgetTitle = title;
        end



        function unit = get.Unit( this )
            unit = this.MF0Widget.WidgetUnit;
        end

        function set.Unit( this, unit )
            metric.dashboard.Verify.ScalarCharOrString( unit );
            this.MF0Widget.WidgetUnit = unit;
        end


        function height = get.Height( this )
            height = this.MF0Widget.Height;
        end

        function set.Height( this, height )

            if ~isfinite( height ) || ( height < 0 )
                error( message( 'dashboard:uidatamodel:PositiveInteger' ) );
            end

            if height < this.HeightLimit
                error( message( 'dashboard:uidatamodel:InvalidHeight',  ...
                    height, this.Type, this.HeightLimit ) );
            end

            this.MF0Widget.Height = height;
        end



        function metricID = get.MetricIDs( this )
            metricID = {  };
            dbs = this.MF0Widget.DataBindings.toArray;
            for i = 1:numel( dbs )
                if strcmp( dbs( i ).Type, 'Primary' ) ...
                        && strcmp( dbs( i ).Source, 'ResultService' )
                    metricID{ end  + 1 } = dbs( i ).ID;%#ok<AGROW>
                end
            end

        end

        function set.MetricIDs( this, metricid )
            if ~iscell( metricid )
                metricid = { metricid };
            end

            cellfun( @metric.dashboard.Verify.ScalarCharOrString, metricid );



            for i = this.MF0Widget.DataBindings.Size: - 1:1
                db = this.MF0Widget.DataBindings.at( i );
                if strcmp( db.Type, 'Primary' ) ...
                        && strcmp( db.Source, 'ResultService' )
                    db.destroy(  );
                end
            end
            for i = 1:numel( metricid )
                this.MF0Widget.DataBindings.add( this.createMetricID( metricid{ i } ) );
            end
        end


        function set.Labels( this, labels )
            try
                labels = string( labels );
                this.MF0Widget.Labels.clear;
                for i = 1:numel( labels )
                    this.MF0Widget.Labels.add( labels( i ) );
                end
            catch ME
                error( message( 'dashboard:uidatamodel:WrongInputType',  ...
                    message( 'dashboard:uidatamodel:StringOrCell' ).getString(  ) ) );
            end
        end

        function labels = get.Labels( this )
            labels = this.MF0Widget.Labels.toArray;
            if isempty( labels )
                labels = {  };
            end
        end



        function set.ItemLabels( this, labels )
            try
                labels = string( labels );
                this.MF0Widget.ItemLabels.clear;
                for i = 1:numel( labels )
                    this.MF0Widget.ItemLabels.add( labels( i ) );
                end
            catch ME
                error( message( 'dashboard:uidatamodel:WrongInputType',  ...
                    message( 'dashboard:uidatamodel:StringOrCell' ).getString(  ) ) );
            end
        end

        function labels = get.ItemLabels( this )
            labels = this.MF0Widget.ItemLabels.toArray;
            if isempty( labels )
                labels = {  };
            end
        end


        function set.Groups( this, groups )
            this.MF0Widget.Groups.clear;
            for i = 1:numel( groups )
                this.MF0Widget.Groups.add( uint32( groups( i ) ) );
            end
        end

        function groups = get.Groups( this )
            groups = this.MF0Widget.Groups.toArray;
            if isempty( groups )
                groups = {  };
            end
        end



        function tt = get.Tooltip( this )
            tt = metric.dashboard.Tooltip(  ...
                mf.zero.getModel( this.MF0Widget ),  ...
                this.MF0Widget.Tooltips,  ...
                this.TooltipLocations );
        end


        function was = get.WidgetActions( this )
            was = metric.dashboard.WidgetAction.empty( 1, 0 );
            for i = 1:this.MF0Widget.DataBindings.Size
                tmp = this.MF0Widget.DataBindings.at( i );
                if strcmp( tmp.Type, 'Secondary' ) ...
                        && strcmp( tmp.Context, 'Component' )
                    was( end  + 1 ) = metric.dashboard.WidgetAction( tmp );%#ok<AGROW>
                end
            end
        end

        function wa = addWidgetAction( this, ID, Source )
            arguments
                this
                ID = ''
                Source = 'ResultService'
            end
            waMF0 = this.createAction(  );
            this.MF0Widget.DataBindings.add( waMF0 );
            wa = metric.dashboard.WidgetAction( waMF0 );
            metric.dashboard.Verify.ScalarCharOrString( Source );
            metric.dashboard.Verify.ScalarCharOrString( ID );
            wa.Source = Source;
            wa.ID = ID;
        end



        function di = get.DataIndex( this )
            di = this.MF0Widget.DataIndex;
        end

        function set.DataIndex( this, di )
            if ~isfinite( di ) || ( di <= 0 ) || ( floor( di ) ~= di )
                error( message( 'dashboard:uidatamodel:PositiveInteger' ) );
            end
            this.MF0Widget.DataIndex = di;
        end



        function do = get.DataOrder( this )
            do = this.MF0Widget.DataOrder.toArray(  );
        end

        function set.DataOrder( this, do )
            if any( ~isfinite( do ) ) || ( any( do <= 0 ) ) || ( any( floor( do ) ~= do ) )
                error( message( 'dashboard:uidatamodel:PositiveInteger' ) );
            end
            this.MF0Widget.DataOrder.clear;
            for i = 1:numel( do )
                this.MF0Widget.DataOrder.add( uint32( do( i ) ) );
            end
        end



        function verify( this )
            verify@metric.dashboard.widgets.WidgetBase( this );
            if isempty( this.MetricIDs )
                error( message( 'dashboard:uidatamodel:NoMetricID',  ...
                    this.Title ) );
            end
            if ~isempty( this.WidgetActions )
                for i = 1:numel( this.WidgetActions )
                    this.WidgetActions( i ).verify(  );
                end
                if numel( this.WidgetActions ) ~= numel( this.MetricIDs )
                    error( message( 'dashboard:uidatamodel:ActionMetricMissmatch' ) );
                end
            end
        end
    end

    methods ( Access = private )

        function metricid = createMetricID( this, id )
            metricid = dashboard.ui.DataBinding( mf.zero.getModel( this.MF0Widget ) );
            metricid.ID = id;
            metricid.Type = 'Primary';
            metricid.Source = 'ResultService';
            metricid.Context = 'Component';
        end

        function action = createAction( this )
            action = dashboard.ui.DataBinding( mf.zero.getModel( this.MF0Widget ) );
            action.ID = '';
            action.Type = 'Secondary';
            action.Source = '';
            action.Context = 'Component';
        end
    end

end


