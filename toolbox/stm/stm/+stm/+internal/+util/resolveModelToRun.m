function[modelToRun,deactivateHarness,currHarness,oldHarness,wasHarnessOpen,harnessName,ownerName,componentUnderTest]=...
    resolveModelToRun(Model,HarnessName)

    modelToRun=Model;
    harnessStr=HarnessName;
    ind=strfind(harnessStr,'%%%');
    deactivateHarness=false;
    currHarness=[];
    oldHarness=[];
    wasHarnessOpen=false;
    harnessName='';
    ownerName='';
    componentUnderTest='';

    useMultipleHarnessOpen=0;
    try
        useMultipleHarnessOpen=slfeature('MultipleHarnessOpen');
    catch me
        if~(isequal(me.identifier,'sl_feature:utils:InvCallForFeatureName')||...
            isequal(me.identifier,'Simulink:Engine:InvCallForFeatureName'))
            rethrow(me);
        end
    end

    if isempty(ind)



        if strcmp(get_param(modelToRun,'lock'),'on')&&...
            useMultipleHarnessOpen==0
            harnessList=Simulink.harness.find(modelToRun,'OpenOnly','on');
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


        strToFind=[Model,'/'];
        index=strfind(ownerName,strToFind);
        isTopModelOwner=false;
        if isempty(index)

            isTopModelOwner=strcmp(ownerName,Model);
        else



            index=index(1);
        end



        if~isTopModelOwner&&(isempty(index)||index~=1)
            error(message('stm:general:CouldNotFindHarness',harnessName,modelToRun));
        end

        modelToRun=harnessName;

        if useMultipleHarnessOpen>0
            if~bdIsLoaded(modelToRun)
                stm.internal.util.loadHarness(ownerName,harnessName);
            end
        else

            harnessList=Simulink.harness.find(Model,'OpenOnly','on');

            if~isempty(harnessList)
                oldHarness=harnessList(1);
                if~(strcmp(ownerName,oldHarness.ownerFullPath)&&strcmp(harnessName,oldHarness.name))

                    deactivateHarness=true;
                    wasHarnessOpen=strcmp('on',get_param(oldHarness.name,'Open'));
                    Simulink.harness.close(oldHarness.ownerFullPath,oldHarness.name);

                    stm.internal.util.loadHarness(ownerName,harnessName);
                else

                    componentUnderTest=getComponentUnderTest(oldHarness);
                    return;
                end
            else
                stm.internal.util.loadHarness(ownerName,harnessName);
            end
        end

        currHarness=Simulink.harness.find(Model,'Name',modelToRun);
        componentUnderTest=getComponentUnderTest(currHarness);
    end
end


function componentUnderTest=getComponentUnderTest(currHarness)


    componentUnderTest='';

    harnessCUT=Simulink.ID.getFullName([currHarness.name,':1']);

    if(strcmp(get_param(harnessCUT,'BlockType'),'ModelReference'))
        componentUnderTest=harnessCUT;
    end
end
