function usComp = getUpSampleComp( hN, hInSignal, hOutSignal, upSampleFactor, sampleOffset, initVal, compName, desc, slHandle )
















if nargin < 9
slHandle =  - 1;
end 

if nargin < 8
desc = '';
end 

if nargin < 7
compName = 'us';
end 

if nargin < 6
initVal = 0;
end 

usComp = pircore.getUpSampleComp( hN, hInSignal, hOutSignal, upSampleFactor, sampleOffset, initVal, compName, desc, slHandle );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSRUDaZ.p.
% Please follow local copyright laws when handling this file.

