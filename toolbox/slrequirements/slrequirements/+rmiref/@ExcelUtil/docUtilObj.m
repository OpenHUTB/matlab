function docUtil=docUtilObj(docPath)



    persistent docUtilObjects
    if isempty(docUtilObjects)
        docUtilObjects=containers.Map('KeyType','char','ValueType','any');
    end

    if isKey(docUtilObjects,docPath)
        docUtil=docUtilObjects(docPath);
        docUtil.validate();
    else
        docUtil=rmiref.ExcelUtil(docPath);
        docUtilObjects(docPath)=docUtil;
    end
end
