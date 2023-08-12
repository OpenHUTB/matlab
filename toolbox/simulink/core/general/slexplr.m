function varargout = slexplr( varargin )








if ( ( nargin == 1 ) &&  ...
( strcmp( varargin{ 1 }, 'Refresh' ) ) )

else 
rt = slroot;
ws = rt.getChildren;
ws = ws( 1 );
me = daexplr;
me.view( ws );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmps7uSiL.p.
% Please follow local copyright laws when handling this file.

