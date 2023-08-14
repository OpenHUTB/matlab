function result=exists()






    instance=slreq.data.ReqData.getInstance(false);
    result=~isempty(instance);
end
