classdef JSSettingsService<handle

    methods

        function settingsSaveRecentProjects(~,recentHistoryList)
            s=settings;
            if~hasGroup(s,'ExperimentManager')
                addGroup(s,'ExperimentManager','Hidden',true);
            end

            if hasSetting(s.ExperimentManager,'RecentProjectList')
                removeSetting(s.ExperimentManager,'RecentProjectList');
            end
            addSetting(s.ExperimentManager,'RecentProjectList');
            s.ExperimentManager.RecentProjectList.PersonalValue=recentHistoryList;
        end

        function recentHistoryProjectList=settingsGetRecentProjects(~)
            s=settings;
            try
                recentHistoryProjectList=s.ExperimentManager.RecentProjectList.ActiveValue;
            catch
                recentHistoryProjectList={};
            end
        end
    end
end
