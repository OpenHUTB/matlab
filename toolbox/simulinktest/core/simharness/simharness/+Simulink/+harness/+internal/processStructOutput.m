function hInfoOut=processStructOutput(hInfoIn,warnMssgs)






    synchronizationModes={'SyncOnOpenAndClose','SyncOnOpen','SyncOnPushRebuildOnly'};
    verificationModes={'Normal','SIL','PIL'};
    wasCellInitially=iscell(hInfoIn);
    if~wasCellInitially
        assert(numel(hInfoIn)==1);
        hInfoIn={hInfoIn};
    end
    for i=1:numel(hInfoIn)
        if isstruct(hInfoIn{i})
            temp=struct;
            temp.model=hInfoIn{i}.model;
            temp.name=hInfoIn{i}.name;
            temp.description=hInfoIn{i}.description;
            temp.ownerHandle=hInfoIn{i}.ownerHandle;
            temp.ownerFullPath=hInfoIn{i}.ownerFullPath;
            temp.ownerType=hInfoIn{i}.ownerType;
            temp.verificationMode=verificationModes{hInfoIn{i}.param.verificationMode+1};
            temp.saveExternally=hInfoIn{i}.param.saveExternally;
            temp.rebuildOnOpen=hInfoIn{i}.param.rebuildOnOpen;
            temp.rebuildModelData=hInfoIn{i}.param.rebuildModelData;
            temp.postRebuildCallback=hInfoIn{i}.param.postRebuildCallBack;
            temp.graphical=hInfoIn{i}.param.createGraphicalHarness;
            temp.origSrc=hInfoIn{i}.param.source;
            temp.origSink=hInfoIn{i}.param.sink;
            temp.synchronizationMode=synchronizationModes{hInfoIn{i}.param.synchronizationMode+1};
            temp.existingBuildFolder=hInfoIn{i}.param.existingBuildFolder;
            temp.functionInterfaceName=hInfoIn{i}.param.functionInterfaceName;
            hInfoIn{i}=temp;
        end
    end
    if~wasCellInitially
        hInfoIn=hInfoIn{1};
        hInfoOut=hInfoIn;
        return;
    end
    assert(numel(hInfoIn)>1);
    hInfoOut=repmat(struct('harnessInfo',[],'error',[],'warning',[]),size(hInfoIn));
    for i=1:numel(hInfoIn)
        hInfoOut(i).warning=warnMssgs{i};
        if isstruct(hInfoIn{i})
            hInfoOut(i).harnessInfo=hInfoIn{i};
        else
            hInfoOut(i).error=hInfoIn{i};
        end
    end
end

