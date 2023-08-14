


classdef ConvertToSingle<handle

    properties(Constant)
        AUTO_GENERATED_MARKER='auto-generated';
        SINGLE_PRECISION_MLFB_SUFFIX='_single';
        WORKING_DIRECTORY=fullfile('slprj','double2single');
    end

    properties(Access=private)
mlfbHandle
entryPointName
workingDir
generatedCode
singleConfig


        fcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry.empty;
        exprMap=containers.Map;
    end

    methods(Access=public)

        function this=ConvertToSingle(mlfb)
            this.mlfbHandle=get_param(mlfb,'Handle');
            this.workingDir=this.getWorkingDir;

            this.singleConfig=coder.config('single');
            this.singleConfig.CodegenDirectory=fullfile(this.workingDir,'codegen');
            this.singleConfig.TestBenchName=[];
            this.singleConfig.ComputeSimulationRanges=false;
            this.singleConfig.ComputeCodeCoverage=false;
            this.singleConfig.OutputFileNameSuffix='_single';
            this.singleConfig.HighlightPotentialDataTypeIssues=false;
            this.singleConfig.TestNumerics=false;
            this.singleConfig.LogIOForComparisonPlotting=false;
            this.singleConfig.PlotFunction=[];
            this.singleConfig.PlotWithSimulationDataInspector=false;
            this.singleConfig.ProposeTypesMode=coder.FixPtConfig.MODE_MLFB;

            this.generatedCode='';
        end

        function initializeFcnInfoRegistry(this)
            import coder.internal.FcnInfoRegistryBuilder.populateFcnInfoRegistryFromInferenceInfo;

            try
                report=this.fetchMLFBReport();
            catch ex
                rethrow(ex);
            end

            this.entryPointName=report.Functions(1).FunctionName;
            [userWrittenFunctions,designNames]=this.getUserWrittenFunctions(report);
            this.fcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry();
            [~,this.exprMap]=populateFcnInfoRegistryFromInferenceInfo(report,designNames,userWrittenFunctions,this.fcnInfoRegistry,{});


            if isempty(this.exprMap)
                blockPath=getfullname(this.mlfbHandle);
                ex=MException('Coder:FXPCONV:DesignF2FEmpty_DTS',message('Coder:FXPCONV:DesignF2FEmpty_DTS',blockPath).getString());
                throw(ex);
            end


            this.fcnInfoRegistry.setFimath(eval(this.singleConfig.fimath));
        end

        function messages=runConformanceCheck(this)
            driver=coder.internal.Float2FixedConstrainerDriver(this.fcnInfoRegistry,this.entryPointName);


            [messages,~]=driver.constrain(...
            false,...
            true,...
            true,...
            this.mlfbHandle);

            fcnTypeInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos;




            runDMMChecks=false;


            dvoCfg=[];

            processedClasses=containers.Map;
            doubleToSingle=true;
            arrayOfStructSupport=this.singleConfig.EnableArrayOfStructures;
            isMLFBApply=true;
            dvoNonScalarSupport=this.singleConfig.isNonScalarSupportedForDVO;


            isCompatible=true;

            for i=1:numel(fcnTypeInfos)
                fcnInfo=fcnTypeInfos{i};

                [compatible,messages]=fcnInfo.isF2FCompatible(...
                messages,runDMMChecks,dvoCfg,processedClasses,...
                doubleToSingle,arrayOfStructSupport,isMLFBApply,...
                dvoNonScalarSupport);

                isCompatible=isCompatible&&compatible;
            end

            if~isCompatible

                assert(coder.internal.lib.Message.containErrorMsgs(messages));
            end
        end



        function messages=proposeTypes(this)
            messages=coder.internal.lib.Message.empty();

            generateNegFractionLenWarning=false;
            [~,messages]=coder.internal.computeBestTypes(this.fcnInfoRegistry,this.getTypeProposalSettings(),generateNegFractionLenWarning,messages);
        end





        function[messages,statefulFiles]=convert(this,prevStatefulFiles)

            this.setupConvertDir();

            designSettings=this.getDesignSettings();
            fxpConversionSettings=this.getConversionSettings();
            typePropSettings=this.getTypeProposalSettings();
            fpc=coder.internal.DesignTransformer(designSettings,typePropSettings,fxpConversionSettings);

            try
                inputTypeSpec={};
                [~,~,messages,statefulFiles]=fpc.doIt(inputTypeSpec,prevStatefulFiles);
            catch ex
                rethrow(ex);
            end



            outputFileName=fullfile(fpc.outputPath,[fpc.fixPtDesignNames{1},'.m']);
            this.generatedCode=fileread(outputFileName);
        end



        function deleteWorkingDir(this)
            try
                if exist(this.workingDir,'dir')==7
                    rmdir(this.workingDir,'s');
                end
            catch
            end
        end

        function replaceMLFB(this)

            import coder.internal.mlfbDoubleToSingle.utils.SLHelper;

            blockPath=getfullname(this.mlfbHandle);

            if strcmp(coder.internal.f2ffeature('MLFBApplyStyle'),'Replace')


                rt=sfroot;
                sfChartH=rt.find('-isa','Stateflow.Chart','Path',blockPath);
                emChartH=rt.find('-isa','Stateflow.EMChart','Path',blockPath);
                chart=[sfChartH,emChartH];
                chart.Script=this.generatedCode;
            elseif strcmp(coder.internal.f2ffeature('MLFBApplyStyle'),'Variants')

                [origMLFB,singleMLFB,varSubSys,newCreation]=coder.internal.mlfbDoubleToSingle.makeVariantSubsystemForMLFB(blockPath);


                coder.internal.mlfbDoubleToSingle.addMLFBAnnotation(varSubSys,get_param(origMLFB,'Name'),get_param(singleMLFB,'Name'));

                if newCreation
                    set_param(origMLFB,'TreatAsAtomicUnit','on');
                    set_param(singleMLFB,'TreatAsAtomicUnit','on');
                    set_param(varSubSys,'TreatAsAtomicUnit','on');
                end





                if~strcmp(blockPath,singleMLFB)

                    origChart=SLHelper.getChart(origMLFB);
                    singleChart=SLHelper.getChart(singleMLFB);


                    set_param(singleMLFB,'Permissions','ReadWrite');


                    SLHelper.copyChartAndInterfaceObjectsProperties(origChart,singleChart);


                    singleChart.Script=this.generatedCode;


                    this.changeIOTypesInConvertedMLFB(singleMLFB);


                    set_param(origMLFB,'Permissions','ReadOnly');
                else

                    newCreation=false;
                end
            end
        end
    end


    methods(Hidden)
        function name=getEntryPointName(this)
            name=this.entryPointName;
        end
    end

    methods(Access=private)

        function resetAnnotatedTypes(this)
            funcs=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.clearAnnotations();
                end
            end
        end


        function setupConvertDir(this)
            d=this.getOutputFilesDir();

            if 7~=exist(d,'dir')

                mkdir(d);
            end
        end


        function report=fetchMLFBReport(this)
            blockPath=getfullname(this.mlfbHandle);


            rt=sfroot;
            sfChartH=rt.find('-isa','Stateflow.Chart','Path',blockPath);
            emChartH=rt.find('-isa','Stateflow.EMChart','Path',blockPath);
            chartH=[sfChartH,emChartH];

            report=sfprivate('eml_report_manager','report',chartH.Id,this.mlfbHandle,true);
            if isempty(report)
                ex=MException('Coder:FXPCONV:DTS_MLFB_EMFUNCTION',message('Coder:FXPCONV:DTS_MLFB_EMFUNCTION',blockPath).getString());
                throw(ex);
            end

            report=report.inference;
        end



        function changeIOTypesInConvertedMLFB(this,singleMLFB)

            import coder.internal.mlfbDoubleToSingle.utils.SLHelper;
            chartObj=SLHelper.getChart(singleMLFB);

            inheritStr='Inherit: Same as Simulink';


            ins=chartObj.Inputs;
            for i=1:numel(ins)
                if strcmp(ins(i).DataType,'double')
                    ins(i).DataType=inheritStr;
                end
            end


            outs=chartObj.Outputs;
            for i=1:numel(outs)
                if strcmp(outs(i).DataType,'double')
                    outs(i).DataType=inheritStr;
                end
            end






            slrt=slroot;
            params=find(slrt,'Path',getfullname(singleMLFB),...
            'Scope','Parameter');



            maskNames=get_param(singleMLFB,'MaskNames');
            maskValues=get_param(singleMLFB,'MaskValues');

            mlfbTypeInfo=this.getDesignTypeInfo;

            for i=1:numel(params)
                param=params(i);



                if strcmp(param.DataType,'double')
                    param.DataType=inheritStr;
                end


                maskIdx=find(strcmp(maskNames,param.Name));

                if~isempty(maskIdx)

                    assert(isscalar(maskIdx));


                    varTypeInfos=mlfbTypeInfo.getVarInfosByName(param.Name);
                    if~isempty(varTypeInfos)

                        typeInfo=varTypeInfos{1};
                        type=typeInfo.annotated_Type;

                        if ischar(type)&&strcmp(type,'single')

                            maskValues{maskIdx}=sprintf('single(%s)',maskValues{maskIdx});
                        end
                    end
                end
            end
        end



        function mlfbTypeInfo=getDesignTypeInfo(this)
            functionTypeInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            mlfbTypeInfo=[];
            for ii=1:numel(functionTypeInfos)
                if functionTypeInfos{ii}.isDesign
                    mlfbTypeInfo=functionTypeInfos{ii};
                    break;
                end
            end

            assert(~isempty(mlfbTypeInfo),'DUT Function Type Info cannot be empty');
        end

        function[userWrittenFunctions,designNames]=getUserWrittenFunctions(~,inferenceReport)
            inferenceReportFunctions=inferenceReport.Functions;
            inferenceReportScripts=inferenceReport.Scripts;
            rootFcns=inferenceReport.RootFunctionIDs;

            designNames=cell(1,length(inferenceReportFunctions));
            designNamesIdx=1;
            userWrittenFunctions=containers.Map;

            for ii=1:length(inferenceReportFunctions)
                fcnInfo=inferenceReportFunctions(ii);
                fcnName=fcnInfo.FunctionName;

                if(fcnInfo.ScriptID<1)||...
                    (fcnInfo.ScriptID>length(inferenceReportScripts))
                    continue;
                end

                if~inferenceReportScripts(fcnInfo.ScriptID).IsUserVisible


                    continue;
                end






                userWrittenFunctions(fcnName)=true;

                if any(ii==rootFcns)
                    designNames{designNamesIdx}=fcnName;
                    designNamesIdx=designNamesIdx+1;
                end
            end

            designNames(designNamesIdx:end)=[];
        end

        function fixptDesignName=getOutputDesignName(this,design)
            ext=this.singleConfig.OutputFileNameSuffix;
            fixptDesignName=[design,ext];
        end

        function fixPtWrapperName=getOutputWrapperName(this,design)
            ext=this.singleConfig.OutputFileNameSuffix;
            wrapper_prefix=coder.internal.Float2FixedConverter.getDefaultWrapperSuffix();

            fixPtWrapperName=[design,wrapper_prefix,ext];
        end


        function designSettings=getDesignSettings(this)
            design=this.entryPointName;

            fixptDName=this.getOutputDesignName(design);
            fixptWrapperName=this.getOutputWrapperName(design);

            designSettings.designNames={design};
            designSettings.fixPtDesignNames={fixptDName};

            designSettings.designActualFcnNames=design;
            designSettings.outputPath=this.getOutputFilesDir();
            designSettings.fcnInfoRegistry=this.fcnInfoRegistry;

            designSettings.globalUniqNameMap=this.fcnInfoRegistry.getUniqGlobalNameMapping();

            designSettings.simExprInfo=[];
            designSettings.compiledExprInfo=this.exprMap;

            designSettings.testbenchName='';
            designSettings.designIOWrapperName={fixptWrapperName};
        end


        function conversionSettings=getConversionSettings(this)

            persistent p;
            if~isempty(p)
                conversionSettings=p;
                return;
            end

            conversionSettings.autoScaleLoopIndexVars=false;
            conversionSettings.globalFimathStr=this.singleConfig.fimath;
            conversionSettings.fiMathVarName='';
            conversionSettings.userFcnTemplatePath=this.singleConfig.UserFunctionTemplatePath;

            conversionSettings.userFcnMap=containers.Map();
            conversionSettings.suppressErrorMessages=this.singleConfig.SuppressErrorMessages;
            conversionSettings.fiCastFiVars=this.singleConfig.FiCastFiVars;
            conversionSettings.fiCastIntegers=this.singleConfig.FiCastIntegerVars;
            conversionSettings.fiCastDoubleLiteralVars=this.singleConfig.FiCastDoubleLiteralVars;
            conversionSettings.detectFixptOverflows=this.singleConfig.DetectFixptOverflows;
            conversionSettings.debugEnabled=this.singleConfig.DebugEnabled;
            conversionSettings.autoReplaceCfgs=this.singleConfig.getMathFcnConfigs;
            conversionSettings.FixPtFileNameSuffix=this.singleConfig.OutputFileNameSuffix;
            conversionSettings.GenerateParametrizedCode=this.singleConfig.GenerateParametrizedCode;
            conversionSettings.UseF2FPrimitives=this.singleConfig.UseF2FPrimitives;



            conversionSettings.detectDeadCode=0;
            conversionSettings.TransformF2FInIR=false;
            conversionSettings.DoubleToSingle=true;
            conversionSettings.EmitSeperateFimathFunction=this.singleConfig.EmitSeperateFimathFunction;
            conversionSettings.MLFBApply=strcmp(this.singleConfig.ProposeTypesMode,coder.FixPtConfig.MODE_MLFB);

            p=conversionSettings;
        end





        function typeProposalSettings=getTypeProposalSettings(this)

            typeProposalSettings.proposeTargetContainerTypes=this.singleConfig.ProposeTargetContainerTypes;
            typeProposalSettings.defaultWL=this.singleConfig.DefaultWordLength;
            typeProposalSettings.defaultFL=this.singleConfig.DefaultFractionLength;
            defSigned=this.singleConfig.DefaultSignedness;
            switch defSigned
            case coder.FixPtConfig.AutoSignedness
                s=[];
            case coder.FixPtConfig.SignedSignedness
                s=true;
            case coder.FixPtConfig.UnsignedSignedness
                s=false;
            otherwise
                assert(false,'Incorrect default signedness value');
            end
            typeProposalSettings.defaultSignedness=s;
            typeProposalSettings.optimizeWholeNumber=this.singleConfig.OptimizeWholeNumber;
            typeProposalSettings.proposeWLForDefFL=this.singleConfig.ProposeWordLengthsForDefaultFractionLength;
            typeProposalSettings.proposeFLForDefWL=this.singleConfig.ProposeFractionLengthsForDefaultWordLength;
            typeProposalSettings.safetyMargin=this.singleConfig.SafetyMargin;

            typeProposalSettings.defaultFimath=eval(this.singleConfig.fimath);
            typeProposalSettings.codingForHDL=this.singleConfig.CodingForHDL;
            typeProposalSettings.useSimulationRanges=this.singleConfig.UseSimulationRanges;
            typeProposalSettings.useDerivedRanges=this.singleConfig.UseDerivedRanges;
            typeProposalSettings.DoubleToSingle=true;
            typeProposalSettings.proposeAggregateStructTypes=false;
            typeProposalSettings.Config=this.singleConfig;
        end

        function d=getOutputFilesDir(this)
            d=fullfile(this.workingDir,this.entryPointName,'single','tmp');
        end



        function dir=getWorkingDir(this)






            subdirStrs=strsplit(getfullname(this.mlfbHandle),...
            '\W','DelimiterType','RegularExpression');

            for i=0:numel(subdirStrs)-1


                subdir=strjoin(subdirStrs(end-i:end),'_');
                dir=fullfile(this.WORKING_DIRECTORY,subdir);

                if exist(dir,'dir')~=7


                    return
                end
            end




            lastSubdir=dir;

            for i=1:1000
                dir=[lastSubdir,'_',num2str(i)];

                if exist(dir,'dir')~=7


                    return
                end
            end






            error('Could not find a unique temporary directory for double2single conversion');
        end
    end
end


