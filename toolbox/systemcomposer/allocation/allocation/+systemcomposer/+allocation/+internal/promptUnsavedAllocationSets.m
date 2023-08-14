function shouldExit=promptUnsavedAllocationSets(unsavedAllocationSetNames)



    response=questdlg(...
    DAStudio.message('SystemArchitecture:AllocationAPI:UnsavedAllocSetOnExitQuestion',unsavedAllocationSetNames),...
    DAStudio.message('SystemArchitecture:AllocationAPI:UnsavedAllocSetsTitle'),...
    DAStudio.message('SystemArchitecture:AllocationAPI:Save'),...
    DAStudio.message('SystemArchitecture:AllocationAPI:Discard'),...
    DAStudio.message('SystemArchitecture:AllocationAPI:Cancel'),...
    DAStudio.message('SystemArchitecture:AllocationAPI:Save'));
    switch response
    case DAStudio.message('SystemArchitecture:AllocationAPI:Save')

        systemcomposer.allocation.AllocationSet.saveAll();
        shouldExit=true;
    case DAStudio.message('SystemArchitecture:AllocationAPI:Discard')

        shouldExit=true;
    otherwise

        shouldExit=false;
    end

end

