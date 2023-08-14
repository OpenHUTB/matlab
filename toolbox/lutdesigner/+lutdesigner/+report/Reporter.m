classdef Reporter<lutdesigner.service.RemotableObject

    properties(SetAccess=immutable)
LookupTableFinder
    end

    methods
        function this=Reporter(lookupTableFinder)
            this.LookupTableFinder=lookupTableFinder;
        end

        function n=countLookupTablesForAccess(this,accessDesc)
            import lutdesigner.access.Access

            access=Access.fromDesc(accessDesc);
            lutAccesses=this.findLookupTableAccesses(access);
            n=numel(lutAccesses);
        end

        function report=generateReportForAccess(this,accessDesc)
            import lutdesigner.access.Access

            access=Access.fromDesc(accessDesc);

            this.validateOwnerModelCompileErrorFree(access);
            report=this.createReportForAccess(access);
        end
    end

    methods(Access=private)
        function validateOwnerModelCompileErrorFree(~,access)
            if isa(access,'lutdesigner.access.LookupTableControl')
                model=bdroot(access.OwnerPath);
            else
                model=bdroot(access.Path);
            end

            try
                set_param(model,'SimulationCommand','update');
            catch ME

                error(message('lutdesigner:messages:ModelCompilationError'));
            end
        end

        function lutAccesses=findLookupTableAccesses(this,access)
            import lutdesigner.access.Access
            import lutdesigner.access.internal.getLookupTableControlAccessDescs

            if isa(access,'lutdesigner.access.LookupTableControl')
                lutAccesses={access};
                return;
            end

            lutBlocks=this.LookupTableFinder.findLookupTableBlocks(access.Path,'FollowLinks','on');
            lutAccesses=cellfun(@(p)lutdesigner.access.LookupTableBlock(p),lutBlocks,'UniformOutput',false);

            lutControlSystems=this.LookupTableFinder.findLookupTableControlSystems(access.Path,'FollowLinks','on');
            for i=1:numel(lutControlSystems)
                curAccess=Access.fromSimulinkComponent(lutControlSystems{i});
                lutAccesses=[
lutAccesses
                arrayfun(@(x)Access.fromDesc(x),getLookupTableControlAccessDescs(curAccess),'UniformOutput',false)
                ];%#ok
            end
        end

        function report=createReportForAccess(this,access)
            import slreportgen.report.Report
            import mlreportgen.report.Section
            import mlreportgen.report.TableOfContents
            import mlreportgen.dom.Text
            import lutdesigner.access.Access

            reportFilePath=pwd+"/lookupTableReport";
            report=Report(reportFilePath,'html-file');
            oc=onCleanup(@()saveReportAndView(report));

            lutAccesses=this.findLookupTableAccesses(access);
            numLUTs=numel(lutAccesses);

            progressBar=DAStudio.WaitBar;
            progressBar.setLabelText(string(message('lutdesigner:messages:PrintReport')));
            progressBar.setMinimum(0);
            progressBar.setMaximum(numel(lutAccesses));
            progressBar.show();

            for i=1:numLUTs
                appendSectionForLookupTable(report,lutAccesses{i});

                progressBar.setValue(i);
                if progressBar.wasCanceled==1&&i<numLUTs
                    lutdesigner.report.setDisclaimer(rpt,string(message('lutdesigner:messages:ReportTextOnCancelButton')));
                    break;
                end
            end

            catalog=TableOfContents;
            catalog.Title=Text(string(message('lutdesigner:messages:ReportTableOfContents')));
            append(report,catalog);
        end
    end
end

function saveReportAndView(report)
    close(report);
    rptview(report);
end

function appendSectionForLookupTable(report,access)
    import mlreportgen.report.Section

    section=Section(access.Path);
    reporter=createReporterForLookupTable(access);
    append(section,reporter);
    append(report,section);
end

function reporter=createReporterForLookupTable(access)
    import lutdesigner.report.utils.isPreLookup
    import lutdesigner.report.PreLookup
    import slreportgen.utils.isLookupTable
    import slreportgen.report.LookupTable

    if isa(access,'lutdesigner.access.LookupTableBlock')
        blockPath=access.Path;

        if isPreLookup(blockPath)
            reporter=PreLookup(blockPath);
            return;
        end

        if isLookupTable(blockPath)
            reporter=LookupTable(blockPath);
            return;
        end

        reporter=string(message('lutdesigner:messages:CustomBlockReportGenerationLimitation'));
        return;
    end

    assert(isa(access,'lutdesigner.access.LookupTableControl'));
    reporter=string(message('lutdesigner:messages:LookupTableControlReportGenerationLimitation'));
end
