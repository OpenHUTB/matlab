classdef DashboardReportBase < handle

    properties ( SetAccess = private )
        Project
        DashboardLayout
        ReportLocale
        Report
    end

    methods
        function obj = DashboardReportBase( Location, Type, Project, Layout )
            obj.Report = dashboard.internal.report.DashboardReportInternal(  );
            obj.Report.Type = Type;
            if not( isempty( Location ) )
                obj.Report.OutputPath = Location;
            end
            obj.Project = Project;
            obj.DashboardLayout = Layout;
            obj.ReportLocale = matlab.internal.i18n.locale.default.Ctype;
        end

        function generateAndAdd( this, parentToAddTo, widgetsToAdd, scopeArtifact )
            for i = 1:numel( widgetsToAdd )
                widgetReporter = this.getWidgetReporter( widgetsToAdd( i ) );
                widgetReporter.addToReport( parentToAddTo, scopeArtifact );
            end
        end

        function wr = getWidgetReporter( this, widget )
            cfg = this.DashboardLayout.getConfiguration(  );
            if ~isfield( cfg.WidgetReportTypes, widget.Type )
                error( message( "dashboard:report:NoWidgetReportClass", widget.Type ).getString(  ) );
            end
            reporterConstructor = str2func( cfg.WidgetReportTypes.( widget.Type ) );
            wr = reporterConstructor( this, widget );
        end

        function metricCfg = getMetricConfig( ~, metricId )
            cfg = metric.config.Configuration.open(  );
            metricCfg = cfg.getAlgorithmConfiguration( string( metricId ) );
        end

        function metricMetaInfo = getMetricMetaInfo( this, metricId )
            mcfg = this.getMetricConfig( metricId );
            metricMetaInfo = mcfg.getMetaInformation( this.ReportLocale );
            if isempty( metricMetaInfo )
                metricMetaInfo = mcfg.getMetaInformation( 'en_US' );
            end
        end

        function results = getMetricResults( this, metricIds, scopeArtifact )
            eng = metric.Engine( this.Project.RootFolder );
            results = eng.getMetrics( metricIds, 'ArtifactScope', scopeArtifact.UUID );
        end

        function scopeArtifacts = getScopeArtifacts( this, scopeByAddresses )
            scopeArtifacts = [  ];
            as = alm.internal.ArtifactService.get( this.Project.RootFolder );
            if ( as.isUnanalyzedProject )
                error( message( "dashboard:report:UnanalyzedProject" ) );
            end
            g = as.getGraph;
            if this.DashboardLayout.Id == dashboard.internal.LayoutConstants.ModelUnitTestingDashboard
                query = alm.gdb.Query( "QUALITY_METRICS", "SELECT_AllUnits" );
            else
                query = alm.gdb.Query( "QUALITY_METRICS", "SELECT_AllUnitsAndComponents" );
            end
            queryResult = query.execute( g );
            artifacts = cellfun( @( x )x{ 1 }, queryResult.getSequences(  ) )';

            if isempty( artifacts )
                return ;
            end



            if ~isempty( scopeByAddresses )
                [ ~, idxA ] = intersect( string( { artifacts.Address } ), scopeByAddresses );
                artifacts = artifacts( idxA );
            end

            if isempty( artifacts )
                return ;
            end

            labels = { artifacts.Label };
            [ ~, order ] = sort( labels );
            scopeArtifacts = artifacts( order );
        end



        function str = metricValue2String( this, value, unit, metricId, precision )
            arguments
                this
                value( 1, : )
                unit{ mustBeTextScalar } = ""
                metricId{ mustBeTextScalar } = ""
                precision = 2
            end
            switch class( value )
                case 'uint64'
                    if strlength( metricId ) > 0
                        meta = this.getMetricMetaInfo( metricId );
                        if ~isempty( meta.ValueName.EnumNames )
                            assert( numel( meta.ValueName.EnumNames ) >= ( max( value ) + 1 ), 'EnumName index out of bounds' );
                            str = arrayfun( @( val )string( meta.ValueName.EnumNames{ val + 1 } ) + unit, value );
                            return ;
                        end
                    end
                    str = arrayfun( @( val )string( sprintf( '%d%s', val, unit ) ), value );
                    return
                case 'double'
                    if unit == "%"
                        unit = "%%";
                    end
                    fmtStr = sprintf( '%%.%df%s', int32( precision ), unit );
                    str = arrayfun( @( val )string( sprintf( fmtStr, val ) ), value );
                    return ;
                case { 'string', 'char' }
                    str = string( value ) + unit;
                    return
                otherwise
                    error( message( "dashboard:report:UnsupportedDataType", class( value ) ).getString(  ) );
            end
        end
    end

    methods ( Abstract )
        outPath = generate( this, artifactScope, launchReport, debug )
    end
end


