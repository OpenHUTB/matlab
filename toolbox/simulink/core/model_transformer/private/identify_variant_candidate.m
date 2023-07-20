function result=identify_variant_candidate(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    m2m_obj=mdladvObj.UserData;

    TaskObj=mdladvObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
    wmsg=mdladvObj.getCheckResultData('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
    TaskObj.Check.Result=identify_constant_result(m2m_obj,system,wmsg,1);
    TaskObj.Check.ResultInHTML=mdladvObj.formatCheckCallbackOutput(TaskObj.Check,{TaskObj.Check.Result},{''},1,false);

    result=identify_candidate_result(m2m_obj,system,0);
    mdladvObj.setCheckResultStatus(true);
end
