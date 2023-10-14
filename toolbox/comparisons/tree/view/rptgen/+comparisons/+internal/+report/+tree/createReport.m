function reportLocation = createReport( mcosView, sources, reportFolder, reportName, format )

arguments
    mcosView( 1, 1 )
    sources( 1, 2 )cell
    reportFolder{ mustBeFolder }
    reportName( 1, : )char
    format( 1, 1 )comparisons.internal.report.tree.ReportFormat
end

reportFactory = comparisons.internal.report.tree.ReportFactory( format );
reportLocation = reportFactory.createReport( mcosView, sources, reportFolder, reportName );

end


