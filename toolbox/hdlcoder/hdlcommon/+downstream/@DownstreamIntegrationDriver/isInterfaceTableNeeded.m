function isa=isInterfaceTableNeeded(obj)






    isa=obj.isIPWorkflow||obj.isTurnkeyWorkflow||obj.isXPCWorkflow||obj.isDynamicWorkflow;
end
