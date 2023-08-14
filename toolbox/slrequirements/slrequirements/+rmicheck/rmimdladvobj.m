function result=rmimdladvobj(obj,idx)


    decoded=modeladvisorprivate('HTMLjsencode',obj,'decode');
    result=rmisl.blockTable(decoded,'handle',idx);
end
