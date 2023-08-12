function vtype = veriloggetvtype( dt )








switch dt
case ''
error( message( 'HDLShared:directemit:missingdatatype' ) );
case 'auto'
error( message( 'HDLShared:directemit:unsupportedautotype' ) );
otherwise 
try 
n = numerictype( dt );
catch 
error( message( 'HDLShared:directemit:unsupporteddatatype', dt ) );
end 

if n.isscalingslopebias
error( message( 'HDLShared:directemit:unsupportedslopebias', dt ) );
elseif n.isscalingbinarypoint && n.isfixed
vtype = ' ';
if n.SignednessBool
vtype = [ vtype, 'signed ' ];
end 
if n.WordLength ~= 1
vtype = [ vtype, '[', num2str( n.WordLength - 1 ), ':0]' ];
else 
vtype = '';
end 
else 
error( message( 'HDLShared:directemit:unsupporteddatatype', dt ) );
end 

end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpuXd6mx.p.
% Please follow local copyright laws when handling this file.

