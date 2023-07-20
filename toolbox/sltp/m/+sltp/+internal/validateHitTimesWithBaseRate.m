function validateHitTimesWithBaseRate(serializedHitTimes,modelHandle,baseRate)




    assert(isa(baseRate,'double'));
    assert(~isnan(baseRate));


    for i=1:length(serializedHitTimes)

        hitTimes=serializedHitTimes{i}.Time;







        integerMultipleRemainders=mod(hitTimes,baseRate);
        integerMultipleRemainders=...
        min(integerMultipleRemainders,baseRate-integerMultipleRemainders);

        if any(integerMultipleRemainders>128*eps())

            partitionLink=message(...
            'SimulinkPartitioning:General:PartitionLink',...
            get_param(modelHandle,'Name'),serializedHitTimes{i}.SignalName).getString;

            ME=MSLException([],message('SimulinkPartitioning:General:InvalidHitTimes',...
            partitionLink));
            ME=ME.addCause(MSLException([],message(...
            'SimulinkPartitioning:General:InvalidHitTimesBaseRate',...
            num2str(baseRate))));
            throw(ME);
        end
    end

end
