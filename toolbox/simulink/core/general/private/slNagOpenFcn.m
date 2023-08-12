function oFcn = slNagOpenFcn( action, varargin )



persistent OpenFunction;
persistent Message;

oFcn = '';




if isempty( OpenFunction )
OpenFunctions = '';
end 
if isempty( Message )
Message = '';
end 


switch ( action )
case 'set'

if ( ( nargin < 3 ) || ~iscellstr( varargin ) )
DAStudio.error( 'Simulink:utility:invalidInputArgs', 'slNagOpenFcn' );
end 
Message = varargin{ 1 };
OpenFunction = varargin{ 2 };
case 'get'


if ( ( nargin < 2 ) || ~ischar( varargin{ 1 } ) )
DAStudio.error( 'Simulink:utility:invalidInputArgs', 'slNagOpenFcn' );
end 



if ~isempty( findstr( varargin{ 1 }, Message ) )
oFcn = OpenFunction;
OpenFunction = '';
Message = '';
end 
case 'clear'
OpenFunction = '';
Message = '';
otherwise 
DAStudio.error( 'Simulink:utility:invalidInputArgs', 'slNagOpenFcn' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpyyDYU6.p.
% Please follow local copyright laws when handling this file.

