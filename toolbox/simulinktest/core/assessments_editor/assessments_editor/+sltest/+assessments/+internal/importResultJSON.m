function[resultJSON,result,outcome]=importResultJSON(result,resultJSON)
    resultStruct=jsondecode(resultJSON);
    outcome=1;
    if strcmp(resultStruct.type,'result')

        resultStruct=result.getSDITree();
        resultStruct.type='result';
        resultJSON=jsonencode(resultStruct);
        outcome=resultStruct.assessmentResult;
    end
end