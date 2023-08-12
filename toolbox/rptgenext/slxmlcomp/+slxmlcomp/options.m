





















classdef options < handle

properties ( Access = public )
PreferredSimulinkPositionLeft;
PreferredSimulinkPositionRight;
PreferredStateflowPositionLeft;
PreferredStateflowPositionRight;
PreferredReportPosition;
end 

properties ( Access = public, Dependent )
ReportImageFormat;
ReportHighlightImages;
EnableMoveMatches;
end 

properties ( Access = private )
CloseSameNameModel = false;
end 


methods ( Access = public )

function obj = options(  )

persistent pObj
if ~isempty( pObj ) && isvalid( pObj )
obj = pObj;
return 
end 

pObj = obj;
end 

function reset( obj )
obj.PreferredSimulinkPositionLeft = [  ];
obj.PreferredSimulinkPositionRight = [  ];
obj.PreferredStateflowPositionLeft = [  ];
obj.PreferredStateflowPositionRight = [  ];
obj.PreferredReportPosition = [  ];
obj.setCloseSameNameModel( false );
obj.ReportImageFormat = 'svg';
obj.ReportHighlightImages = true;
end 

end 


methods ( Access = public, Hidden = true )

function snapshot = createSnapshot( obj )
props = properties( obj );
props( length( props ) + 1 ) = { 'CloseSameNameModel' };
snapshot = struct;
for ii = 1:length( props )
property = props{ ii };
snapshot.( property ) = obj.( property );
end 
end 

function restoreFromSnapshot( obj, snapshot )
assert( isstruct( snapshot ), 'Input must be a struct' );
props = fields( snapshot );
for ii = 1:length( props )
property = props{ ii };
if strcmp( property, 'CloseSameNameModel' )
obj.setCloseSameNameModel( snapshot.( property ) );
else 
obj.( property ) = snapshot.( property );
end 
end 

end 

end 


methods 

function imageFormat = get.ReportImageFormat( obj )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.PrintableReportImageFormatPreference;%#ok<JAPIMATHWORKS>
imageFormat = obj.getValue( PrintableReportImageFormatPreference.getInstance(  ) );
end 

function set.ReportImageFormat( obj, imageFormat )
imageFormat = convertStringsToChars( imageFormat );
if ~ismember( imageFormat, { 'svg', 'png' } )
error( message( 'SimulinkXMLComparison:report:InvalidReportImageFormat' ) )
end 
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.PrintableReportImageFormatPreference;%#ok<JAPIMATHWORKS>
obj.setValue( PrintableReportImageFormatPreference.getInstance(  ), java.lang.String( imageFormat ) );
end 

function highlightImages = get.ReportHighlightImages( obj )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.PrintableReportHighlightImagesPreference;%#ok<JAPIMATHWORKS>
highlightImages = obj.getValue( PrintableReportHighlightImagesPreference.getInstance(  ) );
end 

function set.ReportHighlightImages( obj, imageFormat )
R36
obj
imageFormat( 1, 1 )logical
end 
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.PrintableReportHighlightImagesPreference;%#ok<JAPIMATHWORKS>
obj.setValue( PrintableReportHighlightImagesPreference.getInstance(  ), java.lang.Boolean( imageFormat ) );
end 

function enableMoveMatches = get.EnableMoveMatches( obj )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.EnableMoveMatchesPreference;%#ok<JAPIMATHWORKS>
enableMoveMatches = obj.getValue( EnableMoveMatchesPreference.getInstance(  ) );
end 

function set.EnableMoveMatches( obj, enableMoveMatches )
R36
obj
enableMoveMatches( 1, 1 )logical
end 
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.EnableMoveMatchesPreference;%#ok<JAPIMATHWORKS>
obj.setValue( EnableMoveMatchesPreference.getInstance(  ), java.lang.Boolean( enableMoveMatches ) );
end 

function closeValue = getCloseSameNameModel( obj )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.CloseSameNameModelPreference;%#ok<JAPIMATHWORKS>
closeValue = obj.getValue( CloseSameNameModelPreference.getInstance(  ) );
end 

function pos = get.PreferredSimulinkPositionLeft( obj )
if isempty( obj.PreferredSimulinkPositionLeft )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.SimulinkPositionLeftPreference;%#ok<*SIMPT,JAPIMATHWORKS>
obj.PreferredSimulinkPositionLeft = obj.getPositionValue( SimulinkPositionLeftPreference.getInstance(  ) );
end 
pos = obj.PreferredSimulinkPositionLeft;
end 

function pos = get.PreferredSimulinkPositionRight( obj )
if isempty( obj.PreferredSimulinkPositionRight )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.SimulinkPositionRightPreference;%#ok<JAPIMATHWORKS>
obj.PreferredSimulinkPositionRight = obj.getPositionValue( SimulinkPositionRightPreference.getInstance(  ) );
end 
pos = obj.PreferredSimulinkPositionRight;
end 

function pos = get.PreferredStateflowPositionLeft( obj )
if isempty( obj.PreferredStateflowPositionLeft )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.StateflowPositionLeftPreference;%#ok<JAPIMATHWORKS>
obj.PreferredStateflowPositionLeft = obj.getPositionValue( StateflowPositionLeftPreference.getInstance(  ) );
end 
pos = obj.PreferredStateflowPositionLeft;
end 

function pos = get.PreferredStateflowPositionRight( obj )
if isempty( obj.PreferredStateflowPositionRight )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.StateflowPositionRightPreference;%#ok<JAPIMATHWORKS>
obj.PreferredStateflowPositionRight = obj.getPositionValue( StateflowPositionRightPreference.getInstance(  ) );
end 
pos = obj.PreferredStateflowPositionRight;
end 

function pos = get.PreferredReportPosition( obj )
if isempty( obj.PreferredReportPosition )
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.ReportPositionPreference;%#ok<JAPIMATHWORKS>
obj.PreferredReportPosition = obj.getPositionValue( ReportPositionPreference.getInstance(  ) );
end 
pos = obj.PreferredReportPosition;
end 

function setCloseSameNameModel( obj, closeValue )
assert( ( isempty( closeValue ) || islogical( closeValue ) ), 'CloseSameNameModel must be Boolean' );
obj.CloseSameNameModel = closeValue;
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.CloseSameNameModelPreference;%#ok<JAPIMATHWORKS>
obj.setValue( CloseSameNameModelPreference.getInstance(  ), closeValue );
end 

function set.PreferredSimulinkPositionLeft( obj, position )
obj.checkValidPosition( position );
obj.PreferredSimulinkPositionLeft = position;
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.SimulinkPositionLeftPreference;%#ok<JAPIMATHWORKS>
obj.setPositionValue( SimulinkPositionLeftPreference.getInstance(  ), position );
end 

function set.PreferredSimulinkPositionRight( obj, position )
obj.checkValidPosition( position );
obj.PreferredSimulinkPositionRight = position;
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.SimulinkPositionRightPreference;%#ok<JAPIMATHWORKS>
obj.setPositionValue( SimulinkPositionRightPreference.getInstance(  ), position );
end 

function set.PreferredStateflowPositionLeft( obj, position )
obj.checkValidPosition( position );
obj.PreferredStateflowPositionLeft = position;
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.StateflowPositionLeftPreference;%#ok<JAPIMATHWORKS>
obj.setPositionValue( StateflowPositionLeftPreference.getInstance(  ), position );
end 

function set.PreferredStateflowPositionRight( obj, position )
obj.checkValidPosition( position );
obj.PreferredStateflowPositionRight = position;
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.StateflowPositionRightPreference;%#ok<JAPIMATHWORKS>
obj.setPositionValue( StateflowPositionRightPreference.getInstance(  ), position );
end 

function set.PreferredReportPosition( obj, position )
obj.checkValidPosition( position );
obj.PreferredReportPosition = position;
import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.preference.ReportPositionPreference;%#ok<JAPIMATHWORKS>
obj.setPositionValue( ReportPositionPreference.getInstance(  ), position );
end 

end 


methods ( Access = private )

function checkValidPosition( ~, position )
assert( isempty( position ) ||  ...
( isnumeric( position ) && size( position, 1 ) == 1 && size( position, 2 ) == 4 ),  ...
'Size must be a 1*4 numeric array' );
end 

function value = getPositionValue( obj, preference )

value = obj.getValue( preference );
value = obj.convertToNumericArray( value );
if obj.isEmptyInitialValue( value )
value = [  ];
end 
end 

function value = convertToNumericArray( ~, jPosition )
value = zeros( 1, numel( jPosition ) );
for ii = 1:numel( jPosition )
value( ii ) = jPosition( ii );
end 
end 

function isEmpty = isEmptyInitialValue( ~, value )
isEmpty = all( value == [ 0, 0, 0, 0 ] );
end 

function value = getValue( ~, preference )
import com.mathworks.comparisons.prefs.ComparisonPreferenceManager;%#ok<JAPIMATHWORKS>
value = ComparisonPreferenceManager.getInstance(  ).getValue( preference );
end 

function setPositionValue( obj, preference, position )
if isempty( position )
position = [ 0, 0, 0, 0 ];
end 


jPosition = javaArray( 'java.lang.Double', 4 );
for ii = 1:numel( position )
jPosition( ii ) = java.lang.Double( position( ii ) );
end 
obj.setValue( preference, jPosition );
end 

function setValue( ~, preference, value )
import com.mathworks.comparisons.prefs.ComparisonPreferenceManager;%#ok<JAPIMATHWORKS>
ComparisonPreferenceManager.getInstance(  ).setValue( preference, value );
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPH3zgd.p.
% Please follow local copyright laws when handling this file.

