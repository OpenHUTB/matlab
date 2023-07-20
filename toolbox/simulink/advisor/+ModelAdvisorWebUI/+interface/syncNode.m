function resultJSON=syncNode(modelId,nodeId,newValue)

    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',jsonencode("sync"));
    resultJSON=jsonencode(result);
end