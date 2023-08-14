




function summary=callInspect(aObj)

    ProfileInspect=slci.internal.Profiler('SLCI','inspectModel',...
    aObj.getModelName(),'');



    mgr=slci.internal.ModelStateMgr(aObj.getModelName());
    aObj.LoadModel();


    aObj.setExtraParserOptions();


    set_param(aObj.getModelName(),'SLCodeInspector','on');

    aObj.InitModel();




    find_system(aObj.getModelName(),...
    'MatchFilter',@Simulink.match.allVariants,...
    'AllBlocks','on',...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'LookUnderReadProtectedSubsystems','on',...
    'Type','block');


    dm=aObj.getDataManager();
    dm.resetData();
    reportConfig=slci.internal.ReportConfig;
    slci.results.setDefaultInspectionStatus(dm,reportConfig);
    slci.results.writeMetaData(aObj);

    try

        aObj.ComputeDerivedCodeFolder();


        aObj.GenerateTheCode();



        ProfileModelCompile=slci.internal.Profiler('SLCI','ModelCompilation',...
        aObj.getModelName(),...
        aObj.getTargetName());
        try
            if aObj.getTopModel()
                mgr.compileModelForTop();
            else
                mgr.compileModelForRef();
            end


        catch ME
            Incompatibilities=slci.compatibility.Incompatibility(...
            [],...
            'ErrorCompilingModel',...
            aObj.getModelName());
            Result=1;
            FatalIncompatibility=true;

            summary=aObj.CollateResults(...
            false,Result,Incompatibilities,FatalIncompatibility,false);
            aObj.HandleException(ME,'Slci:ui:ErrorCompilingModel');
            return;
        end

        ProfileModelCompile.stop();


        is_top_model=1;
        if~aObj.getTopModel
            is_top_model=0;
        end


        mdlHandle=get_param(aObj.getModelName(),'Handle');
        aObj.fParamsTable=...
        slci.internal.buildParamsTable(mdlHandle);
        [aObj.fWSVarInfoTable,aObj.fStructFieldsTable,aObj.fStructIndicesTable]=...
        slci.internal.buildWSVarInfoStructFieldsTables(aObj.getModelName,...
        is_top_model,aObj.fParamsTable);


        isSCAutoMigrationOn=slfeature('AutoMigrationIM')==1;


        aObj.setServicePlatform;

        if isSCAutoMigrationOn
            if aObj.isServicePlatform



                DAStudio.error('Slci:slci:ERROR_SDP_WORKFLOW',...
                aObj.getModelName())
            end

            aObj.fModelMappingTable=...
            slci.internal.ModelMapping(aObj.getModelName);
        end


        matFile=aObj.getMatFile();
        if exist(matFile,'file')
            delete(matFile);
        end


        aObj.SetupRefMdls();


        summary=aObj.checkModelCompatibility();


        ProfilePrep=slci.internal.Profiler('SLCI','Preparation',...
        aObj.getModelName(),...
        aObj.getTargetName());


        slci.results.convertIncompatibilityData(aObj,summary);


        if summary.TerminateOnIncompatibility
            ProfilePrep.stop();

            DAStudio.error('Slci:slci:TERMINATE_ON_INCOMPATIBILITIES',...
            aObj.getModelName());
        end


        if summary.isFatal==true

            ProfilePrep.stop();

            if strcmpi(summary.Incompatibilities(1).getCode(),'ErrorCompilingModel')
                DAStudio.error('Slci:compatibility:ErrorCompilingModel',aObj.getModelName());
            else
                fatalTxt='';
                nl=sprintf('\n');
                for incompatIdx=1:numel(summary.Incompatibilities)
                    if summary.Incompatibilities(incompatIdx).getFatal()
                        fatalTxt=[fatalTxt,nl,summary.Incompatibilities(incompatIdx).getText()];%#ok
                    end
                end
                DAStudio.error('Slci:slci:FATAL_INCOMPATIBILITIES',aObj.getModelName(),fatalTxt);
            end
        end



        aObj.buildCodeInfoTable();


        aObj.setModelSymbolTable();


        aObj.ComputeHeaderPath();


        slci.results.prepareTypeReplacementObjects(aObj);


        ProfilePrep.stop();


        if strcmpi(aObj.getDisplayResults,'Summary')
            slci.internal.outputMessage(DAStudio.message('Slci:slci:InspectCmdStatus',aObj.getModelName()),'info');
        end
        Result=aObj.ExecuteSCI();


        summary=aObj.CollateResults(false,Result,{},false,false);


        slci.results.processResults(aObj,reportConfig);

    catch ME

        if~strcmp(ME.identifier,'Slci:compatibility:ErrorCompilingModel')
            aObj.HandleException(ME);
        end
        slci.results.writeErrorToDD(ME.message,dm);
        Result=1;
        if~strcmp(ME.identifier,'Slci:slci:TERMINATE_ON_INCOMPATIBILITIES')
            summary=aObj.CollateResults(false,Result,{},false,false);
        end
    end




    slci.results.setInspectionStatus(dm,reportConfig);


    if(Result==0)
        engineStatus='PASSED';
    else
        engineStatus='FAILED';
    end
    overallStatus=dm.getObject('RESULTS','Status');
    heavierStatus=reportConfig.getHeaviestStatus(overallStatus,engineStatus);
    if~strcmpi(overallStatus,heavierStatus)
        DAStudio.error('Slci:results:InvalidAggregateResult');
    end


    assert(mgr.getNumCompiles()<2);


    mgr.terminate();


    ProfileInspect.stop();



    if(aObj.getFollowModelLinks())
        subModelsSummary=aObj.InspectSubModels();
        summary=[summary,subModelsSummary];
    end


    dm.saveData();
end


