function v = validateComplexTypesForTargetCodeGen( ~, hC )



v = hdlvalidatestruct;
if isempty( hC.PirInputPorts ) || isempty( hC.PirOutputPorts )
return ;
end 
if targetcodegen.targetCodeGenerationUtils.isFloatingPointMode(  ) &&  ...
~targetcodegen.targetCodeGenerationUtils.isNFPMode(  )
in = hC.PirInputPorts( 1 ).Signal;
out = hC.PirOutputPorts( 1 ).Signal;
if ( ( targetmapping.hasComplexType( in.Type ) && targetmapping.mode( in ) ) ...
 || ( targetmapping.hasComplexType( out.Type ) && targetmapping.mode( out ) ) )
v = hdlvalidatestruct( 1, message( 'hdlcoder:validate:ComplexTypeUnsupported' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnv2DFX.p.
% Please follow local copyright laws when handling this file.

