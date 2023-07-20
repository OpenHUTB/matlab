function flag=checkModelParams(this)




    flag=true;


    sys_name=this.m_sys;
    paramStruct=hdlcoder.ModelChecker.hdlModelParameters;

    fields=fieldnames(paramStruct);
    summary=DAStudio.message('HDLShared:hdlmodelchecker:ModelSettingMessageSummary');
    modelParams={};


    for i=1:numel(fields)
        fieldName=fields(i);
        modelParams{i}=get_param(sys_name,fields{i});%#ok<AGROW>
        if isempty(strfind(paramStruct.(fieldName{1}),modelParams{i}))
            flag=false;
            this.addCheck('warning',summary,'',0,...
            DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_Unsupported',fields{i},...
            modelParams{i},paramStruct.(fieldName{1})));
        end
    end
end
