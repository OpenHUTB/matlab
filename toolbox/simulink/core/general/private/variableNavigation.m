function variableNavigation( mdl_name, textToParse, blockFullName, varargin )




useExplore = false;
useOpen = false;
useCreate = false;
if nargin >= 4
if isequal( varargin{ 1 }, 'open' )
useOpen = true;
elseif isequal( varargin{ 1 }, 'explore' )
useExplore = true;
elseif isequal( varargin{ 1 }, 'create' )
useCreate = true;
end 
end 
if ~useExplore && ~useOpen && ~useCreate
useExplore = true;
end 

[ location, locationIsValid, foundVarName ] = slprivate( 'findVariable', mdl_name, textToParse, blockFullName );

if locationIsValid && ~isempty( foundVarName )
[ location, fullName, fileName, isExplorable, enabled ] = slprivate( 'parseLocation', mdl_name, location, foundVarName );
if isempty( location ) && ( useExplore || useCreate )
if nargin >= 5
slprivate( 'createWorkspaceVar', foundVarName, mdl_name, varargin{ 2 } );
else 
slprivate( 'createWorkspaceVar', foundVarName, mdl_name );
end 
elseif useExplore
slprivate( 'exploreListNode', fileName, location, foundVarName );
elseif useOpen
slprivate( 'showWorkspaceVar', location, foundVarName, fileName );
end 
end 
end 

function varList = parseExpression( textToParse )
tree = mtree( textToParse );
ids = tree.mtfind( 'Kind', 'ID' );
vars = strings( ids );
varList = unique( vars );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJfmMlT.p.
% Please follow local copyright laws when handling this file.

