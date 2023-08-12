classdef TreeSection < mlreportgen.dom.LockedDocumentPart






properties ( Access = public )
MCOSView
Sources
RootEntry
ReportConfig
SectionConfig comparisons.internal.report.tree.sections.SectionConfig
TempDir
end 

properties ( Access = private )
EntriesForSubsection
end 


methods ( Access = public )

function obj = TreeSection( mcosView, sources, rootEntry, rptConfig,  ...
sectionConfig, tempDir, template )

R36
mcosView( 1, 1 )
sources( 1, 2 )cell
rootEntry( 1, 1 )comparisons.viewmodel.tree.mfzero.Entry
rptConfig( 1, 1 )struct
sectionConfig( 1, 1 )comparisons.internal.report.tree.sections.SectionConfig
tempDir{ mustBeFolder }
template{ mustBeFile }
end 

if sectionConfig.IsSubsection
templateName = "Subsection";
else 
templateName = "Section";
end 

obj = obj@mlreportgen.dom.LockedDocumentPart(  ...
rptConfig.ReportFormat.RPTGenType,  ...
template,  ...
templateName );

obj.MCOSView = mcosView;
obj.Sources = sources;
obj.RootEntry = rootEntry;
obj.ReportConfig = rptConfig;
obj.SectionConfig = sectionConfig;
obj.TempDir = tempDir;
end 

function fillSectionTitle( obj )
if ~isempty( obj.SectionConfig.SectionTitle )
obj.append( obj.SectionConfig.SectionTitle );
end 
end 

function fillSubsectionTitle( obj )
import mlreportgen.dom.TableEntry
import mlreportgen.dom.TableRow
import mlreportgen.dom.Table

titles = { '', '' };
import comparisons.internal.tree.TreeReader.getNameOnSide
import comparisons.internal.tree.TreeReader.getPathOnSide
for sideIndex = 1:2
if ~isempty( getNameOnSide( obj.RootEntry, sideIndex ) )
path = getPathOnSide( obj.RootEntry, sideIndex, false );
[ ~, sourceName ] = fileparts( obj.Sources{ sideIndex }.Path );
path{ 1 } = sourceName;
titles{ sideIndex } = [ path{ : } ];
end 
end 

titlesTable = Table( 2 );
titlesTable.Width = '100%';

import comparisons.internal.report.tree.sections.Utils
Utils.evenlyDistributeTableColumnWidths( titlesTable, 2 );

titleRow = TableRow(  );

for title = titles
titleRow.append( TableEntry( title{ 1 } ) );
end 
titlesTable.append( titleRow );
titlesTable.StyleName = 'SubsectionTitle';
obj.append( titlesTable );
end 

function fillSectionContents( obj )
if obj.SectionConfig.IncludeSubsectionTitleInSection
obj.fillSubsectionTitle(  );
end 
obj.addSectionImages(  );
obj.fillParameters(  );
obj.traverseTreeAndFillContents(  );
end 

function fillSubsectionContents( obj )
obj.addSectionImages(  );
obj.traverseTreeAndFillContents(  );
end 

end 

methods ( Access = private )

function traverseTreeAndFillContents( obj )
import comparisons.internal.tree.PreorderTraverser
traverser = PreorderTraverser( obj.RootEntry, @getChildrenWithoutSubsections );
traverser.forEach( @( entry )obj.fillEntryContents( entry ) );

import comparisons.internal.report.tree.sections.Utils
if ~isempty( obj.EntriesForSubsection )
for entry = obj.EntriesForSubsection
subsecFactory = obj.getSubsectionFactory( entry );
subsection = subsecFactory.create(  ...
obj.MCOSView,  ...
obj.Sources,  ...
entry,  ...
obj.ReportConfig,  ...
obj.TempDir ...
 );

subsection.TemplateName = Utils.getTemplateName( subsection );
subsection.open( obj.ReportConfig.RPTGenTemplateKey );
subsection.fill(  );
obj.append( subsection );

if subsection.SectionConfig.ContainsDiffs
obj.SectionConfig.ContainsDiffs = true;
end 
end 
end 

function entryChildren = getChildrenWithoutSubsections( entry )
if ( entry == obj.RootEntry ) || ~obj.requiresSubsection( entry )
entryChildren = entry.children.toArray;
else 
entryChildren = [  ];
end 
end 

end 

function fillEntryContents( obj, entry )
import comparisons.internal.tree.TreeReader.isChanged
import comparisons.internal.report.tree.sections.TreeEntry
import comparisons.internal.report.tree.sections.Utils

if isChanged( entry )
treeEntry = TreeEntry(  ...
obj.MCOSView,  ...
obj.RootEntry,  ...
entry,  ...
obj.ReportConfig.ReportFormat,  ...
obj.SectionConfig,  ...
obj.ReportConfig.ReportFormat.RPTGenDiffTemplate );
treeEntry.TemplateName = Utils.getTemplateName( treeEntry );
treeEntry.open( obj.ReportConfig.RPTGenTemplateKey );
treeEntry.fill(  );
obj.append( treeEntry );
end 

if obj.requiresSubsection( entry )
obj.EntriesForSubsection = [ obj.EntriesForSubsection, entry ];
end 
end 

function needsSubsection = requiresSubsection( obj, entry )
needsSubsection = ~isempty( obj.getSubsectionFactory( entry ) );
end 

function subsectionFactory = getSubsectionFactory( obj, entry )
subsectionFactory = [  ];
for factory = obj.SectionConfig.SubsectionFactories
if ( factory{ 1 }.appliesToDiff( obj.MCOSView, entry ) )
subsectionFactory = factory{ 1 };
return 
end 
end 
end 

function addSectionImages( obj )
import comparisons.internal.report.tree.sections.Utils
import mlreportgen.dom.TableEntry
import mlreportgen.dom.TableRow
import mlreportgen.dom.Table
import mlreportgen.dom.Text

if isempty( obj.SectionConfig.CreateImage )
return 
end 

numSides = numel( obj.Sources );

imageRow = TableRow(  );

for sideIndex = 1:numSides
nodeExists = ~isempty( comparisons.internal.tree.TreeReader.getPathOnSide( obj.RootEntry, sideIndex ) );
if nodeExists
try 
image = obj.SectionConfig.CreateImage( obj.MCOSView, obj.RootEntry, sideIndex, obj.TempDir );
if ~isempty( image )
Utils.scaleImageToWidthInCM( image, 7 );
end 
catch e


warningMessage = [ e.identifier, newline, e.message ];
warning( e.identifier, '%s', warningMessage )
image = Text( warningMessage );
image.WhiteSpace = 'preserve';
end 
else 
image = '';
end 
imageRow.append( TableEntry( image ) );
end 

imageTable = Table( numSides );
imageTable.Width = '100%';
Utils.evenlyDistributeTableColumnWidths( imageTable, numSides );
imageTable.append( imageRow );
obj.append( imageTable );
end 

function fillParameters( obj )
import comparisons.internal.tree.TreeReader.isChanged
import comparisons.internal.report.tree.sections.TreeEntry
import comparisons.internal.report.tree.sections.Utils

if isChanged( obj.RootEntry )
treeEntry = TreeEntry(  ...
obj.MCOSView,  ...
obj.RootEntry,  ...
obj.RootEntry,  ...
obj.ReportConfig.ReportFormat,  ...
obj.SectionConfig,  ...
obj.ReportConfig.ReportFormat.RPTGenDiffTemplate );
treeEntry.TemplateName = Utils.getTemplateName( treeEntry );
treeEntry.open( obj.ReportConfig.RPTGenTemplateKey );
treeEntry.fill(  );
obj.append( treeEntry );
end 
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPbImbm.p.
% Please follow local copyright laws when handling this file.

