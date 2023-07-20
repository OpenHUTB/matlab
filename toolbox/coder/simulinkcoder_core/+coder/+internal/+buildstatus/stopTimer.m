function stopTimer(topMdl)








    msg.option='ctrlTotalElapsedTimer';
    msg.control='stopTimer';






    targetType={'SIM','RTW'};
    for k=1:length(targetType)
        poolUsageChannel=['/BuildStatusUI/',topMdl,'/',targetType{k},'/poolUsage'];
        message.publish(poolUsageChannel,msg);
    end

end