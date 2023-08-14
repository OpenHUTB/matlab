function Result=DefaultUndo(model,checkObj,text)




    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;
    Result=[text.emitHTML,lb];

    try
        mdlObj=get_param(model,'Object');
        MAObj=mdlObj.getModelAdvisorObj;
        restoreName=checkObj.getID;
        restoreObj=Advisor.Utils.LoadRestorePointForPerformanceAdvisor(MAObj,restoreName);
        restoreObj.load;
    catch E


        disp(E.message);
        rethrow(E);
    end
end
