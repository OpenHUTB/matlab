function addParameterSystemObject(obj)





    params=ssm.sl_agent_metadata.internal.utils.getSystemObjectParameterInfo(obj.ModelName);


    obj.bhaviorInfo.parameters=params;
end


