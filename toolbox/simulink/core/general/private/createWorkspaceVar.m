function createWorkspaceVar( var_name, mdl_name, varargin )




wsName = 'all';
if ( nargin == 6 )
dlgSrc = createDataDDG.makeCreateDataDDG( var_name, mdl_name, varargin{ 1 }, varargin{ 2 }, '', '', wsName, varargin{ 3 }, varargin{ 4 } );
elseif ( nargin == 5 )
dlgSrc = createDataDDG.makeCreateDataDDG( var_name, mdl_name, varargin{ 1 }, varargin{ 2 }, '', '', wsName, varargin{ 3 }, false );
elseif ( nargin == 4 )
dlgSrc = createDataDDG.makeCreateDataDDG( var_name, mdl_name, varargin{ 1 }, varargin{ 2 }, '', '', wsName, '', false );
elseif ( nargin == 3 )
dlgSrc = createDataDDG.makeCreateDataDDG( var_name, mdl_name, varargin{ 1 }, '', '', '', wsName, '', false );
else 
dlgSrc = createDataDDG.makeCreateDataDDG( var_name, mdl_name );
end 
slprivate( 'showDDG', dlgSrc );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwJndyZ.p.
% Please follow local copyright laws when handling this file.

