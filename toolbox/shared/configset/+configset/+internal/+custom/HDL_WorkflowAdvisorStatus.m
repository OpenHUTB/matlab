function[status,dscr]=HDL_WorkflowAdvisorStatus(cs,name)%#ok<INUSD>



    dscr='';

    isWorkflowAdvisorOpen=false;
    try

        modelName=get_param(cs.getModel,'Name');






        mdladvObj=hdlwa.getHdladvObj;






        if~isempty(mdladvObj)&&strcmp(modelName,mdladvObj.ModelName)



            isWorkflowAdvisorOpen=mdladvObj.MAExplorer.isVisible;
        end
    catch

    end

    if isWorkflowAdvisorOpen



        status=configset.internal.data.ParamStatus.ReadOnly;
    else


        status=configset.internal.data.ParamStatus.Normal;
    end