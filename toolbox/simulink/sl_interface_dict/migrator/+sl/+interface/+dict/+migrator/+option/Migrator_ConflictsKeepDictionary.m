classdef Migrator_ConflictsKeepDictionary<sl.interface.dict.migrator.base.OptionBase





    methods
        function obj=Migrator_ConflictsKeepDictionary(env)

            id='Migrator_ConflictsKeepDictionary';
            obj@sl.interface.dict.migrator.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('interface_dictionary:migrator:uiConflictsResolutionDialogButtonKeep');
            obj.Value='conflicts';
            obj.Answer=true;
        end

        function ret=onNext(obj)
            if obj.Answer
                obj.Env.ValMsgs.flags.ConflictsBehavior='KeepInterfaceDictionary';
            end
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('interface_dictionary:migrator:uiConflictsResolutionKeepDictionaryHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


