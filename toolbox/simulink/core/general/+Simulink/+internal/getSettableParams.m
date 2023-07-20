function paramNames=getSettableParams(slObj)







    params=get_param(slObj,'ObjectParameters');
    paramNames=fieldnames(params);


    settableParamsIdx=structfun(@(x)~any(strcmp('read-only',x.Attributes)),params);
    paramNames=paramNames(settableParamsIdx);
end