function num=numMethodOutputs(obj,methodName)






    metaMethod=matlab.system.internal.getMetaMethod(obj,methodName);

    num=numel(metaMethod.OutputNames);
    if(num>0)&&(metaMethod.OutputNames{end}=="varargout")
        num=-num;
    end
end
