classdef VRedSummary<slreportgen.webview.EmbeddedWebViewDocument
















    properties

        RepData(1,1)Simulink.variant.reducer.summary.SummaryData;
    end

    methods
        function rpt=VRedSummary(reportPath,modelName,repData)




            rpt@slreportgen.webview.EmbeddedWebViewDocument(reportPath,...
            repData.OrigTopModelName,modelName);

            rpt.TemplatePath='two_webviews.htmtx';



            rpt.ValidateLinksAndAnchors=false;


            rpt.ExportOptions(1).WebViewHoleId='model1';


            rpt.ExportOptions(2).WebViewHoleId='model2';

            for webId=1:2
                rpt.ExportOptions(webId).IncludeMaskedSubsystems=true;
                rpt.ExportOptions(webId).IncludeSimulinkLibraryLinks=true;
                rpt.ExportOptions(webId).IncludeReferencedModels=true;
                rpt.ExportOptions(webId).IncludeUserLibraryLinks=true;
            end


            rpt.PackageType='unzipped';


            rpt.RepData=repData;
        end

        function fillmodel1(rpt)

            appendWebView(rpt,'model1')
        end

        function fillmodel2(rpt)

            appendWebView(rpt,'model2')
        end

    end

    methods(Hidden)
        fillContent(rpt);

        appendTitle(rpt);

        appendReducerOptions(rpt);

        appendRemovedBlocks(rpt);

        appendModifiedBlocks(rpt);

        appendBlocksAdded(rpt);

        appendModifiedMaskedBlocks(rpt);

        appendCallbacks(rpt);

        appendWarnings(rpt);

        appendSavedDependencies(rpt);

        appendConsiderationsAndLimitations(rpt);

        appendChartsWithVarSFTrans(rpt);

        appendReducedVariantVariables(rpt);

        appendConvertedVariantVariables(rpt);
    end
end


