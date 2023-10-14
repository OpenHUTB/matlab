classdef ReportGeneration < designcostestimation.internal.services.Service

    properties ( SetAccess = private )
        ReportName char
        ReportType char = 'pdf';
        ReportLocation char = '';
        EstimationData
        ReportOrchestrator designcostestimation.internal.reportutil.ReportOrchestrator
        ReportFullFile char = '';
    end

    methods

        function obj = ReportGeneration( estimationData, reportName, reportType, reportLocation )
            obj.EstimationData = estimationData;
            obj.ReportName = reportName;
            obj.ReportType = reportType;
            obj.ReportLocation = reportLocation;
            obj.ReportOrchestrator = designcostestimation.internal.reportutil.ReportOrchestrator;
        end


        function runService( obj, launchReport )
            arguments
                obj
                launchReport( 1, 1 )logical = false;
            end

            obj.ReportOrchestrator.createReport( obj.ReportName, obj.ReportLocation, obj.ReportType );
            obj.ReportFullFile = obj.ReportOrchestrator.ReportName;

            hasProgramSizeEstimate = obj.hasProgramSizeEstimate(  );
            hasDataSegmentEstimate = obj.hasDataSegmentEstimate(  );
            if ( hasProgramSizeEstimate )
                Design = keys( obj.EstimationData.ProgramSizeEstimate );
            else
                Design = keys( obj.EstimationData.DataSegmentEstimate );
            end


            for i = 1:length( Design )

                obj.ReportOrchestrator.ProgramSizeEstimate = [  ];
                obj.ReportOrchestrator.DataSegmentEstimate = [  ];

                DesignName = Design{ i };


                service = designcostestimation.internal.services.LifetimeManagement( DesignName );

                obj.ReportOrchestrator.CurrentDesign = DesignName;

                if ( hasProgramSizeEstimate )
                    obj.ReportOrchestrator.ProgramSizeEstimate = obj.EstimationData.ProgramSizeEstimate( DesignName );
                end

                if ( hasDataSegmentEstimate )
                    obj.ReportOrchestrator.DataSegmentEstimate = obj.EstimationData.DataSegmentEstimate( DesignName );
                end

                obj.ReportOrchestrator.addChapter(  );

                service.restoreDesigns(  );
            end
            if launchReport
                obj.ReportOrchestrator.openReport(  );
            else

                obj.ReportOrchestrator.closeReport(  );
            end
        end
    end

    methods ( Hidden )

        function has = hasProgramSizeEstimate( obj )
            has = ~isempty( obj.EstimationData.ProgramSizeEstimate );
        end


        function has = hasDataSegmentEstimate( obj )
            has = ~isempty( obj.EstimationData.DataSegmentEstimate );
        end

    end
end


