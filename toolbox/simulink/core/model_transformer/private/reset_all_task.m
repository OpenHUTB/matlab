function reset_all_task(mdlAdv)





    taskObj=mdlAdv.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
    taskObj.reset;
    taskObj=mdlAdv.getTaskObj('com.mathworks.Simulink.MdlTransformer.DSMElim');
    taskObj.reset;
    taskObj=mdlAdv.getTaskObj('com.mathworks.Simulink.MdlTransformer.LutXform');
    taskObj.reset;
    taskObj=mdlAdv.getTaskObj('com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform');
    taskObj.reset;
end
