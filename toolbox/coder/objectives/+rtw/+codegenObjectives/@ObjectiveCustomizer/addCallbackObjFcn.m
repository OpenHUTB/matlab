


function idx=addCallbackObjFcn(obj,func)
    if~(obj.initialized)
        obj.initialize();
    end

    if isempty(obj.callbackFcn)
        obj.callbackFcn{end+1}=func;
        idx=length(obj.callbackFcn);
    else
        obj.callbackFcn{1}=[];
        idx=[];
        args{1}='multipleSLCustomizationFiles';
        rtw.codegenObjectives.ObjectiveCustomizer.throwError(args);
    end
end
