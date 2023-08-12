function updateDataLabels( p, action )

















if nargin < 2
action = 'update';
end 
N = getNumDatasets( p );
dl = p.pLabels;

if isempty( dl )






argSlices = internal.polariCommon.createArgSets( p.DefaultDataLabel, 1:N );
newDataLabels = internal.polariCommon.fevalArgSets( @sprintf, argSlices );

elseif ischar( dl ) || ( isstring( dl ) && isscalar( dl ) )



newDataLabels = internal.polariCommon.xlatExtendedASCII( dl );
if N > 1

argSlices = internal.polariCommon.createArgSets(  ...
p.DefaultDataLabel, 2:N );
newDataLabels = [ newDataLabels, internal.polariCommon.fevalArgSets( @sprintf, argSlices ) ];
end 

elseif iscellstr( dl ) || isstring( dl )


dl = internal.polariCommon.convertEmbeddedCellsToCharMatrices( dl );
dl = internal.polariCommon.convertEmbeddedCRsToCharMatrices( dl );





idx = find( cellfun( @isempty, dl ) );
if ~isempty( idx )
argSlices = internal.polariCommon.createArgSets( p.DefaultDataLabel, idx );
newDataLabels = internal.polariCommon.fevalArgSets( @sprintf, argSlices );
dl( idx ) = newDataLabels;
end 


Ndl = numel( dl );
if Ndl < N



idx = Ndl + 1:N;
if ~isempty( idx )
argSlices = internal.polariCommon.createArgSets( p.DefaultDataLabel, idx );
newDataLabels = internal.polariCommon.fevalArgSets( @sprintf, argSlices );
dl( idx ) = newDataLabels;
end 

elseif Ndl > N

dl = dl( 1:N );
end 
newDataLabels = internal.polariCommon.xlatExtendedASCII( dl );
else 
assert( false, 'Unrecognized type for pLabels' );
end 

if strcmpi( action, 'never' )


p.pDataLabels = newDataLabels;

elseif strcmpi( action, 'force' )


p.pDataLabels = newDataLabels;
updateLegend( p );
else 

if ~isequal( p.pDataLabels, newDataLabels )
p.pDataLabels = newDataLabels;
updateLegend( p );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpovRE_t.p.
% Please follow local copyright laws when handling this file.

