function tf = isSLTestMUnitFile( fileName )

arguments
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
