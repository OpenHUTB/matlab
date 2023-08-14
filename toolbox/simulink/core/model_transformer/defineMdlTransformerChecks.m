function recordCellArray=defineMdlTransformerChecks




    recordCellArray={};

    rec=ModelAdvisor.Check('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
    rec.Title=DAStudio.message('sl_pir_cpp:creator:Title_IdentifyConst');
    rec.TitleTips=[DAStudio.message('sl_pir_cpp:creator:Tips_IdentifyConst_Part1'),char(10),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:SysConst1'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:SysConst2'),char(10),char(10)...
    ,DAStudio.message('sl_pir_cpp:creator:Tips_IdentifyConst_Part2'),char(10),char(10)];

    rec.setCallbackFcn(@identify_variant_constant,'None','StyleOne');
    rec.Enable=true;
    rec.Value=true;
    rec.setInputParametersLayoutGrid([2,1]);

    inputParam1=ModelAdvisor.InputParameter;
    inputParam1.Name=DAStudio.message('sl_pir_cpp:creator:ParamName_IdentifyConst');
    inputParam1.Type='String';
    inputParam1.Value='e.g. system_consts';
    inputParam1.setRowSpan([1,1]);
    inputParam1.setColSpan([1,1]);

    inputParam2=ModelAdvisor.InputParameter;
    inputParam2.Name=DAStudio.message('sl_pir_cpp:creator:ParamName_ConvertVariant');
    inputParam2.Type='String';
    inputParam2.Value='gen0_';
    inputParam2.setRowSpan([2,1]);
    inputParam2.setColSpan([1,1]);
    rec.setInputParameters({inputParam1,inputParam2});

    action=ModelAdvisor.Action;
    action.setCallbackFcn(@variant_transform);
    action.Name='Refactor Model';
    action.Description=DAStudio.message('sl_pir_cpp:creator:SysConst3');
    rec.setAction(action);

    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.MdlTransformer.IdentifyVariantCandidate');
    rec.Title=DAStudio.message('sl_pir_cpp:creator:Title_IdentifyCandidate');
    rec.TitleTips=[DAStudio.message('sl_pir_cpp:creator:Tips_IdentifyCandidate_Part1'),char(10),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:Candidate1'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:Candidate2'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:Candidate3'),char(10),char(10)...
    ,DAStudio.message('sl_pir_cpp:creator:Tips_IdentifyCandidate_Part2')];
    rec.setCallbackFcn(@identify_variant_candidate,'None','StyleOne');
    rec.Enable=true;
    rec.Value=true;
    rec.setInputParametersLayoutGrid([1,1]);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.Simulink.MdlTransformer.VariantTransform');
    rec.Title=DAStudio.message('sl_pir_cpp:creator:Title_ConvertVariant');
    rec.TitleTips=[DAStudio.message('sl_pir_cpp:creator:Tips_ConvertVariant'),char(10),char(10)...
    ,DAStudio.message('sl_pir_cpp:creator:Param_ConvertVariant'),char(10),char(10)];

    rec.setCallbackFcn(@variant_transform,'None','StyleOne');
    rec.Enable=true;
    rec.Value=true;
    rec.setInputParametersLayoutGrid([1,1]);

    inputParam2=ModelAdvisor.InputParameter;
    inputParam2.Name=DAStudio.message('sl_pir_cpp:creator:ParamName_ConvertVariant');
    inputParam2.Type='String';
    inputParam2.Value='gen0_';
    inputParam2.setRowSpan([1,1]);
    inputParam2.setColSpan([1,1]);
    rec.setInputParameters({inputParam2});
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.MdlTransformer.DSMElim');
    rec.Title=DAStudio.message('sl_pir_cpp:creator:DSMElimStep1');
    rec.TitleTips=[DAStudio.message('sl_pir_cpp:creator:Tips_DSMElimStep1_b'),char(10),char(10)];
    rec.setCallbackFcn(@dsmElimIdentify,'None','StyleOne');
    rec.Enable=true;
    rec.Value=true;

    rec.setInputParametersLayoutGrid([1,1]);
    inputParam1=ModelAdvisor.InputParameter;
    inputParam1.Name=DAStudio.message('sl_pir_cpp:creator:ParamName_DSMPrefix');
    inputParam1.Type='String';
    inputParam1.Value='gen1_';
    inputParam1.setRowSpan([1,1]);
    inputParam1.setColSpan([1,1]);
    rec.setInputParameters({inputParam1});

    action=ModelAdvisor.Action;
    action.setCallbackFcn(@dsmElimModelgen);
    action.Name='Refactor Model';
    action.Description=[DAStudio.message('sl_pir_cpp:creator:Tips_DSMElimStep2')];
    rec.setAction(action);

    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.MdlTransformer.LutXform');
    rec.Title='Lookup Table Transformation';
    rec.TitleTips=[DAStudio.message('sl_pir_cpp:creator:Tips_IdentifyLutPart1'),char(10),char(10)...
    ,DAStudio.message('sl_pir_cpp:creator:LutCriteria0'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:LutCriteria1'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:LutCriteria2'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:LutCriteria3'),char(10),char(10)];


    rec.setCallbackFcn(@lutIdentify,'None','StyleOne');
    rec.Enable=true;
    rec.Value=true;

    rec.setInputParametersLayoutGrid([2,1]);

    inputParam1=ModelAdvisor.InputParameter;
    inputParam1.Name=DAStudio.message('sl_pir_cpp:creator:SkipLutInLibrary');
    inputParam1.Type='bool';
    inputParam1.Value=true;
    inputParam1.setRowSpan([1,1]);
    inputParam1.setColSpan([1,1]);

    inputParam2=ModelAdvisor.InputParameter;
    inputParam2.Name=DAStudio.message('sl_pir_cpp:creator:ParamName_ConvertVariant');
    inputParam2.Type='String';
    inputParam2.Value='gen2_';
    inputParam2.setRowSpan([2,1]);
    inputParam2.setColSpan([1,1]);
    rec.setInputParameters({inputParam1,inputParam2});

    action=ModelAdvisor.Action;
    action.setCallbackFcn(@lutRefactoring);
    action.Name='Refactor Model';
    action.Description=DAStudio.message('sl_pir_cpp:creator:LutRefactoringButton');
    rec.setAction(action);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform');
    rec.Title='Common Source Interpolation Transformation';
    rec.TitleTips=[DAStudio.message('sl_pir_cpp:creator:Tips_IdentifyCommonSrcInterp'),char(10),char(10)...
    ,DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpCriteria0'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpCriteria1'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpCriteria2'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpCriteria3'),char(10)...
    ,char(187),' ',DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpCriteria4'),char(10),char(10)];
    rec.setCallbackFcn(@commonSrcInterpIdentify,'None','StyleOne');
    rec.Enable=true;
    rec.Value=true;

    rec.setInputParametersLayoutGrid([2,1]);



    inputParam1=ModelAdvisor.InputParameter;
    inputParam1.Name=DAStudio.message('sl_pir_cpp:creator:SkipInterpInLibrary');
    inputParam1.Type='bool';
    inputParam1.Value=true;
    inputParam1.setRowSpan([1,1]);
    inputParam1.setColSpan([1,1]);

    inputParam2=ModelAdvisor.InputParameter;
    inputParam2.Name=DAStudio.message('sl_pir_cpp:creator:ParamName_ConvertVariant');
    inputParam2.Type='String';
    inputParam2.Value='gen2_';
    inputParam2.setRowSpan([2,1]);
    inputParam2.setColSpan([1,1]);
    rec.setInputParameters({inputParam1,inputParam2});

    action=ModelAdvisor.Action;
    action.setCallbackFcn(@commonSrcInterpRefactoring);
    action.Name='Refactor Model';
    action.Description=DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpRefactoringButton');
    rec.setAction(action);
    recordCellArray{end+1}=rec;
end


