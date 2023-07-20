function unjustifyViolation(model,resultDetail)

    manager=slcheck.getAdvisorJustificationManager(model);

    if~manager.isCheckJustified(num2str(resultDetail.getHash()),...
        resultDetail.CheckID)
        return;
    end

    resultDetail.resetViolationStatus;
    manager.removeAnnotation(num2str(resultDetail.getHash()));
    if resultDetail.Type==ModelAdvisor.ResultDetailType.SID...
        ||resultDetail.Type==ModelAdvisor.ResultDetailType.Signal
        edittime.util.runEditTimeChecksOnBlock(model,resultDetail.data);
    end
end