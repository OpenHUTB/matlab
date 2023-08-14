function covHarnessInfo=getCovHarnessInfo(harnessInfo)



    covHarnessInfo.ownerModel='';
    covHarnessInfo.harnessModel='';
    covHarnessInfo.ownerBlock='';
    covHarnessInfo.ownerType='';
    covHarnessInfo.keepHarnessCvData=true;
    covHarnessInfo.forceTopModelResultsRemoval=false;

    if~isempty(harnessInfo)
        covHarnessInfo.ownerModel=harnessInfo.model;
        covHarnessInfo.harnessModel=harnessInfo.name;

        isSubsysHarness=strcmpi(harnessInfo.ownerType,'Simulink.SubSystem');
        covHarnessInfo.keepHarnessCvData=~strcmpi(harnessInfo.ownerType,'Simulink.SFunction')&&...
        ~strcmpi(harnessInfo.ownerType,'Simulink.MATLABSystem');

        covHarnessInfo.keepHarnessCvData=covHarnessInfo.keepHarnessCvData&&...
        ~(isSubsysHarness&&harnessInfo.synchronizationMode==2);

        covHarnessInfo.keepHarnessCvData=covHarnessInfo.keepHarnessCvData&&...
        ~(isSubsysHarness&&~isempty(harnessInfo.functionInterfaceName)&&...
        strcmp(get_param(harnessInfo.name,'XILSubsystemWorkflow'),'ReusableLibrary'));

        covHarnessInfo.ownerBlock=harnessInfo.ownerFullPath;
        covHarnessInfo.ownerType=harnessInfo.ownerType;
        if strcmpi(covHarnessInfo.ownerType,'Simulink.BlockDiagram')&&...
            bdIsSubsystem(covHarnessInfo.ownerModel)

            covHarnessInfo.ownerType='Simulink.SubSystem';
        end

        if strcmpi(harnessInfo.ownerType,'Simulink.CCaller')




            covHarnessInfo.forceTopModelResultsRemoval=true;
        end
    end
end

