function setAdapterMode( blkHdl, mode, opts )




modeEnum = systemcomposer.internal.adapter.ModeEnums;
component = systemcomposer.utils.getArchitecturePeer( blkHdl );
if isempty( component )
return ;
end 
assert( component.isAdapterComponent );



assert( ~component.getParentArchitecture(  ).isSoftwareArchitecture(  ) || strcmpi( mode, modeEnum.None ) ||  ...
strcmpi( mode, modeEnum.Merge ) || isempty( mode ),  ...
'The adapter mode must be ''None'' or ''Merge'' in software architectures' );

adaptDefn = component.p_Adaptation;

mdl = mf.zero.getModel( component );
txn = mdl.beginTransaction(  );

if isempty( adaptDefn )
adaptDefn = component.initAdaptationDefinition(  );
end 

if strcmpi( mode, modeEnum.UnitDelay )

adaptDefn.clearAdaptations(  );
adapt = systemcomposer.architecture.model.design.ZeroOrderHoldAdaptation( mdl );
adaptDefn.addAdaptation( adapt );

elseif strcmpi( mode, modeEnum.RateTransition )

adaptDefn.clearAdaptations(  );
adapt = systemcomposer.architecture.model.design.RateTransitionAdaptation( mdl );
if isempty( opts )

adapt.ensureIntegrity = true;
adapt.ensureDeterministic = false;
adapt.initialValue = '0';
else 
adapt.ensureIntegrity = opts( 'Integrity' );
adapt.ensureDeterministic = opts( 'Deterministic' );
adapt.initialValue = opts( 'InitialConditions' );
end 
adaptDefn.addAdaptation( adapt );
elseif strcmpi( mode, modeEnum.Merge )
adaptDefn.clearAdaptations(  );
adapt = systemcomposer.architecture.model.design.MergeAdaptation( mdl );
adaptDefn.addAdaptation( adapt );
else 

adaptDefn.clearAdaptations(  );


end 

txn.commit(  );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWUy2la.p.
% Please follow local copyright laws when handling this file.

