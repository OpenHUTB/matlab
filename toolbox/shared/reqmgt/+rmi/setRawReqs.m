function setRawReqs(objH,isSf,reqStr,modelH)



    if isSf
        sf('set',objH,'.requirementInfo',reqStr);
    else
        set_param(objH,'requirementInfo',reqStr);
    end


    if nargin<4
        modelH=getDiagramHandle(objH,isSf);
    end
    if~rmisl.isComponentHarness(modelH)




        harnessInfo=Simulink.harness.internal.getActiveHarness(modelH);
        if~isempty(harnessInfo)
            if isSf
                sfRt=sfroot;
                obj=sfRt.idToHandle(objH);
            else
                obj=get_param(objH,'Object');
            end
            sidInHarness=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(obj);
            if isempty(sidInHarness)
                return;
            end
            objInHarness=Simulink.ID.getHandle(sidInHarness);
            if isSf
                sf('set',objInHarness.Id,'.requirementInfo',reqStr);
            else
                set_param(objInHarness,'requirementInfo',reqStr);
            end
        end
    end
end

function modelH=getDiagramHandle(objH,isSf)
    if isSf
        sfRt=sfroot;
        sfObj=sfRt.idToHandle(objH);
        if isa(sfObj,'Stateflow.Chart')||isa(sfObj,'Stateflow.EMChart')
            sfH=get_param(sfObj.Path,'Handle');
        else
            sfH=get_param(sfObj.Chart.Path,'Handle');
        end
        modelH=bdroot(sfH);
    else
        modelH=bdroot(objH);
    end
end
