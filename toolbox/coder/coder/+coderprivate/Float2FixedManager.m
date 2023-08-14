


classdef Float2FixedManager<handle
    methods(Static,Access=public)
        function i=instance()
            mlock;
            persistent singleton;
            if isempty(singleton)
                singleton=coderprivate.Float2FixedManager;
            end
            i=singleton;
        end
    end

    properties(Access=public)
fpc
deferredBackendLoad
origCoderReport
    end

    methods(Access=public)
        function obj=Float2FixedManager()
            obj.fpc=[];
            obj.deferredBackendLoad=false;
        end


        function resetEntireTable(obj)
            if~isempty(obj.fpc)
                obj.fpc.clearSimulationData();
                obj.fpc.clearStaticAnalysisData();
            end
        end


        function reset(obj)
            if~isempty(obj.fpc)
                obj.fpc=[];
            end
        end


        function resetSimulationRanges(obj)
            if~isempty(obj.fpc)
                obj.fpc.clearSimulationData();
            end
        end


        function resetDerivedRanges(obj)
            if~isempty(obj.fpc)
                obj.fpc.clearStaticAnalysisData();
                [~,~]=proposeTypes(obj,data);
            end
        end








        function[inference,mexFile,messages,success,callerCalleeList,errorMessage]=buildFloatingPointCode(obj,data,entryPoints)
            inference=[];
            mexFile='';
            messages=[];
            callerCalleeList=[];
            success=false;
            errorMessage='';
            try

                searchPaths=cell(data.getSearchPaths());
                if~isempty(searchPaths)
                    oldPath=obj.addSearchPaths(searchPaths);
                    c=onCleanup(@()path(oldPath));
                end


                configuration=data.getConfiguration();
                prjRoot=char(configuration.getFile().getParentFile().getAbsolutePath());
                cd(prjRoot);


                designNames=cell(1,length(entryPoints));
                for ii=1:length(entryPoints)
                    ep=entryPoints{ii};
                    [dDir,designNames{ii},~]=fileparts(ep);
                    checkDesignDir(dDir,prjRoot);
                end
                primaryDesignName=designNames{1};

                obj.fpc=coder.internal.Float2FixedConverter(designNames);
                fm=data.getFimath;
                obj.fpc.setFimathString(char(fm));




                isFixPtDesigned=com.mathworks.toolbox.coder.app.UnifiedTargetFactory.isFixedPointConverterProject(configuration);
                obj.fpc.UseCoderForCodegen=~isFixPtDesigned;

                codingForHDL=data.getClass.getName.contains(java.lang.String('HDLCoder'));

                if isFixPtDesigned
                    obj.fpc.fxpCfg.ProposeTypesMode=coder.FixPtConfig.MODE_FIXPT;
                elseif codingForHDL
                    obj.fpc.fxpCfg.ProposeTypesMode=coder.FixPtConfig.MODE_HDL;
                else
                    obj.fpc.fxpCfg.ProposeTypesMode=coder.FixPtConfig.MODE_C;
                end

                if~codingForHDL

                    obj.fpc.floatGlobalTypes=obj.getGlobalTypes(configuration,obj.fpc.fxpCfg.ProposeTypesMode);
                end

                obj.fpc.isGUIWorkflow=true;


                obj.fpc.fxpCfg.ComputeCodeCoverage=data.isCoverageEnabled;
                obj.fpc.fxpCfg.HistogramLogging=data.isHistogramLoggingEnabled;

                buildPath=char(data.getBuildPath);
                workingPath=char(data.getWorkingPath);%#ok<NASGU>
                isBuildFolderSpecified=data.isBuildFolderSpecified;

                if isBuildFolderSpecified


                    obj.fpc.fxpCfg.CodegenDirectory=buildPath;
                    [buildDirRoot,codegenFolderName,~]=fileparts(buildPath);
                    designFolderName=primaryDesignName;

                    [workDir,outputDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(buildDirRoot,codegenFolderName,designFolderName);
                else


                    codegenFolderName='codegen';
                    designFolderName=primaryDesignName;

                    [workDir,outputDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(prjRoot,codegenFolderName,designFolderName);
                end

                obj.fpc.fxpCfg.DesignDirectory=dDir;
                obj.fpc.fxpCfg.CodegenWorkDirectory=workDir;
                obj.fpc.fxpCfg.OutputFilesDirectory=outputDir;


                for ii=1:length(entryPoints)
                    ep=entryPoints{ii};
                    obj.fpc.inputTypes{ii}=coderprivate.Float2FixedManager.getInputs(data.getConfiguration(),ep);
                end

                fm=data.getFimath;
                obj.fpc.setFimathString(char(fm));

                obj.fpc.inferTypes();

                if obj.deferredBackendLoad
                    obj.fpc.loadConverterState();
                    obj.deferredBackendLoad=false;
                end
                [report,f2fCompatibilityMessages,callerCalleeList]=obj.fpc.buildDesign(true);
                messages=coderprivate.convertMessagesToJavaArray(report);
                messages=coderprivate.Float2FixedManager.FilterForcePushToCloudMessage(messages,entryPoints);
                f2fCompatibilityMessages=arrayfun(@(msg)msg.toGUIStruct(),f2fCompatibilityMessages);
                messages=[messages,f2fCompatibilityMessages];
                success=report.summary.passed&&~coder.internal.lib.Message.containErrorMsgs(f2fCompatibilityMessages);
                mexFile=fullfile(obj.fpc.fxpCfg.OutputFilesDirectory,[obj.fpc.floatMexFileName,'.',mexext]);

                obj.fpc.addDataFromUI(data.getComputedFixedPointData);


                inference=obj.fpc.getInferenceForGUI();



                if(success)
                    inference.FixedPointVariableInfo=obj.fpc.getVariableInfo();
                    obj.origCoderReport=report;
                else
                    obj.origCoderReport=[];
                end
            catch ex
                obj.origCoderReport=[];
                if~isempty(strfind(ex.identifier,'Coder:'))
                    errorMessage=ex.message;
                else
                    rethrow(ex);
                end
            end

            function checkDesignDir(dDir,prjRoot)
                if(ispc&&~strcmpi(dDir,prjRoot))
                    error(message('Coder:FXPCONV:InvalidDesignDirectory'));
                elseif(~ispc&&~strcmp(dDir,prjRoot))
                    error(message('Coder:FXPCONV:InvalidDesignDirectory'));
                end
            end
        end



        function[ranges,expressions,coverageInfo,errorMessage,messages]=runSimulation(obj,data,entryPoint,testFile,~,~,~)%#ok<INUSL>
            errorMessage='';
            coverageInfo=[];
            ranges=[];
            expressions=[];
            messages=[];
            try

                searchPaths=cell(data.getSearchPaths());
                if~isempty(searchPaths)
                    oldPath=obj.addSearchPaths(searchPaths);
                    c=onCleanup(@()path(oldPath));
                end

                obj.fpc.addTestBench(testFile);

                enableInstrumentation=true;

                obj.fpc.fxpCfg.HistogramLogging=data.isHistogramLoggingEnabled;
                obj.fpc.fxpCfg.ComputeCodeCoverage=data.isCoverageEnabled;
                obj.fpc.fxpCfg.UseSimulationRanges=data.isUsingSimulationRanges;
                obj.fpc.fxpCfg.UseDerivedRanges=data.isUsingDerivedRanges;

                [~,testFileName,~]=fileparts(testFile);
                [coverageInfo,messages]=obj.fpc.computeSimulationRanges(testFileName,enableInstrumentation);

                [ranges,expressions,proposeTypesMsgs]=proposeTypes(obj,data);
                messages=arrayfun(@(msg)msg.toGUIStruct(),[messages,proposeTypesMsgs]);
            catch ex
                if strfind(ex.identifier,'Coder:FXPCONV:')
                    errorMessage=ex.message;
                else
                    rethrow(ex);
                end
            end
        end



        function[ranges,expressions,messages,errorMessage,bbaResult]=computeDerivedRanges(obj,data,entryPoint)
            errorMessage='';
            ranges=[];
            bbaResult=[];
            try

                searchPaths=cell(data.getSearchPaths());
                if~isempty(searchPaths)
                    oldPath=obj.addSearchPaths(searchPaths);
                    c=onCleanup(@()path(oldPath));
                end

                obj.fpc.inputTypes=coderprivate.Float2FixedManager.getInputs(data.getConfiguration,entryPoint);
                obj.fpc.addAnnotationsFromPlugin(data.getUserFixedPointData);

                obj.fpc.fxpCfg.ComputeDerivedRanges=true;
                obj.fpc.fxpCfg.UseSimulationRanges=data.isUsingSimulationRanges;
                obj.fpc.fxpCfg.UseDerivedRanges=data.isUsingDerivedRanges;


                obj.fpc.fxpCfg.StaticAnalysisTimeoutMinutes=data.getStaticAnalysisTimeoutMinutes();
                obj.fpc.fxpCfg.StaticAnalysisQuickMode=data.isStaticAnalysisLimitedToGlobalRanges();

                [~,f2fCompatibilityMessages,bbaResult]=obj.fpc.computeDerivedRanges;

                messages=arrayfun(@(msg)msg.toGUIStruct(),f2fCompatibilityMessages);

                [ranges,expressions,proposeTypesMsgs]=proposeTypes(obj,data);

                proposeTypesMsgs=arrayfun(@(msg)msg.toGUIStruct(),proposeTypesMsgs);

                messages=[messages,proposeTypesMsgs];
            catch ex
                if strfind(ex.identifier,'Coder:FXPCONV:')
                    errorMessage=ex.message;
                else
                    rethrow(ex);
                end
            end
        end

        function data=getHistogramData(obj,fcnUniqueID,varName)
            data=obj.fpc.getHistogramData(fcnUniqueID,varName);
        end

        function[success,report,outputSummary,isVarLoggableInfo,messages,errorMessage]=generateFixedPointCode(obj,data,~)
            errorMessage='';
            messages=[];
            outputSummary=[];
            success=false;
            report=[];
            isVarLoggableInfo={};
            try

                searchPaths=cell(data.getSearchPaths());
                if~isempty(searchPaths)
                    oldPath=obj.addSearchPaths(searchPaths);
                    c=onCleanup(@()path(oldPath));
                end

                fxpFileSuffix=char(data.getGeneratedFileSuffix);
                obj.fpc.fxpCfg.FixPtFileNameSuffix=fxpFileSuffix;
                obj.fpc.fxpCfg.DetectFixptOverflows=data.isOverflowDetectionEnabled();
                fm=data.getFimath;


                obj.fpc.setFimathString(char(fm));



                obj.fpc.addAnnotationsFromPlugin(data.getUserFixedPointData);
                obj.fpc.addFunctionReplacementsFromPlugin(data.getFunctionReplacements);


                obj.fpc.fxpCfg.clearApproximations();
                mathApproxConfigs=coderprivate.Float2FixedManager.getMathFcnGenConfigs(data);
                cellfun(@(approxCfg)obj.fpc.fxpCfg.addApproximation(approxCfg),mathApproxConfigs);
                launchReport=obj.fpc.fxpCfg.LaunchNumericTypesReport;
                typeReportPath=obj.fpc.printTypeReport(launchReport);


                obj.fpc.fxpCfg.HighlightPotentialDataTypeIssues=data.isEnableEfficiencyChecks();

                pEPIndex=1;
                if~coder.internal.Float2FixedConverter.checkFixedPointCodeName(obj.fpc.DesignFunctionNames{pEPIndex},fxpFileSuffix)
                    throw(MException(message('Coder:FXPCONV:invalidFixPtSuffixGUI',fxpFileSuffix)));
                end

                [report,outputSummary,isVarLoggableInfo,f2fmsgs]=obj.fpc.generateFixedPointCode();
                outputSummary.reports{end+1}=typeReportPath;
                outputSummary.typeReport=typeReportPath;
                outputSummary.data.report=obj.origCoderReport;

                f2fmsgs=arrayfun(@(msg)msg.toGUIStruct(),f2fmsgs);
                messages=coderprivate.convertMessagesToJavaArray(report);
                messages=[f2fmsgs,messages];
                success=~isempty(report)&&isfield(report,'summary')&&report.summary.passed;
            catch ex
                if strfind(ex.identifier,'Coder:FXPCONV:')
                    errorMessage=ex.message;
                else
                    rethrow(ex);
                end
            end
        end

        function[messages,errorMessage,errStructInfo,reportFile]=verifyNumerics(obj,data,~,testFiles)
            messages=[];
            errorMessage='';
            errStructInfo=repmat(coder.internal.Float2FixedConverter.getErrorStruct(),0,0);
            reportFile='';

            try

                searchPaths=cell(data.getSearchPaths());
                if~isempty(searchPaths)
                    oldPath=obj.addSearchPaths(searchPaths);
                    c=onCleanup(@()path(oldPath));
                end

                [~,testFileNames,~]=cellfun(@(testFile)fileparts(testFile),testFiles,'UniformOutput',false);

                customPlotFunction=strtrim(char(data.getPlotFunction));

                if~isempty(customPlotFunction)
                    obj.fpc.fxpCfg.PlotFunction=customPlotFunction;
                else
                    obj.fpc.fxpCfg.PlotFunction=[];
                end

                obj.fpc.fxpCfg.PlotWithSimulationDataInspector=data.plotWithSDI();

                logIOForPlots=data.isVerificationLoggingEnabled;
                if logIOForPlots
                    tmpVarsToLogMap=obj.parseLogEnabledVars(data.getUserFixedPointData());
                    obj.fpc.constructCoderEnabledLogListForSelected(tmpVarsToLogMap);
                    obj.fpc.fxpCfg.EnableMEXLogging=true;
                end
                obj.fpc.fxpCfg.LogIOForComparisonPlotting=logIOForPlots;
                obj.fpc.fxpCfg.DetectFixptOverflows=data.isOverflowDetectionEnabled();
                [msgs,reportFile]=obj.fpc.verifyFixedPoint(testFileNames);
                errStructInfo=obj.fpc.coderLoggedErrorData;
                if~isempty(msgs)
                    messages=arrayfun(@(msg)msg.toGUIStruct(),msgs);
                end




            catch ex
                if strfind(ex.identifier,'Coder:FXPCONV:')
                    errorMessage=ex.message;
                else
                    rethrow(ex);
                end
            end
        end



        function generatePlot(obj,uniqueID,variableName,variableKind)
            if strcmp(variableKind,coder.internal.ComparisonPlotService.INOUT_EXPR)
                obj.fpc.generatePlot(uniqueID,variableName,coder.internal.ComparisonPlotService.INPUT_EXPR);
                obj.fpc.generatePlot(uniqueID,variableName,coder.internal.ComparisonPlotService.OUTPUT_EXPR);
            else
                obj.fpc.generatePlot(uniqueID,variableName,variableKind);
            end
        end



        function variables=getVariableKinds(~,entryPoint)
            try
                info=coder.internal.tools.MLFcnInfo(entryPoint);
                variableIndex=1;
                keyList=keys(info);
                variables={};
                for i=1:numel(keyList)
                    key=keyList{1};
                    variables{variableIndex}={key,info(key).inputVars,info{key}.outputVars,info(key).persistentVars};%#ok<AGROW>
                end
            catch me
                me.throwAsCaller();
            end
        end


        function[types,expressions,messages]=proposeTypes(obj,data)
            try
                if data.isProposingFractionLengths
                    obj.fpc.fxpCfg.ProposeFractionLengthsForDefaultWordLength=true;
                    obj.fpc.fxpCfg.ProposeWordLengthsForDefaultFractionLength=false;
                else
                    obj.fpc.fxpCfg.ProposeFractionLengthsForDefaultWordLength=false;
                    obj.fpc.fxpCfg.ProposeWordLengthsForDefaultFractionLength=true;
                end

                defWL=data.getDefaultWordLength;
                obj.fpc.fxpCfg.DefaultWordLength=defWL;

                defFL=data.getDefaultFractionLength;
                obj.fpc.fxpCfg.DefaultFractionLength=defFL;

                defSignedness='Automatic';
                if~data.isDefaultSignednessAutomatic
                    if data.isDefaultSignednessUnsigned
                        defSignedness='Unsigned';
                    else
                        defSignedness='Signed';
                    end
                end
                obj.fpc.fxpCfg.DefaultSignedness=defSignedness;

                obj.fpc.fxpCfg.OptimizeWholeNumber=data.isOptimizeWholeNumbersEnabled;

                fxpMargin=data.getSafetyMargin();
                obj.fpc.fxpCfg.SafetyMargin=fxpMargin;

                obj.fpc.fxpCfg.UseSimulationRanges=data.isUsingSimulationRanges;
                obj.fpc.fxpCfg.UseDerivedRanges=data.isUsingDerivedRanges;

                assert(obj.fpc.fxpCfg.UseSimulationRanges||obj.fpc.fxpCfg.UseDerivedRanges);

                fm=data.getFimath;
                obj.fpc.setFimathString(char(fm));

                obj.fpc.addAnnotationsFromPlugin(data.getUserFixedPointData);
                obj.fpc.fxpCfg.ProposeTargetContainerTypes=data.isProposeContainerTypesEnabled();
                [types,expressions,messages]=obj.fpc.proposeTypes();
                obj.fpc.addAnnotationsFromPlugin(data.getUserFixedPointData);
            catch me
                me.throwAsCaller();
            end
        end

    end

    methods(Access=private)

        function gTypes=getGlobalTypes(~,javaConfig,mode)
            gTypes={};

            if strcmp(mode,coder.FixPtConfig.MODE_FIXPT)
                if strcmp(char(javaConfig.getParamAsString('param.UseGlobals'))...
                    ,'option.UseGlobals.No')
                    return
                end
            end

            paramGlobals=coder.internal.gui.GuiUtils.getGlobalsReader(javaConfig);
            if isempty(paramGlobals)
                return;
            end

            [nGtcs,gtcs]=emlcprivate('getGlobalTypesFromXml',paramGlobals,coder.internal.FeatureControl);

            if nGtcs>0
                gTypes=gtcs;
            end
        end


        function pathBackup=addSearchPaths(~,searchPaths)
            assert(~isempty(searchPaths));
            assert(1==nargout);
            searchPaths=strjoin(searchPaths',':');
            pathBackup=path;

            if isfolder(searchPaths)
                addpath(searchPaths);
            else
                old_warning=warning;
                warning('off','backtrace');
                warning(message('Coder:FXPCONV:SearchPathsNotFound',searchPaths));
                warning(old_warning);
            end
        end



        function coderVarMaps=parseLogEnabledVars(~,xmlReader)
            coderVarMaps=coder.internal.lib.Map();

            functionReader=xmlReader.getChild('Function');
            while functionReader.isPresent()
                functionName=functionReader.readAttribute('name').toCharArray';
                uniqID=functionReader.readAttribute('uniqueId');
                if~isempty(uniqID)
                    uniqID=uniqID.toCharArray';
                else
                    uniqID=functionName;
                end

                varsToLog={};
                variableReader=functionReader.getChild('Variable');
                while(variableReader.isPresent)
                    variableName=variableReader.readAttribute('name').toCharArray';
                    fieldReader=variableReader.getChild('Column');
                    while fieldReader.isPresent
                        fieldName=fieldReader.readAttribute('property').toCharArray';
                        if strcmp(fieldName,'LoggingEnabled')
                            if strcmp('true',strtrim(fieldReader.readAttribute('value').toCharArray()'))
                                varsToLog{end+1}=variableName;%#ok<AGROW>
                            end
                        end
                        fieldReader=fieldReader.next();
                    end
                    variableReader=variableReader.next();
                end

                coderVarMaps(uniqID)=varsToLog;
                functionReader=functionReader.next();
            end
        end
    end

    methods(Static)

        function messages=FilterForcePushToCloudMessage(messages,entryPoints)
            if(~isempty(messages)&&...
                strcmpi(messages(1).functionName,'forcePushIntoCloud')&&...
                strfind(messages(1).file,matlabroot))






                [~,designName,~]=fileparts(entryPoints{1});
                messages(1).functionName=designName;
                messages(1).file=entryPoints{1};
            end
        end

        function applyFunctionReplacementsToConfig(config,xmlReader)


            assert(isa(xmlReader,'com.mathworks.project.api.XmlReader'));
            assert(isa(config,'coder.FixPtConfig'));


            coder.internal.Float2FixedConverter.loadFunctionReplacementsFromProject(xmlReader,config);


            config.clearApproximations();
            mathApproxConfigs=coderprivate.Float2FixedManager.getMathFcnGenConfigsFromXml(xmlReader);
            cellfun(@(approxCfg)config.addApproximation(approxCfg),mathApproxConfigs);
        end

        function approxCfgs=getMathFcnGenConfigs(data)
            dataXml=data.getFunctionReplacements();
            if~isempty(dataXml)
                approxCfgs=coderprivate.Float2FixedManager.getMathFcnGenConfigsFromXml(data.getFunctionReplacements());
            else
                approxCfgs={};
            end
        end

        function approxCfgs=getMathFcnGenConfigsFromXml(xmlReaderObj)
            approxCfgs={};
            import com.mathworks.project.impl.ProjectGUI
            import com.mathworks.toolbox.coder.fixedpoint.replace.FunctionReplacementStrategies
            import com.mathworks.toolbox.coder.fixedpoint.replace.FunctionReplacementsModel

            assert(isa(xmlReaderObj,'com.mathworks.project.api.XmlReader'));
            interpLookUp=coder.internal.lib.Map();
            interpLookUp('NONE')=0;
            interpLookUp('LINEAR')=1;
            interpLookUp('QUADRATIC')=2;
            interpLookUp('CUBIC')=3;
            interpLookUp('FLAT')=4;

            ser=FunctionReplacementsModel.createDefaultSerializer();
            map=ser.deserialize(xmlReaderObj);
            entries=map.entrySet.toArray;
            for ii=1:length(entries)
                entry=entries(ii);
                fcn=char(entry.getKey.getFunctionName);
                if~isempty(fcn)
                    strgObj=entry.getValue;
                    if isa(strgObj,'com.mathworks.toolbox.coder.fixedpoint.replace.FunctionReplacementStrategies$LookupTable')
                        interpolation=char(strgObj.getDegreeOfInterpolation);
                        designMin=char(strgObj.getInputMin);
                        designMax=char(strgObj.getInputMax);
                        if strcmp(designMin,'Auto')||strcmp(designMax,'Auto')
                            designMin=[];
                            designMax=[];
                        else
                            designMin=str2double(designMin);
                            designMax=str2double(designMax);
                        end
                        numberOfPoints=strgObj.getResolutionAttribute();

                        approxCfgs{end+1}=coderprivate.Float2FixedManager.BuildApproxationObj(fcn,numberOfPoints,designMin,designMax,interpolation,interpLookUp);%#ok<AGROW>
                    end
                end
            end
        end


        function approxCfg=BuildApproxationObj(fcn,numberOfPoints,designMin,designMax,interpolation,interpLookUp)
            isFlatMode=strcmpi(interpolation,'Flat');
            if(isFlatMode)
                arch='Flat';
            else
                arch='LookupTable';
            end
            approxCfg=coder.approximation('Function',fcn,'Architecture',arch);
            tmp=coder.internal.mathfcngenerator.MathFunctionGenerator;
            isASupportedFcn=tmp.isSupportedFunction(fcn);
            if~isASupportedFcn
                approxCfg.CandidateFunction=str2func(fcn);
            end
            approxCfg.NumberOfPoints=numberOfPoints;
            if~isempty(designMin)&&~isempty(designMax)
                approxCfg.InputRange=[designMin,designMax];
            end
            if(~isFlatMode)
                assert(any(strcmp(interpLookUp.keys,interpolation)),'Incorrect interpolation found');
                approxCfg.InterpolationDegree=interpLookUp(interpolation);
            end
        end

        function inDataProps=getInputs(configuration,file)
            inDataProps={};
            data=coder.internal.gui.GuiUtils.getInputRootReader(configuration,java.io.File(file));
            if~isempty(data)
                [xInput,idpTable]=coder.internal.gui.GuiUtils.getInputDataReader(data);
                nItcs=0;

                while xInput.isPresent()
                    inputName=char(xInput.readAttribute('Name'));
                    try
                        inputs=emlcprivate('xml2type',coder.internal.FeatureControl,xInput,inputName,inputName,idpTable);
                        for input=1:numel(inputs)
                            nItcs=nItcs+1;
                            iTcs{nItcs}=inputs(input);%#ok<AGROW>
                        end
                    catch ex
                        if strcmp(ex.identifier,'Coder:common:TypeSpecUnknownClass')

                            mEx=MException(message('Coder:FXPCONV:InputTypesNotDefined',inputName));
                            mEx.addCause(ex);
                            throw(mEx);
                        else
                            throw(ex);
                        end
                    end
                    xInput=xInput.next();
                end

                if nItcs
                    inDataProps=iTcs;
                end
            end
        end
    end
end
