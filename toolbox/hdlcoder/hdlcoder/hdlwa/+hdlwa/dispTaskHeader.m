function dispTaskHeader(taskID,verbosity)

    taskName=message(taskID).getString;
    msg=message('hdlcommon:workflow:WorkflowStage',taskName).getString;
    hdldisp(['++++++++++++++ ',msg,' ++++++++++++++']);

    if verbosity>0
        hdlDispWithTimeStamp(taskName,verbosity);
    end
end