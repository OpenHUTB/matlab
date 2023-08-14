function result=checkInvalidChecks()

    config=ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.getCompletecuiCellArray;

    checkList=config;
    hasInValidChecks=false;
    for i=1:length(checkList)
        if(checkList{i}.MACIndex<0)
            hasInValidChecks=true;
            result=struct('hasInValidChecks',hasInValidChecks);
            return;
        end
    end

    result=struct('hasInValidChecks',hasInValidChecks);
end


