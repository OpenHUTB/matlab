

classdef System_Model<coder.internal.wizard.OptionBase
    methods
        function obj=System_Model(env)
            id='System_Model';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Flavor';
            obj.Type='radio';
            obj.Value=false;
            obj.DepInfo='';



            obj.MsgParam={env.ModelName};
        end
        function onNext(obj)
            env=obj.Env;
            env.SourceSubsystemHandle=[];
            env.BuildMode=coder.internal.wizard.BuildMode.TOPMODELBUILD;
        end
    end
end
