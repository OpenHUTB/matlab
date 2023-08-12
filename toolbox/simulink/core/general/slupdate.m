function report = slupdate( varargin )










if nargin < 2 || ~( ischar( varargin{ end  } ) && strcmpi( varargin{ end  }, 'legacy' ) )
DAStudio.error( 'Simulink:slupdate:slupdateDeprecationError' )
else 
varargin = varargin( 1:end  - 1 );
end 

[ report, cmdLineText ] = ModelUpdater.update( varargin{ : } );
if ~isempty( cmdLineText )
disp( cmdLineText )
end 



MSLDiagnostic( 'Simulink:slupdate:slupdateDeprecation', varargin{ 1 } ).reportAsWarning;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxVeFKD.p.
% Please follow local copyright laws when handling this file.

