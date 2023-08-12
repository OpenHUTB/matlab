function result = vhdlnzeros( n )





if n == 0
result = '';
elseif n == 1
result = '''0''';
else 
if hdlgetparameter( 'safe_zero_concat' )
result = sprintf( '''%d'' & ', zeros( 1, n - 1 ) );
result = [ result, '''0''' ];
else 
result = [ '"', sprintf( '%d', zeros( 1, n ) ), '"' ];
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpSPLTeZ.p.
% Please follow local copyright laws when handling this file.

