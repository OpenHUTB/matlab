function initMessages(obj)
    initMessages@coder.report.CodeMetricsBase(obj);
    obj.msgs.intro_msg=obj.getMessage('CodeMetricsIntroduction');
    obj.msgs.codegen_adv_help_msg=obj.getMessage('OpenCodeGenAdvHelp');
    obj.msgs.openCodeGenAdvHelp_msg=obj.getMessage('ConsultCodeGen');
    obj.msgs.c_file_header=obj.getMessage('CFileHeaderExcludeERTmain');
    obj.msgs.mdlref_fcn_msg=obj.getMessage('MdlrefFcn');
    obj.msgs.mdlref_file_msg=obj.getMessage('MdlrefFile');
end
