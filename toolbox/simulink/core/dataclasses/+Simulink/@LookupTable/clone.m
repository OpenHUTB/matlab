function clone(obj,cloneName)



    assert(isscalar(obj));
    origObj=[];
    try
        origObj=evalin('caller',cloneName);
    catch
    end


    if obj.CoderInfo.HasContext
        objCopy=slprivate('copyHelper',obj);
        assignin('caller',cloneName,objCopy);
        copyValue=evalin('caller',cloneName);
        if obj.CoderInfo.isContextEqual(copyValue.CoderInfo)
            obj.CoderInfo.copyCodeMappingProperties(cloneName);
        else

            if isempty(origObj)
                evalin('caller',['clear ',cloneName]);
            else
                assignin('caller',cloneName,origObj);
            end
            DAStudio.error('Simulink:Data:InvalidCloneOfMWSObject');
        end
    else
        copyObj=copy(obj);
        assignin('caller',cloneName,copyObj);
    end
end
