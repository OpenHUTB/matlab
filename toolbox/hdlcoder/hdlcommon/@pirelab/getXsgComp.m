function xsgComp = getXsgComp( hN, name, inputSignals, outputSignals,  ...
entityName, inportNames, outportNames, clkNames, ceNames, ceclrNames,  ...
rates, baseRate, hasDownSample, blackBoxAttributes, vhdlComponentLibrary,  ...
slbh )




assert( nargin >= 13, 'No enough arguments are given to create Xsg comp' );

if nargin < 16
slbh =  - 1;
end 

if nargin < 15
vhdlComponentLibrary = '';
end 

if nargin < 14
blackBoxAttributes = false;
end 

xsgComp = pircore.getXsgComp( hN, name, inputSignals, outputSignals,  ...
entityName, inportNames, outportNames, clkNames, ceNames, ceclrNames,  ...
rates, baseRate, hasDownSample, blackBoxAttributes, vhdlComponentLibrary,  ...
slbh );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZyTOQd.p.
% Please follow local copyright laws when handling this file.

