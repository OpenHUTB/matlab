function maCheck=filterResultWithJustifications(model,maCheck)










    filterManager=slcheck.getAdvisorJustificationManager(model);


    if filterManager.isCheckJustified(maCheck.ID,maCheck.ID)

        maCheck.justify(true);
    else
        for idx=1:numel(maCheck.ResultDetails)
            if(filterManager.isCheckJustified(...
                maCheck.ResultDetails(idx).getHash(),...
                maCheck.ID))
                maCheck.ResultDetails(idx).setViolationStatus(ModelAdvisor.CheckStatus.Justified);
            end
        end
        if~isempty(maCheck.ResultDetails)&&all([maCheck.ResultDetails(:).getViolationStatus]==ModelAdvisor.CheckStatus.Justified)
            maCheck.justify(true);
        end
    end


end
