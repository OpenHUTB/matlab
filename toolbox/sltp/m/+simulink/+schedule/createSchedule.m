function out = createSchedule( scheduleIn, order, namedargs )












R36
scheduleIn( 1, 1 )simulink.schedule.OrderedSchedule
order( :, 1 )string
namedargs.IgnoreExtra( 1, 1 )logical = false
end 

order = simulink.schedule.internal.validateNamesAgainst(  ...
order, scheduleIn.Order.Partition, namedargs.IgnoreExtra );

out = scheduleIn;
out.Order.Index( order ) = ( 1:length( order ) )';
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplYV8pm.p.
% Please follow local copyright laws when handling this file.

