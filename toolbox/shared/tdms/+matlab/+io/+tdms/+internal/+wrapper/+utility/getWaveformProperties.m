function [ PropertyNames, PropertyValues ] = getWaveformProperties( TT )


R36
TT timetable
end 
PropertyNames = [ "wf_start_time", "wf_start_offset", "wf_increment", "wf_samples" ];
PropertyValues = { TT.Properties.StartTime, 0, seconds( TT.Properties.TimeStep ), height( TT ) };
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpv_A13O.p.
% Please follow local copyright laws when handling this file.

