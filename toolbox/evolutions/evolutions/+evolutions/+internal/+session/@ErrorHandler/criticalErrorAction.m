function criticalErrorAction(~,~,data)






    pm=evolutions.internal.project.ProjectManager.get;
    pm.refreshEti(data.EventData.Eti);

    evolutions.internal.session.EventHandler.publish('RefreshClients',data);
end
