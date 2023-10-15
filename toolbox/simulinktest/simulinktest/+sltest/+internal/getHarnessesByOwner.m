function harnessNames = getHarnessesByOwner( harnessOwner )
arguments
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



