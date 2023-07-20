

function result=syncFixPtConfigWithJava(mode,cfg,javaAdapter)




    mode=validatestring(mode,{'tojava','tocfg'});
    if isempty(cfg)
        cfg=coder.config('fixpt');
    else
        if coder.internal.isScalarText(cfg)
            cfg=evalin('base',cfg);
        end
        validateattributes(cfg,{'coder.FixPtConfig'},{'scalar'});
    end

    if isa(javaAdapter,'com.mathworks.project.impl.model.Configuration')
        javaAdapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaAdapter);%#ok<*JAPIMATHWORKS> 
    else
        validateattributes(javaAdapter,{'com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapter'},{'scalar'});
    end

    switch mode
    case 'tojava'
        cfgToJava(cfg,javaAdapter);
        result=javaAdapter;
    case 'tocfg'
        javaToCfg(cfg,javaAdapter);
        result=cfg;
    end
end


function cfgToJava(cfg,data)




    if isa(cfg,'coder.FixPtConfig')
        conversionMode='FIXED_POINT';
    elseif isa(cfg,'coder.SingleConfig')
        conversionMode='SINGLE';
    else
        conversionMode='NONE';
    end
    data.setNumericConversionMode(eval(['com.mathworks.toolbox.coder.fixedpoint.NumericConversionMode.',conversionMode]));%#ok<EVLDOT> 

    data.setDefaultWordLength(cfg.DefaultWordLength);
    data.setDefaultFractionLength(cfg.DefaultFractionLength);
    data.setDefaultSignedness(cfg.DefaultSignedness=="Automatic",cfg.DefaultSignedness=="Unsigned");
    data.setProposeContainerTypes(cfg.ProposeTargetContainerTypes);
    data.setOptimizeWholeNumbersEnabled(cfg.OptimizeWholeNumber);
    data.setSafetyMargin(cfg.SafetyMargin);
    data.setCoverageEnabled(cfg.ComputeCodeCoverage);
    data.setHistogramLoggingEnabled(cfg.HistogramLogging);
    data.setGeneratedFileSuffix(cfg.FixPtFileNameSuffix);
    data.setOverflowDetectionEnabled(cfg.DetectFixptOverflows);
    data.setVerificationLoggingEnabled(cfg.LogIOForComparisonPlotting);
    data.setPlotFunction(cfg.PlotFunction);
    data.setPlotWithSDI(cfg.PlotWithSimulationDataInspector);
    data.setEnableEfficiencyChecks(cfg.HighlightPotentialDataTypeIssues);
    data.setStaticAnalysisTimeoutMinutes(cfg.StaticAnalysisTimeoutMinutes);
    data.setStaticAnalysisLimitedToGlobalRanges(cfg.StaticAnalysisQuickMode);
    data.setFimath(cfg.fimath);
    data.setUsingDerivedRanges(cfg.UseDerivedRanges);
    data.setUsingSimulationRanges(cfg.UseSimulationRanges);
    data.setProposeFractionLengths(cfg.ProposeFractionLengthsForDefaultWordLength||...
    ~cfg.ProposeWordLengthsForDefaultFractionLength);

    if~isempty(cfg.TestBenchName)
        testFile=which(cfg.TestBenchName);
        if~isempty(testFile)&&isfile(testFile)
            data.setTestFiles(java.util.Collections.singleton(java.io.File(testFile)));
        end
    end

    replacementsXml=convertFunctionReplacements(cfg);
    if~isempty(replacementsXml)
        data.setFunctionReplacements(com.mathworks.project.api.XmlApi.getInstance().read(replacementsXml));
    end
end


function xml=convertFunctionReplacements(cfg)
    replacementMap=cfg.getAllFunctionReplacements();
    approxMap=cfg.getMathFcnConfigs();

    if size(replacementMap,1)==0&&size(approxMap,1)==0
        xml='';
        return;
    end

    import('com.mathworks.toolbox.coder.fixedpoint.replace.FunctionReplacementsModel');
    import('com.mathworks.toolbox.coder.fixedpoint.replace.FunctionReplacementType');

    javaModel=FunctionReplacementsModel([]);

    replaced=strtrim(replacementMap.keys());
    replacements=strtrim(replacementMap.values());
    for i=1:numel(replaced)
        if isempty(replaced{i})
            continue;
        end
        strat=FunctionReplacementType.USER_DEFINED.createStrategy();
        strat.setReplacement(replacements{i});
        replaceFunction(replaced{i},strat);
    end

    replaced=strtrim(approxMap.keys());
    replacements=approxMap.values();
    for i=1:numel(replaced)
        if isempty(replaced{i})
            continue;
        end
        approx=replacements{i};
        strat=FunctionReplacementType.LOOKUP_TABLE.createStrategy();
        strat.setResolution(approx.NumberOfPoints);
        strat.setDegreeOfInterpolation(getInterpolationDegreeString(approx.InterpolationDegree));
        if~isempty(approx.InputRange)
            strat.setInputMin(num2str(approx.InputRange(1)));
            strat.setInputMax(num2str(approx.InputRange(2)));
        else
            strat.setInputMin('Auto');
            strat.setInputMax('Auto');
        end
        replaceFunction(replaced{i},strat);
    end

    xmlWriter=com.mathworks.project.api.XmlApi.getInstance().create('FunctionReplacements');
    javaModel.serialize(xmlWriter);
    xml=char(xmlWriter.getXML());


    function replaceFunction(funcName,strategy)
        assert(false)
        import('com.mathworks.toolbox.coder.fixedpoint.replace.ReplacementKey');
        javaModel.addFunctionReplacement(ReplacementKey.parse(funcName),strategy);
    end
end


function strVal=getInterpolationDegreeString(numericVal)
    allStrs={'NONE','LINEAR','QUADRATIC','CUBIC','FLAT'};
    if numericVal>0&&numericVal<=numel(allStrs)
        strVal=allStrs{numericVal};
    else
        strVal='NONE';
    end
end


function javaToCfg(cfg,data)


    entryPoints=fromJava(data.getEntryPoints);
    if~isempty(entryPoints)
        [~,designName,~]=fileparts(entryPoints{1});
        buildPath=fromJava(data.getBuildPath);
        isBuildFolderSpecified=data.isBuildFolderSpecified;

        if isBuildFolderSpecified
            [buildDirRoot,codegenFolderName,~]=fileparts(buildPath);
            designFolderName=designName;
            [workDir,~]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(buildDirRoot,codegenFolderName,designFolderName);
        else
            codegenFolderName='codegen';
            designFolderName=designName;
            prjRoot=char(data.getConfiguration().getFile().getParentFile().getAbsolutePath());
            [workDir,~]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(prjRoot,codegenFolderName,designFolderName);
        end
        cfg.CodegenWorkDirectory=workDir;
    end

    cfg.TestBenchName=fromJava(data.getTestFiles);
    if data.isProposingFractionLengths
        cfg.ProposeFractionLengthsForDefaultWordLength=true;
        cfg.ProposeWordLengthsForDefaultFractionLength=false;
    else
        cfg.ProposeFractionLengthsForDefaultWordLength=false;
        cfg.ProposeWordLengthsForDefaultFractionLength=true;
    end
    cfg.DefaultWordLength=data.getDefaultWordLength;
    cfg.DefaultFractionLength=data.getDefaultFractionLength;

    cfg.ProposeTargetContainerTypes=data.isProposeContainerTypesEnabled();

    defSignedness='Automatic';
    if~data.isDefaultSignednessAutomatic
        if data.isDefaultSignednessUnsigned
            defSignedness='Unsigned';
        else
            defSignedness='Signed';
        end
    end
    cfg.DefaultSignedness=defSignedness;
    cfg.OptimizeWholeNumber=data.isOptimizeWholeNumbersEnabled;
    cfg.HistogramLogging=data.isHistogramLoggingEnabled;
    cfg.ComputeCodeCoverage=data.isCoverageEnabled;
    cfg.SafetyMargin=data.getSafetyMargin();
    cfg.fimath=fromJava(data.getFimath);





    cfg.StaticAnalysisTimeoutMinutes=data.getStaticAnalysisTimeoutMinutes();
    cfg.StaticAnalysisQuickMode=data.isStaticAnalysisLimitedToGlobalRanges();
    cfg.UseSimulationRanges=data.isUsingSimulationRanges;
    cfg.UseDerivedRanges=data.isUsingDerivedRanges;
    cfg.FixPtFileNameSuffix=fromJava(data.getGeneratedFileSuffix());
    cfg.DetectFixptOverflows=data.isOverflowDetectionEnabled;
    cfg.LogIOForComparisonPlotting=data.isVerificationLoggingEnabled();




    if cfg.LogIOForComparisonPlotting
        cfg.TestNumerics=true;
    end
    customPlotFunction=strtrim(char(data.getPlotFunction));
    cfg.PlotFunction=customPlotFunction;
    cfg.PlotWithSimulationDataInspector=data.plotWithSDI();
    cfg.HighlightPotentialDataTypeIssues=data.isEnableEfficiencyChecks();
    coder.internal.Float2FixedConverter.loadAnnotationsFromProjectUserData(data.getUserFixedPointData(),cfg);
    coder.internal.Float2FixedConverter.loadFunctionReplacementsFromProject(data.getFunctionReplacements(),cfg);
    mathApproxConfigs=coderprivate.Float2FixedManager.getMathFcnGenConfigs(data);
    cellfun(@(approxCfg)cfg.addApproximation(approxCfg),mathApproxConfigs);
end


function out=fromJava(val)


    switch class(val)
    case 'java.util.TreeSet'
        out=cell(1,val.size);
        iterator=val.iterator();
        ii=0;
        while iterator.hasNext()
            item=iterator.next();
            ii=ii+1;
            if~isempty(item)



                if isa(item,'java.io.File')
                    out{ii}=fromJava(item.getAbsolutePath());
                else
                    out{ii}=fromJava(item);
                end
            end
        end
    case 'java.lang.String'
        out=char(val);
    case 'java.io.File'
        out=fromJava(val.getAbsolutePath());
    otherwise

        error('unhandled type');
    end
end
