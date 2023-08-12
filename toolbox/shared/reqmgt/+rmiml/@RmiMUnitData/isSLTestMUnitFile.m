function tf = isSLTestMUnitFile( fileName )




R36
fileName string{ mustBeNonempty };
end 

if sharedSLTestInstalled(  )

tf = simulinktest.munitutils.isSLTestMUnitFile( fileName );
else 
tf = false;
end 
end 

function tf = sharedSLTestInstalled(  )



tf = license( 'test', 'Simulink_Test' ) &&  ...
dig.isProductInstalled( 'Simulink Test' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpL4pzDn.p.
% Please follow local copyright laws when handling this file.

