function maddComp = getScalarMACComp( hN, hInSignals, hOutSignals, rndMode, ovMode, compName, desc, slbh,  ...
hwModeLatency, adderSign, nfpOptions, fused )



if nargin < 12
fused = false;
else 

if ~targetcodegen.targetCodeGenerationUtils.isNFPMode(  )
fused = false;
end 
end 

if nargin < 11
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
end 

if nargin < 10
adderSign = '++';
end 

if nargin < 9
hwModeLatency = 0;
end 


if nargin < 8
slbh =  - 1;
end 

if nargin < 7
desc = '';
end 

if nargin < 6
compName = 'multiply add';
end 

inSigs = pirelab.convertRowVecsToUnorderedVecs( hN, hInSignals );
maddComp = pircore.getScalarMACComp( hN, inSigs, hOutSignals,  ...
rndMode, ovMode,  ...
compName, desc, slbh, hwModeLatency, adderSign, nfpOptions, fused );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp8M40u0.p.
% Please follow local copyright laws when handling this file.

