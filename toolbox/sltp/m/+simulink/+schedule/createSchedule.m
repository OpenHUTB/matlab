function out = createSchedule( scheduleIn, order, namedargs )

arguments
    scheduleIn( 1, 1 )simulink.schedule.OrderedSchedule
    order( :, 1 )string
    namedargs.IgnoreExtra( 1, 1 )logical = false
end

order = simulink.schedule.internal.validateNamesAgainst(  ...
    order, scheduleIn.Order.Partition, namedargs.IgnoreExtra );

out = scheduleIn;
out.Order.Index( order ) = ( 1:length( order ) )';
end
