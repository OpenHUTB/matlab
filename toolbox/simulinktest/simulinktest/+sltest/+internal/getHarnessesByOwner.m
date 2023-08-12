



function harnessNames = getHarnessesByOwner( harnessOwner )
R36
harnessOwner( 1, 1 )string;
end 

try 
isBdHarnessOwner = bdroot( harnessOwner ) == harnessOwner;
harnessList = sltest.harness.find( harnessOwner );

mask = true( size( harnessList ) );
if isBdHarnessOwner

mask = { harnessList.ownerType } == "Simulink.BlockDiagram";
end 
harnessNames = string( { harnessList( mask ).name } );
catch 

harnessNames = string.empty;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppI3mXu.p.
% Please follow local copyright laws when handling this file.

