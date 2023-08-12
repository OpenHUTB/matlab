function [ bool ] = isSimulinkSignalClass( className )








validNames = {  ...
'double';
'single';
'int';
'int8';
'int16';
'int32';
'int64';
'uint';
'uint8';
'uint16';
'uint32';
'uint64';
'embedded.fi';
'Simulink.SimulationData.Dataset';
'Simulink.SimulationData.Signal';
'struct';
'Simulink.TsArray';
'timeseries';
'Simulink.Timeseries';
'char';
 };



bool = ismember( className, validNames );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpwnx8qJ.p.
% Please follow local copyright laws when handling this file.

