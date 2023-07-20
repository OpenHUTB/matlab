function me=runPreload(obj,simInput)


    me=[];
    preLoadScript=simInput.PreLoadScript;
    if~isempty(simInput.TestIteration.TestParameter.PreLoadScript)
        preLoadScript=simInput.TestIteration.TestParameter.PreLoadScript;
    end

    if~isempty(preLoadScript)
        try
            msg=stm.internal.MRT.share.getString(('stm:general:EvalPreLoadCallBack'));
            if~isempty(simInput.IterationName)
                msg=[simInput.IterationName,newline,msg];
            end
            obj.updateTestCaseSpinnerLabel(simInput.TestCaseId,msg);


            stm.internal.MRT.share.evaluateScript('','','',preLoadScript,...
            simInput.TestCaseId,'','','','','','','','','',simInput.IterationName,obj.runningOnMRT);
        catch me
            scr=stm.internal.MRT.share.getString(('stm:general:PreloadCallback'));
            msg=stm.internal.MRT.share.getString('stm:general:ScriptError',scr);
            obj.addMessages({msg},{true});
            rethrow(me);
        end
    end
end
