function result=getValidUnitTests(ssbd)





    result={};
    harnessList=sltest.harness.find(ssbd);
    if isempty(harnessList)
        return;
    end
    unitTestNames=Simulink.SubsystemReference.getUnitTestNames(ssbd);
    if isempty(unitTestNames)
        return;
    end

    result=cell(1,length(harnessList));
    for ii=1:length(harnessList)
        if any(strcmp(unitTestNames,harnessList(ii).name))
            result(ii)={harnessList(ii).name};
        end
    end
    result=result(~cellfun('isempty',result));
end
