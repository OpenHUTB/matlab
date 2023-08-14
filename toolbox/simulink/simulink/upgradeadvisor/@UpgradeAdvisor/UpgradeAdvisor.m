



classdef UpgradeAdvisor<handle

    properties(Constant)
        UPGRADE_GROUP_ID='com.mathworks.Simulink.UpgradeAdvisor.UpgradeAdvisor';
        UPGRADE_HIERARCHY_ID='com.mathworks.Simulink.UpgradeAdvisor.UpgradeModelHierarchy';
    end

    properties(Access=private)
        upgradeGroup;
    end

    methods




        function advisor=UpgradeAdvisor()
            mdlAdvisor=ModelAdvisor.Root;

            group=mdlAdvisor.getTaskAdvisorNode(UpgradeAdvisor.UPGRADE_GROUP_ID);

            if isempty(group)
                group=ModelAdvisor.Group(UpgradeAdvisor.UPGRADE_GROUP_ID);
                group.DisplayName=DAStudio.message('SimulinkUpgradeAdvisor:advisor:upgradeNodeTitle');
                group.HelpMethod='helpview';
                group.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'upgrade_advisor'};
                mdlAdvisor.register(group);
            end

            advisor.upgradeGroup=group;
        end


        function addTask(advisor,task)
            advisor.upgradeGroup.addTask(task);
        end


        function addGroup(advisor,group)
            advisor.upgradeGroup.addGroup(group);
        end


        function addProcedure(advisor,procedure)
            advisor.upgradeGroup.addProcedure(procedure);
        end

    end

    methods(Static)

        open(system,selection,suppressUI,suppressProjectDialog,parentModel);

        close();

        sysRoot=load(system);

    end

    methods(Static,Hidden)

        toggleNotifications();

    end

    methods(Static,Access=private)

        updateNotificationButton(system,action);

        open=askToOpenProjectUpgrade(sysPath,projectRoot,projectToClose);

    end

    methods(Static,Hidden)

        function needsReset=setModelUpgradeActive(model)
            needsReset=false;
            if strcmp(get_param(model,'ModelUpgradeActive'),'off')
                if strcmp(get_param(model,'BlockDiagramType'),'model')
                    set_param(model,'ModelUpgradeActive','on')
                    needsReset=true;
                end
            end
        end


        function clearModelUpgradeActive(model)
            try %#ok<TRYNC>
                set_param(model,'ModelUpgradeActive','off')
            end
        end

        function openFromBanner()
            try
                bdHandle=SLM3I.SLDomain.getLastActiveStudioApp.blockDiagramHandle;
                upgradeadvisor(bdHandle);
            catch e
                dp=DAStudio.DialogProvider;
                dp.errordlg(e.message,DAStudio.message('SimulinkUpgradeAdvisor:advisor:errorDialogTitle'),true);
            end
        end

    end
end
