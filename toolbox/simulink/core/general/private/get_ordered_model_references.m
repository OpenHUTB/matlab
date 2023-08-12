function [ oStruct, parBInfo, protOStruct, allOutputStruct ] = get_ordered_model_references ...
( iMdl, iAllMdlref, varargin )



















numOutputs = nargout;
orderedModelRef = Simulink.ModelReference.internal.OrderedModelRefs(  );
[ oStruct, parBInfo, protOStruct, allOutputStruct ] =  ...
orderedModelRef.getOrderedModelRefs ...
( iMdl, iAllMdlref, numOutputs, varargin{ : } );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRLHwf7.p.
% Please follow local copyright laws when handling this file.

