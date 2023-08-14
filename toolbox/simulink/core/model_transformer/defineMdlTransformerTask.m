function nodes=defineMdlTransformerTask




    nodes={};

    taskLvOne=0;


    modelAdvisorTask=ModelAdvisor.Procedure('com.mathworks.Simulink.MdlTransformer.MdlTransformer');
    modelAdvisorTask.CustomObject=createCustomObj;
    modelAdvisorTask.CustomDialogSchema=@mdltransformerDialogSchema;
    modelAdvisorTask.DisplayName=DAStudio.message('sl_pir_cpp:creator:MdlXformer');
    modelAdvisorTask.Description=DAStudio.message('sl_pir_cpp:creator:MdlXformer');
    modelAdvisorTask.HelpMethod='helpview';
    modelAdvisorTask.HelpArgs={fullfile(docroot,'slcheck','helptargets.map'),'com.mathworks.Simulink.MdlTransformer.MdlTransformer'};
    modelAdvisorTask.Children{end+1}='com.mathworks.Simulink.MdlTransformer.ModelTransform';
    nodes{end+1}=modelAdvisorTask;

    taskLvOne=taskLvOne+1;
    taskLvTwo=0;
    modelAdvisorTask=ModelAdvisor.Group('com.mathworks.Simulink.MdlTransformer.ModelTransform');
    modelAdvisorTask.CustomObject=createCustomObj;
    modelAdvisorTask.CustomDialogSchema=@TransformsDialogSchema;
    modelAdvisorTask.CSHParameters.MapKey='modeltransformer';
    modelAdvisorTask.CSHParameters.TopicID=modelAdvisorTask.ID;
    modelAdvisorTask.EnableReset=true;
    modelAdvisorTask.DisplayName=DAStudio.message('sl_pir_cpp:creator:MdlXformer_Transformation');
    modelAdvisorTask.Description=DAStudio.message('sl_pir_cpp:creator:MdlXformer_Transformation');
    modelAdvisorTask.Children{end+1}='com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant';
    modelAdvisorTask.Children{end+1}='com.mathworks.Simulink.MdlTransformer.DSMElim';
    modelAdvisorTask.Children{end+1}='com.mathworks.Simulink.MdlTransformer.LutXform';
    modelAdvisorTask.Children{end+1}='com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform';
    nodes{end+1}=modelAdvisorTask;

    taskLvThree=0;

    taskLvThree=taskLvThree+1;
    modelAdvisorTask=ModelAdvisor.Task('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
    modelAdvisorTask.CustomObject=createCustomObj;
    modelAdvisorTask.CustomDialogSchema=@mdlxformertaskSchema;
    modelAdvisorTask.CSHParameters.MapKey='modeltransformer';
    modelAdvisorTask.CSHParameters.TopicID=modelAdvisorTask.ID;
    modelAdvisorTask.DisplayName=DAStudio.message('sl_pir_cpp:creator:VariantXform1');
    modelAdvisorTask.MAC='com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant';
    modelAdvisorTask.EnableReset=false;

    nodes{end+1}=modelAdvisorTask;


    taskLvThree=taskLvThree+1;
    modelAdvisorTask=ModelAdvisor.Task('com.mathworks.Simulink.MdlTransformer.DSMElim');
    modelAdvisorTask.CustomObject=createCustomObj;
    modelAdvisorTask.CustomDialogSchema=@mdlxformertaskSchema;
    modelAdvisorTask.CSHParameters.MapKey='modeltransformer';
    modelAdvisorTask.CSHParameters.TopicID=modelAdvisorTask.ID;
    modelAdvisorTask.DisplayName=DAStudio.message('sl_pir_cpp:creator:DSMElimTitle');
    modelAdvisorTask.MAC='com.mathworks.Simulink.MdlTransformer.DSMElim';
    modelAdvisorTask.EnableReset=false;

    nodes{end+1}=modelAdvisorTask;


    taskLvThree=taskLvThree+1;
    modelAdvisorTask=ModelAdvisor.Task('com.mathworks.Simulink.MdlTransformer.LutXform');
    modelAdvisorTask.CustomObject=createCustomObj;
    modelAdvisorTask.CustomDialogSchema=@mdlxformertaskSchema;
    modelAdvisorTask.CSHParameters.MapKey='modeltransformer';
    modelAdvisorTask.CSHParameters.TopicID=modelAdvisorTask.ID;
    modelAdvisorTask.DisplayName=DAStudio.message('sl_pir_cpp:creator:LutXformTitle');
    modelAdvisorTask.MAC='com.mathworks.Simulink.MdlTransformer.LutXform';
    modelAdvisorTask.EnableReset=false;

    nodes{end+1}=modelAdvisorTask;


    modelAdvisorTask=ModelAdvisor.Task('com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform');
    modelAdvisorTask.CustomObject=createCustomObj;
    modelAdvisorTask.CustomDialogSchema=@mdlxformertaskSchema;
    modelAdvisorTask.CSHParameters.MapKey='modeltransformer';
    modelAdvisorTask.CSHParameters.TopicID=modelAdvisorTask.ID;
    modelAdvisorTask.DisplayName=DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpXformTitle');
    modelAdvisorTask.MAC='com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform';
    modelAdvisorTask.EnableReset=false;

    nodes{end+1}=modelAdvisorTask;
end


function CustomObj=createCustomObj
    CustomObj=ModelAdvisor.Customization;
    CustomObj.GUITitle=DAStudio.message('sl_pir_cpp:creator:MdlXformer');
    CustomObj.GUICloseCallback={'mdltransformer','string','%<System>','token','Cleanup','string'};
    CustomObj.MenuHelp.Text=DAStudio.message('sl_pir_cpp:creator:MdlXformerHelp');
    CustomObj.MenuHelp.Callback='helpview([docroot,''/slcheck/helptargets.map''],''com.mathworks.Simulink.MdlTransformer.MdlTransformer'');';
    CustomObj.MenuFile.Visible=false;
    CustomObj.MenuRun.Visible=false;
    CustomObj.MenuSettings.Visible=false;
    CustomObj.GUIReportTabName=DAStudio.message('sl_pir_cpp:creator:MdlXformer');
end




