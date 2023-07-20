function import(harnessOwner,varargin)




    p=inputParser;
    p.CaseSensitive=0;
    p.KeepUnmatched=1;
    p.PartialMatching=0;
    componentName='';
    importFileName='';
    fromUI=false;
    srcType='';
    sinkType='';
    rebuildOnOpen=false;
    postCreateCallBack='';
    verificationMode='Normal';


    createWithoutCompile=false;

    synchronizationModes={'SyncOnOpenAndClose','SyncOnOpen','SyncOnPushRebuildOnly'};

    p.addParameter('ComponentName',componentName);
    p.addParameter('ImportFileName',importFileName);
    p.addParameter('SynchronizationMode',synchronizationModes{3},@(x)any(validatestring(x,synchronizationModes)));
    p.addParameter('Source',srcType);
    p.addParameter('Sink',sinkType);
    p.addParameter('FromUI',fromUI);
    p.addParameter('RebuildOnOpen',rebuildOnOpen);
    p.addParameter('PostCreateCallBack',postCreateCallBack);
    p.addParameter('VerificationMode',verificationMode);


    p.addParameter('CreateWithoutCompile',createWithoutCompile);

    p.parse(varargin{:});

    importFileName=p.Results.ImportFileName;
    componentName=p.Results.ComponentName;
    syncModeVal=p.Results.SynchronizationMode;
    srcType=p.Results.Source;
    sinkType=p.Results.Sink;
    fromUI=p.Results.FromUI;
    rebuildOnOpen=p.Results.RebuildOnOpen;
    postCreateCallBack=p.Results.PostCreateCallBack;
    verificationMode=p.Results.VerificationMode;

    isNormal=strcmpi(verificationMode,'Normal');

    if~any(ismember(p.UsingDefaults,'CreateWithoutCompile'))
        MSLDiagnostic('Simulink:Harness:ImportParameterIgnored','CreateWithoutCompile').reportAsWarning;
    end

    if isempty(importFileName)||isempty(componentName)
        DAStudio.error('Simulink:Harness:NotEnoughInputArgs');
    end

    if~exist(importFileName,'file')
        DAStudio.error('Simulink:LoadSave:FileNotFound',importFileName);
    end

    [fullpath,importModelName,ext]=fileparts(importFileName);

    if isempty(fullpath)||isempty(ext)
        importFileName=which(importFileName);
        [~,importModelName,ext]=fileparts(importFileName);
    end

    if(~strcmp(ext,'.slx')&&~strcmp(ext,'.mdl'))
        DAStudio.error('Simulink:LoadSave:FileNotValidMDL',importFileName);
    end

    try
        bd=find_system('type','block_diagram','Name',importModelName);
        if isempty(bd)
            load_system(importFileName);
        end
        if strcmpi(get_param(importModelName,'Dirty'),'on')
            DAStudio.error('Simulink:Harness:ImportFailedUnsavedModel',importModelName);
        end
        if strcmp(get_param(bdroot(harnessOwner),'Name'),importModelName)
            DAStudio.error('Simulink:Harness:ImportFailedImportSelf');
        end
        ocObj=onCleanup(@()close_system(importModelName,0));
    catch ME
        throwAsCaller(ME);
    end


    additionalArgs=[fieldnames(p.Unmatched),struct2cell(p.Unmatched)];
    additionalArgs=additionalArgs';
    additionalArgs=additionalArgs(:)';

    if strcmp(get_param(importModelName,'LibraryType'),'BlockLibrary')
        DAStudio.error('Simulink:Harness:ImportFailedLibraryModel',...
        importFileName);
    end

    if~isempty(Simulink.harness.find(importModelName))
        DAStudio.error('Simulink:Harness:ImportFailedHasHarness',...
        importFileName);
    end

    CUTBlock='';


    if strfind(componentName,[importModelName,'/'])==1
        componentName=eraseBetween(componentName,1,length([importModelName,'/']));
    end
    try
        CUTBlock=find_system(importModelName,'SearchDepth',1,'Name',componentName);
    catch

    end

    if isempty(CUTBlock)
        DAStudio.error('Simulink:Harness:ImportCUTNotFound',componentName,importModelName);
    end

    [systemModel,harnessOwnerHandle]=Simulink.harness.internal.parseForSystemModel(harnessOwner);
    [harnessType,~]=Simulink.harness.internal.validateOwnerHandle(systemModel,harnessOwnerHandle);

    obj=get_param(harnessOwnerHandle,'Object');



    if isNormal&&ismember('SynchronizationMode',p.UsingDefaults)&&...
        ((~isa(obj,'Simulink.BlockDiagram')&&...
        Simulink.harness.internal.isImplicitLink(harnessOwnerHandle))||...
        strcmpi(get_param(systemModel,'BlockDiagramType'),'library'))
        syncModeVal=synchronizationModes{2};
    elseif~isNormal&&ismember('SynchronizationMode',p.UsingDefaults)
        syncModeVal=synchronizationModes{3};
    end

    if~fromUI
        importBlockType=get_param(CUTBlock{:},'BlockType');
        [supportedTypes,isCompatible]=validateComponentForImport(importBlockType,harnessType);
        if~isCompatible
            DAStudio.error('Simulink:Harness:ImportCUTInvalidBlockType',...
            importBlockType,componentName,importModelName,harnessType,supportedTypes);
        end
    end

    if isempty(srcType)&&isempty(sinkType)
        [srcType,sinkType]=inferSourceAndSinkType(importModelName);
    elseif isempty(sinkType)
        [~,sinkType]=inferSourceAndSinkType(importModelName);
    elseif isempty(srcType)
        [srcType,~]=inferSourceAndSinkType(importModelName);
    end


    if exist('ocObj','var')
        ocObj.delete;
    end

    origDirty=get_param(systemModel,'Dirty');

    harnessStruct=Simulink.harness.internal.create(harnessOwner,true,true,additionalArgs{:},'SynchronizationMode',...
    syncModeVal,'Source',srcType,'Sink',sinkType,'RebuildOnOpen',rebuildOnOpen,'VerificationMode',verificationMode);

    try
        if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
            Simulink.harness.internal.importBDHarness(systemModel,harnessStruct.name,importFileName,componentName);
        else
            Simulink.harness.internal.importBlockHarness(systemModel,harnessStruct.name,importFileName,...
            componentName,harnessOwnerHandle);
        end

        if~any(ismember(p.UsingDefaults,'PostCreateCallBack'))
            Simulink.harness.load(harnessStruct.ownerFullPath,harnessStruct.name);
            harnessBlockHandles=Simulink.harness.internal.getHarnessHandles(get_param(harnessStruct.model,'Handle'),...
            harnessStruct.ownerHandle,harnessStruct.name);

            try

                feval(postCreateCallBack,harnessBlockHandles);
            catch ME1
                errId='Simulink:Harness:PostCreateCallBackError';
                ME2=MException(errId,'%s',DAStudio.message(errId));
                ME2=ME2.addCause(ME1);
                Simulink.harness.internal.warn(ME2);
            end
            harnessInfo=Simulink.harness.find(harnessStruct.ownerFullPath,'Name',harnessStruct.name);
            if~isempty(harnessInfo)&&harnessInfo.isOpen
                Simulink.harness.close(harnessInfo.ownerFullPath,harnessInfo.name);
            end
        end
    catch ME
        set_param(systemModel,'Dirty',origDirty);
        throwAsCaller(ME);
    end


    Simulink.harness.internal.refreshHarnessListDlg(harnessStruct.model);
end


function[srcType,sinkType]=inferSourceAndSinkType(importModelName)

    import Simulink.harness.internal.TestHarnessSourceTypes;
    import Simulink.harness.internal.TestHarnessSinkTypes;

    srcType=TestHarnessSourceTypes.NONE.name;
    sinkType=TestHarnessSinkTypes.NONE.name;

    try

        if~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','SubSystem','MaskType','Sigbuilder block'))
            srcType=TestHarnessSourceTypes.SIGNAL_BUILDER.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','SubSystem','MaskType','SignalEditor'))&&slfeature('UseSignalEditorHarnessInput')>0
            srcType=TestHarnessSourceTypes.SIGNAL_EDITOR.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','Inport'))
            srcType=TestHarnessSourceTypes.INPORT.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','FromWorkspace'))
            srcType=TestHarnessSourceTypes.FROM_WORKSPACE.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','FromFile'))
            srcType=TestHarnessSourceTypes.FROM_FILE.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','Constant'))
            srcType=TestHarnessSourceTypes.CONSTANT.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','Ground'))
            srcType=TestHarnessSourceTypes.GROUND.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'SFBlockType','Test Sequence'))
            srcType=TestHarnessSourceTypes.REACTIVE_TEST.name;
            sinkType=TestHarnessSinkTypes.REACTIVE_TEST.name;
            return;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'SFBlockType','Chart'))
            srcType=TestHarnessSourceTypes.STATEFLOW.name;
            sinkType=TestHarnessSinkTypes.STATEFLOW.name;
            return;
        end


        if~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','Outport'))
            sinkType=TestHarnessSinkTypes.OUTPORT.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','Scope'))
            sinkType=TestHarnessSinkTypes.SCOPE.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','ToWorkspace'))
            sinkType=TestHarnessSinkTypes.TO_WORKSPACE.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','ToFile'))
            sinkType=TestHarnessSinkTypes.TO_FILE.name;
        elseif~isempty(find_system(importModelName,'SearchDepth',1,'BlockType','Terminator'))
            sinkType=TestHarnessSinkTypes.TERMINATOR.name;
        end

    catch

    end
end

function[supportedTypes,isCompatible]=validateComponentForImport(importBlockType,ownerType)

    switch ownerType
    case{'Simulink.BlockDiagram','Simulink.ModelReference'}
        supportedTypes='SubSystem, ModelReference';
        if strcmp(importBlockType,'SubSystem')||...
            strcmp(importBlockType,'ModelReference')
            isCompatible=true;
        else
            isCompatible=false;
        end
        return;

    case 'Simulink.SubSystem'
        supportedTypes='SubSystem, ModelReference, S-Function, M-S-Function, MATLABSystem, FMU';
        if strcmp(importBlockType,'SubSystem')||...
            strcmp(importBlockType,'ModelReference')||...
            strcmp(importBlockType,'S-Function')||...
            strcmp(importBlockType,'M-S-Function')||...
            strcmp(importBlockType,'MATLABSystem')||...
            strcmp(importBlockType,'FMU')
            isCompatible=true;
        else
            isCompatible=false;
        end
        return;

    case 'Simulink.SFunction'
        supportedTypes='S-Function';
        if strcmp(importBlockType,'S-Function')
            isCompatible=true;
        else
            isCompatible=false;
        end
        return;

    case 'Simulink.MSFunction'
        supportedTypes='M-S-Function';
        if strcmp(importBlockType,'M-S-Function')
            isCompatible=true;
        else
            isCompatible=false;
        end
        return;

    case 'Simulink.MATLABSystem'
        supportedTypes='MATLABSystem';
        if strcmp(importBlockType,'MATLABSystem')
            isCompatible=true;
        else
            isCompatible=false;
        end
        return;
    case 'Simulink.FMU'
        supportedTypes='FMU';
        if strcmp(importBlockType,'FMU')
            isCompatible=true;
        else
            isCompatible=false;
        end
        return;
    case 'Simulink.CCaller'
        supportedTypes='SubSystem, C Caller';
        if strcmp(importBlockType,'CCaller')
            isCompatible=true;
        else
            isCompatible=false;
        end
        return;
    case 'Simulink.CFunction'
        supportedTypes='SubSystem, C Function';
        if strcmp(importBlockType,'CFunction')
            isCompatible=true;
        else
            isCompatible=false;
        end
        return;
    otherwise
        supportedTypes='';
        isCompatible=false;
    end
end

