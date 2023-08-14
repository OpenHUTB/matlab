function varargout=extract(obj,model,varargin)




    opts=obj.validateExtractArgs(varargin{:});

    obj.OrigModelH=get_param(model,'handle');
    obj.Opts=opts;

    mdlName=get_param(model,'Name');


    origBackendFeature=slsvTestingHook('UnifiedHarnessBackendMode',1);
    backendCleanupObj=onCleanup(@()slsvTestingHook('UnifiedHarnessBackendMode',origBackendFeature));

    mdlDirty=get_param(obj.OrigModelH,'dirty');
    set_param(obj.OrigModelH,'dirty','off');
    dirtyCleanupObj=onCleanup(@()set_param(obj.OrigModelH,'dirty',mdlDirty));

    obj.turnOffAndStoreWarningStatus;

    try

        [extractedModelPath,testcomp]=obj.getExtractionInfo([mdlName,'_SldvStub'],obj.OrigModelH);
        if~obj.Status
            return;
        end

        [artifactFolder,extractedHarnessModel,ext]=fileparts(extractedModelPath);


        Simulink.harness.internal.create(mdlName,...
        false,...
        false,...
        'Name',extractedHarnessModel,...
        'Source','Inport',...
        'SaveExternally',false,...
        'RebuildOnOpen',false,...
        'SLDVCompatible',true);


        set_param(obj.OrigModelH,'dirty','off');
        Simulink.harness.internal.export(mdlName,extractedHarnessModel,false,'Name',[extractedHarnessModel,ext]);
        close_system(extractedHarnessModel,0);
        set_param(obj.OrigModelH,'dirty','off');


        if~strcmp(pwd,artifactFolder)
            movefile([extractedHarnessModel,ext],artifactFolder);
        end
        load_system(extractedModelPath)
        obj.ModelH=get_param(extractedHarnessModel,'handle');



        sldvshareprivate('configSLDVCompatibleHarness',obj.OrigModelH,obj.ModelH);


        origCS=getActiveConfigSet(obj.ModelH);
        if isa(origCS,'Simulink.ConfigSetRef')

            Sldv.utils.replaceConfigSetRefWithCopy(obj.ModelH);
            detachConfigSet(obj.ModelH,origCS.Name);
        end

        save_system(obj.ModelH);

        obj.Status=true;

        if~isempty(testcomp)
            testcomp.analysisInfo.blockDiagramExtract=true;
            testcomp.analysisInfo.extractedModelH=obj.ModelH;
        end
    catch Mex
        errID='Sldv:SubSysExtract:UnableGenExtractMdl';
        errMex=MException(errID,getString(message(errID)));
        if strcmp(Mex.identifier,'Simulink:Harness:HarnessCreationAborted')
            Mex=Mex.cause{1};
        end
        errMex=errMex.addCause(Mex);
        deriveErrorMsg(obj,errMex,true);
        obj.Status=false;
    end

    obj.restoreWarningStatus;

    varargout{1}=obj.Status;
    varargout{2}=obj.ModelH;
    varargout{3}=obj.ErrMsg;
end

