function me=runPostload(obj,simInput,simWatcher)


    me=[];
    postLoadScript=simInput.PostLoadScript;
    if~isempty(simInput.TestIteration.TestParameter.PostLoadScript)
        postLoadScript=simInput.TestIteration.TestParameter.PostLoadScript;
    end

    if~isempty(postLoadScript)

        try













            msg=stm.internal.MRT.share.getString(('stm:general:EvalPostLoadCallBack'));
            if~isempty(simInput.IterationName)
                msg=[simInput.IterationName,newline,msg];
            end
            obj.updateTestCaseSpinnerLabel(simInput.TestCaseId,msg);
            sltest_isharness=false;
            if~strcmp(simWatcher.modelToRun,simInput.Model)

                sltest_isharness=true;
                sltest_bdroot=simWatcher.harnessName;
                sltest_sut=simWatcher.ownerName;
            else

                sltest_bdroot=simWatcher.modelToRun;
                sltest_sut=simWatcher.modelToRun;
            end
            stm.internal.MRT.share.evaluateScript(sltest_bdroot,...
            sltest_sut,sltest_isharness,postLoadScript,...
            simInput.TestCaseId,'','','','','','','','','',...
            simInput.IterationName,obj.runningOnMRT);
        catch me
            scr=stm.internal.MRT.share.getString(('stm:general:PostloadCallback'));
            msg=stm.internal.MRT.share.getString('stm:general:ScriptError',scr);
            obj.addMessages({msg},{true});
            rethrow(me);
        end
    end
end
