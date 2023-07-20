
function harnessStruct=rebuildCodeContext(owner,name,instancePath)
    try
        if slfeature('CodeContextHarness')==0
            DAStudio.error('Simulink:CodeContext:CodeContextFeatureNotOn');
        end

        [harnessInfo.model,harnessInfo.ownerHandle]=Simulink.harness.internal.parseForSystemModel(owner);
        harnessInfo.ownerFullPath=getfullname(harnessInfo.ownerHandle);
        harnessStruct=Simulink.libcodegen.internal.getCodeContext(harnessInfo.model,harnessInfo.ownerHandle,name);
        if isempty(harnessStruct)
            DAStudio.error('Simulink:CodeContext:CodeContextNotFound',getfullname(owner),name);
        end

        harnessInfoFile=[harnessInfo.model,'_harnessInfo.xml'];
        harnessInfo=Simulink.harness.internal.getHarnessInfoDefaults(harnessInfo,harnessInfoFile);
        harnessInfo.name=name;
        harnessInfo.description=harnessStruct.description;
        harnessInfo.param.saveExternally=harnessStruct.saveExternally;
        fileName='';
        if harnessInfo.param.saveExternally
            fileName=[name,'.slx'];
        end
        harnessInfo.param.fileName=fileName;
        harnessInfo.param.isCodeContext=true;
        harnessInfo.param.usedSignalsOnly={};
        harnessInfo.param.UsedSignalsCell={};
        harnessInfo.instanceHandle=get_param(instancePath,'Handle');
        harnessInfo.param.createGraphicalHarness=false;

        harnessInfo.param.synchronizationMode=1;
        instanceModel=bdroot(instancePath);

        referenceBlock=get_param(instancePath,'ReferenceBlock');



        if isempty(referenceBlock)||bdIsLibrary(bdroot(instancePath))
            DAStudio.error('Simulink:CodeContext:CodeContextInvalidInstance',instancePath);
        end
        refBlockHandle=get_param(referenceBlock,'Handle');
        if refBlockHandle~=harnessInfo.ownerHandle
            DAStudio.error('Simulink:CodeContext:CodeContextInvalidInstance',instancePath);
        end

        harnessStruct=Simulink.libcodegen.internal.rebuildContext(harnessStruct.model,instanceModel,harnessInfo);
    catch ME

        ME.throwAsCaller;
    end
end
