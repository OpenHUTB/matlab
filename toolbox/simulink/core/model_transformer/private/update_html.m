function ResultInHTML=update_html(task,ResultInHTML)














    MAObj=task.MAObj;
    bd=get_param(MAObj.ModelName,'Object');

    if strcmpi(task.ID,MAObj.LatestRunID)==1&&(task.State==ModelAdvisor.CheckStatus.Passed)
        checkObj=task.MAObj.getCheckObj(task.ID);
        m2m_obj=task.MAObj.UserData;
        wmsg=task.MAObj.getCheckResultData(task.ID);
        if(isa(m2m_obj,'slEnginePir.m2m')||isa(m2m_obj,'slEnginePir.model2model'))&&...
            ~m2m_obj.fTransformed
            if strcmpi(task.ID,'com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant')
                checkObj.Result=identify_candidate_result(m2m_obj,bd.Name,wmsg,~task.check.Action.Enable);
            elseif strcmpi(task.ID,'com.mathworks.Simulink.MdlTransformer.DSMElim')
                checkObj.Result=dsmElimDispCandidate(m2m_obj,bd.Name,~task.check.Action.Enable);
            elseif strcmpi(task.ID,'com.mathworks.Simulink.MdlTransformer.LutXform')
                checkObj.Result=lutXformCandidate(m2m_obj,bd.Name,~task.check.Action.Enable);
            elseif strcmpi(task.ID,'com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform')
                checkObj.Result=commonSrcInterpXformCandidate(m2m_obj,bd.Name,~task.check.Action.Enable);
            end
            ResultInHTML=task.MAObj.formatCheckCallbackOutput(checkObj,{checkObj.Result},{''},1,false);
        end
    end
end


