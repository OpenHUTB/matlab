function resultJSON=sync(appID,json,isDirty)







    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',jsonencode('sync'));
    resultJSON=jsonencode(result);
end