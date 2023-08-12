function formattedDefs = tokenizeCustomDefines( customDefs )





















pat = '(-D)?((\w+=(("[^"]*")|([^ \n]*)))|(\w+))';
formattedDefs = regexp( customDefs, pat, 'match' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpm27Yvb.p.
% Please follow local copyright laws when handling this file.

