

function resultObj = processCodeEfficiencyResults( reportContext, opts )
R36
reportContext( 1, 1 )coder.report.ReportContext
opts.IssueCategories( 1, : ) = codergui.internal.insight.getCodeEfficiencyCategories(  )
opts.ContributionContext( 1, 1 )coder.report.ContributionContext
opts.EnableAll( 1, 1 )logical = false
end 



report = reportContext.Report;
inspector = reportContext.DesignInspectorResults;
isProper = isfield( report, 'summary' ) && isfield( report.summary, 'passed' ) &&  ...
~isempty( inspector ) && isvalid( inspector );
passed = isProper && report.summary.passed;
cfg = reportContext.Config;

if reportContext.ClientType == "float2fixed"


filteredScriptNames = { report.summary.name };
else 
filteredScriptNames = {  };
end 

byCatId = containers.Map(  );



for category = reshape( opts.IssueCategories, 1, [  ] )
if ~opts.EnableAll
if strlength( category.ConfigFeatureFlag ) > 0 && ~isempty( cfg ) &&  ...
( ~isprop( cfg, category.ConfigFeatureFlag ) || ~cfg.( category.ConfigFeatureFlag ) )
continue 
end 
if ( strlength( category.EnabledCallback ) > 0 && strlength( which( category.EnabledCallback ) ) > 0 &&  ...
~feval( category.EnabledCallback, reportContext ) )
continue 
end 
end 
if byCatId.isKey( category.InternalId )
error( 'Issue category tags/ids must be unique: %s', catId );
end 

byIssueType = containers.Map(  );
byCatId( category.InternalId ) = byIssueType;
if ~passed
continue 
end 

for issueType = reshape( category.IssueTypes, 1, [  ] )
if isempty( issueType.Checks )
continue 
end 
if byIssueType.isKey( issueType.TypeId )
error( 'Duplicate issue ID: %s', issueType.TypeId );
end 

rawMerged = cell( 1, numel( issueType.Checks ) );
for j = 1:numel( issueType.Checks )
rawMerged{ j } = inspector.parseCGIRResults( char( issueType.Checks( j ) ) ).tag;
end 
rawMerged = [ rawMerged{ : } ];



if ~isempty( filteredScriptNames )
rawMerged = filterBySidScript( rawMerged, filteredScriptNames );
end 


asLocations = emlcprivate( 'extractLocations', rawMerged, issueType.CliTextKey, reportContext.Report );

asMessages = emlcprivate( 'propagateLocations', asLocations, reportContext.Report );
if isfield( opts, 'ContributionContext' )
asMessages = patchWithTextLine( asMessages, opts.ContributionContext );
end 
byIssueType( issueType.TypeId ) = asMessages;
end 
end 

resultObj = codergui.internal.insight.CodeEfficiencyResults( opts.IssueCategories, byCatId );
end 


function filtered = filterBySidScript( occurrences, filteredNames )
R36
occurrences cell
filteredNames string
end 

oNames = cell( size( occurrences ) );
for i = 1:numel( occurrences )
[ ~, oNames{ i } ] = coder.report.RegisterCGIRInspectorResults.parseRecordSID( occurrences{ i } );
end 
filtered = occurrences( ~ismember( oNames, filteredNames ) );
end 


function asMessages = patchWithTextLine( asMessages, contribContext )
R36
asMessages struct
contribContext( 1, 1 )coder.report.ContributionContext
end 

for i = 1:numel( asMessages )
asMessages( i ).TextLine = contribContext.positionToLine( asMessages( i ).ScriptID,  ...
asMessages( i ).TextStart + 1 );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQftEvg.p.
% Please follow local copyright laws when handling this file.

