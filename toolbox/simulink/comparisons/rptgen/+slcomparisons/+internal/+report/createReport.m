function reportLocation = createReport( mcosView, sources, reportFolder, reportName, format )





R36
mcosView( 1, 1 )
sources( 1, 2 )cell
reportFolder{ mustBeFolder }
reportName( 1, : )char
format( 1, 1 )comparisons.internal.report.tree.ReportFormat
end 

reportConstructor = @slComparisonReport;
reportFactory = comparisons.internal.report.tree.ReportFactory( format, reportConstructor );
reportLocation = reportFactory.createReport( mcosView, sources, reportFolder, reportName );

function report = slComparisonReport( mcosView, sources, reportLocation, rptFormat )
SLFileInfoRetrievers = {  ...
@slcomparisons.internal.report.fileinfo.getMD5Checksum,  ...
@slcomparisons.internal.report.fileinfo.getModelVersion,  ...
@slcomparisons.internal.report.fileinfo.getReleaseName,  ...
@slcomparisons.internal.report.fileinfo.getDescription ...
 };
SLProducts = "Simulink";
SLSectionFactories = {  ...
slcomparisons.internal.report.sections.SimulinkSectionFactory(  ) ...
 };
SLGetNameOfFilter = @( f )slcomparisons.internal.report.getNameOfFilter( f );

report = comparisons.internal.report.tree.ComparisonReport( mcosView, sources, reportLocation, rptFormat );

report.FileInfoRetrievers = [ report.FileInfoRetrievers, SLFileInfoRetrievers ];
report.Products = [ report.Products, SLProducts ];
report.SectionFactories = [ SLSectionFactories, report.SectionFactories ];
report.GetNameOfFilter = SLGetNameOfFilter;
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpevnDXY.p.
% Please follow local copyright laws when handling this file.

