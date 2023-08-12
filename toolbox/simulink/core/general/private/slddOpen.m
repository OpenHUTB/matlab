






function slddOpen( varargin )




if nargin == 0
[ filename, pathname ] = uigetfile(  ...
{ '*.sldd', 'Data Dictionary files (*.sldd)'; ...
'*.*', 'All Files (*.*)' },  ...
'Open Data Dictionary' );
if ~isequal( filename, 0 ) && ~isequal( pathname, 0 )

ddFilepath = fullfile( pathname, filename );
dd1 = Simulink.dd.open( ddFilepath,  ...
'SubdictionaryErrorAction', 'warn' );
if dd1.isOpen
dd1.explore;
end 
end 
else 
assert( nargin == 1 );
ddName = varargin{ 1 };



dd1 = Simulink.dd.open( ddName,  ...
'SubdictionaryErrorAction', 'warn' );
if dd1.isOpen

dd1.show( true );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp8pRWxh.p.
% Please follow local copyright laws when handling this file.

