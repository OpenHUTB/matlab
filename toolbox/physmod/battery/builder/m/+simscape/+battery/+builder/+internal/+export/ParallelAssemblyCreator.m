classdef ( Sealed = true, Hidden = true )ParallelAssemblyCreator < simscape.battery.builder.internal.export.BatteryTypeCreator




properties ( SetAccess = immutable )
BatteryResolutionCreator;
end 

methods 
function obj = ParallelAssemblyCreator( parallelAssembly, filePath, isHighestLevel )
R36
parallelAssembly( 1, 1 ){ mustBeA( parallelAssembly, "simscape.battery.builder.ParallelAssembly" ) }
filePath( 1, 1 ){ mustBeTextScalar( filePath ) }
isHighestLevel( 1, 1 )logical{ mustBeA( isHighestLevel, "logical" ) }
end 


cellData = simscape.battery.builder.internal.export.CellData( parallelAssembly.Cell.CellModelOptions );

switch parallelAssembly.ModelResolution
case "Detailed"
obj.BatteryResolutionCreator = simscape.battery.builder.internal.export.DetailedBatteryWriter( parallelAssembly.Type );
obj.BatteryResolutionCreator.ChildComponentIdentifier = "Cell";
obj.BatteryResolutionCreator.BatteryCompositeComponentVariables = cellData.getVisibleVariables.getCompositeComponentVariables( "P" );
otherwise 
obj.BatteryResolutionCreator = simscape.battery.builder.internal.export.LumpedBatteryWriter( parallelAssembly.Type );
obj.BatteryResolutionCreator.ChildComponentIdentifier = parallelAssembly.Name;
obj.BatteryResolutionCreator.BatteryCompositeComponentVariables = cellData.getVisibleVariables.getCompositeComponentVariables( "1" );
end 
obj.BatteryResolutionCreator.ChildComponent = cellData.getComponentDotPath;
visibleParameters = cellData.getVisibleParameters(  );
obj.BatteryResolutionCreator.CellBalancing = parallelAssembly.BalancingStrategy;
compositeComponentParameters = visibleParameters.getDefaultCompositeComponentParameters(  );
obj.BatteryResolutionCreator.BatteryCompositeComponentParameters = compositeComponentParameters;
obj.BatteryResolutionCreator.NonCellResistanceParameters = obj.getNonCellResistanceParameters( parallelAssembly );
obj.BatteryResolutionCreator.ControlParameters = cellData.getControlParameterStringValue(  );
obj.BatteryResolutionCreator.ChildrenInParallel = parallelAssembly.NumParallelCells;
obj.BatteryResolutionCreator.ComponentName = obj.getBlockName( parallelAssembly, isHighestLevel );
obj.BatteryResolutionCreator.ComponentDescription = getString( message( 'physmod:battery:builder:blocks:ParallelAssemblyBlockDescription' ), matlab.internal.i18n.locale( 'en_US' ) );
obj.BatteryResolutionCreator.FilePath = filePath;
obj.BatteryResolutionCreator.IconName = "parallelAssembly.svg";


obj.BatteryResolutionCreator.CoolingPlateLocation = parallelAssembly.CoolingPlate;
obj.BatteryResolutionCreator.CoolantThermalPath = parallelAssembly.CoolantThermalPath;
obj.BatteryResolutionCreator.AmbientThermalPath = parallelAssembly.AmbientThermalPath;
end 

function blockDetails = createBlock( obj )

blockDetails = obj.BatteryResolutionCreator.createComponent(  );
blockDetails = blockDetails.setBatteryType( "ParallelAssembly" );
end 
end 

methods ( Access = private, Static )
function nonCellResistanceParameters = getNonCellResistanceParameters( parallelAssembly )

nonCellResistanceParameters = simscape.battery.builder.internal.export.ComponentParameters(  );
switch parallelAssembly.NonCellResistance
case "Yes"
labelName = string( getString( message( 'physmod:battery:builder:blocks:NonCellResistanceName' ), matlab.internal.i18n.locale( 'en_US' ) ) );
groupName = string( getString( message( 'physmod:battery:builder:blocks:ParallelAssemblySectionName' ), matlab.internal.i18n.locale( 'en_US' ) ) );
nonCellResistanceParameters = nonCellResistanceParameters.addParameters( "NonCellElectricalResistance", labelName, "1/1000", "Ohm", groupName, "1" );
otherwise 

end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqOUQ71.p.
% Please follow local copyright laws when handling this file.

