


classdef Optimization_Execution<coder.internal.wizard.OptionBase
    methods
        function obj=Optimization_Execution(env)
            id='Optimization_Execution';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Finish';
            obj.Type='radio';
            obj.Value=false;
        end
        function onNext(obj)
            env=obj.Env;
            env.setCommonOptimization();
            env.setCommonSettings();
            env.setParamOptional('BooleansAsBitfields','off');
            env.setParamOptional('DataBitsets','off');
            env.setParamOptional('StateBitsets','off');
            env.setParamOptional('GlobalVariableUsage','None');
            env.setParamOptional('MATLABDynamicMemAlloc','off');
            env.setParamOptional('ProdLongLongMode','on');
            env.setParamRequired('EfficientTunableParamExpr','on');
            env.setParamOptional('PreserveIfCondition','off');



            if isempty(env.getParam('ObjectivePriorities'))
                env.setParamOptional('ObjectivePriorities',{{'Execution efficiency','RAM efficiency'}});
            end
        end
    end
end


