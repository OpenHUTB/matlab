function result = harvestRebuildReasons( varargin )























h = Simulink.ModelReference.internal.RebuildReasonHarvestor( varargin{ : } );
h.harvest(  );
result = h.getTable(  );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpaVHn8K.p.
% Please follow local copyright laws when handling this file.

