

function result=defaultActionCBforEdittimeCheck(taskobj)
    mdladvObj=taskobj.MAObj;
    checkObj=taskobj.Check;
    resultDetailObjs=checkObj.ResultDetails;
    edittimeObj=eval([checkObj.CallbackHandle,'(''',checkObj.ID,''')']);
    for i=1:numel(resultDetailObjs)
        edittimeObj.fix(resultDetailObjs(i));
    end
    result=ModelAdvisor.Text('Fix operation has been successfully completed.');
    mdladvObj.setActionEnable(false);

end