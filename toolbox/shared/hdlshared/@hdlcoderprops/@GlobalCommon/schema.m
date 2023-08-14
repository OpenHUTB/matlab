function schema





    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'GlobalCommon',pk.findclass('AbstractProp'));

    schema.prop(c,'hdl_subsystem','mxArray');

    p=schema.prop(c,'target_language','HDLTargetLanguageType');
    set(p,'SetFunction',@set_target_language);

    p=schema.prop(c,'workflow','ustring');
    set(p,'FactoryValue','Generic ASIC/FPGA');

    p=schema.prop(c,'targetPlatform','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'referenceDesign','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'referenceDesignPath','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'targetFrequency','double');
    set(p,'FactoryValue',0,...
    'SetFunction',@set_targetfrequency);

    p=schema.prop(c,'extraEffortMargin','double');
    set(p,'FactoryValue',1);

    schema.prop(c,'filter_input_type_std_logic','bool');
    schema.prop(c,'filter_output_type_std_logic','bool');
    schema.prop(c,'comment_char','string');


    p=schema.prop(c,'split_entity_arch','bool');
    set(p,'SetFunction',@set_split_entity_arch);

    schema.prop(c,'splitMooreChartStateUpdate','bool');

    p=schema.prop(c,'loop_unrolling','bool');
    set(p,'SetFunction',@set_loop_unrolling);

    schema.prop(c,'inline_configurations','bool');
    schema.prop(c,'use_aggregates_for_const','bool');
    schema.prop(c,'safe_zero_concat','bool');
    schema.prop(c,'split_arch_file_postfix','string');
    schema.prop(c,'split_entity_file_postfix','string');
    schema.prop(c,'vhdl_package_body_decl','string');
    schema.prop(c,'vhdl_package_body_end','string');
    schema.prop(c,'vhdl_package_comment','string');
    schema.prop(c,'vhdl_package_constants','string');
    schema.prop(c,'vhdl_package_decl','string');
    schema.prop(c,'vhdl_package_decl_end','string');
    schema.prop(c,'vhdl_package_function_headers','string');
    schema.prop(c,'vhdl_package_functions','string');
    schema.prop(c,'vhdl_package_library','string');
    schema.prop(c,'vhdl_package_type_defs','string');


    schema.prop(c,'use_verilog_timescale','bool');
    schema.prop(c,'timescale','string');


    schema.prop(c,'base_data_type','string');
    schema.prop(c,'reg_data_type','string');
    schema.prop(c,'assign_prefix','string');
    schema.prop(c,'assign_op','string');
    schema.prop(c,'array_deref','string');

    schema.prop(c,'filename_suffix','string');
    schema.prop(c,'package_suffix','string');

    p=schema.prop(c,'vhdl_package_required','bool');
    set(p,'FactoryValue',false);





    schema.prop(c,'ReferenceModelPrefix','bool');
    schema.prop(c,'async_reset','bool');
    schema.prop(c,'bit_true_to_filter','bool');
    schema.prop(c,'cast_before_sum','bool');
    schema.prop(c,'checkhdl','bool');
    schema.prop(c,'enableprefix','ustring');
    schema.prop(c,'clockenablename','ustring');
    schema.prop(c,'clockname','ustring');
    schema.prop(c,'clockenableoutputname','ustring');
    schema.prop(c,'OptimizeTimingController','bool');
    schema.prop(c,'ResettableTimingController','bool');
    schema.prop(c,'TimingControllerPostfix','ustring');
    schema.prop(c,'TCCounterLimitCompOp','ustring');
    schema.prop(c,'NoResetInitializationMode','string');

    schema.prop(c,'minimizeclockenables','bool');
    schema.prop(c,'minimizeglobalresets','bool');

    p=schema.prop(c,'NoResetInitScript','ustring');
    set(p,'FactoryValue','noresetinitscript.tcl');

    p=schema.prop(c,'complexmulelaboration','ustring');
    set(p,'FactoryValue','MultiplyAddBlock');

    p=schema.prop(c,'flattenbus','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'clockinputs','int32');
    set(p,'SetFunction',@set_positive);

    schema.prop(c,'triggerasclock','int32');
    set(p,'SetFunction',@set_positive);

    schema.prop(c,'asyncresetport','bool');

    schema.prop(c,'conditionalizepipeline','bool');

    schema.prop(c,'inferControlPorts','bool');

    p=schema.prop(c,'floatingPointTargetConfiguration','mxArray');
    set(p,'FactoryValue',[],...
    'SetFunction',@set_floatingpointtargetconfiguration);

    schema.prop(c,'codegendir','ustring');
    p=schema.prop(c,'codegensubdir','int32');
    set(p,'SetFunction',@set_positiveInteger);

    p=schema.prop(c,'blockcount','int32');
    set(p,'SetFunction',@set_positive);

    schema.prop(c,'codegensuccessful','bool');
    schema.prop(c,'debug','int32');
    schema.prop(c,'generatehdlcode','bool');
    schema.prop(c,'generatemodel','bool');
    schema.prop(c,'generatetb','bool');
    schema.prop(c,'generatecegenmodel','bool');


    schema.prop(c,'traceability','bool');

    schema.prop(c,'runtimeReport','bool');

    schema.prop(c,'resourceReport','bool');

    schema.prop(c,'optimizationReport','bool');

    schema.prop(c,'ErrorCheckReport','bool');

    schema.prop(c,'hdlgeneratewebview','bool');

    schema.prop(c,'ipcoreReport','bool');

    schema.prop(c,'recommendations','bool');

    schema.prop(c,'emitRequirementComments','bool');

    schema.prop(c,'EnableComments','bool');

    schema.prop(c,'backannotation','bool');

    schema.prop(c,'hierarchicalDistPipelining','bool');

    schema.prop(c,'preserveDesignDelays','bool');

    schema.prop(c,'acquireDesignDelaysForEMLOptimizations','bool');

    schema.prop(c,'clockratepipelining','bool');
    schema.prop(c,'crpwithoutflattening','bool');
    p=schema.prop(c,'crpDelayBalancingIterLimit','int32');
    set(p,'SetFunction',@set_positiveInteger);
    schema.prop(c,'usecrpalternativestrategy','bool');
    schema.prop(c,'increasecrpbudget','bool');
    schema.prop(c,'adaptivepipelining','bool');
    schema.prop(c,'lutmaptoram','bool');
    schema.prop(c,'clockratepipelineoutputports','bool');
    schema.prop(c,'balanceclockrateoutputports','bool');
    schema.prop(c,'clonemodules','bool');

    schema.prop(c,'CriticalPathEstimation','bool');
    schema.prop(c,'TimingDatabaseDirectory','ustring');
    schema.prop(c,'StaticLatencyPathAnalysis','bool');
    schema.prop(c,'optimizeserializer','bool');
    schema.prop(c,'NumCriticalPathsEstimated','double');
    schema.prop(c,'CriticalPathEstimationFile','ustring');
    schema.prop(c,'SLPAFile','ustring');
    schema.prop(c,'SLPALoopsFile','ustring');
    schema.prop(c,'SLPABackEdgeFile','ustring');
    schema.prop(c,'SLPAGMMapMATFile','ustring');
    schema.prop(c,'HardwarePipeliningCharacterizationFile','ustring');
    schema.prop(c,'RoutingFudgeFactor','double');
    schema.prop(c,'OptimizationCompatibilityCheck','bool');
    schema.prop(c,'shareequalwl','bool');
    schema.prop(c,'sharedmulsign','int32');
    schema.prop(c,'MultiplierPromotionThreshold','int32');
    schema.prop(c,'minDelaysRequiredAtLocalMultirateOutput','int32');

    schema.prop(c,'axiStreamingTransformFeatureControl','bool');
    schema.prop(c,'axiInterface512BitDataPortFeatureControl','bool');
    schema.prop(c,'SerializerRatioThreshold','int32');

    schema.prop(c,'HighlightFeedbackLoops','bool');
    schema.prop(c,'HighlightFeedbackLoopsFile','ustring');
    schema.prop(c,'HighlightClockRatePipeliningDiagnostic','bool');
    schema.prop(c,'HighlightClockRatePipeliningFile','ustring');
    schema.prop(c,'highlightremoveddeadblocks','bool');
    schema.prop(c,'DistributedPipeliningBarriers','bool');
    schema.prop(c,'DistributedPipeliningBarriersFile','ustring');
    schema.prop(c,'HighlightLUTPipeliningDiagnostic','bool');
    schema.prop(c,'HighlightLUTPipeliningDiagnosticFile','ustring');
    schema.prop(c,'SetLUTPipeliningOffScriptFile','ustring');
    schema.prop(c,'ClearHighlightingFile','ustring');
    schema.prop(c,'BlocksWithNoCharacterizationFile','ustring');
    schema.prop(c,'RetimingCP','bool');
    schema.prop(c,'RetimingCPFile','ustring');

    schema.prop(c,'functionallyEquivalentRetiming','bool');

    p=schema.prop(c,'DistributedPipelining','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'DistributedPipeliningPrecision','int32');
    set(p,'FactoryValue',-1);

    p=schema.prop(c,'UseSynthesisEstimatesForDistributedPipelining','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'distributedPipeliningPriority','int32');
    set(p,'FactoryValue',1);

    schema.prop(c,'retimingDetails','bool');

    schema.prop(c,'criticalPathDetails','bool');

    schema.prop(c,'signalNamesMangling','double');

    schema.prop(c,'guidedRetiming','bool');

    schema.prop(c,'latencyConstraint','double');

    schema.prop(c,'reduceMatchingDelays','bool');

    schema.prop(c,'optimizationData','ustring');

    schema.prop(c,'cpGuidanceFile','ustring');

    schema.prop(c,'cpAnnotationFile','ustring');

    schema.prop(c,'maskParameterAsGeneric','bool');

    schema.prop(c,'alteraBackwardIncompatibleSinCosPipeline','bool');
    schema.prop(c,'generateTargetComps','bool');
    schema.prop(c,'familyDevicePackageSpeed','mxArray');
    schema.prop(c,'toolName','ustring');
    schema.prop(c,'synthesisToolChipFamily','ustring');
    schema.prop(c,'synthesisToolDeviceName','ustring');
    schema.prop(c,'synthesisToolPackageName','ustring');
    schema.prop(c,'synthesisToolSpeedValue','ustring');
    schema.prop(c,'synthesisTool','ustring');
    schema.prop(c,'synthesisProjectAdditionalFiles','ustring');
    schema.prop(c,'simulationLibPath','ustring');
    schema.prop(c,'xilinxSimulatorLibPath','ustring');
    schema.prop(c,'optimizeMdlGen','bool');


    schema.prop(c,'AdderSharingMinimumBitwidth','int32');
    schema.prop(c,'MultiplierSharingMinimumBitwidth','int32');
    schema.prop(c,'MultiplyAddSharingMinimumBitwidth','int32');
    schema.prop(c,'ShareAdders','bool');
    schema.prop(c,'ShareMultipliers','bool');
    schema.prop(c,'ShareMultiplyAdds','bool');
    schema.prop(c,'ShareMATLABBlocks','bool');
    schema.prop(c,'ShareAtomicSubsystems','bool');
    schema.prop(c,'ShareCounterSerDes','bool');
    schema.prop(c,'ShareFloatingPointIPs','bool');
    schema.prop(c,'PipelinedSharing','bool');
    schema.prop(c,'OptimizeCRPSharingRegisters','bool');
    schema.prop(c,'ClockRatePipeliningBudgetCheck','bool');


    schema.prop(c,'nativeFloatingPoint','int32');
    schema.prop(c,'FPToleranceStrategy','int32');
    schema.prop(c,'FPToleranceValue','double');
    schema.prop(c,'nfpLatency','ustring');
    schema.prop(c,'nfpDenormals','int32');

    schema.prop(c,'sschdlMatrixProductSumCustomLatency','int32');


    schema.prop(c,'ScalarizePorts','int32');
    set(p,'FactoryValue',0);

    schema.prop(c,'OneBasedPortIndexing','bool');
    set(p,'FactoryValue',false);


    schema.prop(c,'samplespercycle','double');
    set(p,'FactoryValue',1);

    schema.prop(c,'inputfifosize','double');
    set(p,'FactoryValue',10);
    schema.prop(c,'outputfifosize','double');
    set(p,'FactoryValue',10);

    schema.prop(c,'largedelaymemory','bool');
    set(p,'FactoryValue',false);
    schema.prop(c,'delaysizethreshold','double');
    set(p,'FactoryValue',1024);


    schema.prop(c,'scalarizePortsAtTop','bool');


    p=schema.prop(c,'oversampling','mxArray');
    set(p,'SetFunction',@set_positiveInteger);


    p=schema.prop(c,'clockratepipeliningfraction','mxArray');
    set(p,'SetFunction',@set_crpfraction);

    schema.prop(c,'tool_file_comment','ustring');
    schema.prop(c,'rcs_cvs_tag','ustring');

    schema.prop(c,'CustomFileHeaderComment','ustring');
    schema.prop(c,'CustomFileFooterComment','ustring');

    schema.prop(c,'datecomment','int32');
    schema.prop(c,'resetname','ustring');
    schema.prop(c,'reset_asserted_level','bool');
    schema.prop(c,'clockedge','bool');
    schema.prop(c,'clockedgestyle','bool');
    schema.prop(c,'simulator_flags','ustring');

    schema.prop(c,'block_generate_label','ustring');
    schema.prop(c,'clock_process_label','ustring');
    schema.prop(c,'complex_imag_postfix','ustring');
    schema.prop(c,'complex_real_postfix','ustring');
    schema.prop(c,'entity_conflict_postfix','ustring');
    schema.prop(c,'instance_generate_label','ustring');
    schema.prop(c,'instance_prefix','ustring');
    schema.prop(c,'instance_postfix','ustring');
    schema.prop(c,'output_generate_label','ustring');
    schema.prop(c,'vector_prefix','ustring');
    schema.prop(c,'pipelinepostfix','ustring');
    schema.prop(c,'module_prefix','ustring');








    p=schema.prop(c,'vhdl_library_name','ustring');
    set(p,'FactoryValue','work');

    p=schema.prop(c,'top_level_vhdl_library_name','ustring');
    set(p,'FactoryValue','work');

    p=schema.prop(c,'use_single_library','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'vhdl_architecture_name','ustring');
    set(p,'FactoryValue','rtl');


    p=schema.prop(c,'gen_eda_scripts','bool');
    set(p,'FactoryValue',true);


    schema.prop(c,'multicyclepathinfo','bool');


    schema.prop(c,'MulticyclePathConstraints','bool');


    schema.prop(c,'codegenerationoutput','CodeGenerationOutputType');
    schema.prop(c,'generatedmodelname','ustring');
    schema.prop(c,'generatedmodelnameprefix','ustring');
    schema.prop(c,'validationmodelnamesuffix','ustring');
    schema.prop(c,'showcodegenpir','bool');
    schema.prop(c,'serializemodel','double');
    schema.prop(c,'serializeio','double');
    schema.prop(c,'autoroute','bool');
    schema.prop(c,'autoplace','bool');
    schema.prop(c,'UseArrangeSystem','bool');
    schema.prop(c,'interblkhorzscale','double');
    schema.prop(c,'interblkvertscale','double');
    schema.prop(c,'customdotpath','ustring');
    schema.prop(c,'hiliteancestors','bool');
    schema.prop(c,'hilitecolor','ustring');
    schema.prop(c,'generatevalidationmodel','bool');
    schema.prop(c,'balancedelays','bool');
    schema.prop(c,'balancedelayscontrolsfeedbackloops','bool');
    schema.prop(c,'delayabsorption','bool');
    schema.prop(c,'inlinesubsystems','bool');
    schema.prop(c,'stringtypesupport','bool');
    schema.prop(c,'deleteunusedblocks','bool');
    schema.prop(c,'deleteunusedblocksundermask','bool');
    schema.prop(c,'deleteunusedports','bool');
    schema.prop(c,'rammappingthreshold','double');
    schema.prop(c,'iothreshold','double');
    schema.prop(c,'mappipelinedelaystoram','bool');
    schema.prop(c,'removeredundantcounters','bool');
    schema.prop(c,'replaceunitdelaywithintegerdelay','bool');
    schema.prop(c,'concatenatedelays','bool');
    schema.prop(c,'mergedelaysonfanouts','bool');
    schema.prop(c,'folddelaystoconstant','bool');
    schema.prop(c,'maxoversampling','double');
    schema.prop(c,'maxcomputationlatency','double');
    schema.prop(c,'ramarchitecture','bool');
    schema.prop(c,'usematrixtypesineml','bool');
    schema.prop(c,'CompactSwitch','bool');
    schema.prop(c,'SimIndexCheck','bool');
    schema.prop(c,'subsystemreuse','ustring');
    schema.prop(c,'inlinematlabblockcode','bool');
    schema.prop(c,'inlinehdlcode','bool');
    schema.prop(c,'multiplierpartitioningthreshold','double');
    schema.prop(c,'treatdelaybalancingfailureas','ustring');
    schema.prop(c,'transformdelayswithcontrollogic','bool');
    schema.prop(c,'transformnonzeroinitvaldelay','bool');
    schema.prop(c,'delayelaborationlimit','int32');

    p=schema.prop(c,'RAMStyleAttributeName','ustring');
    set(p,'FactoryValue','');


    schema.prop(c,'obfuscategeneratedhdlcode','bool');

    schema.prop(c,'generaterecordtype','bool');


    schema.prop(c,'triggerasclockwithoutsyncregisters','bool');


    p=schema.prop(c,'initializeblockram','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'initializerealport','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'mapVectorPortToStream','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'verbose','int32');
    set(p,'SetFunction',@set_verbose,'FactoryValue',int32(1));

    p=schema.prop(c,'reserved_word_postfix','ustring');
    set(p,'FactoryValue','_rsvd');

    p=schema.prop(c,'synthesisondirective','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'synthesisoffdirective','ustring');
    set(p,'FactoryValue','');



    schema.prop(c,'gain_multipliers','HDLMultipliersType');
    schema.prop(c,'product_of_elements_style','HDLFinalAddersType');
    schema.prop(c,'sum_of_elements_style','HDLFinalAddersType');


    schema.prop(c,'filter_target_language','HDLTargetLanguageType');
    schema.prop(c,'tb_target_language','HDLTargetLanguageType');

    p=schema.prop(c,'vhdl_package_required','bool');
    set(p,'FactoryValue',false);



    p=schema.prop(c,'initialize_real_signals','bool');
    set(p,'FactoryValue',true);


    p=schema.prop(c,'referencedmodels','mxArray');
    set(p,'FactoryValue',{});

    p=schema.prop(c,'modelrates','mxArray');
    set(p,'FactoryValue',[10;20],'SetFunction',@set_modelrates);

    schema.prop(c,'top_nodename','ustring');

    p=schema.prop(c,'isvhdl','bool');
    set(p,'FactoryValue',true,'AccessFlags.PublicSet','Off');

    p=schema.prop(c,'isverilog','bool');
    set(p,'AccessFlags.PublicSet','Off');

    p=schema.prop(c,'issystemverilog','bool');
    set(p,'AccessFlags.PublicSet','Off');

    p=schema.prop(c,'vhdl_package_name','ustring');
    set(p,'FactoryValue','package');

    p=schema.prop(c,'savepirtoscript','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'pirtc','bool');
    set(p,'FactoryValue',false);




    schema.prop(c,'vhdl_file_ext','ustring');
    schema.prop(c,'verilog_file_ext','ustring');
    schema.prop(c,'systemverilog_file_ext','ustring');



    p=schema.prop(c,'filename_suffix','ustring');
    set(p,'SetFunction',@set_filename_suffix,'GetFunction',@get_filename_suffix);

    schema.prop(c,'minimizeIntermediateSignals','bool');
    schema.prop(c,'generatecodeinfo','bool');




    p=schema.prop(c,'gatewayoutwithdtc','bool');
    set(p,'FactoryValue',false);


    p=schema.prop(c,'incrementalcodegenfortopmodel','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'hdlwfSmartbuild','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'hdlcodingstandard','int32');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'HDLCodingStandardCustomizations','mxArray');
    set(p,'FactoryValue',[],...
    'SetFunction',@set_codingstdcustomizations);

    p=schema.prop(c,'ReferenceDesignParameter','mxArray');
    set(p,'FactoryValue',{});


    p=schema.prop(c,'hdllinttool','int32');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'hdllintinit','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'hdllintterm','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'hdllintcmd','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'DetectBlackBoxNameCollision','DetectBlackBoxNameCollisionType');
    set(p,'FactoryValue','Warning');

    p=schema.prop(c,'UsePipelinedToolboxFunctions','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'ConcatenateHDLModules','bool');
    set(p,'FactoryValue',false);


    p=schema.prop(c,'using_ml2pir','int32');
    set(p,'FactoryValue',0);



    p=schema.prop(c,'cache_mlfb_inference_reports','bool');
    set(p,'FactoryValue',false);


    p=schema.prop(c,'EnableTestpoints','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'AvoidMatchingDelaysForTestpoints','bool');
    set(p,'FactoryValue',false);


    p=schema.prop(c,'GenDUTPortForTunableParam','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'AvoidMatchingDelaysForTunableParam','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'HDLDTO','int32');
    set(p,'FactoryValue',1);






    schema.prop(c,'TraceabilityStyle','HDLTraceabilityStyle');


    schema.prop(c,'TraceabilityProcessing','bool');


    schema.prop(c,'LayoutStyle','ModelLayoutStyle');



    p=schema.prop(c,'EnableForGenerateLoops','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'TreatRealsInGeneratedCodeAs','TreatRealsInGeneratedCodeAsType');
    set(p,'FactoryValue','Error');

    p=schema.prop(c,'TreatBalanceDelaysOffAs','TreatBalanceDelaysOffAsType');
    set(p,'FactoryValue','Error');


    p=schema.prop(c,'CompileStrategy','EnumCompileStrategy');
    set(p,'FactoryValue','CompileAll');

    p=schema.prop(c,'EnumEncodingScheme','int32');
    set(p,'FactoryValue',0);

    p=schema.prop(c,'BuildToProtectModel','bool');
    set(p,'FactoryValue',false);


    p=schema.prop(c,'OptimizeConstants','bool');
    set(p,'FactoryValue',true);


    p=schema.prop(c,'OptimizeFixedPointConstants','bool');
    set(p,'FactoryValue',false);


    p=schema.prop(c,'FrameToSampleConversion','bool');
    set(p,'FactoryValue',false);


    function fns=set_filename_suffix(this,fns)

        set(this,[this.target_language,'_file_ext'],fns);


        function fns=get_filename_suffix(this,~)

            fns=get(this,[this.target_language,'_file_ext']);



            function value=set_positive(~,value)

                if value<0
                    error(message('HDLShared:CLI:valueNotPositive'));
                end


                function codstdobj=set_codingstdcustomizations(this,codstdobj)%#ok<INUSL>

                    if~isempty(codstdobj)&&~isa(codstdobj,'hdlcodingstd.BaseCustomizations')
                        errstr=class(codstdobj);
                        codstdobj=[];%#ok<NASGU>
                        error(message('HDLShared:CLI:InvalidCodingStdCustomizations',errstr));
                    end


                    function value=set_positiveInteger(this,value)%#ok

                        if isempty(value)||~isnumeric(value)||(rem(value,1)~=0)||(value<=0)
                            error(message('HDLShared:CLI:nonpositiveinteger'));
                        end


                        function value=set_crpfraction(this,value)%#ok

                            if isempty(value)||~isnumeric(value)||(value<0)||(value>1)||(rem(value*100,1)~=0)
                                error(message('HDLShared:CLI:illegalCRPFractionValue','ClockRatePipeliningFraction'));
                            end


                            function mrates=set_modelrates(~,mrates)

                                if~isnumeric(mrates)||all(size(mrates)>1)
                                    error(message('HDLShared:CLI:notNumericVector'))
                                end


                                function verb=set_verbose(~,verb)

                                    if verb<0
                                        error(message('HDLShared:CLI:negativeVerbose'));
                                    end

                                    verb=int32(verb);


                                    function configobj=set_floatingpointtargetconfiguration(this,configobj)%#ok<INUSL>
                                        if(ischar(configobj)&&strcmpi(configobj,'none'))
                                            configobj=[];
                                        end

                                        if~isempty(configobj)&&~isa(configobj,'hdlcoder.FloatingPointTargetConfig')
                                            error(message('HDLShared:CLI:InvalidFloatingPointTargetConfiguration',class(configobj)));
                                        end


                                        function val=set_targetfrequency(this,val)%#ok<INUSL>
                                            if(~isnumeric(val)||val<0)
                                                error(message('hdlcommon:targetcodegen:InvalidTargetFrequency'));
                                            end































