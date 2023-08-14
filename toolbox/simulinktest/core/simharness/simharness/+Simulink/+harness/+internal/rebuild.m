function rebuild(harnessOwner,harnessName,varargin)




    try
        [systemModel,harness]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);
        functionInterfaceName=harness.functionInterfaceName;
        systemH=get_param(systemModel,'Handle');
        if(bdIsLibrary(systemModel)&&isempty(functionInterfaceName))||bdIsSubsystem(systemModel)
            DAStudio.error('Simulink:Harness:CannotRebuildLibHarness');
        end
    catch ME
        throwAsCaller(makeHarnessRebuildAbortedError(ME));
    end

    activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);

    if~isempty(activeHarness)&&slfeature('MultipleHarnessOpen')<1
        if~(any(strcmp({activeHarness.name},harness.name))&&...
            any(strcmp({activeHarness.ownerFullPath},harness.ownerFullPath)))
            errId='Simulink:Harness:CannotRebuildHarnessWhenAnotherHarnessIsActive';
            ME=MException(errId,'%s',...
            DAStudio.message(errId,harness.name,harness.ownerFullPath,activeHarness.name,activeHarness.ownerFullPath));
            throwAsCaller(makeHarnessRebuildAbortedError(ME));
        end
    end



    try
        Simulink.harness.internal.checkHarnessOwner(systemH,harness.name,harness.ownerHandle);
    catch ME
        throwAsCaller(makeHarnessRebuildAbortedError(ME));
    end


    p=inputParser;
    p.CaseSensitive=0;
    p.KeepUnmatched=0;
    p.PartialMatching=0;
    p.addParameter('RebuildModelData',harness.rebuildModelData,...
    @(x)validateattributes(x,{'logical'},{'nonempty'}));
    p.parse(varargin{:});

    cleanupUtilLib=onCleanup(@()Simulink.harness.internal.closeUtilLib());

    try
        if~isempty(functionInterfaceName)&&slfeature('RLSTestHarness')>0

            codeContext=Simulink.libcodegen.internal.getCodeContext(systemModel,harness.ownerHandle,functionInterfaceName);
            if isempty(codeContext)
                DAStudio.error('Simulink:CodeContext:CodeContextNotFound',functionInterfaceName,harness.ownerFullPath);
            end

            tempModel=[tempname,'.slx'];


            Simulink.libcodegen.internal.exportCodeContext(codeContext.ownerHandle,codeContext.name,'Name',tempModel);
            load_system(tempModel);
            [~,tempModelName,~]=fileparts(tempModel);
            oc1=onCleanup(@()close_system(tempModel,0));


            tempCUT=find_system(tempModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');

            ws=warning('off','Simulink:Harness:HarnessMoved');
            oc2=onCleanup(@()warning(ws.state,'Simulink:Harness:HarnessMoved'));
            Simulink.harness.internal.move(harness.ownerFullPath,harness.name,'DestinationOwner',tempCUT{1});
            sltest.harness.rebuild(tempCUT{1},harness.name);
            Simulink.harness.internal.move(tempCUT{1},harness.name,'DestinationOwner',harness.ownerFullPath);

            Simulink.harness.internal.set(harness.ownerFullPath,harness.name,'FunctionInterfaceName',functionInterfaceName);
            Simulink.harness.internal.set(harness.ownerFullPath,harness.name,'RebuildWithoutCompile',false);
        else
            Simulink.harness.internal.rebuildHarness(systemH,...
            harness.name,...
            harness.ownerHandle,...
            p.Results.RebuildModelData);
        end
    catch ME
        throwAsCaller(makeHarnessRebuildAbortedError(ME));
    end

end

function ME2=makeHarnessRebuildAbortedError(ME)
    errId2='Simulink:Harness:HarnessRebuildAborted';
    errId1='Simulink:Harness:CannotRebuildLibHarness';
    if~strcmp(errId2,ME.identifier)&&~strcmp(errId1,ME.identifier)
        ME2=MException(errId2,'%s',DAStudio.message(errId2));
        ME2=ME2.addCause(ME);
    else
        ME2=ME;
    end
end

