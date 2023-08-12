classdef MathTargetLibrary < hdlimplbase.EmlImplBase



methods 
function this = MathTargetLibrary( block )
supportedBlocks = {  ...
'built-in/Math',  ...
 };

if nargin == 0
block = '';
end 

this.init( 'SupportedBlocks', supportedBlocks,  ...
'Block', block,  ...
'ArchitectureNames', 'MathTargetLib',  ...
'Hidden', true );

end 

end 

methods 
hNewC = elaborate( this, hN, blockComp )
stateInfo = getStateInfo( this, hC )
registerImplParamInfo( this )
end 


methods ( Hidden )
v_settings = block_validate_settings( this, hC )
hNewC = conjDetailedImpl( ~, hN, blockComp, hInSignals, hOutSignals, outSigType )
hNewC = hypotDetailedImpl( ~, hN, blockComp, hInSignals, hOutSignals, nfpOptions, outSigType )
hNewC = magnitude2DetailedImpl( ~, hN, blockComp, hInSignals, hOutSignals, nfpOptions, outSigType )
hNewC = squareDetailedImpl( ~, hN, blockComp, hInSignals, hOutSignals, nfpOptions, outSigType )
v = validateBlock( this, hC )
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp0NIolH.p.
% Please follow local copyright laws when handling this file.

