function postSimulationCallback( mdlName, isModelRef, varargin )%#ok<INUSL>




if ~isModelRef
soc.internal.cleanUpInternalDataCachingFiles;
end 

id = 'SimulinkDiscreteEvent:MatlabEventSystem:DefaultOutputConnection';
prefName = [ 'Warnings', strrep( id, ':', '' ) ];
prefName = prefName( 1:63 );
warningStateAtStart = soc.internal.getPreference( prefName );

if ~isModelRef && ismember( warningStateAtStart, { 'on', 'off' } )
warning( warningStateAtStart, id );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQElUfO.p.
% Please follow local copyright laws when handling this file.

