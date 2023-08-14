function[modelLoaded,groupnames]=getSignalBuilderGroups(model,testHarness)


    groupnames='';
    modelLoaded=true;
    wstate=warning('off','all');
    wCleanup=onCleanup(@()warning(wstate));

    models=find_system('type','block_diagram');
    if~isempty(setdiff(model,models))
        modelLoaded=false;
        load_system(model);
    end

    if~isempty(testHarness)
        harness=Simulink.harness.find(model,'Name',testHarness);

        if~harness.isOpen


            stm.internal.util.loadHarness(harness.ownerFullPath,...
            harness.name);
            hCleanup=onCleanup(@()close_system(harness.name,0));
        end
        harnessH=get_param(harness.name,'Handle');
        sigbH=sigbuild_handle(harnessH);
    else
        modelH=get_param(model,'Handle');
        sigbH=sigbuild_handle(modelH);
    end

    if~isempty(sigbH)
        [~,~,~,groupnames]=signalbuilder(sigbH);
    end

end


function sigbH=sigbuild_handle(modelH)
    sigbH=find_system(modelH,...
    'SearchDepth',1,...
    'LoadFullyIfNeeded','off',...
    'FollowLinks','off',...
    'LookUnderMasks','all',...
    'BlockType','SubSystem',...
    'PreSaveFcn','sigbuilder_block(''preSave'');');
    if isempty(sigbH)||length(sigbH)~=1
        sigbH=[];
    end
end

