function vtype = verilogblockdatatype( dt )





switch dt
case { 'single', 'half' }

vtype = 'real';
case 'double'
vtype = 'real';
case 'boolean'
vtype = 'wire';
case 'str'
vtype = 'wire [7:0]';
otherwise 
vtype = [ 'wire', veriloggetvtype( dt ) ];
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmp24M8eQ.p.
% Please follow local copyright laws when handling this file.

