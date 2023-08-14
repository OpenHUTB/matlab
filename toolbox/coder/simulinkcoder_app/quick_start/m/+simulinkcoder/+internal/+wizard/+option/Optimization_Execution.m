

classdef Optimization_Execution<coder.internal.wizard.option.Optimization_Execution
    methods
        function obj=Optimization_Execution(env)
            obj@coder.internal.wizard.option.Optimization_Execution(env);
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



            if isempty(env.getParam('ObjectivePriorities'))
                env.setParamOptional('ObjectivePriorities',{{'Execution efficiency'}});
            end
        end
    end
end


