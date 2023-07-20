classdef Migrator_ConflictsOverride<sl.interface.dict.migrator.base.OptionBase





    methods
        function obj=Migrator_ConflictsOverride(env)





            id='Migrator_ConflictsOverride';
            obj@sl.interface.dict.migrator.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('interface_dictionary:migrator:uiConflictsResolutionDialogButtonOverride');
            obj.Value='conflicts';
            obj.Answer=false;
        end

        function ret=onNext(obj)
            if obj.Answer
                obj.Env.ValMsgs.flags.ConflictsBehavior='OverwriteInterfaceDictionary';
            end
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('interface_dictionary:migrator:uiConflictsResolutionOverrideHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


