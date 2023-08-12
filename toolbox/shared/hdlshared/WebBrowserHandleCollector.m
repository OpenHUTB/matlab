


classdef WebBrowserHandleCollector < containers.Map


methods ( Access = public )


function this = WebBrowserHandleCollector( varargin )
mlock
this = this@containers.Map( varargin{ : } );
end 

function this = addWebBrowser( this, filePath )












browserHandle = [  ];
s = struct( 'type', '()', 'subs', filePath );
subsasgn( this, s, browserHandle );

return 
end 

function this = closeAllWebBrowsers( this )


cellfun( @( h )close( h ), this.values(  ) );


this.remove( this.keys(  ) );
return 
end 

function disp( this )
disp( [ 'WebBrowserHandleCollector object has ', num2str( this.Count(  ) ), ' handles' ] );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpC_UpdZ.p.
% Please follow local copyright laws when handling this file.

