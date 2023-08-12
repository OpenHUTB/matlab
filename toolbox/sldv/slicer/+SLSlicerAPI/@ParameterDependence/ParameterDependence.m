classdef ParameterDependence < handle
















































properties ( Access = private )
debugService;
end 

properties ( Dependent = true )
slicerObject;
end 

methods 
function obj = ParameterDependence( model, parametersToConsider )
R36
model( 1, : )


parametersToConsider( :, : ) = [  ]
end 
if ~isSlicerInstalledAndLicensed
error( 'Sldv:ModelSlicer:ModelSlicer:NotLicensed', getString( message( 'Sldv:ModelSlicer:ModelSlicer:NotLicensed' ) ) )
end 


obj.debugService = SlicerApplication.SimParam.DebugService( model, parametersToConsider );
end 

function val = get.slicerObject( obj )
val = obj.debugService.slicerObj;
end 

function [ affectedBlocksH, slicerObj ] = blocksAffectedByParameter( obj, varUsage, varargin )


import SlicerApplication.utils.getAffectedBlocksFromSlicerStartingPoints;
if ~isscalar( varUsage )


error( 'Sldv:DebugUsingSlicer:ScalarValueRequiredForVariableUsage', getString( message( 'Sldv:DebugUsingSlicer:ScalarValueRequiredForVariableUsage' ) ) );
end 
obj.debugService.checkValidityOfSlicerObj(  );


includeIndirect = true;

blockList = obj.getBlocksUsingParameter( varUsage, 'IncludeIndirect', includeIndirect );


[ affectedBlocks, slicerObj ] = getAffectedBlocksFromSlicerStartingPoints( obj.debugService.model,  ...
blockList, obj.debugService.slicerObj, varargin{ : } );

affectedBlocksH = get_param( affectedBlocks, 'handle' );
if iscell( affectedBlocksH )
affectedBlocksH = [ affectedBlocksH{ : } ];
end 
end 

function [ varUsages, slicerObj ] = parametersAffectingBlock( obj, block, optional )


R36
obj( 1, 1 )SLSlicerAPI.ParameterDependence
block( 1, : )
optional.IncludeIndirect( 1, 1 )logical = true
end 
[ ~, dimCol ] = size( block );
if dimCol ~= 1 && ~ischar( block )





error( 'Sldv:DebugUsingSlicer:ScalarValueRequiredForBlocks', getString( message( 'Sldv:DebugUsingSlicer:ScalarValueRequiredForBlocks' ) ) );
end 
obj.debugService.checkValidityOfSlicerObj(  );


[ varUsages, slicerObj ] = obj.debugService.getParametersAffectingBlock( block, optional.IncludeIndirect );
end 
end 

methods ( Access = public, Hidden = true )
function users = getBlocksUsingParameter( obj, varUsage, optional )

R36
obj( 1, 1 )SLSlicerAPI.ParameterDependence
varUsage( 1, 1 )Simulink.VariableUsage
optional.IncludeIndirect( 1, 1 )logical = true
end 


users = obj.debugService.getStartingPointsForParam( varUsage, optional.IncludeIndirect );
end 

function addParametersToClassScope( obj, parameters )

R36
obj( 1, 1 )SLSlicerAPI.ParameterDependence
parameters( :, : )Simulink.VariableUsage
end 
obj.debugService.addParameterToClassScope( parameters );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLtJLMR.p.
% Please follow local copyright laws when handling this file.

