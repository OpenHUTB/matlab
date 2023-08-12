function SubComp = getSubComp( hN, hInSignals, hOutSignals,  ...
rndMode, satMode, compName, accumType )




if ( nargin < 7 )
applyAccumType = false;
else 
applyAccumType = true;
end 

if ( nargin < 6 )
compName = 'subtractor';
end 

if ( nargin < 5 )
satMode = 'Wrap';
end 

if ( nargin < 4 )
rndMode = 'Floor';
end 

if applyAccumType


accumTpEx = pirelab.getTypeInfoAsFi( accumType, rndMode, satMode );
sub_accum = hN.addSignal( accumType, sprintf( '%s_accum', compName ) );

SubComp = hN.addComponent2(  ...
'kind', 'cgireml',  ...
'Name', compName,  ...
'InputSignals', hInSignals,  ...
'OutputSignals', sub_accum,  ...
'EMLFileName', 'hdleml_sub',  ...
'EMLParams', { accumTpEx } );

pirelab.getDTCComp( hN, sub_accum, hOutSignals, rndMode, satMode, 'RWV', 'sub_accum_dtc' );

else 


outTpEx = pirelab.getTypeInfoAsFi( hOutSignals.Type, rndMode, satMode );

SubComp = hN.addComponent2(  ...
'kind', 'cgireml',  ...
'Name', compName,  ...
'InputSignals', hInSignals,  ...
'OutputSignals', hOutSignals,  ...
'EMLFileName', 'hdleml_sub',  ...
'EMLParams', { outTpEx } );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQxizwf.p.
% Please follow local copyright laws when handling this file.

