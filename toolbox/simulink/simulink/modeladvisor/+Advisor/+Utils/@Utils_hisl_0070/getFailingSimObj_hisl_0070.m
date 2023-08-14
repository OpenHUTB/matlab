function failObj=getFailingSimObj_hisl_0070(slBlock,opts)

    failObj={};
    if~iscell(slBlock)
        slBlock={slBlock};
    end
    for k=1:length(slBlock)



        if~Advisor.Utils.isSFChart(slBlock{k}.Handle)&&(~Advisor.Utils.Utils_hisl_0070.hasReqs(slBlock{k},opts)&&~Advisor.Utils.Utils_hisl_0070.isObjExcluded_hisl_0070(slBlock{k},opts))
            failObj=[failObj;slBlock(k)];
        end
    end
end

