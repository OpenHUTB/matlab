function ret=removeModelPartitionsFixitPorts(block)










    ret=set_param_action(block,'ScheduleRates','on',...
    'ScheduleRatesWith','Ports');

end
