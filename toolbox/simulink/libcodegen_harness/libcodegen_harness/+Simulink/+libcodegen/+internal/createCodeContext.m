
function harnessStruct=createCodeContext(ccOwner,varargin)

    try

        if slfeature('CodeContextHarness')==0
            DAStudio.error('Simulink:CodeContext:CodeContextFeatureNotOn');
        end


        try
            [harnessInfo.model,harnessInfo.ownerHandle]=Simulink.harness.internal.parseForSystemModel(ccOwner);
        catch ME
            mainError=MSLException([],message('Simulink:CodeContext:CodeContextCreateError',ccOwner));
            mainError.addCause(ME);
            mainError.throwAsCaller();
        end


        if Simulink.harness.isHarnessBD(harnessInfo.model)
            DAStudio.error('Simulink:CodeContext:CodeContextCannotBeCreatedForAHarnessMdl');
        end


        if Simulink.harness.internal.isMathWorksLibrary(get_param(harnessInfo.model,'Handle'))
            DAStudio.error('Simulink:CodeContext:CodeContextCannotBeCreatedForAMWLib');
        end


        if bdIsLibrary(harnessInfo.model)&&strcmp('on',get_param(harnessInfo.model,'Lock'))
            DAStudio.error('Simulink:CodeContext:CannotCreateCodeContextWhenLibIsLocked',harnessInfo.model);
        end



        blockType=get_param(ccOwner,'BlockType');
        if~strcmp(get_param(bdroot(ccOwner),'BlockDiagramType'),'library')||...
            ~strcmp(blockType,'SubSystem')||...
            ~strcmp(get_param(ccOwner,'TreatAsAtomicUnit'),'on')||...
            ~strcmp(get_param(ccOwner,'RTWSystemCode'),'Reusable function')||...
            ~strcmp(harnessInfo.model,get_param(ccOwner,'Parent'))
            DAStudio.error('Simulink:CodeContext:CodeContextInvalidOwnerType',getfullname(ccOwner));
        end


        if~isempty(get_param(ccOwner,'ReferenceBlock'))
            DAStudio.error('Simulink:CodeContext:CodeContextInvalidOwnerLinkType',getfullname(ccOwner));
        end



        try
            [harnessInfo.ownerType,harnessInfo.ownerFullPath]=Simulink.harness.internal.validateOwnerHandle(harnessInfo.model,harnessInfo.ownerHandle);
            assert(strcmp(harnessInfo.ownerType,'Simulink.SubSystem'));
        catch
            DAStudio.error('Simulink:CodeContext:CodeContextInvalidOwnerType',getfullname(ccOwner));
        end


        harnessInfoFile=[harnessInfo.model,'_harnessInfo.xml'];
        harnessInfoFileExists=(exist(harnessInfoFile,'file')==2);


        harnessInfo=Simulink.harness.internal.getHarnessInfoDefaults(harnessInfo,harnessInfoFile);


        harnessInfo.param.synchronizationMode=1;

        p=inputParser;
        p.CaseSensitive=0;
        p.PartialMatching=0;
        name='';
        instancePath='';
        fromUI=false;

        p.addParameter('InstancePath',instancePath);
        p.addParameter('FromUI',fromUI);
        p.addParameter('Name',name);
        p.addParameter('Description',harnessInfo.description,@(x)validateattributes(x,{'char'},{'real'}));
        p.addParameter('CodeContextPath',harnessInfo.param.fileName,@(x)validateattributes(x,{'char'},{'real'}));
        p.addParameter('SaveExternally',harnessInfo.param.saveExternally,...
        @(x)validateattributes(x,{'logical'},{'nonempty'}));

        p.parse(varargin{:});

        instancePath=p.Results.InstancePath;
        instanceModel='';
        if~isempty(instancePath)
            instanceModel=bdroot(instancePath);
        end

        fromUI=p.Results.FromUI;%#ok
        instancePath=p.Results.InstancePath;
        harnessInfo.name=p.Results.Name;
        harnessInfo.description=p.Results.Description;
        harnessInfo.param.fileName=p.Results.CodeContextPath;
        harnessInfo.param.saveExternally=p.Results.SaveExternally;
        harnessInfo.param.isCodeContext=true;
        harnessInfo.param.usedSignalsOnly={};
        harnessInfo.param.UsedSignalsCell={};

        if isempty(harnessInfo.name)
            componentName=get_param(harnessInfo.ownerHandle,'Name');
            harnessInfo.name=Simulink.libcodegen.internal.getDefaultCCName(harnessInfo.model,componentName);
        else
            contextName=harnessInfo.name;
            if~isvarname(contextName)
                DAStudio.error('Simulink:CodeContext:ContextNameNotValid',...
                contextName);
            end

            if length(contextName)>58
                DAStudio.error('Simulink:CodeContext:NameTooLong',contextName);
            end
        end

        if isempty(instancePath)
            harnessInfo.instanceHandle=-1;
            harnessInfo.param.createGraphicalHarness=true;
        else
            harnessInfo.instanceHandle=get_param(instancePath,'Handle');
            harnessInfo.param.createGraphicalHarness=false;
        end






        hasCodeContexts=~isempty(Simulink.libcodegen.internal.getAllCodeContexts(harnessInfo.model));
        if~harnessInfo.param.saveExternally&&harnessInfoFileExists
            MSLDiagnostic('Simulink:CodeContext:InternalCodeContextModelNotConfigWarning',...
            harnessInfo.name,harnessInfo.model).reportAsWarning;
            harnessInfo.param.saveExternally=true;
        elseif(harnessInfo.param.saveExternally||...
            ~isempty(harnessInfo.param.fileName))&&...
            ~harnessInfoFileExists&&...
hasCodeContexts
            MSLDiagnostic('Simulink:CodeContext:ExternalCodeContextModelNotConfigWarning',...
            harnessInfo.name,harnessInfo.model).reportAsWarning;
            harnessInfo.param.saveExternally=false;
        elseif harnessInfoFileExists||...
            (~hasCodeContexts&&...
            ~isempty(harnessInfo.param.fileName))
            harnessInfo.param.saveExternally=true;
            harnessInfo.param.fileName=fullfile(pwd,[harnessInfo.name,'.slx']);
        end


        if~isempty(instancePath)
            referenceBlock=get_param(instancePath,'ReferenceBlock');



            if isempty(referenceBlock)||bdIsLibrary(bdroot(instancePath))
                DAStudio.error('Simulink:CodeContext:CodeContextInvalidInstance',instancePath);
            end
            refBlockHandle=get_param(referenceBlock,'Handle');
            if refBlockHandle~=harnessInfo.ownerHandle
                DAStudio.error('Simulink:CodeContext:CodeContextInvalidInstance',instancePath);
            end
        end




        if isempty(instancePath)
            harnessStruct=Simulink.libcodegen.internal.createGraphicalCodeContext(harnessInfo.model,harnessInfo,false);
            setDefaultRTWParams(harnessStruct);
        else
            harnessInfo.param.saveExternally=false;
            harnessInfo.param.fileName='';
            harnessStruct=Simulink.libcodegen.internal.createCompiledCodeContext(harnessInfo.model,instanceModel,harnessInfo,false);
        end


        Simulink.libcodegen.internal.refreshContextListDlg(harnessStruct.model);

    catch ME

        ME.throwAsCaller;
    end


end

function setDefaultRTWParams(harnessStruct)
    try
        Simulink.libcodegen.internal.loadCodeContext(harnessStruct.ownerFullPath,harnessStruct.name);
        oc=onCleanup(@()close_system(harnessStruct.name));

        cs=getActiveConfigSet(harnessStruct.name);
        if~isa(cs,'Simulink.ConfigSet')
            return;
        end

        set_param(harnessStruct.name,'SystemTargetFile','ert.tlc');
        set_param(harnessStruct.name,'SolverType','Fixed-step');
        set_param(harnessStruct.name,'UtilityFuncGeneration','Shared location');
        set_param(harnessStruct.name,'GenerateSharedConstants','on');
        set_param(harnessStruct.name,'GenerateReport','off');
        set_param(harnessStruct.name,'GenCodeOnly','on');
        set_param(harnessStruct.name,'PassReuseOutputArgsAs','Individual arguments');
        set_param(harnessStruct.name,'ModelReferencePassRootInputsByReference','on');

        if harnessStruct.saveExternally
            save_system(harnessStruct.name);
        end

    catch me %#ok unused




    end



end
