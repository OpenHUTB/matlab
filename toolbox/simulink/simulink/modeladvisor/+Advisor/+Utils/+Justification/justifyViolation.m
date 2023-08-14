function justifyViolation(model,resultDetail,comment,id)




    manager=slcheck.getAdvisorJustificationManager(model);
    manager.justifyViolation(num2str(resultDetail.getHash()),comment,id);
    resultDetail.setViolationStatus(ModelAdvisor.CheckStatus.Justified);


    if resultDetail.Type==ModelAdvisor.ResultDetailType.SID...
        ||resultDetail.Type==ModelAdvisor.ResultDetailType.Signal
        edittime.util.runEditTimeChecksOnBlock(model,resultDetail.data)
    end
end
