function [ ok, errorid ] = warnAboutBusElementMinMaxValidity( updatedBusElement, varargin )
















ok = true;
errorid = '';

narginchk( 1, 2 );


assert( isa( updatedBusElement, 'Simulink.BusElement' ) );




if nargin == 2
hdlg = varargin{ 1 };
assert( isa( hdlg, 'DAStudio.Dialog' ) );
if ~hdlg.isStandAlone
return ;
end 
end 

wStates = warning( 'backtrace', 'off' );
warnCleaner = onCleanup( @(  )warning( wStates ) );




















if ~isempty( updatedBusElement.Min )
updatedBusElement.Min = updatedBusElement.Min;
elseif ~isempty( updatedBusElement.Max )
updatedBusElement.Max = updatedBusElement.Max;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwxDjA8.p.
% Please follow local copyright laws when handling this file.

