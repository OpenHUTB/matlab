function reportLocation = compareAndGenerateHTMLReport( leftFile, rightFile, reportFolder, reportName, filters )







R36
leftFile{ mustBeTextScalar }
rightFile{ mustBeTextScalar }
reportFolder{ mustBeTextScalar } = pwd
reportName{ mustBeTextScalar } = 'comparisonReport'
filters{ mustBeFilterOrEmpty } = [  ]
end 

mcosView = sldiff.internal.mcos( leftFile, rightFile );

if nargin == 5

mcosView.filter( filters );
end 

sources = { leftFile, rightFile };
reportFormat = comparisons.internal.report.tree.ReportFormat.HTML;

reportLocation = slcomparisons.internal.report.createReport(  ...
mcosView,  ...
sources,  ...
reportFolder,  ...
reportName,  ...
reportFormat );
end 

function mustBeFilterOrEmpty( arg )
if ~isempty( arg ) && ~isa( arg, 'sldiff.internal.filter.Filter' )
errorStruct.message = "Invalid filter class: " + class( arg ) + newline +  ...
"Filter must be of class sldiff.internal.filter.Filter or empty";
errorStruct.identifier = "comparisons:rptgen:InvalidFilter";
error( errorStruct );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7GXjiG.p.
% Please follow local copyright laws when handling this file.

