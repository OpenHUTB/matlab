function flag=isTargetPropertyActive(obj,sourceSetPropName,propName)




    assert(isscalar(sourceSetPropName));
    policy=getPolicy(obj.(sourceSetPropName),obj.getExecPlatformIndex());
    flag=policy.isTargetPropertyActive(obj,propName);
end
