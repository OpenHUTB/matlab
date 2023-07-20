function performAction(clientMsg)






    inputData=Simulink.stawebscope.servermanager.getTabularData(clientMsg.Item);

    execute=Simulink.stawebscope.servermanager.getActionExecutor(clientMsg.Action);

    editedData=execute(clientMsg.Data,inputData,clientMsg.Item);

    Simulink.stawebscope.servermanager.commitDataAndPublishToClient(clientMsg,editedData);

end

