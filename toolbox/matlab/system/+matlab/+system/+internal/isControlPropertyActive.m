function flag=isControlPropertyActive(obj,sourceSetPropName)





    for name=sourceSetPropName(:)'
        policy=getPolicy(obj.(name),obj.getExecPlatformIndex());
        flag=policy.isControlPropertyActive(obj);

        if flag

            return
        end
    end
end
