function res=isInCodePerspective(modelName)
    modelH=get_param(modelName,'Handle');
    cp=simulinkcoder.internal.CodePerspective.getInstance;
    res=cp.isInPerspective(modelH);
end
