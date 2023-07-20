



classdef MigratorWizard<sl.interface.dict.migrator.MigratorWizardBase

    properties(Access=private)
        ContextName;
        DictionaryName;
        Migrator;
    end

    properties(Hidden,Constant)

        GuiTag='Tag_Dictionary_Migrator';
    end

    methods(Access=public)
        function env=MigratorWizard(contextName,dictionaryName)



            env@sl.interface.dict.migrator.MigratorWizardBase();

            env.ContextName=contextName;
            env.DictionaryName=dictionaryName;

            env.analyze();
        end

        function open(env)
            if env.QFlags.nothingToMigrate
                msgbox(DAStudio.message('interface_dictionary:migrator:uiMigratorWizardNothingToMigrateHelp'),...
                DAStudio.message('interface_dictionary:migrator:uiMigratorWizardNothingToMigrate'));

                env.cleanupOnPrematureClose();
            else
                env.Gui.start;
            end
        end

        function closeWizard=finish(env)
            closeWizard=true;


            env.start_spin();
            c=onCleanup(@()env.stop_spin());

            if~env.QFlags.nothingToMigrate
                if~isempty(env.CurrentQuestion)
                    env.CurrentQuestion.onNext();
                end
                env.Migrator.ConflictResolutionPolicy=env.ValMsgs.flags.ConflictsBehavior;
                env.Migrator.apply();
            end
            env.IsWizardFinished=true;
        end
    end

    methods(Access=private)
        function analyze(env)

            env.Migrator=Simulink.interface.dictionary.Migrator(...
            env.ContextName,...
            'InterfaceDictionaryName',env.DictionaryName,...
            'DeleteFromOriginalSource',true);




            env.Migrator.analyze();

            dataTypesToMigrate=env.Migrator.DataTypesToMigrate;
            interfacesToMigrate=env.Migrator.InterfacesToMigrate;
            conflictObjects=env.Migrator.ConflictObjects;
            env.ValMsgs.flags.MigratedDataTypes=[];
            env.ValMsgs.flags.MigratedInterfaces=[];

            if~(isempty(dataTypesToMigrate)&&isempty(interfacesToMigrate)&&isempty(conflictObjects))
                env.QFlags.nothingToMigrate=false;
                env.ValMsgs.flags.MigratedDataTypes=dataTypesToMigrate;
                env.ValMsgs.flags.MigratedInterfaces=interfacesToMigrate;

                if~isempty(conflictObjects)
                    conflicts='';
                    for i=1:length(conflictObjects)


                        entry=conflictObjects{i};
                        for l=1:length(entry)
                            item=entry{l};
                            if~strcmp(item.Source,env.DictionaryName)
                                conflicts{end+1}={item.Name,item.Source};%#ok
                            end
                        end
                    end
                    env.ValMsgs.flags.Conflicts=conflicts;
                else
                    env.ValMsgs.flags.Conflicts='';
                end
            else
                env.QFlags.nothingToMigrate=true;
                env.ValMsgs.flags.Conflicts='';
            end
        end
    end

end
