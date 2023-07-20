
function edittimeConfiguration=createJSONfromStruct(edittimeCheckData)





    jsonData.Tree=edittimeCheckData;
    edittimeConfiguration=jsonencode(jsonData,'PrettyPrint',true);


end
