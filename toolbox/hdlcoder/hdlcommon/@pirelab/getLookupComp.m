function cgirComp = getLookupComp( hN, hInSignals, hOutSignals,  ...
input_values, table_data, other_data, oType_ex, compName, desc )


if nargin < 9
desc = [  ];
end 

if nargin < 8
compName = 'LUT';
end 

if nargin < 7

oType_ex = pirelab.getTypeInfoAsFi( hOutSignals( 1 ).Type, 'Nearest', 'Saturate' );
end 

if nargin < 6 || isempty( other_data )
other_data = 0;
end 

fcnBody = getLookupCode( input_values, table_data, other_data );

cgirComp = hN.addComponent2(  ...
'kind', 'cgireml',  ...
'Name', compName,  ...
'InputSignals', hInSignals,  ...
'OutputSignals', hOutSignals,  ...
'EMLFileName', 'hdleml_lookup_switch',  ...
'EMLFileBody', fcnBody,  ...
'EMLParams', { oType_ex },  ...
'EMLFlag_TreatInputIntsAsFixpt', true,  ...
'EMLFlag_SaturateOnIntOverflow', false,  ...
'BlockComment', desc );

cgirComp.runConcurrencyMaximizer( false );
end 


function fcnBody = getLookupCode( input_values, table_data, other_data )
fcnBody = sprintf( [ '%%#codegen\n',  ...
'function y = hdleml_lookup_switch(u, outtp_ex)\n',  ...
'%%   Copyright 2010 The MathWorks, Inc.\n',  ...
'coder.allowpcode(''plain'')\n',  ...
'eml_prefer_const(outtp_ex);\n',  ...
'\n',  ...
'\ny = hdleml_define(outtp_ex);\n',  ...
'switch int32(u)\n' ] );

iscomplex = ~isreal( table_data );
invals = int32( input_values );
if iscomplex
for ii = 1:length( input_values )
fcnBody = sprintf( '%s\tcase %d\n\t\ty(:) = %.15g + %.15gi;\n',  ...
fcnBody, invals( ii ),  ...
double( real( table_data( ii ) ) ), double( imag( table_data( ii ) ) ) );
end 
else 
for ii = 1:length( input_values )
fcnBody = sprintf( '%s\tcase %d\n\t\ty(:) = %.15g;\n',  ...
fcnBody, invals( ii ), double( table_data( ii ) ) );
end 
end 

iscomplex = ~isreal( other_data );
if iscomplex
fcnBody = sprintf( '%s\totherwise \n\t\ty(:) = %.15g + %.15gi;\n',  ...
fcnBody, double( real( other_data ) ), double( imag( other_data ) ) );
else 
fcnBody = sprintf( '%s\totherwise \n\t\ty(:) = %.15g;\n',  ...
fcnBody, double( other_data ) );
end 

fcnBody = sprintf( '%send\n', fcnBody );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5Mp2tn.p.
% Please follow local copyright laws when handling this file.

