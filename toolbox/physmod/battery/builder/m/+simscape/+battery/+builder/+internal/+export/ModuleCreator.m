classdef ( Sealed = true, Hidden = true )ModuleCreator < simscape.battery.builder.internal.export.BatteryTypeCreator




properties ( SetAccess = immutable )
BatteryResolutionCreator;
end 


methods 
function obj = ModuleCreator( module, filePath, isHighestLevel, blockDatabase )
R36
module( 1, 1 ){ mustBeA( module, "simscape.battery.builder.Module" ) }
filePath( 1, 1 ){ mustBeTextScalar( filePath ) }
isHighestLevel( 1, 1 )logical{ mustBeA( isHighestLevel, "logical" ) }
blockDatabase( 1, 1 ){ mustBeA( blockDatabase, "simscape.battery.builder.internal.export.BlockDatabase" ) }
end 

switch module.ModelResolution
case "Detailed"
obj.BatteryResolutionCreator = simscape.battery.builder.internal.export.DetailedBatteryWriter( module.Type );
childComponent = obj.getChildBlock( module, blockDatabase );
obj.BatteryResolutionCreator.ChildComponent = childComponent.ComponentPath;
obj.BatteryResolutionCreator.ChildComponentIdentifier = module.ParallelAssembly.Name;
obj.BatteryResolutionCreator.BatteryCompositeComponentParameters = obj.getBatteryCompositeComponentParameters( module, childComponent.BlockParameters );
obj.BatteryResolutionCreator.BatteryCompositeComponentVariables = childComponent.BlockVariables.getCompositeComponentVariables( "S" );
obj.BatteryResolutionCreator.BatteryCompositeComponentInputs = childComponent.BlockInputs;
obj.BatteryResolutionCreator.CellBalancing = "";
case "Lumped"
obj.BatteryResolutionCreator = simscape.battery.builder.internal.export.LumpedBatteryWriter( module.Type );
cellData = simscape.battery.builder.internal.export.CellData( module.ParallelAssembly.Cell.CellModelOptions );
obj.BatteryResolutionCreator.ChildComponent = cellData.getComponentDotPath;
obj.BatteryResolutionCreator.ChildComponentIdentifier = module.Name;
obj.BatteryResolutionCreator.BatteryCompositeComponentParameters = obj.getBatteryCompositeComponentParameters( module, cellData.getVisibleParameters(  ) );
obj.BatteryResolutionCreator.BatteryCompositeComponentVariables = cellData.getVisibleVariables.getCompositeComponentVariables( "1" );
obj.BatteryResolutionCreator.ControlParameters = cellData.getControlParameterStringValue(  );
obj.BatteryResolutionCreator.ChildrenInParallel = module.ParallelAssembly.NumParallelCells;
obj.BatteryResolutionCreator.CellBalancing = module.BalancingStrategy;
otherwise 
obj.BatteryResolutionCreator = simscape.battery.builder.internal.export.GroupedBatteryWriter(  );
cellData = simscape.battery.builder.internal.export.CellData( module.ParallelAssembly.Cell.CellModelOptions );
obj.BatteryResolutionCreator.ChildComponent = cellData.getComponentDotPath;
obj.BatteryResolutionCreator.ChildComponentIdentifier = "battery";
obj.BatteryResolutionCreator.BatteryCompositeComponentParameters = obj.getBatteryCompositeComponentParameters( module, cellData.getVisibleParameters(  ) );
obj.BatteryResolutionCreator.BatteryCompositeComponentVariables = cellData.getVisibleVariables.getCompositeComponentVariables( "TotalNumModels" );
obj.BatteryResolutionCreator.ControlParameters = cellData.getControlParameterStringValue(  );
obj.BatteryResolutionCreator.ChildrenInParallel = module.ParallelAssembly.NumParallelCells;
obj.BatteryResolutionCreator.CellBalancing = module.BalancingStrategy;
obj.BatteryResolutionCreator.SeriesGrouping = module.SeriesGrouping;
obj.BatteryResolutionCreator.ParallelGrouping = module.ParallelGrouping;
end 
obj.BatteryResolutionCreator.NonCellResistanceParameters = obj.getNonCellResistanceParameters( module );
obj.BatteryResolutionCreator.ChildrenInSeries = module.NumSeriesAssemblies;
obj.BatteryResolutionCreator.ChildrenInParallel = module.ParallelAssembly.NumParallelCells;
obj.BatteryResolutionCreator.ComponentName = obj.getBlockName( module, isHighestLevel );
obj.BatteryResolutionCreator.ComponentDescription = getString( message( 'physmod:battery:builder:blocks:ModuleBlockDescription' ), matlab.internal.i18n.locale( 'en_US' ) );
obj.BatteryResolutionCreator.FilePath = filePath;
obj.BatteryResolutionCreator.IconName = "module.svg";


obj.BatteryResolutionCreator.CoolingPlateLocation = module.CoolingPlate;
obj.BatteryResolutionCreator.CoolantThermalPath = module.CoolantThermalPath;
obj.BatteryResolutionCreator.AmbientThermalPath = module.AmbientThermalPath;
end 

function blockDetails = createBlock( obj )

blockDetails = obj.BatteryResolutionCreator.createComponent(  );
blockDetails = blockDetails.setBatteryType( simscape.battery.builder.Module.Type );
end 
end 

methods ( Static, Access = private )
function block = getChildBlock( module, blockDatabase )

block = blockDatabase.getBlock( "ParallelAssembly", module.ParallelAssembly.BlockType );
end 

function compositeComponentParameters = getBatteryCompositeComponentParameters( module, parameters )


compositeComponentParameters = parameters.getDefaultCompositeComponentParameters(  );
nonCellResistanceName = "NonCellElectricalResistance";
switch module.NonCellResistance
case "Yes"
compositeComponentParameters = compositeComponentParameters.setParameterSpecification( nonCellResistanceName, "Value", "{0,'Ohm'}" );
compositeComponentParameters = compositeComponentParameters.setParameterSpecification( nonCellResistanceName, "Label", "" );
compositeComponentParameters = compositeComponentParameters.setParameterSpecification( nonCellResistanceName, "Group", "" );
compositeComponentParameters = compositeComponentParameters.setParameterSpecification( nonCellResistanceName, "IsComponentParameter", false );
otherwise 
compositeComponentParameters = compositeComponentParameters.setParameterSpecification( nonCellResistanceName, "Value", "NonCellResistanceParallelAssembly" );
labelName = string( getString( message( 'physmod:battery:builder:blocks:NonCellResistanceParallelAssemblyName' ), matlab.internal.i18n.locale( 'en_US' ) ) );
sectionName = string( getString( message( 'physmod:battery:builder:blocks:ParallelAssemblySectionName' ), matlab.internal.i18n.locale( 'en_US' ) ) );
compositeComponentParameters = compositeComponentParameters.setParameterSpecification( nonCellResistanceName, "Label", labelName );
compositeComponentParameters = compositeComponentParameters.setParameterSpecification( nonCellResistanceName, "Group", sectionName );
compositeComponentParameters = compositeComponentParameters.setParameterSpecification( nonCellResistanceName, "IsComponentParameter", true );
end 
end 

function nonCellResistanceParameters = getNonCellResistanceParameters( module )

nonCellResistanceParameters = simscape.battery.builder.internal.export.ComponentParameters(  );
if module.NonCellResistance == "Yes"
labelName = string( getString( message( 'physmod:battery:builder:blocks:NonCellResistanceName' ), matlab.internal.i18n.locale( 'en_US' ) ) );
sectionName = string( getString( message( 'physmod:battery:builder:blocks:ModuleSectionName' ), matlab.internal.i18n.locale( 'en_US' ) ) );
nonCellResistanceParameters = nonCellResistanceParameters.addParameters( "NonCellElectricalResistance", labelName, "1/1000", "Ohm", sectionName, "1" );
elseif module.ParallelAssembly.NonCellResistance == "Yes" && ( module.ModelResolution == "Lumped" || module.ModelResolution == "Grouped" )
labelName = string( getString( message( 'physmod:battery:builder:blocks:NonCellResistanceParallelAssemblyName' ), matlab.internal.i18n.locale( 'en_US' ) ) );
sectionName = string( getString( message( 'physmod:battery:builder:blocks:ParallelAssemblySectionName' ), matlab.internal.i18n.locale( 'en_US' ) ) );
nonCellResistanceParameters = nonCellResistanceParameters.addParameters( "NonCellResistanceParallelAssembly", labelName, "1/1000", "Ohm", sectionName, "1" );
else 

end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpC0WcW0.p.
% Please follow local copyright laws when handling this file.

