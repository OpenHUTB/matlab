function schema






    hCreateInPackage=findpackage('IMT');


    hThisClass=schema.class(hCreateInPackage,'TestInfo');


    hThisProp=schema.prop(hThisClass,'ModelName','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'TestIndexDescription','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'SubsystemName','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'TargetLanguage','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'DesignName','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'CodegenArguments','MATLAB array');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'SystemLocale','string');
    hThisProp.FactoryValue='en';


    hThisProp=schema.prop(hThisClass,'LogData','bool');
    hThisProp.FactoryValue=true;


    hThisProp=schema.prop(hThisClass,'Platform','string vector');
    hThisProp.FactoryValue={'win32'};


    hThisProp=schema.prop(hThisClass,'pre_matlab_startup_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_test_setup_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'matlab_script_name','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_matlab_execute_script','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_matlab_execute_script','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'simulink_script_name','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_simulink_execute_script','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_simulink_execute_script','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_model_close_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'model_close_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'post_model_close_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_simulink_startup_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'simulink_startup_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_simulink_startup_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_simulink_load_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'simulink_load_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_simulink_load_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_simulink_load_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'simulink_find_system_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_simulink_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'simulink_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_simulink_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_simulink_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_simulink_validate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'simulink_validate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_simulink_validate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_simulink_compile_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'simulink_compile_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_simulink_compile_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_simulink_compile_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_rtw_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'rtw_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_rtw_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_rtw_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_parallel_rtw_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'parallel_rtw_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_parallel_rtw_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_parallel_rtw_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_rtw_build_generated_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'rtw_build_generated_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_rtw_build_generated_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_rtw_execute_generated_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'rtw_execute_generated_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_rtw_execute_generated_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_accelerator_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'accelerator_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_accelerator_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_accelerator_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_accelerator_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'accelerator_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_accelerator_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_accelerator_validate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'accelerator_validate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_accelerator_validate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_hdl_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'hdl_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_hdl_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_hdl_generate_code_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_check_hdl_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'check_hdl_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_check_hdl_generate_code_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_hdl_generate_test_bench_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'hdl_generate_test_bench_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_hdl_generate_test_bench_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_generic_codegen_generatecode_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'generic_codegen_generatecode_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_generic_codegen_generatecode_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_rtw_gen_code_misra_analysis_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'rtw_gen_code_misra_analysis_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_rtw_gen_code_misra_analysis_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_simulink_model_coverage_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_simulink_model_coverage_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_sil_gencode_sim_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'sil_gencode_sim_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_sil_gencode_sim_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_sil_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'sil_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_sil_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'sldv_test_system','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'sldv_options_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'sldv_testgeneration_customerworkflow','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'sldv_runtimeerrordetection_customerworkflow','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'sldv_deadlogicdetection_customerworkflow','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'sldv_propertyproving_customerworkflow','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_sldv_compatibility_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_sldv_compatibility_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_sldv_test_generation_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_sldv_test_generation_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_sldv_report_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_sldv_report_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_sldv_harness_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_sldv_harness_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_sldv_simulate_test_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_sldv_simulate_test_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'MISRACVersion','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'MISRACRules','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'MISRACRulesPolicy','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'BaselineOneStep','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'BaselineFinal','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'BaselineTolerance','double');
    hThisProp.FactoryValue=10*eps;


    hThisProp=schema.prop(hThisClass,'BaselineToleranceType','string');
    hThisProp.FactoryValue='absolute';



    hThisProp=schema.prop(hThisClass,'RelativeStartDirectory','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'RelativePaths','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'AbsolutePaths','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'CreateBaseline','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'SupportedTestSuites','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'Compiler','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'SimModeForSIL','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'xPCPreBuildAction','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'xPCConcurrentTasking','string');
    hThisProp.FactoryValue='off';






    hThisProp=schema.prop(hThisClass,'SimharnessModelWHarnesses','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'SimharnessSource','string');
    hThisProp.FactoryValue='Inport';

    hThisProp=schema.prop(hThisClass,'SimharnessSink','string');
    hThisProp.FactoryValue='Outport';

    hThisProp=schema.prop(hThisClass,'SimharnessCustomHarnessName','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'SimharnessCreateGraphicalHarness','string');
    hThisProp.FactoryValue='0';

    hThisProp=schema.prop(hThisClass,'SimharnessEnableComponentEditing','string');
    hThisProp.FactoryValue='0';


    hThisProp=schema.prop(hThisClass,'pre_simharness_create_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_simharness_create_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'pre_simharness_activate_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_simharness_activate_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'pre_simharness_deactivate_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_simharness_deactivate_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'pre_simharness_activateaftersaveload_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'post_simharness_activateaftersaveload_action','string');
    hThisProp.FactoryValue='';







    hThisProp=schema.prop(hThisClass,'pre_simulink_menu_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'simulink_menu_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_simulink_menu_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_simulink_menu_simulate_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_accelerator_menu_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'accelerator_menu_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_accelerator_menu_simulate_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_rapid_accelerator_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'rapid_accelerator_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_rapid_accelerator_generate_code_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'internal_post_rapid_accelerator_generate_code_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_rapid_accelerator_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'rapid_accelerator_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_rapid_accelerator_simulate_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_rapid_accelerator_validate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'rapid_accelerator_validate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_rapid_accelerator_validate_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_rapid_accelerator_menu_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'rapid_accelerator_menu_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_rapid_accelerator_menu_simulate_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'pre_matlab_coder_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'matlab_coder_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_matlab_coder_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'MatlabCoderProjectName','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'MatlabCoderTargetType','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'MatlabCoderRunTimeInputs','MATLAB array');
    hThisProp.FactoryValue=[];


    hThisProp=schema.prop(hThisClass,'MatlabCoderEntryPoints','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'MatlabCoderOutputFile','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'MLCoderPrjRelativeCodeGenDir','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_matlab_coder_generatecode_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'matlab_coder_generatecode_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_matlab_coder_generatecode_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_matlab_coder_build_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'matlab_coder_build_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_matlab_coder_build_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_matlab_coder_execute_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'matlab_coder_execute_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_matlab_coder_execute_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'MAGroupID','string');
    hThisProp.FactoryValue='_SYSTEM_By Product_Embedded Coder';


    hThisProp=schema.prop(hThisClass,'MAHighlighting','bool');
    hThisProp.FactoryValue=true;


    hThisProp=schema.prop(hThisClass,'MACheckIDCell','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'pre_modeladvisor_launch_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_modeladvisor_launch_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_modeladvisor_runchecks_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_modeladvisor_runchecks_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'pre_modeladvisor_highlighting_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_modeladvisor_highlighting_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'slci_followmodellinks','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'pre_simulink_interaction_action','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'simulink_interaction_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_simulink_interaction_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'SimulinkInteractionTestList','string vector');
    hThisProp.FactoryValue={};




    hThisProp=schema.prop(hThisClass,'InputDataMATFileForOCRA','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'BaselineMATFilesForOCRA','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'InputTypeForOCRA','string');
    hThisProp.FactoryValue='matfile';


    hThisProp=schema.prop(hThisClass,'pre_ocra_normal_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'ocra_normal_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'post_ocra_normal_simulate_action','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'ocra_normal_validate_action','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'STMTestName','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'STM_MRT','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'ResultID','int');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'SimulationIndex','int');
    hThisProp.FactoryValue=1;

    hThisProp=schema.prop(hThisClass,'IsTestSuite','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'TestSuiteCMD','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'EquivalenceTestStatus','int');
    hThisProp.FactoryValue=0;





