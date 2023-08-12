function [ symbolValue, varargout ] = getScopeSectionItem( symbolName, dataLocation, ddSection, varargin )






















assert( ischar( dataLocation ) );
assert( ~isempty( dataLocation ) );
assert( ischar( symbolName ) );
assert( ~isempty( symbolName ) );
if strcmp( dataLocation, 'base' )
symbolValue = evalin( 'base', symbolName );
if nargout > 1
varargout{ 1 } = dataLocation;
end 
return ;
end 


dd = Simulink.dd.open( dataLocation );



accessBaseWorkspace = dd.HasAccessToBaseWorkspace ||  ...
( nargin > 3 && varargin{ 1 } == "on" ) ||  ...
slfeature( 'SLModelAllowedBaseWorkspaceAccess' ) == 0;
resolvedLocation = dataLocation;

if dd.entryExists( [ ddSection, '.', symbolName ], false )
symbolValue = dd.getEntry( [ ddSection, '.', symbolName ] );
elseif accessBaseWorkspace && evalin( 'base', "exist('" + symbolName + "','var')" )
symbolValue = evalin( 'base', symbolName );
resolvedLocation = 'base';
else 
throw( MException( message( 'SLDD:sldd:EntryNotFound' ) ) );
end 

if nargin > 1


varargout{ 1 } = resolvedLocation;
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpVIlzkm.p.
% Please follow local copyright laws when handling this file.

