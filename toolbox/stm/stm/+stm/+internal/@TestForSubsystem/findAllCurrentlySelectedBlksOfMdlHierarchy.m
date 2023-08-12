function res = findAllCurrentlySelectedBlksOfMdlHierarchy( topModel )




R36
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
R36
mdl char = "";
end 


if mdl == ""
selectedBlks = string( Simulink.ID.getSID( find_system( 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'Type', 'block', 'Selected', 'on' ) ) );
return ;
end 
selectedBlks = string( Simulink.ID.getSID( find_system( mdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'Type', 'block', 'Selected', 'on' ) ) );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpvdOIw7.p.
% Please follow local copyright laws when handling this file.

