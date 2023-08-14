function info=prepareAnalysisInfo(data,titles,createLink,filter)




    info=[];

    if nargin<3
        createLink=0;
    end

    if nargin<4
        filter=[];
    end

    info.optionsInformation=prepareOptionsInformation(data,filter);
    info.modelInformation=prepareModelInformation(data);
    info.artifactInformation=prepareArtifactInformation(data);

    if isfield(data.AnalysisInformation,'Parameters')&&...
        ~isempty(data.AnalysisInformation.Parameters)
        [parameterSettings,variantSettings]=prepareParameterAndVariantSettings(data.AnalysisInformation.Parameters);
        [info.parameterSettings,info.variantSettings]=assignParameterAndVariantSettings(parameterSettings,variantSettings);
        [info.variantConstraints]=prepareVariantConstraints(data.AnalysisInformation.MultiParamConstraints);
    end

    if isfield(data.AnalysisInformation,'Approximations')
        if isfield(data,'Objectives')&&~isempty(data.Objectives)
            hasSFcnRTE=any(strcmpi({data.Objectives.type},'S-Function Runtime Error'))||...
            any(strcmpi({data.Objectives.type},'C/C++ Runtime Error'));
        else
            hasSFcnRTE=false;
        end

        approx=prepareApproximations(data.AnalysisInformation.Approximations,...
        data.ModelInformation.Name,createLink,hasSFcnRTE);
        if~isempty(approx)
            info.approximations=approx;
        end
    end

    if isfield(data.AnalysisInformation,'AbstractedBlocks')
        abstractedBlocks=prepareAbstractionSummary(data.AnalysisInformation.AbstractedBlocks,...
        data.ModelInformation.Name,createLink);
        if~isempty(abstractedBlocks)
            info.approximations.unsupported=abstractedBlocks;
        end
    end
    if isfield(data.AnalysisInformation,'ExportFcnGroupInfo')
        info.harnessInformation.ExportFcnGroupInfo=prepareExportFcnScheduleInfo(data.ModelInformation.Name,...
        data.AnalysisInformation.ExportFcnGroupInfo,createLink);
    end
    if isfield(data.AnalysisInformation,'StubbedSimulinkFcnInfo')


        [~,extractedMdlName,~]=fileparts(data.ModelInformation.ExtractedModel);
        info.harnessInformation.stubbedSimulinkFcnInfo=prepareStubbedSimulinkFcnInfo(extractedMdlName,...
        data.AnalysisInformation.StubbedSimulinkFcnInfo,createLink);
    end
    if strcmp(data.AnalysisInformation.Options.BlockReplacement,'on')
        info.blockReplacements=Sldv.ReportUtils.prepareBlockReplacements(data,createLink);
    end

    [dvconstraints,minmaxconstraints]=prepareAllConstraints(data,titles,createLink);
    if~isempty(dvconstraints)
        info.dvconstraints=dvconstraints;
    end
    if~isempty(minmaxconstraints)
        info.minmaxconstraints=minmaxconstraints;
    end

end

function opts=prepareOptionsInformation(data,filter)
    dvopts=data.AnalysisInformation.Options;
    name={};
    value={};
    name{end+1}=getString(message('Sldv:RptGen:AnalysisMode'));
    value{end+1}=dvopts.Mode;
    if sldvprivate('isReuseTranslationON',dvopts)
        name{end+1}=getString(message('Sldv:RptGen:RebuildModelRepresentation'));
        value{end+1}=dvopts.RebuildModelRepresentation;
    end
    if strcmp(dvopts.Mode,'TestGeneration')
        if slavteng('feature','GeneratedCodeTestGen')
            name{end+1}=getString(message('Sldv:RptGen:TestgenTarget'));
            value{end+1}=dvopts.TestgenTarget;
        end
        name{end+1}=getString(message('Sldv:RptGen:TestSuiteOptimization'));
        value{end+1}=dvopts.TestSuiteOptimization;
        name{end+1}=getString(message('Sldv:RptGen:MaximumTestcaseSteps'));
        value{end+1}=[num2str(dvopts.MaxTestCaseSteps),getString(message('Sldv:RptGen:TimeSteps'))];
        name{end+1}=getString(message('Sldv:RptGen:TestConditions'));
        value{end+1}=dvopts.TestConditions;
        name{end+1}=getString(message('Sldv:RptGen:TestObjectives'));
        value{end+1}=dvopts.TestObjectives;
        name{end+1}=getString(message('Sldv:RptGen:ModelCoverageObjectives'));
        value{end+1}=dvopts.ModelCoverageObjectives;

        name{end+1}=getString(message('Sldv:RptGen:AddTestsForMissingCov'));
        if strcmpi(dvopts.IgnoreCovSatisfied,'on')||strcmpi(dvopts.ExtendExistingTests,'on')
            value{end+1}='on';
        else
            value{end+1}='off';
        end

        if strcmpi(dvopts.CovFilter,'on')
            name{end+1}=getString(message('Sldv:RptGen:ModelCoverageFilterFile'));
            value{end+1}=dvopts.CovFilterFileName;
        end
        if~isempty(filter)&&~strcmp(dvopts.CovFilterFileName,filter.fileName)
            name{end+1}=getString(message('Sldv:RptGen:ReportFilterFile'));
            value{end+1}=filter.fileName;
        end

        if slavteng('feature','RelationalBoundary')
            name{end+1}=getString(message('Sldv:RptGen:IncludeRelBound'));
            value{end+1}=dvopts.IncludeRelationalBoundary;
            if strcmpi(dvopts.IncludeRelationalBoundary,'on')
                name{end+1}=getString(message('Sldv:RptGen:RelBoundAbsoluteTolerance'));
                value{end+1}=dvopts.AbsoluteTolerance;
                name{end+1}=getString(message('Sldv:RptGen:RelBoundRelativeTolerance'));
                value{end+1}=dvopts.RelativeTolerance;
            end
        end

    elseif strcmp(dvopts.Mode,'PropertyProving')
        name{end+1}=getString(message('Sldv:RptGen:ProvingStrategy'));
        value{end+1}=dvopts.ProvingStrategy;
        if~strcmp(dvopts.ProvingStrategy,'Prove')
            name{end+1}=getString(message('Sldv:RptGen:MaximumViolationSteps'));
            value{end+1}=[num2str(dvopts.MaxViolationSteps),getString(message('Sldv:RptGen:TimeSteps'))];
        end
        name{end+1}=getString(message('Sldv:RptGen:ProofAssumptions'));
        value{end+1}=dvopts.ProofAssumptions;
        name{end+1}=getString(message('Sldv:RptGen:TestObjectives'));
        value{end+1}=dvopts.TestObjectives;
        name{end+1}=getString(message('Sldv:RptGen:Assertions'));
        value{end+1}=dvopts.Assertions;
    elseif strcmp(dvopts.Mode,'DesignErrorDetection')
        props=find(dvopts.classhandle.properties,'accessflags.publicset','on',...
        'accessflags.publicget','on','visible','on',...
        'accessflags.serialize','on','Name','DetectDeadLogic');

        if~isempty(props)&&(strcmp(dvopts.DetectDeadLogic,'on')||slfeature('SLDVCombinedDLRTE'))
            name{end+1}=getString(message('Sldv:RptGen:DetectDeadLogic'));
            value{end+1}=dvopts.DetectDeadLogic;
            name{end+1}=getString(message('Sldv:RptGen:DetectActiveLogic'));
            value{end+1}=dvopts.DetectActiveLogic;
            if strcmp(dvopts.DetectDeadLogic,'on')
                name{end+1}=getString(message('Sldv:RptGen:DeadLogicObjectives'));
                value{end+1}=dvopts.DeadLogicObjectives;
            end
        end
        if isempty(props)||strcmp(dvopts.DetectDeadLogic,'off')||slfeature('SLDVCombinedDLRTE')
            name{end+1}=getString(message('Sldv:RptGen:DetectIntegerOverflow'));
            value{end+1}=dvopts.DetectIntegerOverflow;

            name{end+1}=getString(message('Sldv:RptGen:DetectDivisionZero'));
            value{end+1}=dvopts.DetectDivisionByZero;

            name{end+1}=getString(message('Sldv:RptGen:CheckSpecifiedIntermediateMinimum'));
            value{end+1}=dvopts.DesignMinMaxCheck;

            name{end+1}=getString(message('Sldv:RptGen:DetectOutOfBound'));
            value{end+1}=dvopts.DetectOutOfBounds;

            name{end+1}=getString(message('Sldv:RptGen:DetectInfNaN'));
            value{end+1}=dvopts.DetectInfNaN;

            name{end+1}=getString(message('Sldv:RptGen:DetectSubnrml'));
            value{end+1}=dvopts.DetectSubnormal;

            if slavteng('feature','DsmHazards')
                name{end+1}=getString(message('Sldv:RptGen:DetectDSMAccessViolations'));
                value{end+1}=dvopts.DetectDSMAccessViolations;
            end

            if slfeature('SldvCombinedDlRteAndBlockInputBoundaryViolations')>=2
                name{end+1}=getString(message('Sldv:RptGen:DetectBlockInputRangeViolations'));
                value{end+1}=dvopts.DetectBlockInputRangeViolations;
            end

            name{end+1}=getString(message('Sldv:RptGen:DetectHisl_0002'));
            value{end+1}=dvopts.DetectHISMViolationsHisl_0002;

            name{end+1}=getString(message('Sldv:RptGen:DetectHisl_0003'));
            value{end+1}=dvopts.DetectHISMViolationsHisl_0003;

            name{end+1}=getString(message('Sldv:RptGen:DetectHisl_0004'));
            value{end+1}=dvopts.DetectHISMViolationsHisl_0004;

            name{end+1}=getString(message('Sldv:RptGen:DetectHisl_0028'));
            value{end+1}=dvopts.DetectHISMViolationsHisl_0028;
        end

        if strcmpi(dvopts.CovFilter,'on')
            name{end+1}=getString(message('Sldv:RptGen:ModelCoverageFilterFile'));
            value{end+1}=dvopts.CovFilterFileName;
        end
        if~isempty(filter)&&~strcmp(dvopts.CovFilterFileName,filter.fileName)
            name{end+1}=getString(message('Sldv:RptGen:ReportFilterFile'));
            value{end+1}=filter.fileName;
        end
    end
    name{end+1}=getString(message('Sldv:RptGen:MaximumAnalysisTime'));
    value{end+1}=[num2str(dvopts.MaxProcessTime),getString(message('Sldv:RptGen:Sec'))];
    name{end+1}=getString(message('Sldv:RptGen:BlockReplacement'));
    value{end+1}=dvopts.BlockReplacement;
    if strcmp(dvopts.BlockReplacement,'on')
        name{end+1}=getString(message('Sldv:RptGen:BlockReplacementRules'));
        value{end+1}=dvopts.BlockReplacementRulesList;
    end
    name{end+1}=getString(message('Sldv:RptGen:ParametersAnalysis'));
    value{end+1}=dvopts.Parameters;
    if strcmp(dvopts.Parameters,'on')&&strcmp(dvopts.ParametersUseConfig,'off')
        name{end+1}=getString(message('Sldv:RptGen:ParametersConfigurationFile'));
        value{end+1}=dvopts.ParametersConfigFile;
    end
    name{end+1}=getString(message('Sldv:RptGen:IncludeExpectedOutputValues'));
    value{end+1}=dvopts.SaveExpectedOutput;
    name{end+1}=getString(message('Sldv:RptGen:DontCareRandomizeData'));
    value{end+1}=dvopts.RandomizeNoEffectData;
    name{end+1}=getString(message('Sldv:RptGen:ReduceRatApprox'));
    value{end+1}=dvopts.ReduceRationalApprox;
    name{end+1}=getString(message('Sldv:RptGen:SaveHarness'));
    value{end+1}=dvopts.SaveHarnessModel;
    name{end+1}=getString(message('Sldv:RptGen:SaveReport'));
    value{end+1}=dvopts.SaveReport;

    opts=reshape([name,value],[length(name),2]);
end

function modelInformation=prepareModelInformation(data)
    modelInformation=cell(4,2);
    modelInformation(1,1)={getString(message('Sldv:RptGen:ModelFile'))};
    modelInformation(1,2)={data.ModelInformation.Name};
    modelInformation(2,1)={getString(message('Sldv:RptGen:ModelVersion'))};
    modelInformation(2,2)={data.ModelInformation.Version};
    if isfield(data.ModelInformation,'TimeStamp')
        modelInformation(3,1)={getString(message('Sldv:RptGen:ModelTimeStamp'))};
        modelInformation(3,2)={data.ModelInformation.TimeStamp};
    end
    modelInformation(4,1)={getString(message('Sldv:RptGen:ModelAuthor'))};
    modelInformation(4,2)={data.ModelInformation.Author};
end

function artifactInformation=prepareArtifactInformation(data)
    dvopts=data.AnalysisInformation.Options;
    if~strcmp(dvopts.Mode,'TestGeneration')
        artifactInformation=[];
        return;
    end


    artifactInformation=cell(4,2);


    fileStr=data.AnalysisInformation.Options.CoverageDataFile;
    if isempty(fileStr)||strcmpi(dvopts.IgnoreCovSatisfied,'off')
        fileStr=getString(message('Sldv:RptGen:NA'));
    end
    artifactInformation(1,1)={getString(message('Sldv:RptGen:CoverageData'))};
    artifactInformation(1,2)={fileStr};


    fileStr=data.AnalysisInformation.Options.ExistingTestFile;
    if isempty(fileStr)||strcmpi(dvopts.ExtendExistingTests,'off')
        fileStr=getString(message('Sldv:RptGen:NA'));
    end
    artifactInformation(2,1)={getString(message('Sldv:RptGen:TestData'))};
    artifactInformation(2,2)={fileStr};
end

function[params,variants]=prepareParameterAndVariantSettings(dataparams)
    n_config=length(dataparams);
    n=length(dataparams{1});
    params=cell(n_config,1);
    variants=cell(n_config,1);


    for i=1:n_config
        [parameter_counter,variant_counter]=getParameterAndVariantCount(dataparams{i},n);

        params_i={};
        variants_i={};
        if parameter_counter>0
            params_i=cell(parameter_counter+1,2);
            params_i(1,1)={getString(message('Sldv:RptGen:ParameterColName'))};
            params_i(1,2)={getString(message('Sldv:RptGen:ParameterSpecificationColName'))};
        end

        if variant_counter>0
            variants_i=cell(variant_counter+1,1);
            variants_i(1,1)={getString(message('Sldv:RptGen:VariantColName'))};
        end

        pIdx=1;
        vIdx=1;
        for j=1:n
            if isequal(dataparams{i}{j}.type,'Variant')
                vn=dataparams{i}{j}.name;
                variants_i{vIdx+1,1}={vn};%#ok<*AGROW> 
                vIdx=vIdx+1;
                continue;
            end

            p=dataparams{i}{j}.name;
            params_i(pIdx+1,1)={p};
            v=dataparams{i}{j}.values;
            params_i(pIdx+1,2)={v};
            pIdx=pIdx+1;
        end
        params{i}=params_i;
        variants{i}=variants_i;
    end
end

function[constraints,minmaxconstraints]=prepareAllConstraints(data,titles,createLink)
    constraints=[];
    minmaxconstraints=[];

    if isempty(data.Constraints)
        return;
    end

    if isfield(data.Constraints,'Analysis')
        constraints.table(1,:)=deal({getString(message('Sldv:RptGen:Name')),titles.dvconstraint});
        constraints=addDataConstraintInfo(data,data.Constraints.Analysis,...
        data.ModelObjects,constraints,...
        ', ',createLink);
    end

    if isfield(data.Constraints,'DesignMinMax')
        minmaxconstraints.table(1,:)=deal({getString(message('Sldv:RptGen:Name')),titles.minmaxconstraint});
        minmaxconstraints=addDataConstraintInfo(data,data.Constraints.DesignMinMax,...
        data.ModelObjects,minmaxconstraints,'..',...
        createLink);
    end
end

function constr=addDataConstraintInfo(sldvData,constraints,modelObjs,constr,rangeFormat,createLink)
    for i=1:length(constraints)
        constraint_i=constraints(i);

        if isfield(constraint_i,'modelObjIdx')&&createLink
            mo=modelObjs(constraint_i.modelObjIdx);
            [sid,modelname]=Sldv.ReportUtils.getSidFromModelObjectData(sldvData,mo);
            if isempty(sid)
                sid=mo.descr;
            end
            if isempty(modelname)
                modelname=Sldv.ReportUtils.getAnalyzedModelName(sldvData);
            end

            constraint_i_desc=mo.descr;

            if isfield(constraint_i,'outcomeValue')&&constraint_i.outcomeValue>0&&...
                isfield(constraint_i,'busElementIdx')&&constraint_i.busElementIdx>0
                constraint_i_desc=[mo.descr...
                ,getString(message('Sldv:RptGen:outport',num2str(constraint_i.outcomeValue)))...
                ,getString(message('Sldv:RptGen:buselement',constraint_i.descr))];
            end

            link=sldv_hilite('makelink_sid',sid,constraint_i_desc,modelname);
        else
            link=constraints(i).name;
        end
        constr.table(end+1,:)={link,sldvprivate('util_mxarray_print',constraints(i).value,rangeFormat)};
    end
end

function approx=prepareApproximations(approxInfo,modelname,createLink,hasSFcnRTE)
    approx=[];
    analysisApprox=getApproximationMsgs(approxInfo.flags,hasSFcnRTE);
    approxErr=approxInfo.errors;

    if~isempty(analysisApprox)
        approx.analysis=cell(length(analysisApprox)+1,3);
        approx.analysis(1,1)={getString(message('Sldv:RptGen:Hash'))};
        approx.analysis(1,2)={getString(message('Sldv:RptGen:AnalysisTypeColName'))};
        approx.analysis(1,3)={getString(message('Sldv:RptGen:AnalysisDescriptionColName'))};
        for i=1:length(analysisApprox)
            approx.analysis(i+1,1)={num2str(i)};
            approx.analysis(i+1,2)=analysisApprox(i).type;
            approx.analysis(i+1,3)=analysisApprox(i).desc;
        end
    end

    if~isempty(approxErr)
        approx.error=cell(length(approxErr)+1,4);
        approx.error(1,1)={getString(message('Sldv:RptGen:Hash'))};
        approx.error(1,2)={getString(message('Sldv:RptGen:ApproxBlockColName'))};
        approx.error(1,3)={getString(message('Sldv:RptGen:ApproxTypeColName'))};
        approx.error(1,4)={getString(message('Sldv:RptGen:ApproxErrorColName'))};
        for i=1:length(approxErr)
            approx.error(i+1,1)={num2str(i)};
            if~isempty(approxErr(i).sid)&&createLink
                approx.error(i+1,2)={sldv_hilite('makelink_sid',...
                approxErr(i).sid,...
                approxErr(i).name,modelname)};
            else
                approx.error(i+1,2)=approxErr(i).name;
            end
            approx.error(i+1,3)=approxErr(i).type;
            approx.error(i+1,4)=approxErr(i).error;
        end
    end
end

function approx=getApproximationMsgs(flags,hasSFcnRTE)
    approx=[];

    if hasSFcnRTE
        approx(end+1).type={getString(message('Sldv:RptGen:SFunctionApproximation'))};
        approx(end).desc={getString(message('Sldv:RptGen:ModelIncludesSFunctionRTE'))};
    end

    if flags.hasDouble2RatConvert
        approx(end+1).type={getString(message('Sldv:RptGen:RationalApproximation'))};
        approx(end).desc={getString(message('Sldv:RptGen:ModelIncludesFloatingpoint'))};
    end

    if flags.hasWhileLoopApprox
        approx(end+1).type={getString(message('Sldv:RptGen:WhileLoopApproximation'))};
        approx(end).desc={getString(message('Sldv:RptGen:ModelIncludesWhileLoop'))};
    end

    if flags.hasMultiInsNormalMode
        approx(end+1).type={getString(message('Sldv:RptGen:MultiinstanceModelReferenceApproximation'))};
        approx(end).desc={getString(message('Sldv:RptGen:MultipleReferencesToAModel'))};
    end

    if isfield(flags,'lookupApproxisReported')
        if flags.lookupApproxisReported
            approx(end+1).type={getString(message('Sldv:RptGen:LookupTableApproximation'))};
            approx(end).desc={getString(message('Sldv:RptGen:ModelIncludesLookupTables'))};
        end
    end

    if flags.lookup2DisReported
        approx(end+1).type={getString(message('Sldv:RptGen:LookupTable2DLinearization'))};
        approx(end).desc={getString(message('Sldv:RptGen:ModelIncludes2DLookTables'))};
    end

    if isfield(flags,'lookupFxpisReported')
        if flags.lookupFxpisReported
            approx(end+1).type={getString(message('Sldv:RptGen:LookupTableFxpApproximation'))};
            approx(end).desc={getString(message('Sldv:RptGen:ModelIncludesFxpLookupTables'))};
        end
    end
end



function abstractBlocks=prepareAbstractionSummary(blkInfo,modelname,createLink)

    abstractBlocks=[];

    if~isempty(blkInfo)
        abstractBlocks=cell(length(blkInfo)+1,2);
        abstractBlocks(1,1)={getString(message('Sldv:RptGen:AbstractBlockColName'))};
        abstractBlocks(1,2)={getString(message('Sldv:RptGen:AbstractTypeColName'))};
        for i=1:length(blkInfo)
            if~isempty(blkInfo{i}.sid)&&createLink
                abstractBlocks(i+1,1)={sldv_hilite('makelink_sid',...
                blkInfo{i}.sid,blkInfo{i}.name,modelname)};
            else
                abstractBlocks(i+1,1)={blkInfo{i}.name};
            end
            abstractBlocks(i+1,2)={blkInfo{i}.type};
        end
    end
end



function groupInfo=prepareExportFcnScheduleInfo(modelname,exportFcnGroupInfo,createLink)

    groupInfo=[];
    if~isempty(exportFcnGroupInfo)
        n=length(exportFcnGroupInfo);
        tc=cell(n+1,4);
        tc(1,1)={getString(message('Sldv:sldv_new_rpt:ExpFcnOrder'))};
        tc(1,2)={getString(message('Sldv:sldv_new_rpt:ExpFcnPort'))};
        tc(1,3)={getString(message('Sldv:sldv_new_rpt:ExpFcnSampleTime'))};
        tc(1,4)={getString(message('Sldv:sldv_new_rpt:ExpFcnNumInvocation'))};

        i=1;
        j=2;
        while i<=n
            pg=exportFcnGroupInfo(i);
            if~isempty(pg.GrFcnCallInputPort)
                tc(j,1)={num2str(j-1)};
                sid=pg.GrFcnCallInputPort;
                if createLink
                    tc(j,2)={sldv_hilite('makelink_sid',...
                    sid,pg.BlockNameToDisplay,modelname)};
                else
                    tc(j,2)={pg.BlockNameToDisplay};
                end
                rate=pg.MoreDetails.SpecifiedRate;
                if str2double(rate)>0
                    tc(j,3)={pg.MoreDetails.SpecifiedRate};
                    tc(j,4)={'1'};
                else
                    tc(j,3)={getString(message('Simulink:SampleTime:TriggeredSampleTimeDescription'))};
                    tc(j,4)={getString(message('Sldv:sldv_new_rpt:ExpFcnAperiodicInvoc'))};
                end
                j=j+1;
            end
            i=i+1;
        end
        if j==2
            tc=[];
        else
            tc(j:n+1,:)=[];
        end
        groupInfo=tc;
    end
end

function[parameter_counter,variant_counter]=getParameterAndVariantCount(paramInfo,n)
    parameter_counter=0;
    variant_counter=0;

    for idx=1:n
        if isequal(paramInfo{idx}.type,'Variant')
            variant_counter=variant_counter+1;
        else
            parameter_counter=parameter_counter+1;
        end
    end
end

function[parameterSettings,variantSettings]=assignParameterAndVariantSettings(pSettings,vSettings)
    parameterSettings={};
    variantSettings={};

    if~isempty(pSettings{1})
        parameterSettings=pSettings;
    end

    if~isempty(vSettings{1})
        variantSettings=vSettings{1};
    end
end

function variantConstraints=prepareVariantConstraints(multiParamConstraints)
    variantConstraints={};
    if isempty(multiParamConstraints)
        return;
    end

    variantConstraints=cell(numel(multiParamConstraints)+1,1);
    variantConstraints(1,1)={getString(message('Sldv:sldv_new_rpt:Constraints'))};

    for idx=1:numel(multiParamConstraints)
        variantConstraints{idx+1,1}=multiParamConstraints{idx};
    end
end



function simFcnInfo=prepareStubbedSimulinkFcnInfo(modelname,stubbedSimulinkFcnInfo,createLink)

    simFcnInfo=[];
    if~isempty(stubbedSimulinkFcnInfo)
        n=length(stubbedSimulinkFcnInfo);
        tc=cell(n+1,1);
        tc(1,1)={getString(message('Sldv:sldv_new_rpt:StubbedSimulinkFcn'))};

        i=1;
        while i<=n
            currSimFcn=stubbedSimulinkFcnInfo(i);
            sid=currSimFcn.sid;
            fcnName=currSimFcn.functionName;
            if createLink
                tc(i+1,1)={sldv_hilite('makelink_sid',...
                sid,fcnName,modelname)};
            else
                tc(i+1,1)={sid};
            end
            i=i+1;
        end
        simFcnInfo=tc;
    end
end


