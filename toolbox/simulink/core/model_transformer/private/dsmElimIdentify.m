function result=dsmElimIdentify(system)



    result='';
    MAObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    MATask=MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.DSMElim');

    [wmsg,emsg]=m2m_obj_creation(system,MATask,'slEnginePir.m2m_dsm');

    if~isempty(emsg)
        result=emsg;
        return;
    end

    try
        MAObj.UserData.identify;
        MAObj.UserData.muteDebugPrints;
        if MAObj.UserData.hasIdentifiedCandidates
            MATask.check.Action.Enable=true;
            MAObj.UserData.setCandidatesIndex(MAObj.UserData.fDefaultCandIndex);
        end
        result=dsmElimDispCandidate(MAObj.UserData,system,0);
        MAObj.setCheckResultStatus(true);
        MAObj.setCheckResultData(wmsg);
    catch ME
        if~isempty(ME.message)
            result=DAStudio.message('sl_pir_cpp:creator:UnsimulatableModel',MAObj.UserData.fOriMdl);
            MAObj.setCheckErrorSeverity(true);
        end
    end
end