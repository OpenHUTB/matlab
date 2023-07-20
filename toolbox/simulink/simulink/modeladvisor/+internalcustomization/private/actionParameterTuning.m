function result=actionParameterTuning(taskobj)



    mdladvObj=taskobj.MAObj;

    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
    actions=currentCheckObj.ResultData.SampleTimeActions;

    for actionIdx=1:length(actions)
        eval(actions{actionIdx});
    end

    result=currentCheckObj.ResultData.SampleTimeResults;
