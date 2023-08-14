classdef Finish_Create<internal.CodeImporterUI.OptionBase
    methods
        function obj=Finish_Create(env)
            id='Finish_Create';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='hidden';
            obj.Value=true;
            obj.Answer=true;
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
        function onNext(obj)
            obj.Env.Gui.MessageHandler.create;
        end
    end
end
