function result=identify_variant_constant(system)




    result='';
    MAObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    MATask=MAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
    inputParams=MAObj.getInputParameters;
    sys_const_cell=inputParams{1}.Value;

    [wmsg,emsg]=m2m_obj_creation(system,MATask,'slEnginePir.m2m');

    if~isempty(emsg)
        result=emsg;
        return;
    end
    try
        sys_const_cell=strrep(sys_const_cell,' ','');
        if isempty(sys_const_cell)||strcmpi(sys_const_cell,' ')||strcmpi(sys_const_cell,'e.g.system_consts')
            MAObj.UserData.set_variant_constants({});
        else
            sys_consts=evalin('base',sys_const_cell);
            MAObj.UserData.set_variant_constants(sys_consts);
        end
        result=identify_candidate_result(MAObj.UserData,system,wmsg,0);
        MATask.check.Action.Enable=true;
        MAObj.setCheckResultStatus(true);
        MAObj.setCheckResultData(wmsg);
    catch ME
        result=ME.message;
        MAObj.setCheckErrorSeverity(true);
    end

end
