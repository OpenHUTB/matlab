function utilMdlTransformerStart(varargin)

    scope_o=get_param(varargin{1},'object');


    mdlAdv=Simulink.ModelAdvisor.getModelAdvisor(scope_o.getFullName,'new','com.mathworks.Simulink.MdlTransformer.MdlTransformer');



    mdlAdv.ResetAfterAction=false;
    mdlAdv.ShowActionResultInRpt=true;




    mdlAdv.displayExplorer;


    reset_all_task(mdlAdv);
end

function mdlAdv=hideTaskCheckBox(mdlAdv)
    taskObj=mdlAdv.getTaskObj('com.mathworks.Simulink.MdlTransformer.MdlTransformer');
    taskObj.ShowCheckbox=0;
    taskObj=mdlAdv.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
    taskObj.ShowCheckbox=0;
    taskObj=mdlAdv.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantCandidate');
    taskObj.ShowCheckbox=0;
    taskObj=mdlAdv.getTaskObj('com.mathworks.Simulink.MdlTransformer.VariantTransform');
    taskObj.ShowCheckbox=0;
end