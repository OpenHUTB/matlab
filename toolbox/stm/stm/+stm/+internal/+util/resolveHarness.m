function[modelToUse,deactivateHarness,currHarness,oldHarness,description,wasHarnessOpen]=resolveHarness(model,harnessName,varargin)










    shouldOpen=false;
    if nargin==3
        shouldOpen=true;
    end


    if(shouldOpen)
        open_system(model);
    else
        load_system(model);
    end

    harnessStr=harnessName;
    modelToUse=model;
    ind=strfind(harnessStr,'%%%');
    deactivateHarness=false;
    currHarness=[];
    oldHarness=[];
    description='';
    wasHarnessOpen=false;

    useMultipleHarnessOpen=0;
    try
        useMultipleHarnessOpen=stm.internal.util.getFeatureFlag('MultipleHarnessOpen');
    catch me
        if~(isequal(me.identifier,'sl_feature:utils:InvCallForFeatureName')||...
            isequal(me.identifier,'Simulink:Engine:InvCallForFeatureName'))
            rethrow(me);
        end
    end

    if isempty(ind)

        if strcmp(get_param(modelToUse,'lock'),'on')&&...
            useMultipleHarnessOpen==0

            harnessList=Simulink.harness.find(modelToUse,'OpenOnly','on');
            if~isempty(harnessList)
                oldHarness=harnessList(1);
                wasHarnessOpen=strcmp('on',get_param(oldHarness.name,'Open'));

                Simulink.harness.close(oldHarness.ownerFullPath,oldHarness.name);
            end
        end
        return
    elseif~isempty(ind)&&~isequal(ind,1)
        harnessName=harnessStr(1:ind(1)-1);
        ownerName=harnessStr(ind(1)+3:end);
        modelToUse=harnessName;


        hInd=strfind(ownerName,model);
        if(isempty(hInd)||hInd(1)~=1)
            error(message('stm:general:HarnessDoesNotExist',harnessName,ownerName,model));
        end


        load_system(model);
        if useMultipleHarnessOpen>0
            if~bdIsLoaded(harnessName)
                loadHarness(ownerName,harnessName,shouldOpen);
            end
        else
            harnessList=Simulink.harness.find(model,'OpenOnly','on');

            if~isempty(harnessList)
                oldHarness=harnessList(1);
                if~(strcmp(ownerName,oldHarness.ownerFullPath)&&strcmp(harnessName,oldHarness.name))

                    deactivateHarness=true;
                    wasHarnessOpen=strcmp('on',get_param(oldHarness.name,'Open'));

                    Simulink.harness.close(oldHarness.ownerFullPath,oldHarness.name);

                    loadHarness(ownerName,harnessName,shouldOpen);
                else

                    try
                        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(harnessName);
                        description=harnessInfo.description;
                    catch
                    end

                    if shouldOpen

                        loadHarness(ownerName,harnessName,shouldOpen);

                        open_system(harnessName);
                    end

                    return;
                end
            else
                loadHarness(ownerName,harnessName,shouldOpen);
            end
        end

        try

            harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(harnessName);
            description=harnessInfo.description;
        catch


        end
        harnessList=Simulink.harness.find(model,'Name',harnessName,'OpenOnly','on');

        if(~isempty(harnessList))
            currHarness=harnessList(1);
        end
    end
end

function loadHarness(ownerName,harnessName,shouldOpen)
    stm.internal.util.loadHarness(ownerName,harnessName,shouldOpen);
end

