function result=exists()






    instance=slreq.app.MainManager.getInstance(false);
    result=~isempty(instance);
end
