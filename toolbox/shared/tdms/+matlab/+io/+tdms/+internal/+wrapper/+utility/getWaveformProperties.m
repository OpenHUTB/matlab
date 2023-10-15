function [ PropertyNames, PropertyValues ] = getWaveformProperties( TT )

arguments
    TT timetable
end
PropertyNames = [ "wf_start_time", "wf_start_offset", "wf_increment", "wf_samples" ];
PropertyValues = { TT.Properties.StartTime, 0, seconds( TT.Properties.TimeStep ), height( TT ) };
end

