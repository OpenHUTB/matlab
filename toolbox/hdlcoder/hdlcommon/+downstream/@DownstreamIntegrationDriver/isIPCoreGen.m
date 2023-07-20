function result=isIPCoreGen(obj)



    result=obj.isIPWorkflow||(obj.isSLRTWorkflow&&obj.isVivado);

end
