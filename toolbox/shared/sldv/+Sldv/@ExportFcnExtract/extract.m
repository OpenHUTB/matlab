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

        [ExtractedModelPath,testcomp]=obj.getExtractionInfo([mdlName,'_SldvScheduler'],obj.OrigModelH);
        if~obj.Status
            return;
        end

        [artifactFolder,ExtractedHarnessModel,ext]=fileparts(ExtractedModelPath);


        Simulink.harness.internal.create(mdlName,...
        false,...
        false,...
        'Name',ExtractedHarnessModel,...
        'SchedulerBlock','Matlab Function',...
        'Source','Inport',...
        'SaveExternally',false,...
        'RebuildOnOpen',false,...
        'SLDVCompatible',true);


        set_param(obj.OrigModelH,'dirty','off');
        Simulink.harness.internal.export(mdlName,ExtractedHarnessModel,false,'Name',[ExtractedHarnessModel,ext]);
        close_system(ExtractedHarnessModel,0);
        set_param(obj.OrigModelH,'dirty','off');


        if~strcmp(pwd,artifactFolder)
            movefile([ExtractedHarnessModel,ext],artifactFolder);
        end
        load_system(ExtractedModelPath)
        obj.ModelH=get_param(ExtractedHarnessModel,'handle');



        sldvshareprivate('configSLDVCompatibleHarness',obj.OrigModelH,obj.ModelH);


        origCS=getActiveConfigSet(obj.ModelH);
        if isa(origCS,'Simulink.ConfigSetRef')

            Sldv.utils.replaceConfigSetRefWithCopy(obj.ModelH);
            detachConfigSet(obj.ModelH,origCS.Name);
        end


        set_param(obj.ModelH,'EnableRefExpFcnMdlSchedulingChecks','off');

        save_system(obj.ModelH);

        obj.Status=true;

        if~isempty(testcomp)
            testcomp.analysisInfo.blockDiagramExtract=true;
            testcomp.analysisInfo.extractedModelH=obj.ModelH;
        end
    catch Mex
        errMex=MException('Sldv:Compatibility:ExportFcnExtractFail',...
        getString(message('Sldv:SubSysExtract:UnableGenExtractMdl')));
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

