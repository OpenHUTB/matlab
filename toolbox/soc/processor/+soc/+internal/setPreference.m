function setPreference( name, value, varargin )




assert( numel( name ) <= 63, 'The ESB preference name longer than 63 characters' );
esbPrefGroup = 'ESBPreferences';
setpref( esbPrefGroup, name, value );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpysFiV2.p.
% Please follow local copyright laws when handling this file.

