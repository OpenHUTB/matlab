function [ mode, opts ] = getAdapterMode( blkHdl )




modeEnum = systemcomposer.internal.adapter.ModeEnums;
mode = modeEnum.None;
opts = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
component = systemcomposer.utils.getArchitecturePeer( blkHdl );
if isempty( component )
return ;
end 
adaptDefn = component.p_Adaptation;
if ~isempty( adaptDefn )
adapts = adaptDefn.p_Adaptations;
if adapts.Size == uint64( 1 )
adaptObj = adapts.toArray(  );
if isa( adaptObj, 'systemcomposer.architecture.model.design.ZeroOrderHoldAdaptation' )
mode = modeEnum.UnitDelay;
elseif isa( adaptObj, 'systemcomposer.architecture.model.design.RateTransitionAdaptation' )
mode = modeEnum.RateTransition;
opts( 'Integrity' ) = adaptObj.ensureIntegrity;
opts( 'Deterministic' ) = adaptObj.ensureDeterministic;
opts( 'InitialConditions' ) = adaptObj.initialValue;
elseif isa( adaptObj, 'systemcomposer.architecture.model.design.MergeAdaptation' )
mode = modeEnum.Merge;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpasFtbo.p.
% Please follow local copyright laws when handling this file.

