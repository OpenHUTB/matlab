function setupHarnessInfo(coveng)



    try
        topModelH=coveng.topModelH;

        ownerModel=Simulink.harness.internal.getHarnessOwnerBD(topModelH);


        if~isempty(ownerModel)&&SliceUtils.isSlicerAvailable()
            isSlicerActive=~isempty(modelslicerprivate('slicerMapper','get',topModelH));
        else
            isSlicerActive=false;
        end

        if~isempty(ownerModel)&&~isSlicerActive
            covHarnessInfo=cvi.TopModelCov.getCovHarnessInfo(Simulink.harness.internal.getActiveHarness(ownerModel));
            coveng.ownerModel=covHarnessInfo.ownerModel;
            coveng.harnessModel=covHarnessInfo.harnessModel;
            coveng.ownerBlock=covHarnessInfo.ownerBlock;
            coveng.ownerType=covHarnessInfo.ownerType;
            coveng.keepHarnessCvData=covHarnessInfo.keepHarnessCvData;
            coveng.forceTopModelResultsRemoval=covHarnessInfo.forceTopModelResultsRemoval;
            if strcmpi(coveng.ownerType,'simulink.subsystem')
                coveng.unitUnderTestName=Simulink.harness.internal.getActiveHarnessCUT(coveng.ownerModel);
                if~isempty(coveng.harnessModel)&&...
                    SlCov.CodeCovUtils.isReusableLibrarySubsystem(coveng.harnessModel)
                    coveng.forceTopModelResultsRemoval=1;
                end
            end
        end
    catch MEx
        rethrow(MEx);
    end
