function runCleanup(obj,simInput,simOut,useSimInArrayFeature)







    modelsAlreadyLoaded=find_system('type','block_diagram');

    cleanupScript=simInput.CleanupScript;
    if~isempty(simInput.TestIteration.TestParameter.CleanupScript)
        cleanupScript=simInput.TestIteration.TestParameter.CleanupScript;
    end

    if~isempty(cleanupScript)
        try


            msg=stm.internal.MRT.share.getString(('stm:general:RunCleanupScript'));
            if~isempty(simInput.IterationName)
                msg=[simInput.IterationName,newline,msg];
            end

            obj.updateTestCaseSpinnerLabel(simInput.TestCaseId,msg);
            stm.internal.util.RestoreVariable({'sltest_simout','sltest_out_runid'});
            assignin('base','sltest_simout',simOut);
            assignin('base','sltest_out_runid',obj.out.RunID);
            stm.internal.MRT.share.evaluateScript('','','',cleanupScript,...
            simInput.TestCaseId,'','','','','','','','','',...
            simInput.IterationName,obj.runningOnMRT);
        catch me
            scr=stm.internal.MRT.share.getString(('stm:general:CleanupCallback'));
            msg=stm.internal.MRT.share.getString('stm:general:ScriptError',scr);
            obj.addMessages({msg},{true});
            rethrow(me);
        end
    end

    modelsCurrentlyLoaded=find_system('type','block_diagram');
    if(useSimInArrayFeature)
        modelsClosedByCleanup=setdiff(modelsAlreadyLoaded,modelsCurrentlyLoaded);
        obj.modelsClosedByCleanup=modelsClosedByCleanup;
        cellfun(@(x)loadClosedModel(simInput,x,obj.modelConfigSet),modelsClosedByCleanup);
    end
end

function loadClosedModel(simInput,model,currConfigSet)
    if~isempty(simInput.HarnessName)
        ind=strfind(simInput.HarnessName,'%%%');
        harnessName=simInput.HarnessName(1:ind(1)-1);
        if isequal(model,harnessName)
            ownerName=simInput.HarnessName(ind(1)+3:end);
            stm.internal.util.loadHarness(ownerName,harnessName);
            restoreConfigSet(harnessName,currConfigSet)
        end
    else
        if isequal(model,simInput.Model)
            load_system(model);
            restoreConfigSet(model,currConfigSet);
        end
    end
end

function restoreConfigSet(model,currConfigSet)
    if isa(currConfigSet,'Simulink.ConfigSetRef')
        refConfSet=getRefConfigSet(currConfigSet);
        copiedConfigSet=copy(refConfSet);
        attachConfigSet(model,copiedConfigSet,true);
        copiedConfigSetName=copiedConfigSet.Name;
        setActiveConfigSet(model,copiedConfigSetName);
    end
end
