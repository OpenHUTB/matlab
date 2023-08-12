function opts = parseArgs( opts, varargin )
















numArgs = length( varargin );
for k = 1:2:numArgs
flag = varargin{ k };
if ~ischar( flag ) || length( flag ) < 2 || flag( 1 ) ~= '-'
DAStudio.error( 'Simulink:utility:invalidInputArgs', char( flag ) );
end 
flag = flag( 2:end  );
if ~isfield( opts, flag )
DAStudio.error( 'Simulink:utility:invalidInputArgs', flag );
end 
if k == numArgs
DAStudio.error( 'Simulink:utility:invalidArgPairing', flag );
end 
value = varargin{ k + 1 };
if islogical( opts.( flag ) ) && ischar( value )
if strcmp( value, 'on' )
value = true;
elseif strcmp( value, 'off' )
value = false;
end 
end 
if ~isa( value, class( opts.( flag ) ) )
DAStudio.error( 'Simulink:utility:invalidArgPairing', flag );
end 

opts.( flag ) = value;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp8Ml2nl.p.
% Please follow local copyright laws when handling this file.

