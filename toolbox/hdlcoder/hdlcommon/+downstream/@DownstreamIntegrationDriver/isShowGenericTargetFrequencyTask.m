function result=isShowGenericTargetFrequencyTask(obj)





















    result=obj.isShowTargetFrequencyTask&&...
    (obj.isGenericWorkflow||(obj.isIPCoreGen&&~obj.showEmbeddedTasks));

end