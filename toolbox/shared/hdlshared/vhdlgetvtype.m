function vhdltype = vhdlgetvtype( dt )








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
if n.WordLength == 1
vhdltype = 'std_logic';
else 
if n.SignednessBool
vhdltype = 'signed';
else 
vhdltype = 'unsigned';
end 
vhdltype = [ vhdltype, '(', num2str( n.WordLength - 1 ), ' DOWNTO 0)' ];
end 
elseif n.isdouble
vhdltype = 'real';
elseif n.isboolean
vhdltype = 'std_logic';
else 
error( message( 'HDLShared:directemit:unsupporteddatatype', dt ) );
end 

end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpVuKjh7.p.
% Please follow local copyright laws when handling this file.

