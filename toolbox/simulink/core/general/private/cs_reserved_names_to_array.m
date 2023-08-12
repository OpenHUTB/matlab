function ret = cs_reserved_names_to_array( inStr )





ret = {  };
if ~isempty( inStr )
vals = textscan( inStr, '%s', 'Delimiter', [ ' ,', sprintf( '\n' ) ],  ...
'MultipleDelimsAsOne', 1 );
ret = vals{ 1 }';
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpS2tHUz.p.
% Please follow local copyright laws when handling this file.

