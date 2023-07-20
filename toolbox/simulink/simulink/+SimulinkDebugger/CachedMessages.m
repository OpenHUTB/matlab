classdef CachedMessages<handle




    properties(Constant)
        columnIDName_=DAStudio.message('Simulink:Debugger:SSColumn_ID');
        enabledName_=DAStudio.message('Simulink:Debugger:SSColumn_Enabled');
        sourceName_=DAStudio.message('Simulink:Debugger:SSColumn_Source');
        typeName_=DAStudio.message('Simulink:Debugger:SSColumn_Type');
        conditionName_=DAStudio.message('Simulink:Debugger:SSColumn_Condition');
        hitsName_=DAStudio.message('Simulink:Debugger:SSColumn_Hits');
        greater_=DAStudio.message('Simulink:studio:Greater');
        greaterEqual_=DAStudio.message('Simulink:studio:GreaterEqual');
        equal_=DAStudio.message('Simulink:studio:Equal');
        notEqual_=DAStudio.message('Simulink:studio:NotEqual');
        lessEqual_=DAStudio.message('Simulink:studio:LessEqual');
        less_=DAStudio.message('Simulink:studio:Less');
    end
end
