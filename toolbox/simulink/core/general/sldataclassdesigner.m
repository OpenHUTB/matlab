function sldataclassdesigner( varargin )







try 
helpview( [ docroot, '/mapfiles/simulink.map' ], 'DefineDataClasses' );
catch e

warning( e.identifier, e.message );
DAStudio.error( 'Simulink:utility:DataClassDesignerRemoved' );
end 

if ( ( nargin == 1 ) &&  ...
( strcmp( varargin{ 1 }, 'LaunchFromToolsMenu' ) ) )

return ;
else 
DAStudio.error( 'Simulink:utility:DataClassDesignerRemoved' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpckCJan.p.
% Please follow local copyright laws when handling this file.

