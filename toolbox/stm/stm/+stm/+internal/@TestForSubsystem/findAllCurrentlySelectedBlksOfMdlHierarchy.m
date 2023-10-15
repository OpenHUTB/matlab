function res = findAllCurrentlySelectedBlksOfMdlHierarchy( topModel )




arguments
    topModel char = "";
end
res = [  ];
selectedBlks = [  ];
if ( topModel == "" )
    selectedBlks = findAllCurrentlySelectedBlks(  );
    if numel( selectedBlks ) == 0

        error( message( "stm:general:NoCurrentSubsystem" ) );
    end

    topModel = bdroot( selectedBlks( end  ) );
    if numel( unique( bdroot( selectedBlks ) ) ) ~= 1


        selectedBlks = selectedBlks( end  );
    end
    res.selectedBlocks = selectedBlks;
    res.topModel = topModel;
    return ;
end
if ~bdIsLoaded( topModel )
    load_system( topModel );
end


selectedBlks = findAllCurrentlySelectedBlks( topModel );


refModels = reshape( string( find_mdlrefs( topModel, "ReturnTopModelAsLastElement", false, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices ) ), 1, [  ] );
for refModel = refModels
    if bdIsLoaded( refModel )
        selectedBlks = [ selectedBlks;findAllCurrentlySelectedBlks( refModel ) ];%#ok<AGROW>
    end
end
res.selectedBlocks = selectedBlks;
res.topModel = topModel;
if numel( selectedBlks ) == 0
    error( message( "stm:general:NoCurrentSubsystem" ) );
end
end

function selectedBlks = findAllCurrentlySelectedBlks( mdl )
arguments
    mdl char = "";
end


if mdl == ""
    selectedBlks = string( Simulink.ID.getSID( find_system( 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'Type', 'block', 'Selected', 'on' ) ) );
    return ;
end
selectedBlks = string( Simulink.ID.getSID( find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'Type', 'block', 'Selected', 'on' ) ) );
end


